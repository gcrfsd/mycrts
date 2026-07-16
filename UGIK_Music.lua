local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local Music = {}
Music.__index = Music

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

function Music.new(options)
    options = options or {}
    local self = setmetatable({
        Api = (options.Api or "https://wy.rwcdh.dpdns.org"):gsub("/$", ""),
        Queue = {},
        Index = 0,
        Volume = options.Volume or 0.5,
        LoopMode = "列表循环",
        OnStatus = options.OnStatus,
    }, Music)
    self.Sound = Instance.new("Sound")
    self.Sound.Name = "UGIK_Netease_Player"
    self.Sound.Volume = self.Volume
    self.Sound.Parent = SoundService
    self.Sound.Ended:Connect(function()
        if self.LoopMode == "单曲循环" then
            self.Sound.TimePosition = 0
            self.Sound:Play()
        elseif self.LoopMode ~= "顺序播放" or self.Index < #self.Queue then
            self:Next()
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
    self.Index = #results > 0 and 1 or 0
    self:_status(#results > 0 and ("已返回 " .. tostring(#results) .. " 首歌曲") or "没有搜索到歌曲", #results == 0)
    return results
end

function Music:_assetFor(song)
    local info
    for _, level in ipairs({ "standard", "higher", "exhigh" }) do
        local ok, response = pcall(self._get, self, "/song/url/v1?level=" .. level .. "&id=" .. tostring(song.id))
        info = ok and response.data and response.data[1] or nil
        if info and info.url then break end
    end
    if not info or not info.url then
        local ok, fallback = pcall(self._get, self, "/song/url?br=128000&id=" .. tostring(song.id))
        info = ok and fallback.data and fallback.data[1] or nil
    end
    if not info or not info.url then
        self:_status("正在尝试解灰音源: " .. song.name)
        local ok, matched = pcall(self._get, self, "/song/url/match?id=" .. tostring(song.id))
        if ok and matched.code == 200 then
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
        if format == "flac" then error("Delta 不支持当前 FLAC 音源") end
        if not format then error("无法解析返回的音频格式") end
        path = pathBase .. "." .. format
        writefile(path, body)
    end
    local cachedBody
    if readfile then
        local ok, result = pcall(readfile, path)
        if ok then cachedBody = result end
    end
    local cachedFormat = cachedBody and detectAudioFormat(cachedBody)
    if cachedFormat == "flac" or (cachedBody and not cachedFormat) then
        pcall(function() if delfile then delfile(path) end end)
        error(cachedFormat == "flac" and "Delta 不支持缓存的 FLAC 音源" or "缓存音频格式无效")
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
        local canSkip = reason:find("无版权", 1, true) or reason:find("FLAC", 1, true) or reason:find("音频格式", 1, true)
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
    return song
end

function Music:TogglePause()
    if self.Sound.IsPlaying then self.Sound:Pause() else self.Sound:Resume() end
end

function Music:Next()
    if #self.Queue == 0 then return end
    local index = self.Index + 1
    if index > #self.Queue then index = 1 end
    return self:Play(index)
end

function Music:Previous()
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
    local data = self:_get("/lyric?id=" .. tostring(song.id))
    return data.lrc and data.lrc.lyric or "暂无歌词"
end

function Music:Destroy()
    self.Sound:Destroy()
end

return Music
