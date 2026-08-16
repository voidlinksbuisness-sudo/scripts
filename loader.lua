-- FFTM Matcha loader - presets + keybinds, explicit dependency injection
print("[FFTM] Loader build: 2026-08-13-MATCHA-EXPLICIT-DEPS-1")

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

-- ============================================================
-- MATCHA-SAFE SPLIT LOADER
-- ============================================================
-- The old loader concatenated every dependency + main into one enormous
-- chunk. Each source compiles on its own, but Matcha can choke on the
-- combined parser/register state. Instead:
--
--   1. AnimationTracker executes separately and exposes _G.AnimationTracker.
--   2. ESP Utility executes separately and exposes _G.ESP_Utility.
--   3. GameConfig executes in a tiny wrapper and is saved to _G.__FFTM_GameConfig.
--   4. Main executes separately with those globals copied to locals INSIDE
--      the same Main chunk, so nested Main functions capture them normally.
--
-- This avoids relying on cross-loadstring return values.

local function CompileAndRun(name, source)
    print("[FFTM] Compiling " .. name .. "...")

    local chunk = loadstring(source)

    if not chunk then
        warn("[FFTM Loader] " .. name .. " compile failed.")
        return false
    end

    local ok, err = pcall(chunk)

    if not ok then
        warn("[FFTM Loader] " .. name .. " runtime failed: " .. tostring(err))
        return false
    end

    print("[FFTM] " .. name .. " loaded.")
    return true
end


-- ------------------------------------------------------------
-- AnimationTracker
-- ------------------------------------------------------------
if not CompileAndRun("AnimationTracker", animationSource) then
    return
end

if type(_G.AnimationTracker) ~= "table"
    or type(_G.AnimationTracker.new) ~= "function" then

    warn("[FFTM Loader] AnimationTracker did not expose _G.AnimationTracker.")
    return
end


-- ------------------------------------------------------------
-- ESP Utility
-- ------------------------------------------------------------
if not CompileAndRun("ESP Utility", espSource) then
    return
end

if type(_G.ESP_Utility) ~= "table"
    or type(_G.ESP_Utility.NewTracker) ~= "function" then

    warn("[FFTM Loader] ESP Utility did not expose _G.ESP_Utility.")
    return
end


-- ------------------------------------------------------------
-- GameConfig
-- ------------------------------------------------------------
-- game_config.lua returns its table, so capture that result entirely INSIDE
-- this small chunk and move it into _G. This avoids depending on Matcha
-- preserving a return value between separate host loadstring calls.
local gameConfigWrapper =
    "_G.__FFTM_GameConfig = (function()\n"
    .. gameConfigSource
    .. "\nend)()\n"
    .. "if type(_G.__FFTM_GameConfig) ~= 'table' then "
    .. "error('[FFTM] GameConfig wrapper did not produce a table') end\n"

if not CompileAndRun("Game Config", gameConfigWrapper) then
    return
end

if type(_G.__FFTM_GameConfig) ~= "table" then
    warn("[FFTM Loader] Game Config global is missing after load.")
    return
end


-- ------------------------------------------------------------
-- Main
-- ------------------------------------------------------------
-- These dependency locals are declared in the EXACT SAME chunk as mainSource.
-- Therefore functions declared inside fftm_main.lua capture them normally.
local mainWrapper =
    "local AnimationTrackerClass = _G.AnimationTracker\n"
    .. "local ESP_Utility = _G.ESP_Utility\n"
    .. "local GameConfig = _G.__FFTM_GameConfig\n"
    .. "\n"
    .. mainSource

print("[FFTM] Compiling Main with split global dependencies...")

local mainChunk = loadstring(mainWrapper)

if not mainChunk then
    warn("[FFTM Loader] Main compile failed.")
    return
end

local ok, runError = pcall(mainChunk)

if not ok then
    warn("[FFTM Loader] Main runtime failed: " .. tostring(runError))
    return
end

print("[FFTM] Full build loaded successfully (split-loader mode).")
