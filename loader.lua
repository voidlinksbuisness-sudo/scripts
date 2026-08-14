-- FFTM Matcha loader - no hitbox visualizer
print("[FFTM] Loader build: 2026-08-13-MATCHA-PRESETS-FIX-2")

local URLS = {
    AnimationTracker = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/animationtracker(1).lua",
    ESPUtility = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/esp_utility(1).lua",
    GameConfig = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/game_config.lua",
    Main = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/fftm_main.lua",
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

    print("[FFTM] Downloaded " .. name)
    return source
end

local animationSource =
    FetchSource("AnimationTracker", URLS.AnimationTracker)

if animationSource == nil then
    return
end

local espSource =
    FetchSource("ESP Utility", URLS.ESPUtility)

if espSource == nil then
    return
end

local gameConfigSource =
    FetchSource("Game Config", URLS.GameConfig)

if gameConfigSource == nil then
    return
end

local mainSource =
    FetchSource("Main", URLS.Main)

if mainSource == nil then
    return
end

-- Matcha does not reliably preserve return values/globals between separate
-- loadstring chunks. Put all three modules and main into ONE compiled chunk.
--
-- Each dependency gets its own function scope so its `return` works normally.
-- Main also gets its own named function scope to avoid Matcha's local-register
-- limit and the ambiguous-IIFE parser issue.
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

    .. "local function __FFTM_RUN_MAIN()\n"
    .. mainSource
    .. "\nend\n\n"

    .. "__FFTM_RUN_MAIN()\n"

print("[FFTM] Compiling single-chunk core (hitbox visualizer removed)...")

local chunk, compileError =
    loadstring(compositeSource)

if not chunk then
    warn(
        "[FFTM Loader] Compile failed: "
        .. tostring(compileError)
    )
    return
end

local ok, runError =
    pcall(chunk)

if not ok then
    warn(
        "[FFTM Loader] Runtime failed: "
        .. tostring(runError)
    )
    return
end

print("[FFTM] Full build loaded successfully.")
