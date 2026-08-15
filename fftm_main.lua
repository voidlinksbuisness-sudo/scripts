-- FFTM fresh Matcha loader
-- BUILD: 2026-08-14-MATCHA-FRESH-CACHE-BUST-2

print("[FFTM] Loader build: 2026-08-14-MATCHA-FRESH-CACHE-BUST-2")

local CACHE_BUST = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local URLS = {
    AnimationTracker = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/animationtracker(1).lua",
    ESPUtility       = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/esp_utility(1).lua",
    GameConfig       = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/game_config.lua",
    Main             = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/fftm_main.lua",
}

local function FetchFresh(label, url)
    local finalUrl = url .. "?fftm_cb=" .. CACHE_BUST .. "-" .. label

    local ok, body = pcall(function()
        return game:HttpGet(finalUrl, true)
    end)

    if not ok or type(body) ~= "string" or #body == 0 then
        error("[FFTM] Failed to download " .. label .. ": " .. tostring(body))
    end

    print("[FFTM] Downloaded " .. label .. " (" .. tostring(#body) .. " bytes)")
    return body
end

local animationSource = FetchFresh("AnimationTracker", URLS.AnimationTracker)
local espSource = FetchFresh("ESP Utility", URLS.ESPUtility)
local configSource = FetchFresh("Game Config", URLS.GameConfig)
local mainSource = FetchFresh("Main", URLS.Main)

-- Refuse to run the stale whitelist build.
if string.find(mainSource, "GetPlayerFromCharacter", 1, true) then
    error(
        "[FFTM] STALE MAIN DETECTED: downloaded fftm_main.lua still contains "
        .. "GetPlayerFromCharacter. Replace the GitHub file with the MATCHA-2 build."
    )
end

local buildMarker =
    string.match(mainSource, 'FFTM_MAIN_BUILD%s*=%s*"([^"]+)"')

print(
    "[FFTM] Main build detected: "
    .. tostring(buildMarker or "NO_BUILD_MARKER")
)

local composite = [[
local __AnimationTrackerClass = (function()
]] .. animationSource .. [[
end)()

local __ESP_Utility = (function()
]] .. espSource .. [[
end)()

local __GameConfig = (function()
]] .. configSource .. [[
end)()

local function __FFTM_RUN_MAIN(AnimationTrackerClass, ESP_Utility, GameConfig)
]] .. mainSource .. [[
end

__FFTM_RUN_MAIN(__AnimationTrackerClass, __ESP_Utility, __GameConfig)
]]

print("[FFTM] Compiling fresh single-chunk core...")

local chunk, compileErr = loadstring(composite)

if not chunk then
    error("[FFTM] Compile failed: " .. tostring(compileErr))
end

local ok, runtimeErr = pcall(chunk)

if not ok then
    error("[FFTM] Runtime failed: " .. tostring(runtimeErr))
end

print("[FFTM] Full build loaded successfully.")
