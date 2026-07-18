local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local Music = {}
Music.__index = Music
local activeFlacFrame = 0

local function yieldDecoder()
    if task and task.wait then task.wait() end
end

local function encode(value)
    return HttpService:UrlEncode(tostring(value or ""))
end

local function requestFunction()
    return request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)
end

local function downloadAudio(url, requester)
    local secureUrl = url:gsub("^http://", "https://")
    local attempts = {
        function()
            local response = requester({ Url = secureUrl, Method = "GET" })
            local status = response and (response.StatusCode or response.Status)
            if status and tonumber(status) and tonumber(status) >= 400 then error("HTTP " .. tostring(status)) end
            return response and (response.Body or response.body)
        end,
        function()
            local response = requester({ Url = url, Method = "GET" })
            local status = response and (response.StatusCode or response.Status)
            if status and tonumber(status) and tonumber(status) >= 400 then error("HTTP " .. tostring(status)) end
            return response and (response.Body or response.body)
        end,
        function() return game:HttpGet(secureUrl) end,
        function() return game:HttpGet(url) end,
    }
    local errors = {}
    for index, attempt in ipairs(attempts) do
        local ok, body = pcall(attempt)
        if ok and type(body) == "string" and #body >= 1024 then return body end
        errors[#errors + 1] = tostring(index) .. ":" .. tostring(body)
    end
    local host = url:match("^https?://([^/]+)") or "未知主机"
    error("无法连接音频 CDN " .. host .. " [" .. table.concat(errors, " | ") .. "]")
end

local function detectAudioFormat(body)
    if body:sub(1, 4) == "fLaC" then return "flac" end
    if body:sub(1, 4) == "OggS" then return "ogg" end
    if body:sub(1, 4) == "RIFF" then return "wav" end
    if body:sub(1, 3) == "ID3" then return "mp3" end
    local first, second = body:byte(1, 2)
    if first == 0xFF and second and second >= 0xE0 then return "mp3" end
    return nil
end

local function registerAsset(path)
    local loaders = {}
    if getcustomasset then
        loaders[#loaders + 1] = function() return getcustomasset(path) end
        loaders[#loaders + 1] = function() return getcustomasset(path, true) end
    end
    if getsynasset and getsynasset ~= getcustomasset then
        loaders[#loaders + 1] = function() return getsynasset(path) end
    end
    local errors = {}
    for index, loader in ipairs(loaders) do
        local ok, result = pcall(loader)
        if ok and type(result) == "string" and result ~= "" then return result end
        errors[#errors + 1] = tostring(index) .. ":" .. tostring(result)
    end
    error("Delta 本地音频注册失败 [" .. table.concat(errors, " | ") .. "]")
end

local BitReader = {}
BitReader.__index = BitReader

function BitReader.new(data, position)
    return setmetatable({ data = data, byte = position or 1, bit = 0 }, BitReader)
end

function BitReader:Read(count)
    local value = 0
    while count > 0 do
        if self.byte > #self.data then error("FLAC 位流提前结束") end
        local available = 8 - self.bit
        local take = math.min(count, available)
        local current = string.byte(self.data, self.byte)
        local divisor = 2 ^ (available - take)
        local chunk = math.floor(current / divisor) % (2 ^ take)
        value = value * (2 ^ take) + chunk
        self.bit = self.bit + take
        if self.bit == 8 then self.byte = self.byte + 1 self.bit = 0 end
        count = count - take
    end
    return value
end

function BitReader:Signed(count)
    local value = self:Read(count)
    local limit = 2 ^ (count - 1)
    return value >= limit and value - (2 ^ count) or value
end

function BitReader:Unary()
    local zeros = 0
    while self:Read(1) == 0 do
        zeros = zeros + 1
        if zeros > 1048576 then error("FLAC Rice 编码异常") end
    end
    return zeros
end

function BitReader:Align()
    if self.bit ~= 0 then self.byte = self.byte + 1 self.bit = 0 end
end

local function readUtf8Number(data, position)
    local first = string.byte(data, position) or 0
    local length = first < 128 and 1 or first < 224 and 2 or first < 240 and 3 or first < 248 and 4 or first < 252 and 5 or 6
    return position + length
end

local function decodeResidual(reader, samples, startIndex, count, order)
    if count <= 0 then return end
    local method = reader:Read(2)
    local partitionOrder = reader:Read(4)
    local partitions = 2 ^ partitionOrder
    local baseCount = math.floor(count / partitions)
    for partition = 0, partitions - 1 do
        local partitionCount = baseCount
        if partition == 0 then partitionCount = partitionCount - order end
        local parameterBits = method == 0 and 4 or method == 1 and 5 or nil
        if not parameterBits then error("FLAC 使用了不支持的 Rice 编码: " .. tostring(method) .. " frame=" .. tostring(activeFlacFrame) .. " byte=" .. tostring(reader.byte) .. " bit=" .. tostring(reader.bit)) end
        local parameter = reader:Read(parameterBits)
        for offset = 1, partitionCount do
            local value
            if parameter == (2 ^ parameterBits) - 1 then
                local rawBits = reader:Read(5)
                value = rawBits == 0 and 0 or reader:Signed(rawBits)
            else
                local quotient = reader:Unary()
                local remainder = parameter == 0 and 0 or reader:Read(parameter)
                local unsigned = quotient * (2 ^ parameter) + remainder
                value = unsigned % 2 == 0 and unsigned / 2 or -(unsigned + 1) / 2
            end
            samples[startIndex + offset - 1] = value
            if offset % 256 == 0 then yieldDecoder() end
        end
        startIndex = startIndex + partitionCount
    end
end

local function decodeSubframe(reader, blockSize, bits)
    if reader:Read(1) ~= 0 then error("FLAC 子帧头异常") end
    local subframeType = reader:Read(6)
    local wasted = reader:Read(1) == 1
    if wasted then
        local wastedBits = 1
        while reader:Read(1) == 0 do wastedBits = wastedBits + 1 end
        bits = bits - wastedBits
    end
    local samples = {}
    if subframeType == 0 then
        local value = reader:Signed(bits)
        for index = 1, blockSize do samples[index] = value end
        return samples
    end
    local order = 0
    if subframeType == 1 then
    for index = 1, blockSize do
        samples[index] = reader:Signed(bits)
        if index % 256 == 0 then yieldDecoder() end
    end
        return samples
    elseif subframeType >= 8 and subframeType <= 12 then
        order = subframeType - 8
    elseif subframeType >= 32 and subframeType <= 63 then
        order = subframeType - 31
    else
        error("FLAC 子帧预测类型不支持")
    end
    if order >= blockSize then error("FLAC 子帧预测阶数异常") end
    for index = 1, order do samples[index] = reader:Signed(bits) end
    if subframeType >= 32 then
        local precision = reader:Read(4) + 1
        if precision == 16 then error("FLAC LPC 精度异常") end
        local shift = reader:Signed(5)
        local coefficients = {}
        for index = 1, order do coefficients[index] = reader:Signed(precision) end
        decodeResidual(reader, samples, order + 1, blockSize, order)
        for index = order + 1, blockSize do
            local sum = 0
            for coefficient = 1, order do sum = sum + coefficients[coefficient] * samples[index - coefficient] end
            local prediction = shift >= 0 and math.floor(sum / (2 ^ shift)) or sum * (2 ^ (-shift))
            samples[index] = samples[index] + prediction
            if index % 256 == 0 then yieldDecoder() end
        end
    else
        decodeResidual(reader, samples, order + 1, blockSize, order)
        for index = order + 1, blockSize do
            local prediction
            if order == 0 then prediction = 0
            elseif order == 1 then prediction = samples[index - 1]
            elseif order == 2 then prediction = 2 * samples[index - 1] - samples[index - 2]
            elseif order == 3 then prediction = 3 * samples[index - 1] - 3 * samples[index - 2] + samples[index - 3]
            else prediction = 4 * samples[index - 1] - 6 * samples[index - 2] + 4 * samples[index - 3] - samples[index - 4] end
            samples[index] = samples[index] + prediction
            if index % 256 == 0 then yieldDecoder() end
        end
    end
    return samples
end

local function little16(value)
    return string.char(value % 256, math.floor(value / 256) % 256)
end

local function little32(value)
    return string.char(value % 256, math.floor(value / 256) % 256, math.floor(value / 65536) % 256, math.floor(value / 16777216) % 256)
end

local function clampNumber(value, minimum, maximum)
    return value < minimum and minimum or value > maximum and maximum or value
end

local function encodePcm(samples, channels, bits)
    local output = {}
    for index = 1, #samples[1] do
        for channel = 1, channels do
            local value = math.floor(samples[channel][index] or 0)
            local limit = 2 ^ (bits - 1)
            value = clampNumber(value, -limit, limit - 1)
            if bits == 8 then
                output[#output + 1] = string.char((value + 128) % 256)
            elseif bits == 16 then
                if value < 0 then value = value + 65536 end
                output[#output + 1] = string.char(value % 256, math.floor(value / 256) % 256)
            elseif bits == 24 then
                if value < 0 then value = value + 16777216 end
                output[#output + 1] = string.char(value % 256, math.floor(value / 256) % 256, math.floor(value / 65536) % 256)
            else
                if value < 0 then value = value + 4294967296 end
                output[#output + 1] = little32(value)
            end
        end
        if index % 256 == 0 then yieldDecoder() end
    end
    return table.concat(output)
end

local function decodeFlac(data, onProgress)
    if data:sub(1, 4) ~= "fLaC" then error("不是有效的 FLAC 文件") end
    local position = 5
    local sampleRate, channels, bits
    local lastMetadata = false
    while not lastMetadata do
        local header = string.byte(data, position)
        local length = string.byte(data, position + 1) * 65536 + string.byte(data, position + 2) * 256 + string.byte(data, position + 3)
        lastMetadata = header >= 128
        if header % 128 == 0 and length >= 34 then
            local base = position + 4
            local b11, b12, b13, b14 = string.byte(data, base + 10, base + 13)
            sampleRate = b11 * 4096 + b12 * 16 + math.floor(b13 / 16)
            channels = math.floor((b13 % 16) / 2) + 1
            bits = (b13 % 2) * 16 + math.floor(b14 / 16) + 1
        end
        position = position + 4 + length
    end
    if not sampleRate or not channels or not bits then error("FLAC 缺少 STREAMINFO") end
    local chunks = {}
    local totalSamples = 0
    local frameCount = 0
    while position + 4 <= #data do
        activeFlacFrame = position
        frameCount = frameCount + 1
        if frameCount % 4 == 0 then
            if onProgress then pcall(onProgress, clampNumber(position / #data, 0, 1)) end
            if task and task.wait then task.wait() end
        end
        local first, second, third, fourth = string.byte(data, position, position + 3)
        if first ~= 255 or math.floor(second / 4) ~= 62 then break end
        local blockCode = math.floor(third / 16)
        local channelAssignment = math.floor(fourth / 16)
        local sizeCode = math.floor((fourth % 16) / 2)
        local variableBlock = second % 2 == 1
        position = position + 4
        position = readUtf8Number(data, position)
        local blockSize
        if blockCode == 1 then blockSize = 192
        elseif blockCode >= 2 and blockCode <= 5 then blockSize = 576 * (2 ^ (blockCode - 2))
        elseif blockCode == 6 then blockSize = string.byte(data, position) + 1 position = position + 1
        elseif blockCode == 7 then blockSize = string.byte(data, position) * 256 + string.byte(data, position + 1) + 1 position = position + 2
        elseif blockCode >= 8 then blockSize = 256 * (2 ^ (blockCode - 8))
        else blockSize = 4096 end
        local sampleRateCode = third % 16
        if sampleRateCode == 12 then position = position + 1 elseif sampleRateCode >= 13 and sampleRateCode <= 14 then position = position + 2 end
        position = position + 1
        local frameReader = BitReader.new(data, position)
        local frameBits = sizeCode == 1 and 8 or sizeCode == 2 and 12 or sizeCode == 4 and 16 or sizeCode == 5 and 20 or sizeCode == 6 and 24 or bits
        local subframeCount = channelAssignment >= 8 and 2 or channels
        local samples = {}
        for channel = 1, subframeCount do
            local channelBits = frameBits
            if channelAssignment == 8 and channel == 2 then channelBits = channelBits + 1 end
            if channelAssignment == 9 and channel == 1 then channelBits = channelBits + 1 end
            if channelAssignment == 10 and channel == 2 then channelBits = channelBits + 1 end
            samples[channel] = decodeSubframe(frameReader, blockSize, channelBits)
        end
        frameReader:Align()
        position = frameReader.byte + 2
        if channelAssignment == 8 then
            for index = 1, blockSize do samples[2][index] = samples[1][index] - samples[2][index] end
        elseif channelAssignment == 9 then
            for index = 1, blockSize do samples[1][index] = samples[1][index] + samples[2][index] end
        elseif channelAssignment == 10 then
            for index = 1, blockSize do
                local mid = samples[1][index] * 2 + (samples[2][index] % 2)
                local side = samples[2][index]
                samples[1][index] = math.floor((mid + side) / 2)
                samples[2][index] = math.floor((mid - side) / 2)
            end
        end
        chunks[#chunks + 1] = encodePcm(samples, channels, bits)
        totalSamples = totalSamples + blockSize
    end
    local pcm = table.concat(chunks)
    local byteRate = sampleRate * channels * math.ceil(bits / 8)
    local blockAlign = channels * math.ceil(bits / 8)
    local header = "RIFF" .. little32(36 + #pcm) .. "WAVEfmt " .. little32(16) .. little16(1) .. little16(channels) .. little32(sampleRate) .. little32(byteRate) .. little16(blockAlign) .. little16(bits) .. "data" .. little32(#pcm)
    return header .. pcm
end

local function convertFlac(inputPath, outputPath, onProgress)
    if not readfile or not writefile then return false end
    local ok, body = pcall(readfile, inputPath)
    if not ok then return false end
    local decoded, wav = pcall(decodeFlac, body, onProgress)
    if not decoded then return false end
    writefile(outputPath, wav)
    return isfile and isfile(outputPath) or true
end

function Music.new(options)
    options = options or {}
    local self = setmetatable({
        Api = (options.Api or "https://wy.rwcdh.dpdns.org"):gsub("/$", ""),
        Queue = {},
        LocalFiles = {},
        Index = 0,
        SourceMode = "cloud",
        Volume = options.Volume or 0.5,
        LoopMode = "列表循环",
        OnStatus = options.OnStatus,
        OnLyric = options.OnLyric,
        OnSong = options.OnSong,
        LyricLines = {},
        CurrentLyricIndex = 0,
    }, Music)
    self.Sound = Instance.new("Sound")
    self.Sound.Name = "UGIK_Netease_Player"
    self.Sound.Volume = self.Volume
    self.Sound.Parent = SoundService
    self._lyricConnection = RunService.Heartbeat:Connect(function()
        if not self.Sound.IsPlaying or #self.LyricLines == 0 then return end
        local current = 0
        for index, line in ipairs(self.LyricLines) do
            if line.time <= self.Sound.TimePosition then current = index else break end
        end
        if current > 0 and current ~= self.CurrentLyricIndex then
            self.CurrentLyricIndex = current
            if self.OnLyric then pcall(self.OnLyric, self.LyricLines, current) end
        end
    end)
    self.Sound.Ended:Connect(function()
        if self.LoopMode == "单曲循环" then
            self.Sound.TimePosition = 0
            self.Sound:Play()
        else
            local count = self.SourceMode == "local" and #self.LocalFiles or #self.Queue
            if self.LoopMode ~= "顺序播放" or self.Index < count then
                self:Next()
            end
        end
    end)
    return self
end

function Music:_status(text, isError)
    if self.OnStatus then pcall(self.OnStatus, text, isError) end
end

function Music:_get(path)
    local lastError
    for attempt = 1, 3 do
        local ok, result = pcall(function()
            local separator = path:find("?", 1, true) and "&" or "?"
            local body = game:HttpGet(self.Api .. path .. separator .. "_t=" .. tostring(os.time()) .. tostring(attempt))
            return HttpService:JSONDecode(body)
        end)
        if ok then return result end
        lastError = result
        task.wait(attempt * 0.5)
    end
    error("网易云 API 请求失败: " .. tostring(lastError))
end

function Music:Search(keyword, limit)
    keyword = tostring(keyword or ""):match("^%s*(.-)%s*$")
    if keyword == "" then error("请输入歌曲名或歌手") end
    self:_status("正在搜索: " .. keyword)
    local data = self:_get("/cloudsearch?type=1&limit=" .. tostring(limit or 10) .. "&keywords=" .. encode(keyword))
    local songs = data.result and data.result.songs or {}
    local results = {}
    for _, song in ipairs(songs) do
        local artists = {}
        for _, artist in ipairs(song.ar or song.artists or {}) do artists[#artists + 1] = artist.name end
        results[#results + 1] = {
            id = song.id,
            name = song.name or "未知歌曲",
            artist = table.concat(artists, "/"),
            album = (song.al or song.album or {}).name or "",
            duration = song.dt or song.duration or 0,
        }
    end
    self.Queue = results
    self.SourceMode = "cloud"
    self:ClearLyrics()
    self.Index = #results > 0 and 1 or 0
    self:_status(#results > 0 and ("已返回 " .. tostring(#results) .. " 首歌曲") or "没有搜索到歌曲", #results == 0)
    return results
end

function Music:ScanLocal(directory)
    if not listfiles then error("当前执行器不支持 listfiles") end
    local requested = tostring(directory or "")
    local candidates = { requested }
    if requested == "" then
        candidates = { "/storage/emulated/0/Delta/Workspace/UGIK/myself", "UGIK/myself" }
    elseif requested:find("/storage/emulated/0/Delta/Workspace/", 1, true) == 1 then
        candidates[#candidates + 1] = requested:gsub("^/storage/emulated/0/Delta/Workspace/", "")
    end
    local files
    local usedDirectory
    for _, candidate in ipairs(candidates) do
        local ok, result = pcall(listfiles, candidate)
        if ok and type(result) == "table" then files, usedDirectory = result, candidate break end
    end
    if not files and makefolder then
        pcall(function() if not isfolder or not isfolder("UGIK") then makefolder("UGIK") end end)
        pcall(function() if not isfolder or not isfolder("UGIK/myself") then makefolder("UGIK/myself") end end)
        local ok, result = pcall(listfiles, "UGIK/myself")
        if ok and type(result) == "table" then files, usedDirectory = result, "UGIK/myself" end
    end
    if not files then error("无法扫描目录，请确认目录存在且 Delta 已授权存储权限") end
    local results = {}
    for _, path in ipairs(files) do
        local extension = path:lower():match("%.([%w]+)$")
        if extension == "mp3" or extension == "ogg" or extension == "wav" or extension == "flac" then
            results[#results + 1] = { path = path, name = path:match("([^/\\]+)$") or path }
        end
    end
    table.sort(results, function(a, b) return a.name:lower() < b.name:lower() end)
    self.LocalFiles = results
    self.LocalDirectory = usedDirectory
    self.SourceMode = "local"
    self:ClearLyrics()
    self.Index = #results > 0 and 1 or 0
    self:_status("已扫描 " .. tostring(#results) .. " 首本地歌曲")
    return results
end

function Music:PlayLocal(indexOrPath)
    local entry
    if type(indexOrPath) == "number" then
        self.Index = indexOrPath
        entry = self.LocalFiles[indexOrPath]
    else
        local path = tostring(indexOrPath or "")
        for index, item in ipairs(self.LocalFiles) do
            if item.path == path then self.Index, entry = index, item break end
        end
        entry = entry or { path = path, name = path:match("([^/\\]+)$") or path }
    end
    if not entry or entry.path == "" then error("未选择本地歌曲") end
    if readfile then
        local ok, body = pcall(readfile, entry.path)
        if not ok then error("无法读取本地歌曲: " .. tostring(body)) end
        local format = detectAudioFormat(body)
        if not format then error("无法识别本地音频格式") end
        if format == "flac" then
            local convertedPath = "UGIK/local_" .. tostring(self.Index) .. ".wav"
            pcall(function() if makefolder and not isfolder("UGIK") then makefolder("UGIK") end end)
            writefile("UGIK/local_" .. tostring(self.Index) .. ".flac", body)
            if not convertFlac("UGIK/local_" .. tostring(self.Index) .. ".flac", convertedPath, function(progress)
                self:_status("Lua 解码本地 FLAC " .. math.floor(progress * 100) .. "%")
            end) then
                error("本地 FLAC 解码失败")
            end
            pcall(function() if delfile then delfile("UGIK/local_" .. tostring(self.Index) .. ".flac") end end)
            entry = { path = convertedPath, name = entry.name }
        end
    end
    self.SourceMode = "local"
    self.Sound:Stop()
    self.Sound.SoundId = registerAsset(entry.path)
    self.Sound.Volume = self.Volume
    local started = os.clock()
    while not self.Sound.IsLoaded and os.clock() - started < 12 do task.wait(0.1) end
    if not self.Sound.IsLoaded then error("Delta 未能加载本地歌曲") end
    self.Sound:Play()
    self:_status("正在播放本地歌曲: " .. entry.name)
    return entry
end

function Music:_assetFor(song)
    local info
    self:_status("正在通过 API 获取 MP3: " .. song.name)
    local normalOk, normalResponse = pcall(self._get, self, "/song/url?br=320000&id=" .. tostring(song.id))
    if normalOk and normalResponse.code == 200 and normalResponse.data then
        local candidate = normalResponse.data[1] or normalResponse.data
        if type(candidate) == "table" and candidate.url then
            local cleanUrl = candidate.url:match("^[^?]+") or candidate.url
            local format = candidate.type or cleanUrl:match("%.([%w]+)$") or "mp3"
            if format ~= "flac" then info = { url = candidate.url, type = format } end
        end
    end
    if not info then
        self:_status("正在通过 API 解锁歌曲: " .. song.name)
        local ok, response = pcall(self._get, self, "/song/url/v1?level=standard&unblock=true&id=" .. tostring(song.id))
        if ok and response.code == 200 then
            local candidate = response.data and (response.data[1] or response.data)
            if type(candidate) == "table" and candidate.url then
                info = { url = candidate.url, type = candidate.type or "mp3" }
            end
        end
    end
    if not info then
        local matchOk, matched = pcall(self._get, self, "/song/url/match?id=" .. tostring(song.id))
        if matchOk and matched.code == 200 then
            local matchedUrl = matched.proxyUrl ~= "" and matched.proxyUrl or matched.data
            if type(matchedUrl) == "string" and matchedUrl ~= "" then
                local cleanUrl = matchedUrl:match("^[^?]+") or matchedUrl
                info = { url = matchedUrl, type = cleanUrl:match("%.([%w]+)$") or "mp3" }
            end
        end
    end
    if not info or not info.url then error("歌曲无版权或接口未返回播放地址") end
    local requester = requestFunction()
    if not requester or not writefile or (not getcustomasset and not getsynasset) then
        error("当前执行器缺少 request/writefile/getcustomasset")
    end
    local folder = "UGIK"
    pcall(function() if makefolder and not isfolder(folder) then makefolder(folder) end end)
    local pathBase = folder .. "/music_" .. tostring(song.id)
    local path
    if listfiles and isfile then
        pcall(function()
            for _, candidate in ipairs(listfiles(folder)) do
                if candidate:find("music_" .. tostring(song.id), 1, true) and isfile(candidate) then path = candidate break end
            end
        end)
    end
    if not path then
        self:_status("正在下载: " .. song.name)
        local body = downloadAudio(info.url, requester)
        local format = detectAudioFormat(body)
        if not format then error("无法解析返回的音频格式") end
        path = pathBase .. "." .. format
        writefile(path, body)
        if format == "flac" then
            local convertedPath = pathBase .. ".wav"
            self:_status("正在用 Lua 解码 FLAC: " .. song.name)
            if not convertFlac(path, convertedPath, function(progress)
                self:_status("Lua 解码 FLAC " .. math.floor(progress * 100) .. "%")
            end) then
                error("FLAC Lua 解码失败")
            end
            pcall(function() if delfile then delfile(path) end end)
            path = convertedPath
        end
    end
    local cachedBody
    if readfile then
        local ok, result = pcall(readfile, path)
        if ok then cachedBody = result end
    end
    local cachedFormat = cachedBody and detectAudioFormat(cachedBody)
    if cachedBody and not cachedFormat then
        pcall(function() if delfile then delfile(path) end end)
        error("缓存音频格式无效")
    end
    if cachedFormat == "flac" then
        local convertedPath = pathBase .. ".wav"
        self:_status("正在用 Lua 解码缓存 FLAC: " .. song.name)
        if not convertFlac(path, convertedPath, function(progress)
            self:_status("Lua 解码缓存 FLAC " .. math.floor(progress * 100) .. "%")
        end) then
            error("缓存 FLAC Lua 解码失败")
        end
        pcall(function() if delfile then delfile(path) end end)
        path = convertedPath
    end
    return registerAsset(path)
end

function Music:Play(index, attempts)
    index = tonumber(index) or self.Index
    local song = self.Queue[index]
    if not song then error("播放列表为空") end
    self.Index = index
    self:_status("正在加载: " .. song.name)
    self.Sound:Stop()
    local assetOk, assetOrError = pcall(self._assetFor, self, song)
    if not assetOk then
        attempts = (attempts or 0) + 1
        local reason = tostring(assetOrError)
        local canSkip = reason:find("无版权", 1, true) or reason:find("音频格式", 1, true) or reason:find("本地音频注册失败", 1, true)
        if canSkip and attempts < #self.Queue then
            self:_status(song.name .. " 无可用音源，尝试下一首", true)
            local nextIndex = index + 1
            if nextIndex > #self.Queue then nextIndex = 1 end
            return self:Play(nextIndex, attempts)
        end
        error(assetOrError)
    end
    self.Sound.SoundId = assetOrError
    self.Sound.Volume = self.Volume
    local started = os.clock()
    while not self.Sound.IsLoaded and os.clock() - started < 12 do task.wait(0.1) end
    if not self.Sound.IsLoaded then
        local pathPrefix = "UGIK/music_" .. tostring(song.id) .. "."
        pcall(function()
            if listfiles and delfile then
                for _, path in ipairs(listfiles("UGIK")) do
                    if path:find(pathPrefix, 1, true) then delfile(path) end
                end
            end
        end)
        error("音频已下载，但执行器未能加载本地 MP3")
    end
    self.Sound:Play()
    self:_status("正在播放: " .. song.name .. " - " .. song.artist)
    if self.OnSong then pcall(self.OnSong, song) end
    task.spawn(function()
        local lyricOk, lyric = pcall(self.GetLyric, self, song)
        if lyricOk then self:SetLyricText(lyric) end
    end)
    return song
end

function Music:TogglePause()
    if self.Sound.IsPlaying then self.Sound:Pause() else self.Sound:Resume() end
end

function Music:Next()
    if self.SourceMode == "local" then
        if #self.LocalFiles == 0 then return end
        local index = self.Index + 1
        if index > #self.LocalFiles then index = 1 end
        return self:PlayLocal(index)
    end
    if #self.Queue == 0 then return end
    local index = self.Index + 1
    if index > #self.Queue then index = 1 end
    return self:Play(index)
end

function Music:Previous()
    if self.SourceMode == "local" then
        if #self.LocalFiles == 0 then return end
        local index = self.Index - 1
        if index < 1 then index = #self.LocalFiles end
        return self:PlayLocal(index)
    end
    if #self.Queue == 0 then return end
    local index = self.Index - 1
    if index < 1 then index = #self.Queue end
    return self:Play(index)
end

function Music:SetVolume(value)
    self.Volume = math.clamp(tonumber(value) or 0.5, 0, 1)
    self.Sound.Volume = self.Volume
end

function Music:Seek(percent)
    if self.Sound.TimeLength > 0 then
        self.Sound.TimePosition = self.Sound.TimeLength * math.clamp(tonumber(percent) or 0, 0, 1)
    end
end

function Music:SetLoopMode(mode)
    self.LoopMode = mode
end

function Music:GetLyric(song)
    song = song or self.Queue[self.Index]
    if not song then return "暂无歌词" end
    local ok, data = pcall(self._get, self, "/lyric/new?id=" .. tostring(song.id))
    if ok then
        if data.yrc and data.yrc.lyric and data.yrc.lyric ~= "" then return data.yrc.lyric end
        if data.lrc and data.lrc.lyric and data.lrc.lyric ~= "" then return data.lrc.lyric end
    end
    local fallback = self:_get("/lyric?id=" .. tostring(song.id))
    return fallback.lrc and fallback.lrc.lyric or "暂无歌词"
end

function Music:SetLyricText(text)
    self.LyricLines = {}
    self.CurrentLyricIndex = 0
    for rawLine in tostring(text or ""):gmatch("[^\r\n]+") do
        local yrcStart, yrcDuration = rawLine:match("^%[(%d+),(%d+)%]")
        local lyricText = rawLine:gsub("%[[^%]]+%]", ""):gsub("%(%d+,%d+,%d+%)", ""):match("^%s*(.-)%s*$")
        local timestamps = {}
        if yrcStart then
            timestamps[#timestamps + 1] = tonumber(yrcStart) / 1000
        else
            for minutes, seconds, fraction in rawLine:gmatch("%[(%d+):(%d+)%.(%d+)%]") do
                timestamps[#timestamps + 1] = tonumber(minutes) * 60 + tonumber(seconds) + tonumber((fraction .. "00"):sub(1, 2)) / 100
            end
            for minutes, seconds, fraction in rawLine:gmatch("%[(%d+):(%d+):(%d+)%]") do
                timestamps[#timestamps + 1] = tonumber(minutes) * 60 + tonumber(seconds) + tonumber((fraction .. "00"):sub(1, 2)) / 100
            end
            for minutes, seconds in rawLine:gmatch("%[(%d+):(%d+)%]") do
                timestamps[#timestamps + 1] = tonumber(minutes) * 60 + tonumber(seconds)
            end
        end
        for _, time in ipairs(timestamps) do
            if lyricText and lyricText ~= "" then
                self.LyricLines[#self.LyricLines + 1] = { time = time, text = lyricText }
            end
        end
    end
    table.sort(self.LyricLines, function(a, b) return a.time < b.time end)
    if self.OnLyric then pcall(self.OnLyric, self.LyricLines, 0) end
    return self.LyricLines
end

function Music:ClearLyrics()
    self.LyricLines = {}
    self.CurrentLyricIndex = 0
    if self.OnLyric then pcall(self.OnLyric, {}, 0) end
end

function Music:Destroy()
    if self._lyricConnection then self._lyricConnection:Disconnect() end
    self.Sound:Destroy()
end

return Music
