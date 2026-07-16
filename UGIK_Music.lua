local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local Music = {}
Music.__index = Music

local function encode(value)
    return HttpService:UrlEncode(tostring(value or ""))
end

local function requestFunction()
    return request or http_request or (syn and syn.request)
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
        local response = self:_get("/song/url/v1?level=" .. level .. "&id=" .. tostring(song.id))
        info = response.data and response.data[1]
        if info and info.url then break end
    end
    if not info or not info.url then
        local fallback = self:_get("/song/url?br=128000&id=" .. tostring(song.id))
        info = fallback.data and fallback.data[1]
    end
    if not info or not info.url then error("歌曲无版权或接口未返回播放地址") end
    local requester = requestFunction()
    local asset = getcustomasset or getsynasset
    if not requester or not writefile or not asset then
        error("当前执行器缺少 request/writefile/getcustomasset")
    end
    local folder = "UGIK"
    pcall(function() if makefolder and not isfolder(folder) then makefolder(folder) end end)
    local extension = info.type or "mp3"
    local path = folder .. "/music_" .. tostring(song.id) .. "." .. extension
    if not (isfile and isfile(path)) then
        self:_status("正在下载: " .. song.name)
        local audioUrl = info.url:gsub("^http://", "https://")
        local downloaded = requester({
            Url = audioUrl,
            Method = "GET",
            Headers = { ["User-Agent"] = "Mozilla/5.0", Referer = "https://music.163.com/" },
        })
        local body = downloaded and (downloaded.Body or downloaded.body)
        local status = downloaded and (downloaded.StatusCode or downloaded.Status)
        if status and tonumber(status) and tonumber(status) >= 400 then
            error("音频下载失败，HTTP " .. tostring(status))
        end
        if not body or #body < 1024 then error("音频下载未返回有效数据") end
        writefile(path, body)
    end
    return asset(path)
end

function Music:Play(index)
    index = tonumber(index) or self.Index
    local song = self.Queue[index]
    if not song then error("播放列表为空") end
    self.Index = index
    self:_status("正在加载: " .. song.name)
    self.Sound:Stop()
    self.Sound.SoundId = self:_assetFor(song)
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
