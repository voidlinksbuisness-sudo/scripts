-- FFTM loader

local URLS = {
    AnimationTracker = "https://github.com/voidlinksbuisness-sudo/scripts/raw/refs/heads/main/animationtracker(1).lua",
    ESPUtility = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/esp_utility(1).lua",
    Main = "https://github.com/voidlinksbuisness-sudo/scripts/raw/refs/heads/main/fftm_main.lua",
    GameConfig = "https://github.com/voidlinksbuisness-sudo/scripts/raw/refs/heads/main/game_config.lua",
}

getgenv().FFTM_URLS = URLS

local function LoadURL(name, url)
    print("[FFTM] Loading " .. name .. "...")

    local success, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        error("[FFTM] Failed to download " .. name .. ": " .. tostring(source))
    end

    local chunk, compileError = loadstring(source)

    if not chunk then
        error("[FFTM] Failed to compile " .. name .. ": " .. tostring(compileError))
    end

    local ok, result = pcall(chunk)

    if not ok then
        error("[FFTM] " .. name .. " crashed: " .. tostring(result))
    end

    print("[FFTM] Loaded " .. name)

    return result
end

-- Load dependencies first
getgenv().AnimationTrackerClass = LoadURL(
    "AnimationTracker",
    URLS.AnimationTracker
)

getgenv().ESP_Utility = LoadURL(
    "ESP Utility",
    URLS.ESPUtility
)

getgenv().GameConfig = LoadURL(
    "Game Config",
    URLS.GameConfig
)

-- Load main last
LoadURL(
    "Main",
    URLS.Main
)

print("[FFTM] Everything loaded successfully.")
