local BASE_URL = "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/"
local LIBRARY_VERSION = "20260718-glass-lyrics"
local UI_LIBRARY_URL = "https://raw.githubusercontent.com/gcrfsd/mycrts/refs/heads/main/UGIK_UI.lua?v=" .. LIBRARY_VERSION
local MUSIC_LIBRARY_URL = "https://raw.githubusercontent.com/gcrfsd/mycrts/refs/heads/main/UGIK_Music.lua?v=" .. LIBRARY_VERSION

local scripts = {
    "4M1NrMnc.txt",
    "99Cps natural.lua",
    "99夜虚空.txt",
    "AC6.txt",
    "AUTVellure.lua",
    "Alrthisfordetection.txt",
    "Arceus X V3.txt",
    "ArgonHubX.lua",
    "B0bbyHub.lua",
    "Celestial.lua",
    "DARK.lua",
    "DHJB甩飞.txt",
    "DOORS.lua",
    "Fartsaken.txt",
    "KENNY爆打黄油.txt",
    "KENNY画我.lua",
    "KENNY通缉换服.lua",
    "KaiXar.lua",
    "Kalitor.lua",
    "Kenny1.5.txt",
    "Kenny免费私服.lua",
    "Kenny动画中心.lua",
    "Kenny汉化犯罪脚本.txt",
    "Lonely_Hub.lua",
    "Main.lua (2).txt",
    "NEGA.lua",
    "Old_sUNC_updated.txt",
    "POLLUTE.lua",
    "Protected_1265661175270799.lua.txt",
    "Protected_3253786975302161.lua.txt",
    "Protected_4100679075074324.lua.txt",
    "Protected_8207298493860897.lua.txt",
    "Protected_9010113477085067.lua.txt",
    "Protected_9027981647116997.lua.txt",
    "RTXv1.txt",
    "SNT.lua",
    "Simple_Spy_Utility.txt",
    "Tbao.lua",
    "UFC.txt",
    "UWU.lua",
    "V1.lua.txt",
    "V3.txt",
    "V4.txt",
    "V5.txt",
    "V6.txt",
    "Vape.lua",
    "VelocityX.lua",
    "VexonHub汉化.txt",
    "VinzHub.lua",
    "Weed.lua",
    "bf.txt",
    "blq.lua",
    "fe-flinger-gui-works-anywhere_1756291955889_SwfaGHMWsT.txt",
    "js.lua",
    "nodex.lua",
    "obfuscated_script-1758351873821.lua.txt",
    "phantasm.lua",
    "siwang.lua",
    "sm脚本.lua",
    "source.lua.txt",
    "stghongye.lua",
    "zcxb.lua",
    "丁丁 汉化自瞄.txt",
    "七日生存.txt",
    "七日生成kkk.txt",
    "位置仪.txt",
    "假无头.lua",
    "刷屏.txt",
    "前后空翻.txt",
    "动画Spy.lua.txt",
    "双环控制黑洞.txt",
    "哥特风黑洞.txt",
    "场景更改器.lua",
    "坐标仪.txt",
    "坐标传送.txt",
    "坐标查看加传送.txt",
    "夜晚.txt",
    "好看光影.txt",
    "实时数据.txt",
    "开源自动军区跳跃.lua",
    "强行丢弃.txt",
    "忍者.lua",
    "战争大亨.txt",
    "控制台.lua",
    "方块故事tex.lua",
    "无敌少侠飞行r6.txt",
    "昼夜RTX光影.txt",
    "本地音乐播放器.txt",
    "机器人.txt",
    "死铁轨.lua",
    "死铁轨v4.lua",
    "汉化vapev4.txt",
    "汉化墨水Ringta.txt",
    "汉化铁拳.txt",
    "爱男娘.lua",
    "玩家传送.txt",
    "画质提升1.txt",
    "画质提升2.txt",
    "白光影.txt",
    "看物品栏.txt",
    "磁铁黑洞V2.txt",
    "突触X改进.lua.txt",
    "突触X重置版汉化.txt",
    "红木监狱.lua",
    "红辣椒.txt",
    "终极战场自动换服杀戮.lua",
    "翻译.txt",
    "自定义动画.txt",
    "蜘蛛侠.txt",
    "计时器.txt",
    "越跑越快.txt",
    "跳跃对决.txt",
    "近战.lua",
    "键盘.txt",
    "飞行脚本V3(全游戏通用) (1) (1).txt",
    "飞车.txt",
}

local descriptions = {
    ["4M1NrMnc.txt"] = "短代码片段，功能名不明确，需运行确认",
    ["99Cps natural.lua"] = "CpsHub 远程加载，含目标选择/击杀/ESP",
    ["99夜虚空.txt"] = "WeAreDevs 混淆脚本，99 夜/虚空相关",
    ["AC6.txt"] = "FE AC6 音乐漏洞，输入音频 ID 播放",
    ["AUTVellure.lua"] = "AUT/Vellure 远程 Hub，任务/角色功能",
    ["Alrthisfordetection.txt"] = "音频 Spy/声音检测与复制工具",
    ["Arceus X V3.txt"] = "Arceus X V3 执行器 UI/Dex/工具合集",
    ["ArgonHubX.lua"] = "ArgonHubX 远程 Loader，含战斗/视觉/玩家功能",
    ["B0bbyHub.lua"] = "B0bbyHub 综合功能入口",
    ["Celestial.lua"] = "Celestial 鱼类/雷达/氧气等远程 Hub",
    ["DARK.lua"] = "DarkEsc 远程 Loader，含钻石农场/教程功能",
    ["DHJB甩飞.txt"] = "甩飞/物理控制脚本",
    ["DOORS.lua"] = "DOORS/Ninja 远程脚本，含穿墙等功能",
    ["Fartsaken.txt"] = "Forsaken 远程脚本，含锁定/ESP/移动功能",
    ["KENNY爆打黄油.txt"] = "KENNY 系列战斗/娱乐脚本，混淆单行",
    ["KENNY画我.lua"] = "画图/绘制角色相关脚本",
    ["KENNY通缉换服.lua"] = "通缉目标与换服相关脚本",
    ["KaiXar.lua"] = "KaiXar 综合脚本 Hub",
    ["Kalitor.lua"] = "Kalitor 综合脚本 Hub",
    ["Kenny1.5.txt"] = "Kenny 公告加载器，跳转 kenk/kkl 混淆脚本",
    ["Kenny免费私服.lua"] = "Kenny 免费私服脚本，单行 VM 混淆",
    ["Kenny动画中心.lua"] = "Kenny 动画中心，超大型单行动画库",
    ["Kenny汉化犯罪脚本.txt"] = "犯罪类汉化脚本，WeAreDevs 混淆",
    ["Lonely_Hub.lua"] = "Lonely Hub 远程 Fish It 配置/事件功能",
    ["Main.lua (2).txt"] = "WindUI/Platoboost 大型主脚本与授权 UI",
    ["NEGA.lua"] = "NEGA 综合脚本 Hub",
    ["Old_sUNC_updated.txt"] = "sUNC 环境/兼容性检测脚本",
    ["POLLUTE.lua"] = "POLLUTE/Luarmor 远程 Loader，含主题配置",
    ["Protected_1265661175270799.lua.txt"] = "MoonSec/Protected 混淆保护脚本",
    ["Protected_3253786975302161.lua.txt"] = "MoonSec/Protected 混淆保护脚本",
    ["Protected_4100679075074324.lua.txt"] = "MoonSec/Protected 混淆保护脚本",
    ["Protected_8207298493860897.lua.txt"] = "MoonSec/Protected 混淆保护脚本",
    ["Protected_9010113477085067.lua.txt"] = "MoonSec/Protected 混淆保护脚本",
    ["Protected_9027981647116997.lua.txt"] = "MoonSec/Protected 混淆保护脚本",
    ["RTXv1.txt"] = "RTX/画质光影脚本",
    ["SNT.lua"] = "SNT 综合脚本 Hub",
    ["Simple_Spy_Utility.txt"] = "Spy Utility 远程事件/动画/复制调试工具",
    ["Tbao.lua"] = "Tbao 综合脚本 Hub",
    ["UFC.txt"] = "UFC 单行混淆格斗脚本",
    ["UWU.lua"] = "UWU 综合/娱乐脚本",
    ["V1.lua.txt"] = "V 系列脚本 V1",
    ["V3.txt"] = "V 系列脚本 V3",
    ["V4.txt"] = "V 系列脚本 V4",
    ["V5.txt"] = "V 系列脚本 V5",
    ["V6.txt"] = "V 系列脚本 V6",
    ["Vape.lua"] = "Vape/Voidware 远程 Forsaken 功能",
    ["VelocityX.lua"] = "VelocityX 远程实体躲避/门类功能",
    ["VexonHub汉化.txt"] = "VexonHub 汉化版，WeAreDevs 混淆",
    ["VinzHub.lua"] = "VinzHub 远程 Fish It 事件/传送功能",
    ["Weed.lua"] = "Weed Client 远程，含透视/自瞄",
    ["bf.txt"] = "Blox Fruits 自动瞄准/任务/战斗功能",
    ["blq.lua"] = "暴力街区/综合功能，含玩家/杂项页面",
    ["fe-flinger-gui-works-anywhere_1756291955889_SwfaGHMWsT.txt"] = "FE 甩飞 GUI，通用物理甩飞",
    ["js.lua"] = "Zee Hub 远程脚本，难度/关卡功能",
    ["nodex.lua"] = "NodeX 远程 Loader，自动刷取/轨道功能",
    ["obfuscated_script-1758351873821.lua.txt"] = "混淆脚本，具体功能不可静态确认",
    ["phantasm.lua"] = "Phantasm TSB 远程，含锁定/信息/战斗",
    ["siwang.lua"] = "商店/配置/自动功能脚本",
    ["sm脚本.lua"] = "大型混淆综合脚本",
    ["source.lua.txt"] = "大型 UI Library/GUI 源码与工具集合",
    ["stghongye.lua"] = "红叶脚本，含 Webhook/主要功能",
    ["zcxb.lua"] = "BABFT 远程 Loader，自动农场/模块",
    ["丁丁 汉化自瞄.txt"] = "汉化自瞄/战斗辅助",
    ["七日生存.txt"] = "七日生存 ESP、传送、玩家辅助",
    ["七日生成kkk.txt"] = "七日生存生成/ESP/玩家修改",
    ["位置仪.txt"] = "显示与复制当前位置",
    ["假无头.lua"] = "假无头角色外观脚本",
    ["刷屏.txt"] = "聊天刷屏/消息发送脚本",
    ["前后空翻.txt"] = "前后空翻动作，带移动端按钮",
    ["动画Spy.lua.txt"] = "动画 ID 监听、复制、播放工具",
    ["双环控制黑洞.txt"] = "双环黑洞/物理吸附控制",
    ["哥特风黑洞.txt"] = "哥特风黑洞/物理吸附控制",
    ["场景更改器.lua"] = "PShade 场景/光影/天气更改器",
    ["坐标仪.txt"] = "实时坐标显示工具",
    ["坐标传送.txt"] = "输入路径/坐标传送工具",
    ["坐标查看加传送.txt"] = "查看坐标、保存位置并传送",
    ["夜晚.txt"] = "夜晚天空与灯光效果",
    ["好看光影.txt"] = "画质/光影美化",
    ["实时数据.txt"] = "FPS、Ping、内存、人数实时数据面板",
    ["开源自动军区跳跃.lua"] = "军区自动跳跃/自动操作脚本",
    ["强行丢弃.txt"] = "强制丢弃物品/工具",
    ["忍者.lua"] = "Delta/忍者大型 UI，含授权/复制链接",
    ["战争大亨.txt"] = "战争大亨远程，金钱/自动偷箱/购买",
    ["控制台.lua"] = "单行混淆控制台，暴露快捷键文本",
    ["方块故事tex.lua"] = "方块故事/Block Tales 相关脚本",
    ["无敌少侠飞行r6.txt"] = "R6 飞行脚本",
    ["昼夜RTX光影.txt"] = "昼夜/RTX 光影效果",
    ["本地音乐播放器.txt"] = "本地音乐播放器 GUI",
    ["机器人.txt"] = "机器人/自动化相关，单行 VM 混淆",
    ["死铁轨.lua"] = "Dead Rails/Ringta 汉化辅助",
    ["死铁轨v4.lua"] = "Dead Rails v4 辅助脚本",
    ["汉化vapev4.txt"] = "Vape V4 汉化版",
    ["汉化墨水Ringta.txt"] = "墨水/Ringta 汉化脚本",
    ["汉化铁拳.txt"] = "铁拳/格斗类汉化脚本",
    ["爱男娘.lua"] = "娱乐/角色相关脚本",
    ["玩家传送.txt"] = "PlayerTeleporter，玩家列表/传送工具",
    ["画质提升1.txt"] = "画质提升预设 1",
    ["画质提升2.txt"] = "画质提升预设 2",
    ["白光影.txt"] = "白色光影/环境美化",
    ["看物品栏.txt"] = "查看玩家物品栏",
    ["磁铁黑洞V2.txt"] = "磁铁黑洞 V2/物理吸附",
    ["突触X改进.lua.txt"] = "Synapse X 风格改进/工具集",
    ["突触X重置版汉化.txt"] = "Synapse X 重置版汉化",
    ["红木监狱.lua"] = "Redwood Prison 监狱游戏脚本",
    ["红辣椒.txt"] = "红辣椒相关混淆脚本",
    ["终极战场自动换服杀戮.lua"] = "终极战场自动换服/击杀脚本",
    ["翻译.txt"] = "界面/文本翻译工具",
    ["自定义动画.txt"] = "自定义动画播放工具",
    ["蜘蛛侠.txt"] = "蜘蛛侠摆荡/移动能力脚本",
    ["计时器.txt"] = "计时器 GUI 工具",
    ["越跑越快.txt"] = "移动速度逐步提升",
    ["跳跃对决.txt"] = "跳跃对决游戏辅助",
    ["近战.lua"] = "近战/战斗辅助脚本",
    ["键盘.txt"] = "移动端虚拟键盘/按键工具",
    ["飞行脚本V3(全游戏通用) (1) (1).txt"] = "通用飞行脚本 V3",
    ["飞车.txt"] = "飞车/飞行控制 GUI",
}

local externalScripts = {
    { name = "皮脚本", category = "脚本合集", group = "脚本列表", description = "综合脚本合集，加载前写入 XiaoPi 标识", url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua", beforeLoad = function() getgenv().XiaoPi = "皮脚本QQ群1002100032" end },
    { name = "叶脚本", category = "脚本合集", group = "脚本列表", description = "叶脚本综合中心", url = "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua" },
    { name = "BS脚本", category = "脚本合集", group = "脚本列表", description = "BS Script 综合脚本中心", url = "https://gitee.com/BS_script/script/raw/master/BS_Script.Luau" },
    { name = "情云脚本", category = "脚本合集", group = "脚本列表", description = "情云综合脚本入口", url = "https://raw.githubusercontent.com/ChinaQY/-/main/%E6%83%85%E4%BA%91" },
    { name = "Aero栽赃脚本卡密（Yisan）", category = "脚本合集", group = "脚本列表", description = "Aero 脚本，自动设置 SCRIPT_KEY=Yisan", url = "https://api.jnkie.com/api/v1/luascripts/public/d975bd4e6385076888cb440390a8a53d8763b5e17f23f15a66516cd2f87974f7/download", beforeLoad = function() getgenv().SCRIPT_KEY = "Yisan" end },
    { name = "窗脚本（卡密：何意味）", category = "脚本合集", group = "脚本列表", description = "窗脚本加载器，说明内含卡密提示", url = "https://raw.githubusercontent.com/pl11451481mvcxz/-3-/refs/heads/main/%E7%AA%97%E8%84%9A%E6%9C%AC%E5%8A%A0%E8%BD%BD%E5%99%A8" },
    { name = "刘某脚本", category = "脚本合集", group = "脚本列表", description = "Pastefy 远程综合脚本，原示例混淆 URL 已解析", url = "https://pastefy.app/T1OTvxZy/raw" },
    { name = "弑脚本", category = "脚本合集", group = "脚本列表", description = "弑脚本远程中心", url = "https://raw.githubusercontent.com/FengYu-X/_Hub_/refs/heads/X/sha.lua" },
    { name = "XK脚本", category = "脚本合集", group = "脚本列表", description = "XK 脚本中心，加载前写入 XK 标识", url = "https://raw.githubusercontent.com/XiaoXuAnZang/XKscript/refs/heads/main/XUAN.lua", beforeLoad = function() getgenv().XK = "XK脚本中心" end },
    { name = "ROB脚本", category = "脚本合集", group = "脚本列表", description = "ROB V2 综合脚本", url = "https://raw.githubusercontent.com/Zyb150933/ROB/refs/heads/main/ROB.V2" },
    { name = "lc合集", category = "脚本合集", group = "LC脚本", description = "LC 脚本合集入口", url = "https://pastefy.app/SpHM7OAK/raw" },
    { name = "lcNEX脚本", category = "脚本合集", group = "LC脚本", description = "LC NEX 远程脚本", url = "https://api.jnkie.com/api/v1/luascripts/public/6bd5c94e9da68dce4a2bdf5abd1f6fb9a1379f41faaadbc0354b98d543066f58/download" },

    { name = "死铁轨本熊脚本", category = "游戏", group = "死铁轨", description = "Dead Rails 本熊脚本加载器", url = "https://raw.githubusercontent.com/jbu7666gvv/BHBUO/refs/heads/main/loader" },
    { name = "死铁轨杀戮光环", category = "游戏", group = "死铁轨", description = "Dead Rails 自动挥砍/杀戮光环", url = "https://raw.githubusercontent.com/HeadHarse/Dusty/refs/heads/main/OPAUTOSWINGV2" },
    { name = "死铁轨通用脚本", category = "游戏", group = "死铁轨", description = "Dead Rails 通用加载器", url = "https://getnative.cc/script/loader" },
    { name = "skin阉割版", category = "游戏", group = "内脏与黑火药", description = "内脏与黑火药 skin 阉割版", url = "https://raw.githubusercontent.com/wzhxll/2/refs/heads/main/%E9%98%89%E5%89%B2%E7%89%88.lua" },
    { name = "鲨鱼清水脚本", category = "游戏", group = "内脏与黑火药", description = "内脏与黑火药清水脚本，原十进制 URL 已解析", url = "https://pastefy.app/A3Nqz4Np/raw" },
    { name = "TSB侧闪脚本", category = "游戏", group = "tsb", description = "The Strongest Battlegrounds 侧闪功能", url = "https://api.getpolsec.com/scripts/hosted/94a29c6b88bfe8c49ea221eaa9225398790c1b7436b0f08caf7517c3002e8782.lua" },
    { name = "TSB中心脚本", category = "游戏", group = "tsb", description = "Phantasm TSB 中心脚本", url = "https://raw.githubusercontent.com/ATrainz/Phantasm/refs/heads/main/Games/TSB.lua" },
    { name = "dovi中心（自己解卡）", category = "游戏", group = "tsb", description = "TSB dovi 中心，需自行处理卡密", url = "https://raw.githubusercontent.com/needanewphone32-eng/tsbfiles/refs/heads/main/Main1.lua" },
    { name = "TSB隐身脚本", category = "游戏", group = "tsb", description = "TSB 隐身相关脚本", url = "https://rawscripts.net/raw/The-Strongest-Battlegrounds-SION-ELTNAM-ATLASIA-61168" },
    { name = "Abysall Hub脚本（免卡）", category = "游戏", group = "doors", description = "DOORS Abysall Hub，免卡入口", url = "https://raw.githubusercontent.com/XxwanhexxX/doors-zh/refs/heads/main/Abysall.Hub" },
    { name = "ms脚本（最强绕过，功能最多，要解卡）", category = "游戏", group = "doors", description = "DOORS ms 脚本，功能多，需解卡", url = "https://api.luarmor.net/files/v3/loaders/002c19202c9946e6047b0c6e0ad51f84.lua" },
    { name = "暴力区", category = "游戏", group = "暴力区", description = "暴力区游戏脚本", url = "https://raw.githubusercontent.com/Pandu-Hub12/rosblox/refs/heads/main/violence" },
    { name = "evade", category = "游戏", group = "evade", description = "Evade 游戏脚本", url = "https://raw.githubusercontent.com/sccv8/Whakizashix/refs/heads/main/old%20whakizashi.txt" },
    { name = "被遗弃（最强绕过）", category = "游戏", group = "被遗弃", description = "Forsaken/被遗弃绕过脚本", url = "https://raw.githubusercontent.com/aibabylaugh/catsaken-real-script-not-assets/refs/heads/main/obfuscated-1448974601077002340.lua" },
    { name = "被遗弃脚本（修机延迟改5）", category = "游戏", group = "被遗弃", description = "被遗弃修机相关脚本，提示延迟改 5", url = "https://raw.githubusercontent.com/LolnotaKid/project/refs/heads/main/AutoBLOCKKKWAHV1" },
    { name = "监狱人生脚本", category = "游戏", group = "监狱人生", description = "Prison Life 监狱人生脚本", url = "https://raw.githubusercontent.com/zenss555a/script/refs/heads/main/Prison-Life.lua" },
    { name = "血与铁静默自瞄脚本", category = "游戏", group = "血与铁", description = "血与铁静默自瞄，原十进制 URL 已解析", url = "https://raw.githubusercontent.com/sleenndn/Matds/refs/heads/main/bi2.0" },
    { name = "墨水游戏1", category = "游戏", group = "墨水游戏", description = "墨水游戏脚本 1", url = "https://raw.githubusercontent.com/hdjsjjdgrhj/OK/refs/heads/main/sb" },
    { name = "墨水游戏2", category = "游戏", group = "墨水游戏", description = "墨水游戏汉化脚本 2", url = "https://raw.githubusercontent.com/QQ161475237/IDK/main/HX%E6%B1%89%E5%8C%96.txt" },
    { name = "墨水游戏2永久卡密", category = "游戏", group = "墨水游戏", description = "点击复制永久卡密到剪贴板", copyText = "HSX-7562-3194-0835-4981-2470-1488-1029-6967" },

    { name = "动作脚本", category = "娱乐", group = "表情页FE动作", description = "FE 动作/表情脚本", url = "https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua" },
    { name = "ws仿真按键", category = "娱乐", group = "娱乐", description = "移动端 WS 模拟与视角锁定控制面板", callback = "wsControl" },
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local function urlEncode(value)
    return (value:gsub("[^%w%-%._~]", function(char)
        return string.format("%%%02X", string.byte(char))
    end))
end

local function contains(text, value)
    return text:find(value, 1, true) ~= nil
end

local entries = {}
for _, scriptName in ipairs(scripts) do
    local description = descriptions[scriptName] or "未分类脚本，点击按文件名加载"
    entries[#entries + 1] = {
        name = scriptName,
        file = scriptName,
        description = description,
        category = "杂项专区",
        group = "本地脚本",
    }
end

for _, entry in ipairs(externalScripts) do
    entry.category = "杂项专区"
    entries[#entries + 1] = entry
end

local mainScripts = {
    { name = "动物医院脚本", category = "游戏", group = "动物医院", url = "https://raw.githubusercontent.com/caomod2077/Script/main/FN_AnimalHospital.lua" },
    { name = "无卡密动物医院", category = "游戏", group = "动物医院", url = "https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/AnimalHospital" },
    { name = "99夜新脚本", category = "游戏", group = "99夜", url = "https://raw.githubusercontent.com/kyruxv1/final/refs/heads/main/final-99-nitf" },
    { name = "AX Ink Game 汉化", category = "游戏", group = "墨水游戏", url = "https://raw.githubusercontent.com/fningna51-stack/-/main/ax%E8%84%9A%E6%9C%AC%E7%A7%8B%E8%BE%9E%E6%B1%89%E5%8C%96" },
    { name = "最新墨水游戏", category = "游戏", group = "墨水游戏", url = "https://raw.githubusercontent.com/wefwef34/inkgames.github.io/refs/heads/main/ringta.lua" },
    { name = "死铁轨刷债券", category = "游戏", group = "死铁轨", url = "https://raw.githubusercontent.com/erewe23/deadrailsring.github.io/refs/heads/main/ringta.lua" },
    { name = "LC 秒换弹与杀戮光环", category = "游戏", group = "Lexington and Concord", url = "https://rawscripts.net/raw/Lexington-and-Concord-LC-75016" },
    { name = "俄亥俄州脚本", category = "游戏", group = "俄亥俄州", url = "https://pastebin.com/raw/GUmp28kq" },
    { name = "元素力量大亨", category = "游戏", group = "元素力量大亨", url = "https://raw.githubusercontent.com/kichetvip/Script/refs/heads/main/Kiethub-EPT" },
    { name = "可怕的杂货店：夜班", category = "游戏", group = "杂货店夜班", url = "https://gist.githubusercontent.com/fortriftz/b622c2f8346a806a1993ee1c4e216ed7/raw/d41b6c6cc791900e1aadc01a1ab88276031242a9/gistfile1.txt" },
    { name = "新恶魔学脚本", category = "游戏", group = "恶魔学", url = "https://raw.githubusercontent.com/kdkdirjrne/Vgxmod-Hub/refs/heads/main/Loader.lua" },
    { name = "肌肉传奇", category = "游戏", group = "肌肉传奇", url = "https://raw.githubusercontent.com/toxicity-561/Proton-Hub/refs/heads/main/Muscle-Legends.luau" },
    { name = "Ak47脚本", category = "其他", group = "工具", url = "https://raw.githubusercontent.com/sinret/rbxscript.com-scripts-reuploads-/main/ak47" },
    { name = "20个服务器脚本中心", category = "其他", group = "脚本中心", url = "https://raw.githubusercontent.com/fningna51-stack/-/main/AF%20Hun%E8%87%AA%E5%8A%A8%E5%8A%A0%E8%BD%BD" },
    { name = "YX脚本中心", category = "其他", group = "脚本中心", url = "https://raw.githubusercontent.com/YirdeX-Dev/scripts/refs/heads/main/YX-HubLoader.lua" },
    { name = "BS黑洞中心", category = "其他", group = "娱乐", url = "https://gitee.com/BS_script/script/raw/master/BS_Script.Luau" },
    { name = "旧 FE 动作脚本", category = "其他", group = "娱乐", url = "https://raw.githubusercontent.com/Gazer-Ha/Gaze-stuff/refs/heads/main/Fe%20Better%3F%20Movement" },
    { name = "死亡笔记脚本", category = "其他", group = "娱乐", url = "https://pastebin.com/raw/gErHq60M" },
    { name = "FE 杀死所有人", category = "其他", group = "FE", callback = "killAll" },
}
for _, entry in ipairs(mainScripts) do
    entry.description = entry.group .. "专用脚本"
    entries[#entries + 1] = entry
end

local ok, UI = pcall(function()
    return loadstring(game:HttpGet(UI_LIBRARY_URL))()
end)

if not ok or not UI then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "UGIK 加载失败",
            Text = tostring(UI),
            Duration = 5,
        })
    end)
    return
end

local defaultConfig = {
    Theme = "深色", Accent = { 55, 157, 255 }, Transparency = 0,
    Scale = 1, MinimizeMode = "island", Blur = true, Particles = true, Gradient = true, Glass = true,
}
local config = defaultConfig
pcall(function()
    if isfile and isfile("UGIK/config.json") then
        local loaded = HttpService:JSONDecode(readfile("UGIK/config.json"))
        for key, value in pairs(defaultConfig) do if loaded[key] == nil then loaded[key] = value end end
        config = loaded
    end
end)
local function saveConfig()
    pcall(function()
        if makefolder and not isfolder("UGIK") then makefolder("UGIK") end
        if writefile then writefile("UGIK/config.json", HttpService:JSONEncode(config)) end
    end)
end
local accent = Color3.fromRGB(config.Accent[1], config.Accent[2], config.Accent[3])

local Window = UI:CreateWindow({
    Name = "UGIK_Script_Hub",
    Title = "UGIK Script Hub",
    ShortTitle = "UGIK",
    RestoreText = "UG",
    Status = tostring(#entries) .. " 个脚本已就绪",
    Accent = accent,
    MinimizeMode = config.MinimizeMode,
    BackgroundBlur = config.Blur,
    BackgroundParticles = config.Particles,
    BackgroundGradient = config.Gradient,
    LiquidGlass = config.Glass,
})
Window:SetTheme(config.Theme)
Window:SetAccent(accent)
Window:SetScale(config.Scale)
Window:SetTransparency(config.Transparency)

local categoryOrder = { "游戏", "其他", "杂项专区" }
local categoryColors = {
    ["游戏"] = Color3.fromRGB(52, 178, 126),
    ["其他"] = Color3.fromRGB(172, 112, 224),
    ["杂项专区"] = Color3.fromRGB(232, 123, 91),
}
local shortTitles = {
    ["游戏"] = "游",
    ["其他"] = "其",
    ["杂项专区"] = "杂",
}

local gameAliases = {
    ["doors"] = "DOORS",
    ["tsb"] = "最强战场 TSB",
    ["evade"] = "Evade",
    ["被遗弃"] = "被遗弃 Forsaken",
    ["墨水游戏"] = "墨水游戏",
}

local function detectGameName(entry)
    if entry.game then
        return entry.game
    end
    if entry.group and entry.group ~= "本地脚本" then
        return gameAliases[entry.group:lower()] or entry.group
    end

    local text = (entry.name .. " " .. (entry.description or "")):lower()
    if contains(text, "dead rails") or contains(text, "死铁轨") then return "死铁轨" end
    if contains(text, "doors") then return "DOORS" end
    if contains(text, "forsaken") or contains(text, "被遗弃") or contains(text, "fartsaken") then return "被遗弃 Forsaken" end
    if contains(text, "tsb") or contains(text, "终极战场") or contains(text, "phantasm") then return "最强战场 TSB" end
    if contains(text, "blox fruits") or entry.name == "bf.txt" then return "Blox Fruits" end
    if contains(text, "七日") then return "七日生存" end
    if contains(text, "战争大亨") then return "战争大亨" end
    if contains(text, "红木") then return "红木监狱" end
    if contains(text, "监狱") then return "监狱人生" end
    if contains(text, "墨水") then return "墨水游戏" end
    if contains(text, "暴力") then return "暴力区" end
    if contains(text, "evade") then return "Evade" end
    if contains(text, "方块故事") then return "方块故事" end
    if contains(text, "跳跃对决") then return "跳跃对决" end
    if contains(text, "铁拳") then return "铁拳" end
    if contains(text, "军区") then return "军区" end
    if contains(text, "aut/") then return "AUT" end
    return "其他游戏"
end

local counts = {}
local gameCounts = {}
local gameOrder = {}
for _, category in ipairs(categoryOrder) do
    counts[category] = 0
end
for _, entry in ipairs(entries) do
    counts[entry.category] = (counts[entry.category] or 0) + 1
    if entry.category == "游戏" then
        entry.game = detectGameName(entry)
        if not gameCounts[entry.game] then
            gameCounts[entry.game] = 0
            gameOrder[#gameOrder + 1] = entry.game
        end
        gameCounts[entry.game] = gameCounts[entry.game] + 1
    end
end

local panels = {}
local camera = workspace.CurrentCamera
local viewportWidth = camera and camera.ViewportSize.X or 1280
local visiblePanelLimit = UserInputService.TouchEnabled and 1
    or math.max(1, math.min(3, math.floor((viewportWidth - 194) / 306)))
for index, category in ipairs(categoryOrder) do
    panels[category] = Window:CreatePanel({
        Title = category,
        ShortTitle = shortTitles[category],
        Subtitle = tostring(counts[category] or 0) .. " scripts",
        Accent = categoryColors[category],
        Search = true,
        SearchPlaceholder = "搜索" .. category .. "脚本...",
        Visible = index <= visiblePanelLimit,
    })
end

local settingsPanel = Window:CreatePanel({
    Title = "界面设置",
    ShortTitle = "设置",
    Subtitle = "外观与提示",
    Accent = Color3.fromRGB(55, 157, 255),
    Search = false,
    Visible = false,
    Width = 280,
    Height = 360,
})

settingsPanel:AddDropdown({
    Title = "最小化方式",
    Values = { "灵动岛", "悬浮按钮" },
    Default = config.MinimizeMode == "button" and "悬浮按钮" or "灵动岛",
    Callback = function(value)
        config.MinimizeMode = value == "灵动岛" and "island" or "button"
        Window:SetMinimizeMode(config.MinimizeMode)
        saveConfig()
        Window:Notify("界面设置", "最小化方式已切换为" .. value, 3)
    end,
})

settingsPanel:AddDropdown({
    Title = "主题",
    Values = { "深色", "浅色", "霓虹" },
    Default = config.Theme,
    Callback = function(value)
        config.Theme = value
        Window:SetTheme(value)
        saveConfig()
    end,
})

settingsPanel:AddInput({
    Title = "强调色 RGB",
    Default = table.concat(config.Accent, ","),
    Placeholder = "55,157,255",
    Callback = function(value, enterPressed)
        if not enterPressed then return end
        local r, g, b = value:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
        if not r then Window:Notify("颜色格式错误", "请输入 R,G,B", 3) return end
        config.Accent = { math.clamp(tonumber(r), 0, 255), math.clamp(tonumber(g), 0, 255), math.clamp(tonumber(b), 0, 255) }
        Window:SetAccent(Color3.fromRGB(config.Accent[1], config.Accent[2], config.Accent[3]))
        saveConfig()
    end,
})

settingsPanel:AddSlider({
    Title = "界面透明度", Min = 0, Max = 65, Step = 5, Default = math.floor(config.Transparency * 100),
    Callback = function(value)
        config.Transparency = value / 100
        Window:SetTransparency(config.Transparency)
        saveConfig()
    end,
})

settingsPanel:AddSlider({
    Title = "UI 缩放", Min = 70, Max = 130, Step = 5, Default = math.floor(config.Scale * 100),
    Callback = function(value)
        config.Scale = value / 100
        Window:SetScale(config.Scale)
        saveConfig()
    end,
})

settingsPanel:AddToggle({
    Title = "背景模糊",
    Default = config.Blur,
    Callback = function(enabled)
        config.Blur = enabled
        saveConfig()
        Window:SetBackdropEffects({ Blur = enabled })
    end,
})

settingsPanel:AddToggle({
    Title = "蓝色粒子",
    Default = config.Particles,
    Callback = function(enabled)
        config.Particles = enabled
        saveConfig()
        Window:SetBackdropEffects({ Particles = enabled })
    end,
})

settingsPanel:AddToggle({
    Title = "动态渐变",
    Default = config.Gradient,
    Callback = function(enabled)
        config.Gradient = enabled
        saveConfig()
        Window:SetBackdropEffects({ Gradient = enabled })
    end,
})

settingsPanel:AddToggle({
    Title = "液态玻璃",
    Default = config.Glass,
    Callback = function(enabled)
        config.Glass = enabled
        Window:SetLiquidGlass(enabled)
        saveConfig()
    end,
})

settingsPanel:AddButton({
    Title = "测试右下角提示",
    Description = "显示一条 4 秒自定义提示",
    ActionText = ">",
    Callback = function()
        Window:Notify("UGIK 提示", "右下角提示系统工作正常", 4, Color3.fromRGB(55, 157, 255))
    end,
})

local importBox = settingsPanel:AddInput({ Title = "导入配置", Placeholder = "粘贴 JSON 后回车" })
settingsPanel:AddButton({
    Title = "导出配置", Description = "复制当前配置 JSON", ActionText = "复制",
    Callback = function()
        local text = HttpService:JSONEncode(config)
        if setclipboard then setclipboard(text) end
        Window:Notify("配置已导出", "JSON 已复制", 3)
    end,
})
settingsPanel:AddButton({
    Title = "应用导入配置", ActionText = ">",
    Callback = function()
        local success, loaded = pcall(HttpService.JSONDecode, HttpService, importBox.Text)
        if not success then Window:Notify("导入失败", "JSON 格式错误", 4) return end
        config = loaded
        saveConfig()
        Window:Notify("配置已导入", "重新执行 Loader 后生效", 4)
    end,
})
settingsPanel:AddButton({
    Title = "恢复默认配置", ActionText = ">",
    Callback = function()
        config = { Theme = "深色", Accent = { 55, 157, 255 }, Transparency = 0, Scale = 1, MinimizeMode = "island", Blur = true, Particles = true, Gradient = true, Glass = true }
        saveConfig()
        Window:Notify("已恢复默认", "重新执行 Loader 后生效", 4)
    end,
})

local musicPanel = Window:CreatePanel({
    Title = "网易云音乐",
    ShortTitle = "音乐",
    Subtitle = "搜索与播放",
    Accent = Color3.fromRGB(224, 72, 82),
    Search = false,
    Visible = false,
    Width = 300,
    Height = 520,
})

local musicOk, MusicLibrary = pcall(function()
    return loadstring(game:HttpGet(MUSIC_LIBRARY_URL))()
end)
local music
local lyricView
if musicOk and MusicLibrary then
    music = MusicLibrary.new({
        Api = "https://wy.rwcdh.dpdns.org",
        Volume = 0.5,
        OnStatus = function(message, isError)
            Window:SetStatus(message, isError and Color3.fromRGB(242, 91, 103) or Color3.fromRGB(76, 205, 142))
        end,
        OnLyric = function(lines, currentIndex)
            if lyricView then lyricView:SetLines(lines, currentIndex) end
        end,
        OnSong = function()
            if lyricView then lyricView:SetLines({ { text = "正在获取歌词..." } }, 1) end
        end,
    })
end

local searchBox = musicPanel:AddInput({ Title = "搜索歌曲", Placeholder = "歌曲名或歌手" })
local resultIndexes = {}
local selectedIndex = 1
local resultDropdown = musicPanel:AddDropdown({
    Title = "搜索结果",
    Values = { "请先搜索" },
    Callback = function(value)
        selectedIndex = resultIndexes[value] or 1
    end,
})

musicPanel:AddButton({
    Title = "搜索", Description = "从网易云搜索前 10 条单曲", ActionText = ">",
    Callback = function()
        if not music then Window:Notify("音乐库加载失败", tostring(MusicLibrary), 5) return end
        task.spawn(function()
            local success, results = pcall(music.Search, music, searchBox.Text, 10)
            if not success then Window:Notify("搜索失败", tostring(results), 5) return end
            local labels = {}
            resultIndexes = {}
            for index, song in ipairs(results) do
                local label = song.name .. " - " .. song.artist
                labels[#labels + 1] = label
                resultIndexes[label] = index
            end
            resultDropdown:SetValues(labels)
            selectedIndex = 1
            Window:Notify("搜索完成", tostring(#labels) .. " 条结果", 3)
        end)
    end,
})

musicPanel:AddButton({
    Title = "播放所选歌曲", ActionText = ">",
    Callback = function()
        if not music then return end
        task.spawn(function()
            local success, message = pcall(music.Play, music, selectedIndex)
            if not success then Window:Notify("播放失败", tostring(message), 5) end
        end)
    end,
})
musicPanel:AddButton({ Title = "播放 / 暂停", Callback = function() if music then music:TogglePause() end end })
musicPanel:AddButton({ Title = "上一首", Callback = function() if music then task.spawn(function() pcall(music.Previous, music) end) end end })
musicPanel:AddButton({ Title = "下一首", Callback = function() if music then task.spawn(function() pcall(music.Next, music) end) end end })
musicPanel:AddSlider({ Title = "音量", Min = 0, Max = 100, Step = 5, Default = 50, Callback = function(value) if music then music:SetVolume(value / 100) end end })
musicPanel:AddSlider({ Title = "播放进度", Min = 0, Max = 100, Step = 5, Default = 0, Callback = function(value) if music then music:Seek(value / 100) end end })
musicPanel:AddDropdown({ Title = "循环模式", Values = { "列表循环", "单曲循环", "顺序播放" }, Default = "列表循环", Callback = function(value) if music then music:SetLoopMode(value) end end })

local localDirectory = musicPanel:AddInput({
    Title = "本地歌曲目录",
    Default = "/storage/emulated/0/Delta/Workspace/UGIK/myself",
    Placeholder = "输入 Delta Workspace 目录",
})
local localIndexes = {}
local selectedLocalIndex = 1
local localDropdown = musicPanel:AddDropdown({
    Title = "本地歌曲",
    Values = { "点击扫描本地歌曲" },
    Callback = function(value) selectedLocalIndex = localIndexes[value] or 1 end,
})
musicPanel:AddButton({
    Title = "扫描本地歌曲", Description = "支持 MP3、OGG、WAV、FLAC", ActionText = ">",
    Callback = function()
        if not music then return end
        local success, files = pcall(music.ScanLocal, music, localDirectory.Text)
        if not success then Window:Notify("扫描失败", tostring(files), 5) return end
        local labels = {}
        localIndexes = {}
        for index, entry in ipairs(files) do
            labels[#labels + 1] = entry.name
            localIndexes[entry.name] = index
        end
        localDropdown:SetValues(labels)
        selectedLocalIndex = 1
        Window:Notify("扫描完成", tostring(#labels) .. " 首本地歌曲", 3)
    end,
})
musicPanel:AddButton({
    Title = "播放本地歌曲", ActionText = ">",
    Callback = function()
        if not music then return end
        task.spawn(function()
            local success, message = pcall(music.PlayLocal, music, selectedLocalIndex)
            if not success then Window:Notify("本地播放失败", tostring(message), 5) end
        end)
    end,
})
lyricView = musicPanel:AddScrollingText({ Title = "滚动歌词", Height = 180 })
local currentLyric = ""
musicPanel:AddButton({
    Title = "获取当前歌词", ActionText = ">",
    Callback = function()
        if not music then return end
        task.spawn(function()
            local success, lyric = pcall(music.GetLyric, music)
            currentLyric = success and lyric or ("歌词获取失败: " .. tostring(lyric))
            if success then
                music:SetLyricText(lyric)
            else
                lyricView:SetLines({ { text = currentLyric } }, 1)
            end
        end)
    end,
})
musicPanel:AddButton({
    Title = "复制完整歌词", ActionText = "复制",
    Callback = function()
        if setclipboard and currentLyric ~= "" then
            setclipboard(currentLyric)
            Window:Notify("歌词已复制", "完整歌词已写入剪贴板", 3)
        end
    end,
})

local gamePanels = {}
for index, gameName in ipairs(gameOrder) do
    local gamePanel = Window:CreatePanel({
        Title = gameName,
        ShortTitle = tostring(index),
        Subtitle = tostring(gameCounts[gameName]) .. " scripts",
        Accent = categoryColors["游戏"],
        Search = true,
        SearchPlaceholder = "搜索" .. gameName .. "脚本...",
        ShowInDock = false,
        Visible = false,
    })
    gamePanels[gameName] = gamePanel

    panels["游戏"]:AddButton({
        Title = gameName,
        Description = tostring(gameCounts[gameName]) .. " 个专用脚本",
        SearchText = gameName,
        ActionText = ">",
        Callback = function()
            gamePanel:SetVisible(true)
        end,
    })
end

local busy = false
local wsPanel

local function copyToClipboard(value)
    local copied = pcall(function()
        if setclipboard then
            setclipboard(value)
        else
            game:GetService("StarterGui"):SetCore("CopyToClipboard", { Text = value })
        end
    end)
    if copied then
        Window:Notify("复制成功", "内容已复制到剪贴板", 2)
    else
        Window:Notify("复制失败", "请手动复制: " .. value, 4)
    end
end

local function openWsControl()
    if wsPanel then
        wsPanel:SetVisible(true)
        return
    end

    wsPanel = Window:CreatePanel({
        Title = "WS 移动控制",
        ShortTitle = "WS",
        Subtitle = "速度与视角",
        Accent = Color3.fromRGB(238, 170, 69),
        Search = false,
        Width = 270,
        Height = 230,
    })
    wsPanel:SetVisible(true)

    local player = Players.LocalPlayer
    local character
    local rootPart
    local humanoid
    local wsEnabled = false
    local lockEnabled = false
    local wsGeneration = 0

    local function updateCharacter(newCharacter)
        character = newCharacter or player.Character
        if character then
            rootPart = character:FindFirstChild("HumanoidRootPart")
            humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.AutoRotate = not lockEnabled
            end
        end
    end
    updateCharacter()
    player.CharacterAdded:Connect(function(newCharacter)
        task.wait(0.3)
        updateCharacter(newCharacter)
    end)

    local function startWsLoop()
        wsGeneration = wsGeneration + 1
        local generation = wsGeneration
        task.spawn(function()
            local direction = 1
            while wsEnabled and generation == wsGeneration do
                local camera = workspace.CurrentCamera
                if rootPart and camera then
                    local look = camera.CFrame.LookVector
                    local flat = Vector3.new(look.X, 0, look.Z)
                    if flat.Magnitude > 0.01 then
                        rootPart.Velocity = flat.Unit * direction * 30
                        direction = -direction
                    end
                end
                task.wait(0.1)
            end
            if rootPart and generation == wsGeneration then
                rootPart.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    end

    wsPanel:AddToggle({
        Title = "WS 仿真移动",
        Callback = function(enabled)
            wsEnabled = enabled
            if enabled then
                startWsLoop()
            else
                wsGeneration = wsGeneration + 1
                if rootPart then
                    rootPart.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end,
    })

    wsPanel:AddToggle({
        Title = "视角方向锁定",
        Callback = function(enabled)
            lockEnabled = enabled
            UserInputService.MouseBehavior = enabled and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
            if humanoid then
                humanoid.AutoRotate = not enabled
            end
        end,
    })

    wsPanel:AddLabel("移动速度固定为 30，每 0.1 秒切换前后方向。")

    RunService.RenderStepped:Connect(function()
        if not lockEnabled or not rootPart or not humanoid or not workspace.CurrentCamera then
            return
        end
        local look = workspace.CurrentCamera.CFrame.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0.01 then
            rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + flat.Unit)
        end
    end)
end

local function runEntry(entry)
    if entry.copyText then
        copyToClipboard(entry.copyText)
        return
    end
    if entry.callback == "wsControl" then
        openWsControl()
        return
    end
    if entry.callback == "killAll" then
        local event = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
        event = event and event:FindFirstChild("KillEvent")
        if event then event:FireServer() else Window:Notify("运行失败", "当前游戏没有 KillEvent", 4) end
        return
    end
    if busy then
        Window:SetStatus("已有脚本正在加载", Color3.fromRGB(245, 183, 76))
        return
    end

    busy = true
    Window:SetStatus("加载中: " .. entry.name, Color3.fromRGB(76, 184, 255))
    task.spawn(function()
        local url = entry.url or (BASE_URL .. urlEncode(entry.file or entry.name))
        local loaded, result = pcall(function()
            if entry.beforeLoad then
                entry.beforeLoad()
            end
            return loadstring(game:HttpGet(url))()
        end)
        if loaded then
            Window:SetStatus("已加载: " .. entry.name, Color3.fromRGB(76, 205, 142))
        else
            Window:SetStatus("加载失败: " .. tostring(result), Color3.fromRGB(242, 91, 103))
            Window:Notify("脚本加载失败", entry.name, 3)
        end
        busy = false
    end)
end

local function addEntryButton(panel, entry)
    local group = entry.group and ("[" .. entry.group .. "] ") or ""
    panel:AddButton({
        Title = entry.name,
        Description = group .. (entry.description or "点击运行脚本"),
        SearchText = entry.category .. " " .. (entry.group or ""),
        ActionText = entry.copyText and "复制" or ">",
        Callback = function()
            runEntry(entry)
        end,
    })
end

for _, entry in ipairs(entries) do
    local currentEntry = entry
    local categoryPanel = entry.category == "游戏" and gamePanels[entry.game]
        or panels[entry.category]
        or panels["其他"]
    addEntryButton(categoryPanel, currentEntry)
end

Window:Notify("UGIK", tostring(#entries) .. " 个脚本已按分类载入", 2)
