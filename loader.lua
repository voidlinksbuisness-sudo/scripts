-- FFTM Matcha loader - split compile + cache bust + clean output

local URLS = {
    AnimationTracker = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/main/animationtracker(1).lua",
    ESPUtility = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/main/esp_utility(1).lua",
    GameConfig = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/main/game_config.lua",
    Main = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/main/fftm_main.lua",
}

local function FetchSource(name, url)
    local separator = string.find(url, "?", 1, true) and "&" or "?"

    local requestUrl =
        url
        .. separator
        .. "fftm_cb="
        .. tostring(os.time())
        .. "_"
        .. tostring(math.random(100000, 999999))

    local ok, source = pcall(function()
        return game:HttpGet(requestUrl)
    end)

    if not ok then
        warn("[FFTM Loader] Failed to download " .. name .. ": " .. tostring(source))
        return nil
    end

    if type(source) ~= "string" or source == "" then
        warn("[FFTM Loader] Empty response for " .. name)
        return nil
    end

    if source:match("^%s*404")
        or source:find("404: Not Found", 1, true) then

        warn("[FFTM Loader] URL returned 404 for " .. name)
        return nil
    end

    return source
end

local animationSource =
    FetchSource("AnimationTracker", URLS.AnimationTracker)

if not animationSource then
    return
end

local espSource =
    FetchSource("ESP Utility", URLS.ESPUtility)

if not espSource then
    return
end

local gameConfigSource =
    FetchSource("Game Config", URLS.GameConfig)

if not gameConfigSource then
    return
end

local mainSource =
    FetchSource("Main", URLS.Main)

if not mainSource then
    return
end


--==================================================
-- DEPENDENCIES
--==================================================

local dependencySource =
    "local print = function(...) end\n"
    .. "local warn = function(...) end\n"

    .. "local __AnimationTrackerClass = (function()\n"
    .. animationSource
    .. "\nend)()\n\n"

    .. "local __ESP_Utility = (function()\n"
    .. espSource
    .. "\nend)()\n\n"

    .. "local __GameConfig = (function()\n"
    .. gameConfigSource
    .. "\nend)()\n\n"

    .. [[
local __env

if type(getgenv) == "function" then
    __env = getgenv()
else
    __env = _G
end

__env.AnimationTrackerClass = __AnimationTrackerClass
__env.ESP_Utility = __ESP_Utility
__env.GameConfig = __GameConfig
]]


local dependencyChunk, dependencyCompileError =
    loadstring(dependencySource)

if not dependencyChunk then
    warn(
        "[FFTM Loader] Dependency compile failed: "
        .. tostring(dependencyCompileError)
    )
    return
end


local dependencyOk, dependencyRunError =
    pcall(dependencyChunk)

if not dependencyOk then
    warn(
        "[FFTM Loader] Dependency runtime failed: "
        .. tostring(dependencyRunError)
    )
    return
end


--==================================================
-- MAIN
--==================================================

local buildTag =
    mainSource:match(
        'FFTM_MAIN_BUILD%s*=%s*"([^"]+)"'
    )
    or mainSource:match(
        "FFTM_MAIN_BUILD%s*=%s*'([^']+)'"
    )
    or "unknown"


-- Suppress prints/warns from fftm_main.lua itself
local silentMainSource =
    "local print = function(...) end\n"
    .. "local warn = function(...) end\n"
    .. mainSource


local mainChunk, mainCompileError =
    loadstring(silentMainSource)

if not mainChunk then
    warn(
        "[FFTM Loader] Main compile failed: "
        .. tostring(mainCompileError)
    )
    return
end


local mainOk, mainRunError =
    pcall(mainChunk)

if not mainOk then
    warn(
        "[FFTM Loader] Main runtime failed: "
        .. tostring(mainRunError)
    )
    return
end


--==================================================
-- SUCCESS OUTPUT
--==================================================

print("[FFTM] Version: " .. tostring(buildTag))
print("[FFTM] Executed successfully.")
