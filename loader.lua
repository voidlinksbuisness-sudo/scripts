-- FFTM Matcha single-chunk loader
-- All remote Lua sources are combined and executed in ONE loadstring chunk.

local URLS = {
    AnimationTracker = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/animationtracker(1).lua",
    ESPUtility = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/esp_utility(1).lua",
    GameConfig = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/game_config.lua",
    HitboxVisualizer = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/visual%20box",
    Main = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/fftm_main.lua",
}

local function FetchSource(name, url)
    if type(url) ~= "string" or url == "" then
        error("[FFTM Loader] Missing URL for " .. tostring(name))
    end

    local separator = string.find(url, "?", 1, true) and "&" or "?"
    local requestUrl = url
        .. separator
        .. "fftm_cb="
        .. tostring(os.time())
        .. "_"
        .. tostring(math.random(100000, 999999))

    local ok, source = pcall(function()
        return game:HttpGet(requestUrl)
    end)

    if not ok then
        error("[FFTM Loader] Failed to download " .. name .. ": " .. tostring(source))
    end

    if type(source) ~= "string" or source == "" then
        error("[FFTM Loader] Empty response for " .. name)
    end

    if source:match("^%s*404") or source:find("404: Not Found", 1, true) then
        error("[FFTM Loader] URL returned 404 for " .. name .. ": " .. url)
    end

    print("[FFTM] Downloaded " .. name)
    return source
end

local animationSource = FetchSource("AnimationTracker", URLS.AnimationTracker)
local espSource = FetchSource("ESP Utility", URLS.ESPUtility)
local gameConfigSource = FetchSource("Game Config", URLS.GameConfig)
local hitboxSource = FetchSource("Hitbox Visualizer", URLS.HitboxVisualizer)
local mainSource = FetchSource("Main", URLS.Main)

local compositeSource =
    "local AnimationTrackerClass = (function()\n"
    .. animationSource
    .. "\nend)()\n\n"
    .. "local ESP_Utility = (function()\n"
    .. espSource
    .. "\nend)()\n\n"
    .. "local GameConfig = (function()\n"
    .. gameConfigSource
    .. "\nend)()\n\n"
    .. "local HitboxVisualizer = (function()\n"
    .. hitboxSource
    .. "\nend)()\n\n"
    .. "-- ===== FFTM MAIN =====\n"
    .. mainSource

print("[FFTM] Compiling single-chunk build...")

local chunk, compileError = loadstring(compositeSource)

if not chunk then
    error("[FFTM Loader] Combined compile failed: " .. tostring(compileError))
end

local ok, runError = pcall(chunk)

if not ok then
    error("[FFTM Loader] Combined runtime failed: " .. tostring(runError))
end

print("[FFTM] Single-chunk build loaded successfully.")
