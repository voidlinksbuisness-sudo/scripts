-- Dueling Grounds split loader
-- Upload dueling_grounds_main.lua and dueling_grounds_config.lua to the same repo.

print("[DG] Loader build: 2026-08-16-RMB-DOUBLE-PARRY-1")

local URLS = {
    AnimationTracker = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/animationtracker(1).lua",
    ESPUtility = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/esp_utility(1).lua",
    GameConfig = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/dueling_grounds_config.lua",
    Main = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/refs/heads/main/dueling_grounds_main.lua",
}

local CACHE_BUST = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local function Fetch(label, url)
    local separator = string.find(url, "?", 1, true) and "&" or "?"
    local finalUrl = url .. separator .. "dg_cb=" .. CACHE_BUST .. "-" .. label

    local ok, body = pcall(function()
        return game:HttpGet(finalUrl)
    end)

    if not ok or type(body) ~= "string" or body == "" then
        error("[DG] Failed to download " .. tostring(label) .. ": " .. tostring(body))
    end

    print("[DG] Downloaded " .. label)
    return body
end

local function Compile(label, source)
    local fn, err = loadstring(source)
    if not fn then
        error("[DG] " .. label .. " compile failed: " .. tostring(err))
    end
    return fn
end

local trackerSource = Fetch("AnimationTracker", URLS.AnimationTracker)
local espSource = Fetch("ESP Utility", URLS.ESPUtility)
local configSource = Fetch("Game Config", URLS.GameConfig)
local mainSource = Fetch("Main", URLS.Main)

print("[DG] Compiling AnimationTracker...")
local trackerFn = Compile("AnimationTracker", trackerSource)
local AnimationTrackerClass = trackerFn()
if type(AnimationTrackerClass) ~= "table" then
    AnimationTrackerClass = _G.AnimationTracker
end
if type(AnimationTrackerClass) ~= "table" or type(AnimationTrackerClass.new) ~= "function" then
    error("[DG] AnimationTracker returned an invalid module.")
end
print("[DG] AnimationTracker loaded.")

print("[DG] Compiling ESP Utility...")
local espFn = Compile("ESP Utility", espSource)
local ESP_Utility = espFn()
if type(ESP_Utility) ~= "table" then
    ESP_Utility = _G.ESP_Utility
end
if type(ESP_Utility) ~= "table" or type(ESP_Utility.NewTracker) ~= "function" then
    error("[DG] ESP Utility returned an invalid module.")
end
print("[DG] ESP Utility loaded.")

print("[DG] Compiling Game Config...")

-- Matcha may lose return values from separate loadstring calls.
-- Wrap the original config source inside a function, call it INSIDE the same
-- compiled chunk, and publish the returned table to _G before the chunk exits.
local wrappedConfigSource =
    "local function __DG_LoadConfig()\n"
    .. configSource
    .. "\nend\n"
    .. "_G.__DG_GameConfig = __DG_LoadConfig()\n"

local configFn = Compile("Game Config", wrappedConfigSource)
configFn()

local GameConfig = _G.__DG_GameConfig

if type(GameConfig) ~= "table" then
    error("[DG] Game Config export failed: expected table, got " .. type(GameConfig))
end

print("[DG] Game Config loaded.")

print("[DG] Compiling Main...")
local prefix = [[
local AnimationTrackerClass = _G.__DG_AnimationTrackerClass
local ESP_Utility = _G.__DG_ESPUtility
local GameConfig = _G.__DG_GameConfig
]]

_G.__DG_AnimationTrackerClass = AnimationTrackerClass
_G.__DG_ESPUtility = ESP_Utility
_G.__DG_GameConfig = GameConfig

local mainFn = Compile("Main", prefix .. "\n" .. mainSource)
mainFn()

print("[DG] Full Dueling Grounds build loaded successfully.")
