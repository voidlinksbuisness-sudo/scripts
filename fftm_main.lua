-- FFTM_MAIN_BUILD = "2026-08-14-X-CONTEXTACTION-FIX-8"
--// WABI SABI UI
loadstring(game:HttpGet("https://scripts.wabisabi.mom/wabi-sabi-ui-lib.lua"))()

local Library = WabiSabi

local Window = Library:CreateWindow({
    Title = "Free Fortnite Cheats TM",
    SubTitle = "v1.1 PRESETS",
    Size = Vector2.new(580, 460),
    Resize = true,
    Theme = "AmethystDark",
})

local Main = Window:AddTab({
    Title = "Main",
    Icon = "house"
})

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local SelectedFolder = nil
local CycleKeybind = Enum.KeyCode.X

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// COLORS
local C = {
    box = Color3.fromRGB(255, 70, 70),
    line = Color3.fromRGB(255, 255, 255),
    health = Color3.fromRGB(0, 255, 0),
}

--// STATE
local state = {
    ESP = false,
    Tracers = false,
    TracerTransparency = 0,

    PlayerHealth = false,
    SelfHealth = false,
}

--// PLAYER HELPERS
local function getRoot(player)
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local SELF_RADIUS = 4

local function nearSelf(pos, myPos)
    if not myPos then
        return false
    end

    local dx = math.abs(pos.X - myPos.X)
    local dy = math.abs(pos.Y - myPos.Y)
    local dz = math.abs(pos.Z - myPos.Z)

    return dx < SELF_RADIUS
        and dy < SELF_RADIUS
        and dz < SELF_RADIUS
end

--// DRAWING POOLS
local espBoxes = {}
local tracerLines = {}
local healthTexts = {}

--// HEALTH CONFIG
local MAX_DISTANCE = 50
local MAX_DISTANCE_SQUARED = MAX_DISTANCE * MAX_DISTANCE

--// SELF HEALTH
local myHealthText = Drawing.new("Text")

myHealthText.Size = 20
myHealthText.Outline = true
myHealthText.Font = Drawing.Fonts.Fortnite
myHealthText.ZIndex = 20
myHealthText.Transparency = 1
myHealthText.Color = C.health
myHealthText.Visible = false
myHealthText.Center = true

--// HEALTH TEXT CREATION
local function makeHealthText()
    local text = Drawing.new("Text")

    text.Size = 20
    text.Outline = true
    text.Font = Drawing.Fonts.Fortnite
    text.ZIndex = 20
    text.Transparency = 1
    text.Color = C.health
    text.Visible = false
    text.Center = true

    return text
end

local function getHealthText(i)
    local text = healthTexts[i]

    if not text then
        text = makeHealthText()
        healthTexts[i] = text
    end

    return text
end

--// CHARACTER CACHE
local characterCache = {}

local function getCharacterData(player)
    local character = player.Character

    if not character then
        return nil, nil
    end

    local data = characterCache[player]

    if not data or data.Character ~= character then
        data = {
            Character = character,
            Humanoid = character:FindFirstChildOfClass("Humanoid"),
            Root = character:FindFirstChild("HumanoidRootPart"),
        }

        characterCache[player] = data
    else
        if not data.Humanoid then
            data.Humanoid = character:FindFirstChildOfClass("Humanoid")
        end

        if not data.Root then
            data.Root = character:FindFirstChild("HumanoidRootPart")
        end
    end

    return data.Humanoid, data.Root
end

--// ESP BOX
local function getEspBox(i)
    local box = espBoxes[i]

    if not box then
        box = Drawing.new("Square")

        box.Filled = false
        box.Thickness = 2
        box.Color = C.box
        box.Transparency = 1
        box.Visible = false
        box.ZIndex = 2

        espBoxes[i] = box
    end

    return box
end

--// TRACER
local function getTracer(i)
    local line = tracerLines[i]

    if not line then
        line = Drawing.new("Line")

        line.Thickness = 2
        line.Color = C.line
        line.Transparency = 1
        line.Visible = false
        line.ZIndex = 1

        tracerLines[i] = line
    end

    return line
end

--// HIDE UNUSED DRAWINGS
local function hidePoolFrom(pool, fromIndex)
    for i = fromIndex, #pool do
        pool[i].Visible = false
    end
end

--// ESP + TRACERS
local function updateEspTracers(players)
    if not state.ESP and not state.Tracers then
        hidePoolFrom(espBoxes, 1)
        hidePoolFrom(tracerLines, 1)
        return
    end

    local viewport = Camera.ViewportSize

    local origin = Vector2.new(
        viewport.X / 2,
        viewport.Y
    )

    local myRoot = getRoot(LocalPlayer)
    local myPos = myRoot and myRoot.Position

    local camPos = Camera.CFrame.Position
    local count = #players

    for i, player in ipairs(players) do
        local box = getEspBox(i)
        local line = getTracer(i)

        local showBox = false
        local showLine = false

        -- Don't draw ESP/tracers on ourselves
        if player ~= LocalPlayer then
            local root = getRoot(player)

            if root then
                local pos = root.Position

                if not nearSelf(pos, myPos) then
                    local screenPos, onScreen = WorldToScreen(pos)

                    if onScreen
                        and screenPos.X >= 0
                        and screenPos.X <= viewport.X
                        and screenPos.Y >= 0
                        and screenPos.Y <= viewport.Y then

                        --// ESP
                        if state.ESP then
                            local dist = (camPos - pos).Magnitude

                            local scale = 1500 / dist

                            if scale > 400 then
                                scale = 400
                            elseif scale < 8 then
                                scale = 8
                            end

                            local size = Vector2.new(
                                scale,
                                scale * 1.5
                            )

                            box.Size = size

                            box.Position = Vector2.new(
                                screenPos.X - size.X / 2,
                                screenPos.Y - size.Y / 2
                            )

                            showBox = true
                        end

                        --// TRACERS
                        if state.Tracers then
                            line.From = origin
                            line.To = screenPos

                            line.Transparency =
                                1 - (state.TracerTransparency / 100)

                            showLine = true
                        end
                    end
                end
            end
        end

        box.Visible = showBox
        line.Visible = showLine
    end

    hidePoolFrom(espBoxes, count + 1)
    hidePoolFrom(tracerLines, count + 1)
end

--// HEALTH ESP
local function updateHealth(players)
    local viewport = Camera.ViewportSize

    --==================================================
    -- SELF HEALTH
    --==================================================

    if state.SelfHealth then
        local myCharacter = LocalPlayer.Character

        local myHumanoid = myCharacter
            and myCharacter:FindFirstChildOfClass("Humanoid")

        if myHumanoid and myHumanoid.Health > 0 then
            myHealthText.Text =
                "+ " .. math.floor(myHumanoid.Health)

            myHealthText.Position = Vector2.new(
                viewport.X / 2,
                viewport.Y / 2
            )

            myHealthText.Visible = true
        else
            myHealthText.Visible = false
        end
    else
        myHealthText.Visible = false
    end

    --==================================================
    -- OTHER PLAYERS
    --==================================================

    if not state.PlayerHealth then
        hidePoolFrom(healthTexts, 1)
        return
    end

    local myCharacter = LocalPlayer.Character

    if not myCharacter then
        hidePoolFrom(healthTexts, 1)
        return
    end

    local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")

    if not myRoot then
        hidePoolFrom(healthTexts, 1)
        return
    end

    local myPosition = myRoot.Position
    local count = 0

    for _, player in ipairs(players) do
        if player ~= LocalPlayer then
            count += 1

            local text = getHealthText(count)
            local humanoid, root = getCharacterData(player)

            local visible = false

            if humanoid
                and root
                and humanoid.Health > 0 then

                local position = root.Position

                local dx = position.X - myPosition.X
                local dy = position.Y - myPosition.Y
                local dz = position.Z - myPosition.Z

                local distanceSquared =
                    dx * dx +
                    dy * dy +
                    dz * dz

                if distanceSquared <= MAX_DISTANCE_SQUARED then
                    local screenPosition, onScreen = WorldToScreen(
                        position + Vector3.new(0, 3, 0)
                    )

                    if onScreen
                        and screenPosition.X >= 0
                        and screenPosition.X <= viewport.X
                        and screenPosition.Y >= 0
                        and screenPosition.Y <= viewport.Y then

                        text.Position = Vector2.new(
                            screenPosition.X,
                            screenPosition.Y
                        )

                        text.Text =
                            "+ " .. math.floor(humanoid.Health)

                        visible = true
                    end
                end
            end

            text.Visible = visible
        end
    end

    -- Hide unused health drawings
    hidePoolFrom(healthTexts, count + 1)
end

--==================================================
-- WABI SABI CONTROLS
--==================================================

local UIToggles = {}

UIToggles.ESP = Main:AddToggle({
    Id = "esp",
    Title = "ESP",
    Default = false,

    Callback = function(value)
        state.ESP = value
        print("ESP:", value)
    end
})

UIToggles.Tracers = Main:AddToggle({
    Id = "tracers",
    Title = "Tracers",
    Default = false,

    Callback = function(value)
        state.Tracers = value
        print("Tracers:", value)
    end
})

Main:AddSlider({
    Id = "tracer_transparency",
    Title = "Tracer Transparency",
    Min = 0,
    Max = 100,
    Default = 0,

    Callback = function(value)
        state.TracerTransparency = value
        print("Tracer Transparency:", value)
    end
})

--// PLAYER HEALTH

UIToggles.PlayerHealth = Main:AddToggle({
    Id = "player_health",
    Title = "Player Health",
    Default = false,

    Callback = function(value)
        state.PlayerHealth = value
        print("Player Health:", value)
    end
})

--// SELF HEALTH

UIToggles.SelfHealth = Main:AddToggle({
    Id = "self_health",
    Title = "Self Health",
    Default = false,

    Callback = function(value)
        state.SelfHealth = value
        print("Self Health:", value)
    end
})

--==================================================
-- GAKURAN DEPENDENCY / STATE BRIDGE
--==================================================

-- Wabi-compatible notification wrapper used by the imported setup.
local function Notify(title, content, duration)
    Library:Notify({
        Title = tostring(title or "Notice"),
        Content = tostring(content or ""),
        Duration = duration or 4
    })
end

-- esp_utility.lua expects a global-style notify(title, content, duration).
if not notify then
    notify = function(content, title, duration)
        Notify(title or "ESP Utility", content or "", duration or 3)
    end
end

local function NewValueControl(defaultValue)
    local control = { Value = defaultValue }

    control.Get = function(...)
        return control.Value
    end

    control.Set = function(value)
        control.Value = value
    end

    return control
end

local IncludeLocalCharacter = false

-- Legacy logger refresh hook. The INS UI version updated text labels here;
-- the Wabi merge keeps the data/cache behavior without those old labels.
local function UpdateClipboardSection()
end

local AutoParryToggle      = NewValueControl(true)
local AutoDodgeToggle      = NewValueControl(true)
local AutoTargetNearest    = NewValueControl(false)
local MultiTarget          = NewValueControl(true)
local HeightToggle         = NewValueControl(true)
local TargetFacingYou      = NewValueControl(false)
local YouFacingTarget      = NewValueControl(true)
local ParryDebugToggle     = NewValueControl(false)
local PingCompensateToggle = NewValueControl(true)
local AutoPlayToggle       = NewValueControl(true)

-- Dependencies are injected as locals by loader.lua into this SAME Lua chunk.
-- This avoids Matcha losing module return values between separate loadstring calls.


print("[FFTM] Single-chunk dependency scope active.")

-- Extra tabs keep the original Wabi Sabi look.
-- All UI calls are guarded so a bad tab object cannot stop the script.
local function SafeAddTab(title, icon)
    local ok, result = pcall(function()
        return Window:AddTab({
            Title = title,
            Icon = icon
        })
    end)

    if ok and result then
        return result
    end

    warn("[UI] Could not create tab '" .. tostring(title) .. "'. Falling back to Main.")
    return Main
end

local function SafeControl(tab, methodName, config)
    local target = tab

    if not target or type(target[methodName]) ~= "function" then
        target = Main
    end

    if not target or type(target[methodName]) ~= "function" then
        warn("[UI] Missing " .. tostring(methodName) .. " for control: " .. tostring(config and config.Title))
        return nil
    end

    local ok, result = pcall(function()
        return target[methodName](target, config)
    end)

    if not ok then
        warn("[UI] " .. tostring(methodName) .. " failed for '" ..
            tostring(config and config.Title) .. "': " .. tostring(result))
        return nil
    end

    return result
end

local function SafeAddToggle(tab, config)
    return SafeControl(tab, "AddToggle", config)
end

local function SafeAddSlider(tab, config)
    return SafeControl(tab, "AddSlider", config)
end

local function SafeAddDropdown(tab, config)
    return SafeControl(tab, "AddDropdown", config)
end

local function SafeAddButton(tab, config)
    return SafeControl(tab, "AddButton", config)
end

local AutoParryTab   = SafeAddTab("Auto Parry", "swords")
local TargetingTab   = SafeAddTab("Targeting", "crosshair")
local ParryConfigTab = SafeAddTab("Parry Config", "settings")
local ConfigTab      = SafeAddTab("Config", "settings")

UIToggles.AutoParry = SafeAddToggle(AutoParryTab, {
    Id = "auto_parry",
    Title = "Auto Parry",
    Default = true,
    Callback = function(value)
        AutoParryToggle.Set(value)
    end
})

UIToggles.AutoDodge = SafeAddToggle(AutoParryTab, {
    Id = "auto_dodge",
    Title = "Auto Dodge / Heavy",
    Default = true,
    Callback = function(value)
        AutoDodgeToggle.Set(value)
    end
})

UIToggles.AutoPlay = SafeAddToggle(AutoParryTab, {
    Id = "auto_play",
    Title = "Auto Play",
    Default = true,
    Callback = function(value)
        AutoPlayToggle.Set(value)
    end
})

UIToggles.ParryDebug = SafeAddToggle(AutoParryTab, {
    Id = "parry_debug",
    Title = "Debug Parry",
    Default = false,
    Callback = function(value)
        ParryDebugToggle.Set(value)
    end
})

UIToggles.AutoTargetNearest = SafeAddToggle(TargetingTab, {
    Id = "auto_target_nearest",
    Title = "Auto Target Nearest",
    Default = false,
    Callback = function(value)
        AutoTargetNearest.Set(value)
    end
})

UIToggles.MultipleTargets = SafeAddToggle(TargetingTab, {
    Id = "multiple_targets",
    Title = "Multiple Targets",
    Default = true,
    Callback = function(value)
        MultiTarget.Set(value)
    end
})

UIToggles.IncludeLocalCharacter = SafeAddToggle(TargetingTab, {
    Id = "include_local_character",
    Title = "Include Local Character",
    Default = false,
    Callback = function(value)
        IncludeLocalCharacter = value
    end
})

UIToggles.TargetFacingYou = SafeAddToggle(TargetingTab, {
    Id = "target_facing_you",
    Title = "Target Facing You",
    Default = false,
    Callback = function(value)
        TargetFacingYou.Set(value)
    end
})

UIToggles.YouFacingTarget = SafeAddToggle(TargetingTab, {
    Id = "you_facing_target",
    Title = "You Facing Target",
    Default = true,
    Callback = function(value)
        YouFacingTarget.Set(value)
    end
})

UIToggles.HeightMultiplier = SafeAddToggle(ParryConfigTab, {
    Id = "height_multiplier",
    Title = "Height Multiplier",
    Default = true,
    Callback = function(value)
        HeightToggle.Set(value)
    end
})

UIToggles.PingCompensation = SafeAddToggle(ParryConfigTab, {
    Id = "ping_compensation",
    Title = "Ping Compensation",
    Default = true,
    Callback = function(value)
        PingCompensateToggle.Set(value)
    end
})

-- Dependencies already exist as locals from loader.lua's combined chunk.
if type(AnimationTrackerClass) ~= "table" or type(AnimationTrackerClass.new) ~= "function" then
    error("[FFTM] AnimationTracker dependency is missing or invalid.")
end

if type(ESP_Utility) ~= "table" or type(ESP_Utility.NewTracker) ~= "function" then
    error("[FFTM] ESP Utility dependency is missing or invalid.")
end

if type(GameConfig) ~= "table" then
    error("[FFTM] GameConfig dependency is missing or invalid.")
end

local AnimationsLoggedCache = {}
local AnimationsLoggedOrder = {}


-- ==========================================
-- Game Configuration
-- ==========================================

local GameName = "Gakuran"

local IgnoreIds = {
73766443218740,111699625251889,85823794654077,99661732639863,106268941365574,109816855387997,122561749929324,129805948180599,
90752347516770,135133599113049,132695091086148,137015026151472,114511731321756,100794890036133,109303037515668,117293898907979,74690341409113,73090768467054,72284079162560,89016181362524,
76945839486275,101161965631044,128307941333158,85931837451298,91352556581859,77911299793653,129335968179665, 122384188141033,
132695766056641,113331696487725,124220338099067,99799500309776,108636808436488,90015977935891,87932588807124,132477488202815,102982320608759,109278619250401,79971841883936,97783129267001,72822821848529,79974955602012,77798715679680,85845666927963,108862846290180,108045962864902,93184693099565,120399899079666,99958962160522,
}

--IgnoreIds = {}


local ParriedAnimation = {"rbxassetid://100773926241456", "rbxassetid://102823909334302", "rbxassetid://96304721384743", "rbxassetid://82979105739696", "rbxassetid://96600699015093",
"rbxassetid://138519505081692",
}
local StunnedAnimation = {"rbxassetid://122541287927198", "rbxassetid://83600639547203", "rbxassetid://80309578200579", "rbxassetid://92787945841620", "rbxassetid://108045962864902", "rbxassetid://104407197874289"}
local ParryingAnimation = {"rbxassetid://118147060185189", "rbxassetid://80135556847061", "rbxassetid://88718564310179"} -- Blocking
local ParryFailed = {"rbxassetid://4210597123"} -- BlockHit

local AutoParryRange = 10
local MaxCycleRange = 20
local ParryWindow = 0.2
local ProbabilityToParry = 100
local DefaultReactionTime = 0.1
local ParryOffset = 0
local BlockHoldTime = 0.27

-- ==========================================
-- PARRY LEARNING / DATABASE
-- ==========================================
-- Point this at the Python server included with this build.
-- Example: "http://192.168.1.50:8787"
local ParryLearning = {
    Enabled = true,
    ApiBase = "https://fftm-parry-api.voidlinksbuisness.workers.dev",
    ApiToken = "fftm_8fJ2kQ9xLm4Vt7Pz1Nc6Ry3Hs0Wd5Ba",
    PingBucketSize = 20,
    MinimumSamples = 3,
    CacheSeconds = 15,
    RequestTimeout = 4,
}

local HttpService = game:GetService("HttpService")
local LearnedTimingCache = {}

local function UrlEncode(value)
    value = tostring(value or "")
    value = value:gsub("\n", "\r\n")
    value = value:gsub("([^%w%-_%.~])", function(char)
        return string.format("%%%02X", string.byte(char))
    end)
    return value
end


local function GetLearningRequestFunction()
    if type(request) == "function" then
        return request
    end

    if type(http_request) == "function" then
        return http_request
    end

    if type(syn) == "table" and type(syn.request) == "function" then
        return syn.request
    end

    return nil
end

local function GetPingBucket(pingMs)
    local size = tonumber(ParryLearning.PingBucketSize) or 20
    local ping = math.max(0, tonumber(pingMs) or 0)
    local lower = math.floor(ping / size) * size
    return lower, lower + size, tostring(lower) .. "-" .. tostring(lower + size)
end

local function GetLearningCacheKey(style, animationId, bucketLabel)
    return tostring(style or "Unknown")
        .. "|"
        .. tostring(animationId or "Unknown")
        .. "|"
        .. tostring(bucketLabel or "Unknown")
end

local function LearningHttp(method, path, body)
    if not ParryLearning.Enabled then
        return nil
    end

    local requestFn = GetLearningRequestFunction()
    if not requestFn then
        return nil
    end

    local headers = {
        ["Accept"] = "application/json",
        ["Authorization"] = "Bearer " .. tostring(ParryLearning.ApiToken or ""),
    }

    if body ~= nil then
        headers["Content-Type"] = "application/json"
    end

    local ok, response = pcall(function()
        return requestFn({
            Url = tostring(ParryLearning.ApiBase) .. path,
            Method = method,
            Headers = headers,
            Body = body and HttpService:JSONEncode(body) or nil,
            Timeout = ParryLearning.RequestTimeout,
        })
    end)

    if not ok or type(response) ~= "table" then
        return nil
    end

    local status = tonumber(response.StatusCode or response.Status or 0) or 0
    if status < 200 or status >= 300 then
        return nil
    end

    local responseBody = response.Body or response.body
    if type(responseBody) ~= "string" or responseBody == "" then
        return {}
    end

    local decodeOk, decoded = pcall(function()
        return HttpService:JSONDecode(responseBody)
    end)

    if decodeOk and type(decoded) == "table" then
        return decoded
    end

    return nil
end

local LearningLookupInFlight = {}

local function GetLearnedTiming(attackConfig, animationId, pingMs)
    if not ParryLearning.Enabled or not attackConfig or not animationId then
        return nil, nil
    end

    local style = attackConfig.Style or "Unknown"
    local _, _, bucketLabel = GetPingBucket(pingMs)
    local cacheKey = GetLearningCacheKey(style, animationId, bucketLabel)
    local cached = LearnedTimingCache[cacheKey]
    local now = os.clock()

    -- IMPORTANT: never perform an HTTP request on the auto-parry hot path.
    -- If we already have a fresh cache entry, use it immediately.
    if cached and (now - cached.FetchedAt) < ParryLearning.CacheSeconds then
        if cached.Found then
            return cached.Timing, cached
        end
        return nil, cached
    end

    -- No fresh cache entry: launch ONE background lookup and immediately
    -- fall back to the normal configured timing for this attack.
    if not LearningLookupInFlight[cacheKey] then
        LearningLookupInFlight[cacheKey] = true

        task.spawn(function()
            local ok, err = pcall(function()
                local path =
                    "/v1/timing?style=" .. UrlEncode(tostring(style))
                    .. "&animation_id=" .. UrlEncode(tostring(animationId))
                    .. "&ping_ms=" .. UrlEncode(tostring(math.floor((tonumber(pingMs) or 0) + 0.5)))

                local result = LearningHttp("GET", path, nil)
                local fetchedAt = os.clock()

                if result and result.found == true
                    and tonumber(result.timing_seconds)
                    and (tonumber(result.sample_count) or 0) >= ParryLearning.MinimumSamples then

                    LearnedTimingCache[cacheKey] = {
                        Found = true,
                        Timing = tonumber(result.timing_seconds),
                        Count = tonumber(result.sample_count) or 0,
                        PingRange = result.ping_range or bucketLabel,
                        FetchedAt = fetchedAt,
                    }

                    print(string.format(
                        "[Learning] Cached %s | %s | %s | %.3fs | samples=%d",
                        tostring(style),
                        tostring(animationId),
                        tostring(result.ping_range or bucketLabel),
                        tonumber(result.timing_seconds),
                        tonumber(result.sample_count) or 0
                    ))
                else
                    LearnedTimingCache[cacheKey] = {
                        Found = false,
                        Count = result and tonumber(result.sample_count) or 0,
                        PingRange = (result and result.ping_range) or bucketLabel,
                        FetchedAt = fetchedAt,
                    }
                end
            end)

            LearningLookupInFlight[cacheKey] = nil

            if not ok then
                -- Learning must NEVER break auto parry.
                warn("[Learning] Background lookup failed; using fallback timing: " .. tostring(err))

                LearnedTimingCache[cacheKey] = {
                    Found = false,
                    Count = 0,
                    PingRange = bucketLabel,
                    FetchedAt = os.clock(),
                }
            end
        end)
    end

    return nil, {
        Found = false,
        Count = cached and cached.Count or 0,
        PingRange = bucketLabel,
        FetchedAt = now,
        Pending = true,
    }
end

local function SubmitSuccessfulParry(attackConfig, animationId, timingSeconds, pingMs)
    if not ParryLearning.Enabled
        or not attackConfig
        or not animationId
        or type(timingSeconds) ~= "number" then
        return
    end

    local lower, upper, bucketLabel = GetPingBucket(pingMs)
    local style = attackConfig.Style or "Unknown"

    task.spawn(function()
        local result = LearningHttp("POST", "/v1/success", {
            game = GameName,
            style = style,
            animation_id = tostring(animationId),
            display_name = tostring(attackConfig.DisplayName or ""),
            ping_ms = tonumber(pingMs) or 0,
            ping_bucket_min = lower,
            ping_bucket_max = upper,
            timing_seconds = timingSeconds,
        })

        if not result then
            warn(string.format(
                "[Learning] Could not upload success for %s | %s | %s",
                tostring(style),
                tostring(attackConfig.DisplayName or animationId),
                bucketLabel
            ))
            return
        end

        local cacheKey = GetLearningCacheKey(style, animationId, bucketLabel)
        local count = tonumber(result.sample_count) or 0
        local learned = tonumber(result.timing_seconds)

        if learned and count >= ParryLearning.MinimumSamples then
            LearnedTimingCache[cacheKey] = {
                Found = true,
                Timing = learned,
                Count = count,
                PingRange = result.ping_range or bucketLabel,
                FetchedAt = os.clock(),
            }
        else
            -- Force another lookup soon as the bucket approaches the minimum.
            LearnedTimingCache[cacheKey] = {
                Found = false,
                Count = count,
                PingRange = result.ping_range or bucketLabel,
                FetchedAt = os.clock(),
            }
        end

        print(string.format(
            "[Learning] SUCCESS logged | %s | %s | ping %s ms | %.3fs | samples=%d%s",
            tostring(style),
            tostring(attackConfig.DisplayName or animationId),
            tostring(result.ping_range or bucketLabel),
            timingSeconds,
            count,
            learned and (" | learned=" .. string.format("%.3fs", learned)) or ""
        ))
    end)
end


-- ==========================================
local FlattenedConfig = {}

for styleName, assets in pairs(GameConfig) do

    for assetId, data in pairs(assets) do
        if assetId == "M1Time" then continue end
        if assets["M1Time"] then end 
        local flatData = table.clone(data) or {}  
        flatData.Style = styleName
        if data.DisplayName ~= "M2" and assets["M1Time"] then  
            flatData.ReactionTime = assets["M1Time"]
        elseif not data.ReactionTime then 
            flatData.DefaultReactionTime = DefaultReactionTime
        else 
            flatData.ReactionTime = data.ReactionTime
        end
        
        FlattenedConfig[assetId] = flatData
    end
end

GameConfig = FlattenedConfig

local AnimationIdSliders = {}

local function GetAllFoldersInWorkspace()
    local Folders = {}

    for _, Folder in game.Workspace:GetChildren() do  
        if Folder.ClassName == "Folder" then
            table.insert(Folders, Folder.Name)
        end
    end

    return Folders
end

local function GetAllCharactersInFolder()
    if not SelectedFolder or not game.Workspace:FindFirstChild(SelectedFolder) then
        return {}
    end

    local Characters = {}
    local SelectedFolderObject = game.Workspace:FindFirstChild(SelectedFolder)

    if not SelectedFolderObject then
        return Characters
    end

    for _, Character in SelectedFolderObject:GetChildren() do  
        if Character.ClassName == "Model" and Character:FindFirstChildWhichIsA("Humanoid") then
            if not IncludeLocalCharacter then 
                if Character.Address == game.Players.LocalPlayer.Character.Address then continue end 
            end
            table.insert(Characters, Character)
        end
    end

    return Characters
end

local function SetClipboardLoggedCache()
    local totalItems = #AnimationsLoggedOrder
    if totalItems == 0 then
        print("[Clipboard] Nothing logged to copy.")
        return
    end

    local ids = {}
    for i = 1, totalItems do
        -- Extract only the numbers from the asset ID string
        local numericId = tostring(AnimationsLoggedOrder[i]):match("%d+")
        if numericId then
            table.insert(ids, numericId)
        end
    end

    local clipboardString = table.concat(ids, ",")
    
    setclipboard(clipboardString)
    print(string.format("[Clipboard] Successfully copied %d logged animation IDs!", #ids))
    Notify("Clipboard", string.format("Successfully copied %d logged animation IDs!", #ids))
end

local function SetClipboardIgnoreList()
    local totalItems = #AnimationsLoggedOrder
    if totalItems == 0 then
        print("[Clipboard] Nothing logged to copy.")
        return
    end
    
    local newlyAddedIds = {}

    for AnimationId, AnimData in pairs(AnimationsLoggedCache) do  
        local numericId = tonumber(string.match(tostring(AnimationId), "%d+"))
        
        if numericId then
            table.insert(IgnoreIds, numericId)
            
            table.insert(newlyAddedIds, tostring(numericId))
        end
    end

    local outputstring = table.concat(newlyAddedIds, ", ")
    setclipboard(outputstring)    

    print(string.format("[Clipboard] Copied %d NEW IDs! (Total historical ignored count is now: %d)", #newlyAddedIds, #IgnoreIds))
end

local function AnimationGrabber(Folder)
    local OutputLines = {"{"}
    
    for _, Style in Folder:GetChildren() do
        if not Style.Name:find("Anims") then continue end
        
        local styleAnimations = {}
        
        for _, Animation in Style:GetChildren() do              
            if Animation.Name:find("M1") or Animation.Name:find("M2") then 
                local AnimationIdPointer = memory_read("uintptr_t", Animation.Address + 192)
                local AnimationId = memory_read("string", AnimationIdPointer) or ""
                -- Format the individual animation entry
                local animString = string.format('      ["%s"] = {\n          DisplayName = "%s"\n      }', AnimationId, Animation.Name)
                table.insert(styleAnimations, animString)
            end 
        end
        
        if #styleAnimations > 0 then
            table.insert(OutputLines, string.format('   ["%s"] = {', Style.Name))
            table.insert(OutputLines, table.concat(styleAnimations, ",\n"))
            table.insert(OutputLines, '   },')
        end
    end
    
    table.insert(OutputLines, "}")
    
    local Output = table.concat(OutputLines, "\n")
    setclipboard(Output)
    print(Output)
end
--AnimationGrabber(game.ReplicatedStorage.Animations.Combat)

local function LiteGrabber(Folder)
    local OutputLines = {}
    for _, Animation in Folder:GetChildren() do              
        local AnimationIdPointer = memory_read("uintptr_t", Animation.Address + 192)
        local AnimationId = memory_read("string", AnimationIdPointer) or ""
        local String = `Name: {Animation.Name} | Id: {AnimationId}`
        table.insert(OutputLines, String)
    end

    local Output = table.concat(OutputLines, "\n")
    setclipboard(Output)
    print(Output)
end
--LiteGrabber(game.ReplicatedStorage.Animations.Combat.WingChunAnims)

local function UpdateSliders(OldReactionTime)
    for animationId, Info in (GameConfig) do 
        if AnimationIdSliders[animationId] then
            Info.DefaultReactionTime = DefaultReactionTime
            local ReactionTime = Info.M1Time or Info.ReactionTime or Info.DefaultReactionTime
            AnimationIdSliders[animationId]:Set(ReactionTime)            
        end
    end
end

local scheduler = {}
local pendingTasks = {}

function scheduler.delay(delayTime, callback)
    table.insert(pendingTasks, {
        executeAt = os.clock() + delayTime,
        callback = callback
    })
end

function scheduler.update()
    local now = os.clock()
    for i = #pendingTasks, 1, -1 do
        local task = pendingTasks[i]
        if now >= task.executeAt then
            table.remove(pendingTasks, i)
            -- Run the function safely in a separate thread context
            coroutine.wrap(task.callback)()
        end
    end
end


--==================================================
-- GAKURAN AUTOPLAY RUNTIME (restored from original)
--==================================================
local Receptors = {
    ["Receptor1"] = "X",
    ["Receptor2"] = "C",
    ["Receptor3"] = "N",
    ["Receptor4"] = "M",
}

local HeldKeys = {}
local Threshold = 30
local LastCacheTime = 0
local ReceptorXMap = {}

local function AutoPlayTask()
    if not AutoPlayToggle.Get() then
        return
    end

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local RhythmServiceUI = playerGui and playerGui:FindFirstChild("RhythmServiceUI")
    if not RhythmServiceUI then return end

    local RhythmRoot = RhythmServiceUI:FindFirstChild("RhythmRoot")
    if not RhythmRoot then return end

    local ReceptorLookup = RhythmRoot:FindFirstChild("Receptors")
    local Lanes = RhythmRoot:FindFirstChild("Lanes")
    if not ReceptorLookup or not Lanes then return end

    local ReceptorCount = 0
    local now = os.clock()

    if now - LastCacheTime >= 1 then
        table.clear(ReceptorXMap)

        for ReceptorName, Key in pairs(Receptors) do
            local Receptor = ReceptorLookup:FindFirstChild(ReceptorName)
            if Receptor then
                ReceptorCount += 1
                local ReceptorX = math.floor(Receptor.AbsolutePosition.X + Receptor.AbsoluteSize.X / 2)
                ReceptorXMap[ReceptorX] = {
                    ReceptorName = ReceptorName,
                    Key = Key,
                    Receptor = Receptor,
                }
            end
        end

        if ReceptorCount == 2 then
            Receptors["Receptor1"] = "F"
            Receptors["Receptor2"] = "J"
        else
            Receptors["Receptor1"] = "X"
            Receptors["Receptor2"] = "C"
        end

        LastCacheTime = now
    end

    for _, FallingNote in ipairs(Lanes:GetChildren()) do
        if FallingNote.Name ~= "NoteTemplate" then
            continue
        end

        local NotePos = FallingNote.AbsolutePosition
        local NoteSize = FallingNote.AbsoluteSize
        local NoteX = math.floor(NotePos.X + NoteSize.X / 2)

        local Match
        for RX, Data in pairs(ReceptorXMap) do
            if math.abs(NoteX - RX) <= 10 then
                Match = Data
                break
            end
        end

        if not Match then
            continue
        end

        local Tail = FallingNote:FindFirstChild("Tail")
        local TailSize = Tail and Tail.AbsoluteSize
        local HasTail = TailSize and TailSize.Y > 0

        local Receptor = Match.Receptor
        if not Receptor or not Receptor.Parent then
            continue
        end

        local ReceptorPos = Receptor.AbsolutePosition
        local ReceptorName = Match.ReceptorName
        local Key = Match.Key

        if HasTail then
            local WhenYouShouldHold = (Tail.AbsolutePosition.Y + Tail.AbsoluteSize.Y) - ReceptorPos.Y

            if WhenYouShouldHold + 15 > Threshold then
                if not HeldKeys[ReceptorName] then
                    HeldKeys[ReceptorName] = FallingNote.Address
                    keypress(string.byte(Key))
                elseif HeldKeys[ReceptorName] ~= FallingNote.Address then
                    HeldKeys[ReceptorName] = FallingNote.Address
                    keypress(string.byte(Key))
                end
            end

            if FallingNote.Address == HeldKeys[ReceptorName]
                and (Tail.AbsolutePosition.Y - ReceptorPos.Y) > 0 then

                scheduler.delay(0.01, function()
                    HeldKeys[ReceptorName] = nil
                end)

                keyrelease(string.byte(Key))
            end
        else
            if math.abs(NotePos.Y - ReceptorPos.Y) < Threshold then
                if HeldKeys[ReceptorName] then
                    keyrelease(string.byte(Key))
                    HeldKeys[ReceptorName] = nil
                end

                task.spawn(function()
                    keypress(string.byte(Key))
                    task.wait(0.05)
                    keyrelease(string.byte(Key))
                end)
            end
        end
    end
end

-- ==========================================

-- ==========================================

-- ==========================================
local PARRY_DISTANCE = 15 
local PARRY_COOLDOWN = 0.1

local activeOrbs = {}
local lastParryAt = 0

local function GetLocalHRP()
    local localChar = LocalPlayer.Character
    local HRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not HRP then return nil end 
    return HRP
end

function checkRange(Studs, Origin : Part)
    local HRP = GetLocalHRP()

    if (HRP.Position - Origin.Position).Magnitude < Studs then  
        return true 
    else
        return false 
    end
end

local orbSpawnTimes = {} 

local function ListenForOrbs()
    print("Listening for orbs")

    local connection
    
    connection = RunService.Heartbeat:Connect(function()
        -- Safely get the character and HumanoidRootPart every frame
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local myPosition = hrp.Position
        local ActiveOrbs = {}

        local thrownFolder = game.Workspace:FindFirstChild("Thrown")
        if thrownFolder then
            for _, v in ipairs(thrownFolder:GetChildren()) do  
                if (v.Name == "ArdourBall2" or v.Name == "ArdourBall") 
                    and v:IsA("BasePart") 
                    and v:IsDescendantOf(game.Workspace.Thrown) then -- Ensures it isn't a ghost instance
                    
                    table.insert(ActiveOrbs, v)
                end
            end
        end

        for i = #ActiveOrbs, 1, -1 do
            local orb = ActiveOrbs[i]

            -- Double check the orb didn't get destroyed mid-frame
            if orb and orb.Parent then
                local distance = (myPosition - orb.Position).Magnitude

                if distance <= PARRY_DISTANCE and (tick() - lastParryAt >= 0.08) then
                    lastParryAt = tick()
                    
                    BlockStart()
                    BlockEnd()
                    
                    break 
                end
            end
        end
    end)
    
    return connection
end

-- Start listening
if game.PlaceId == 8668476218 or game.PlaceId == 134572803901609 then  
    local orbListener = ListenForOrbs()    
end

-- ==========================================
-- Configs 
-- ==========================================

local ParryKey = string.byte("F")
local DodgeKey = string.byte("Q")

local KeyHeld = false
local TriggerParry = false

local Stunned = false
local currentStunToken = 0

local AnimationTracker = AnimationTrackerClass.new(IgnoreIds)
local LocalTracker = AnimationTrackerClass.new(IgnoreIds)

local DamageLogs = false
-- IncludeLocalCharacter is declared in the Wabi state bridge

local lastAnimationCheck = 0
local connection = nil
local previousHealth = 100
local lastCharacter = nil

local SelectAllMode = true 
local TargetCharacters = {}

local TargetSelectionState = {
    Markers = {},
    Whitelist = {},
    LastSelected = {},
}

local function FindPlayerForCharacter(character)
    if not character then
        return nil
    end

    local ok, playerList = pcall(function()
        return Players:GetPlayers()
    end)

    if not ok or type(playerList) ~= "table" then
        return nil
    end

    for _, player in ipairs(playerList) do
        local okCharacter, playerCharacter = pcall(function()
            return player.Character
        end)

        if okCharacter and playerCharacter == character then
            return player
        end
    end

    return nil
end

local function GetCharacterWhitelistKey(character)
    if not character then
        return nil
    end

    local player = FindPlayerForCharacter(character)

    if player then
        return "uid:" .. tostring(player.UserId)
    end

    return "name:" .. tostring(character.Name)
end

local function GetCharacterDisplayName(character)
    if not character then
        return "Unknown"
    end

    local player = FindPlayerForCharacter(character)

    if player then
        if player.DisplayName and player.DisplayName ~= player.Name then
            return player.DisplayName .. " (@" .. player.Name .. ")"
        end

        return player.Name
    end

    return character.Name
end

local function IsCharacterWhitelisted(character)
    local key = GetCharacterWhitelistKey(character)
    return key ~= nil and TargetSelectionState.Whitelist[key] == true
end

local function SetCharacterWhitelisted(character, enabled)
    local key = GetCharacterWhitelistKey(character)

    if not key then
        return false
    end

    if enabled then
        TargetSelectionState.Whitelist[key] = true
    else
        TargetSelectionState.Whitelist[key] = nil
    end

    return true
end

local function ClearSelectedMarkers()
    for character, markerText in pairs(TargetSelectionState.Markers) do
        if markerText then
            pcall(function()
                markerText.Visible = false
            end)

            pcall(function()
                markerText:Remove()
            end)
        end

        TargetSelectionState.Markers[character] = nil
    end
end

local function AddSelectedMarker(character)
    if not character then
        return
    end

    local markerText = Drawing.new("Text")
    markerText.Text = "SELECTED"
    markerText.Size = 18
    markerText.Center = true
    markerText.Outline = true
    markerText.Transparency = 1
    markerText.Color = Color3.fromRGB(255, 50, 50)
    markerText.Visible = false
    markerText.ZIndex = 30

    TargetSelectionState.Markers[character] = markerText
end

local function UpdateSelectedMarkers()
    for character, markerText in pairs(TargetSelectionState.Markers) do
        local visible = false

        if character and markerText then
            local anchor =
                character:FindFirstChild("Head")
                or character:FindFirstChild("HumanoidRootPart")

            if anchor then
                local screenPos, onScreen =
                    WorldToScreen(anchor.Position + Vector3.new(0, 1.5, 0))

                if onScreen and screenPos then
                    markerText.Position =
                        Vector2.new(screenPos.X, screenPos.Y)

                    visible = true
                end
            end

            markerText.Visible = visible
        end
    end
end

local function CopyWhitelist()
    local copy = {}

    for key, enabled in pairs(TargetSelectionState.Whitelist) do
        if enabled == true then
            copy[key] = true
        end
    end

    return copy
end

local function ApplyWhitelist(saved)
    table.clear(TargetSelectionState.Whitelist)

    if type(saved) ~= "table" then
        return
    end

    for key, enabled in pairs(saved) do
        if type(key) == "string" and enabled == true then
            TargetSelectionState.Whitelist[key] = true
        end
    end
end
local EspTrackers = {} 

local PendingReactionTimestamp = nil 
local EspTracker = nil
local CurrentIndex = 0
local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
local COLOR_RED = Color3.fromRGB(255, 50, 50)
local COLOR_GREEN = Color3.fromRGB(50, 255, 50)

local AnimationRegistry = {}
local LastPendingRegData = nil
local InputRegisteredTime = nil
local TimeBetweenPressingFandParrying = nil

local InputRegisteredTime = nil
local ParryRegisteredTime = nil
local InputLatency = 0 -- (Parry - Input)


local ParryState = {
    IDLE = "idle",

    INPUT_PENDING = "input_pending",   -- F was pressed locally, waiting for animation to appear
    PARRYING = "parrying",             -- Animation just appeared
    PARRYINGFAILED = "parryingfailed",       -- Animation didn't appear (Happens when you're on parry cooldown)

    STUNNED = "stunned",
    WINDOW_EXCEEDED = "window_exceeded", -- If you exceed the window cuz ur not targeting or ur

    SUCCESS = "parrysuccess"       -- Parrying animation was detected so its parrying right now
}

local CurrentParryState = ParryState.IDLE

local function ResetParryState()
    KeyHeld = false
    ReleaseDeadline = 0
    TimeBetweenpressingFandParrying = nil
   -- warn("RELEASE")
    BlockEnd()
end

local function TransitionToState(newState)
    print(string.format("[Parry] %s -> %s", CurrentParryState, newState))
    CurrentParryState = newState
end

-- ==========================================
-- Helpers
-- ==========================================

local function ToggleDamageLogger(state)
    if not state then
        if connection then
        connection:Disconnect()
        connection = nil end
        print("[Logger] Heartbeat damage logger DISABLED.")
        return
    end

    if connection then return end -- Prevent duplicate connections
    print("[Logger] Heartbeat damage logger ACTIVE.")
    
    connection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not hum then return end 

        if lastCharacter and (char.Address ~= lastCharacter.Address) then
            lastCharacter = char
            previousHealth = hum.Health
        end
        local currentHealth = hum.Health
        if currentHealth < previousHealth then
            local damageTaken = previousHealth - currentHealth
            
            if #TargetCharacters then
                local activeAnimations = AnimationTracker:Update(TargetCharacter) or {}
                
                
                for _, anim in activeAnimations do
                    if not anim.AnimationId or anim.TimePosition < 0.1 or anim.TimePosition > 0.7 then continue end 
                    local assetId = tostring(anim.AnimationId)
                    local poolData = GameConfig[assetId]
                    warn(string.format(
                        "[HIT] %d DMG | Anim: %s (%s) %s | Frame Time: %.3f", 
                        damageTaken, 
                        poolData and poolData.DisplayName or anim.Name or "Unknown",
                        assetId, 
                        poolData and poolData.Style or "",
                        anim.TimePosition or 0
                    ))
                end
            end
        end
        previousHealth = currentHealth
    end)
end

-- ==========================================
-- Parry Core Logic
-- ==========================================


local function GetHeightMultiplierForCharacter(TargetCharacter)
    local succ, data = pcall(function()
        local stateFolder = TargetCharacter and TargetCharacter:FindFirstChild("PlayerData")    
        return stateFolder:GetAttribute("CurrentHeight")
    end)
    if succ then  
        return data
    else
     --   print("failed to get height")
        return 1
    end
end


function Dodge()
    --keyrelease(DodgeKey)
    BlockEnd()

    for i = 1, 12, 1 do  
        keypress(DodgeKey)
        keyrelease(DodgeKey) 
    end
    --  mouse2click()    
end

function BlockStart(StartTime, HoldFor)
    if not StartTime then  
        warn("Lacking a start time")
        return
    end

    if ParryRegisteredTime then  
       local TimeBetweenLastParry = os.clock() - ParryRegisteredTime
         if TimeBetweenLastParry < 0.8 then  
             print("parry is gonna be on cooldown")
         --    return
         end 
    end

    if CurrentParryState ~= ParryState.IDLE then  
        warn("tried to press in a non idle state bypass")
        TransitionToState(ParryState.IDLE)
    --    return
    end


    local HoldFor = HoldFor or BlockHoldTime
    ReleaseDeadline = StartTime + HoldFor   

    --print(now, duration, "attempted block", holdTime and holdTime - now)

    KeyHeld = true
  --  keyrelease(ParryKey) 
    
    if AutoParryToggle.Get() == true then
        keypress(ParryKey)    
    end
end

function BlockEnd()
    KeyHeld = false
--    ResetParryState()
    
    if AutoParryToggle.Get() == true then 
        keyrelease(ParryKey) 
    end 
end


-- ==========================================
-- STATE MACHINE
-- ==========================================


--                  ==[Input State]==
-- Local F keypress
local function OnInputF()

    if CurrentParryState == ParryState.IDLE then
        InputRegisteredTime = os.clock()
        TransitionToState(ParryState.INPUT_PENDING)
    else
    --    print("F was pressed while machine wasnt idle")
    end
end


local function DebugParry()
-- 1. Network Variables (These never rely on the parry window data, so we always calculate them)
    local WeActuallyBlockedAt = ParryRegisteredTime
    local WeWantedToBlockAt = InputRegisteredTime
    local TimeTheServerReceived = InputLatency / 2

    if LastPendingRegData then
        -- 2. Animation Variables (Only extracted if the data actually exists)
        local AnimationStartTime = LastPendingRegData.StartTime
        local BlockStart = LastPendingRegData.BlockStart
        local BlockExpire = LastPendingRegData.BlockExpire
        
        -- Relative Offsets (How far into the animation the window is)
        local RelativeBlockStart = BlockStart - AnimationStartTime   -- e.g., 0.300s
        local RelativeBlockExpire = BlockExpire - AnimationStartTime -- e.g., 0.650s
        
        -- Timeline Calculations
        local ClientReactionTime = WeWantedToBlockAt - AnimationStartTime -- Relative to Anim Start (0)
        local ServerRelativeTime = (WeActuallyBlockedAt - TimeTheServerReceived) - AnimationStartTime -- Relative to Anim Start (0)
        
        local IsSuccess = (ClientReactionTime >= RelativeBlockStart and ClientReactionTime <= RelativeBlockExpire)        
        ----------------------------------------------------------------------
        -- FULL DIAGNOSTICS LOG (Data Exists)
        ----------------------------------------------------------------------
        print(string.format(
            "\n================ PARRY DIAGNOSTICS ================\n" ..
            "[NETWORK STATE]\n" ..
            "Total Input Latency:  %.3fs\n" ..
            "One-Way Server Delay: %.3fs\n" ..
            "---------------------------------------------------\n" ..
            "[ANIMATION TIMELINE]\n" ..
            "Target Parry Window:  %.3fs to %.3fs\n" ..
            "Pressed F At:    %.3fs\n" ..
            "Parry Registered At:  %.3fs (ONE-WAY)\n" ..
            "---------------------------------------------------\n" ..
            "[VERDICT]\n" ..
            "Status:               %s\n" ..
            "===================================================",
            InputLatency,
            TimeTheServerReceived,
            RelativeBlockStart, 
            RelativeBlockExpire,
            ClientReactionTime,
            ServerRelativeTime,
            IsSuccess and "[SUCCESS]" or "[MISSED WINDOW]"
        ))
    else
        ----------------------------------------------------------------------
        -- LATENCY ONLY DIAGNOSTICS LOG (No Parry Data)
        ----------------------------------------------------------------------
        print(string.format(
            "\n============ LATENCY ONLY DIAGNOSTICS ============\n" ..
            "[NETWORK STATE]\n" ..
            "Total Input Latency:  %.3fs\n" ..
            "One-Way Server Delay: %.3fs\n" ..
            "---------------------------------------------------\n" ..
            "[ANIMATION TIMELINE]\n" ..
            "No active parry window / registration data found.\n" ..
            "===================================================",
            InputLatency,
            TimeTheServerReceived
        ))
    end
end

-- Parrying animation detected
local function OnParryingAnimationSuccess()
    if CurrentParryState == ParryState.INPUT_PENDING then
        ParryRegisteredTime = os.clock()
        InputLatency = os.clock() - InputRegisteredTime

        if ParryDebugToggle:Get() then  
            DebugParry()
        end
        
        TransitionToState(ParryState.PARRYING)
    end
end

-- Parrying window passed without parrying
local function OnParryingAnimationFailed()
    if CurrentParryState == ParryState.INPUT_PENDING then
        TransitionToState(ParryState.PARRYINGFAILED)
        TransitionToState(ParryState.IDLE)
    end
end


local StunToken = 0
local function OnStunned()
    if CurrentParryState ~= ParryState.STUNNED then 
        TransitionToState(ParryState.STUNNED)
    end

    StunToken += 1
    local MyToken = StunToken
    
    
    scheduler.delay(0.4, function()
        if MyToken == StunToken then 
            BlockEnd()
            TransitionToState(ParryState.IDLE)            
        end
    end)
end


local function OnSuccessfulParry()
    if CurrentParryState == ParryState.PARRYING then  

        local AnimId = LastPendingRegData.AnimationId
        local AttackConfig = GameConfig[AnimId]
        local ParryPressTime = tonumber(InputRegisteredTime - LastPendingRegData.StartTime)
        local EstimatedParryWindow = os.clock() - LastPendingRegData.StartTime
        
        -- SANITY CHECK happens when we evaludte outside of parrying
        if ParryPressTime > 1 or ParryPressTime < 0 then
        --    print("HERE", ParryPressTime, os.clock() - InputRegisteredTime, os.clock() - LastPendingRegData.StartTime)
        --    warn("AAAAAAA")
            return
        end
        
        -- NOTIFY UI
        Notify(
            "Parry Success", 
            string.format("%.3fs PT: %.3fs - %s %s", 
                ParryPressTime, 
                EstimatedParryWindow,
                AttackConfig.Style, 
                AttackConfig.DisplayName
            )
        )
        
        LastPendingRegData.LearnedParryTime = ParryPressTime
        LastPendingRegData.Success = true

        -- The game's local parried animation is our success oracle. Record the
        -- exact press time relative to this attack's animation start in the
        -- CURRENT ping bucket.
        local successPing = tonumber(GetPingValue()) or LastPendingRegData.PingAtPlan or 0
        SubmitSuccessfulParry(AttackConfig, AnimId, ParryPressTime, successPing)

        --LastPendingRegData.Processed = true

        -- CLEANUP
        --InputRegisteredTime = nil
        
        ResetParryState()
        TransitionToState(ParryState.SUCCESS)
        TransitionToState(ParryState.IDLE)
    else
        warn("Tried to evaluate outside of parrying")
        print(CurrentParryState)
    end
end

local function OnWindowExceeded()
    if CurrentParryState == ParryState.PARRYING then 
        TransitionToState(ParryState.WINDOW_EXCEEDED)
        TransitionToState(ParryState.IDLE)
    end
end

local function ParryTask()
    local now = os.clock()

    if KeyHeld and os.clock() > ReleaseDeadline then
        BlockEnd()
    end

    if CurrentParryState == ParryState.INPUT_PENDING then
        local MaxLatency = 0.5 -- This is the maximum time we wait for the parrying animation to appear, if it doesn't appear it means parry cooldown
        local TimePassedSinceFWasPressed = now - InputRegisteredTime

        local ActiveAnims = GetActiveAnimationsForCharacterAsDictionary(LocalPlayer.Character)
       -- print(ActiveAnims)
      
        for i, v in ActiveAnims do
            if table.find(ParryingAnimation, v.AnimationId) then
                OnParryingAnimationSuccess()
                break
            end
        end

        --[[ if table.find(ParriedAnimation, animId) then  
            OnSuccessfulParry()
        end]]

        if not iskeypressed(ParryKey) then  
            warn("F key was released before parrying animation appeared")
            ResetParryState()
            TransitionToState(ParryState.IDLE)
        end

        if TimePassedSinceFWasPressed > MaxLatency then
            warn(string.format("Parrying animation didn't appear, probably on CD MAX: %.2f | TIME: %.2f", MaxLatency, TimePassedSinceFWasPressed))
            OnParryingAnimationFailed()
            TransitionToState(ParryState.IDLE)
        end
    
    
    elseif CurrentParryState == ParryState.PARRYING then

        if not LastPendingRegData then 
        --    TransitionToState(ParryState.IDLE) 
        --    return 
        end

        local ParryWindowStart = ParryRegisteredTime
        local ParryWindowEnd = ParryRegisteredTime + ParryWindow + 0.3

        --local AnimationStartTime = LastPendingRegData.StartTime -- Absolute timestamp (os.clock)
        --local BlockStart = LastPendingRegData.BlockStart       -- Absolute timestamp (os.clock)
        --local BlockExpire = LastPendingRegData.BlockExpire     -- Absolute timestamp (os.clock)

        -- Relative Offsets (How far into the animation the window is)
        --local RelativeBlockStart = BlockStart - AnimationStartTime   -- e.g., 0.300s
        --local RelativeBlockExpire = BlockExpire - AnimationStartTime -- e.g., 0.650s

        
        
        if now > ParryWindowEnd then
            OnWindowExceeded()
        end
    --    TransitionToState(ParryState.IDLE)
    end
end

-- ==========================================


-- Successful timing learning is handled by the database client above.

local function onLocalAnimationAdded(anim)
    local animId = anim.AnimationId

    if table.find(ParriedAnimation, animId) then  
        OnSuccessfulParry()
    end

    if table.find(ParryingAnimation, animId) then
        if not InputRegisteredTime then return end 

        -- For someone reason it was running before UIS??
       --scheduler.delay(0.01, function()
          --  if InputRegisteredTime then
                OnParryingAnimationSuccess()
          --  end
       -- end)
    end
    
    if table.find(StunnedAnimation, animId) then
        -- keypress(string.byte()) if u f in a stun u get a shaky block 
     --  OnStunned()
     --  print("stunned")
    end

    if GameConfig[animId] then  
        print("player is m1ing")
        OnStunned()
    end

end

local AnimationAdded = LocalTracker.AnimationAdded:Connect(onLocalAnimationAdded)

local function LogAnimation(assetId, trackInfo)
    if not AnimationsLoggedCache[assetId] then
        AnimationsLoggedCache[assetId] = { Name = trackInfo.Name }
        table.insert(AnimationsLoggedOrder, assetId)
        UpdateClipboardSection()
    end
end

function GetActiveAnimationsForCharacterAsDictionary(character)
    local ReturnTable = {}
    local activeAnimations = AnimationTracker:Update(character)
    if not activeAnimations or #activeAnimations == 0 then return {} end
    for Index, Anim in activeAnimations do  
        if Anim.AnimationId then  
            ReturnTable[Anim.AnimationId] = Anim
        end
    end

    return ReturnTable
end

-- ==========================================
-- Parry Evaluation
-- ==========================================

local DodgeLockoutEnd = 0

local function ValidateLocalCharacter()
    local localCharacter = LocalPlayer and LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if not localRoot or Stunned then return nil end
    return localCharacter, localRoot
end

local function ValidateTargetCharacter(character)
    local targetRoot = character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return nil end
    return targetRoot
end

local function CheckCharacterDistance(localRoot, targetRoot)
    return (targetRoot.Position - localRoot.Position).Magnitude
end

local function UpdateCharacterESP(character, Distance)
    if not AutoParryToggle.Get() then 
        if EspTrackers[character] and EspTrackers[character].ChangeText then  
            EspTrackers[character]:ChangeText("Name", "AUTO PARRY IS DISARMED", COLOR_RED)  
        end
        return true
    elseif Distance > AutoParryRange then
        if EspTrackers[character] and EspTrackers[character].ChangeText then  
            EspTrackers[character]:ChangeText("Name", character.Name.. " | OUT OF RANGE", COLOR_RED)  
        end
        return false
    else
        if EspTrackers[character] and EspTrackers[character].ChangeText then  
            EspTrackers[character]:ChangeText("Name", character.Name.. " IN RANGE", COLOR_GREEN)  
        end
        return true
    end
end

local function CalculateParryTiming(attackConfig, StartTime, Target, animationId)
    local pingMs = tonumber(GetPingValue()) or 0

    -- Learning is optional. Never allow it to abort or delay parry timing.
    local learnedTiming = nil
    local learnedInfo = nil

    local learningOk, learnedA, learnedB = pcall(
        GetLearnedTiming,
        attackConfig,
        animationId,
        pingMs
    )

    if learningOk then
        learnedTiming = learnedA
        learnedInfo = learnedB
    else
        warn("[Learning] Timing lookup isolated from auto parry: " .. tostring(learnedA))
    end

    local optimalReactionTime
    local timingSource

    if learnedTiming then
        -- This timing was learned inside the exact current ping bucket, so do NOT
        -- compensate for ping a second time.
        optimalReactionTime = learnedTiming
        timingSource = "learned:" .. tostring(learnedInfo and learnedInfo.PingRange or "?")
    else
        -- No learned value for this exact bucket yet:
        -- fall back to the configured/base timing and use the existing half-ping
        -- compensation until successful samples populate this bucket.
        optimalReactionTime = (attackConfig.ReactionTime or DefaultReactionTime)

        if PingCompensateToggle.Get() then
            optimalReactionTime -= (pingMs / 1000) * 0.5
        end

        timingSource = "fallback+ping"
    end

    local HeightMultiplier = 1
    if HeightToggle.Get() then
        HeightMultiplier = GetHeightMultiplierForCharacter(Target)
    end

    local adjustedReactionTime = (optimalReactionTime * HeightMultiplier) + ParryOffset
    local parryWindowStart = adjustedReactionTime
    local parryWindowEnd = adjustedReactionTime + ParryWindow
    local ClockStart = StartTime + parryWindowStart
    local ClockEnd = StartTime + parryWindowEnd

    return ClockStart, ClockEnd, timingSource, pingMs
end

local ConstLatency = 0.018
local EXECUTE_DEBOUNCE = 0.5

local function UpdateAnimationRegistry(animKey, anim, now, currentTrackTime, attackConfig, TargetCharacter)

    if not AnimationRegistry[animKey] then
        local adjustedNow = now - ConstLatency -- - currentTrackTime
        local BlockStart, BlockExpire, timingSource, pingMs = CalculateParryTiming(attackConfig, adjustedNow, TargetCharacter, anim.AnimationId)

        AnimationRegistry[animKey] = {
            StartTime = adjustedNow,
            Processed = false,
            CurrentClockTime = os.clock(),
            CurrentTrackTime = currentTrackTime,
            ReactionTime = attackConfig,
            Ignore = false,
            AnimationId = anim.AnimationId,
            DidALoop = false,
            BlockStart = BlockStart,
            BlockExpire = BlockExpire,
            RandomNum = math.random(1, 100),
            LastExecuteTime = 0, -- debounce timestamp
            TimingSource = timingSource,
            PingAtPlan = pingMs,
        }
    end
    
    local regData = AnimationRegistry[animKey]
    
    if regData.CurrentTrackTime and (currentTrackTime < regData.CurrentTrackTime) then
        local BlockStart, BlockExpire, timingSource, pingMs = CalculateParryTiming(attackConfig, now - currentTrackTime, TargetCharacter, anim.AnimationId)
        
        regData.Processed = false
        regData.DidALoop = true
        warn("Loop detected")
        regData.BlockStart = BlockStart
        regData.BlockExpire = BlockExpire
        regData.TimingSource = timingSource
        regData.PingAtPlan = pingMs
        regData.StartTime = now - ConstLatency -- - currentTrackTime
    end
    
    regData.CurrentClockTime = os.clock()
    regData.CurrentTrackTime = currentTrackTime

    if LastPendingRegData == regData then
        LastPendingRegData = regData
    end

    return regData
end

local function CheckAnimationDirection(character, localCharacter, localRoot, targetRoot, attackConfig)
    if character.Address == localCharacter.Address then return true end
    
    local direction = (targetRoot.Position - localRoot.Position).Unit
    local distance = (targetRoot.Position - localRoot.Position).Magnitude
    local isHeavy = attackConfig.DisplayName == "M2" or attackConfig.DisplayName == "Heavy" or attackConfig.Heavy
  --  print(distance)
    
    if not isHeavy then -- and distance > 4 then  
        if TargetFacingYou.Get() and targetRoot.CFrame.LookVector:Dot(-direction) < 0.1 then return false end
        if YouFacingTarget.Get() and localRoot.CFrame.LookVector:Dot(direction) < 0.1 then return false end
    end
    
    return true
end

local function ExecuteParry(regData, attackConfig)
    local now = os.clock()
    if (now - regData.LastExecuteTime) < EXECUTE_DEBOUNCE then
        return
    end
    regData.LastExecuteTime = now

    local isHeavy = attackConfig.DisplayName == "M2" or attackConfig.DisplayName == "Heavy" or attackConfig.Heavy

    if attackConfig.Jump then 
        task.spawn(function()
            keypress(32)
            task.wait(.06)
            keyrelease(32)                      
        end)
        DodgeLockoutEnd = os.clock() + 0.2
    elseif isHeavy and AutoDodgeToggle.Get() then
        if AutoParryToggle.Get() then  
            Dodge()            
        end
    --    DodgeLockoutEnd = os.clock() + 0.2
    else 
        if LastPendingRegData ~= regData then
            LastPendingRegData = regData
            BlockStart(LastPendingRegData.BlockStart)
            print(string.format("Block triggered by [%s | %s] | %s | ping=%.0fms" ,
                attackConfig.Style,
                attackConfig.DisplayName,
                tostring(regData.TimingSource or "unknown"),
                tonumber(regData.PingAtPlan) or 0
                ))
        elseif LastPendingRegData == regData then
            if regData.DidALoop then  
                print(string.format("Block retriggered for [%s | %s] because its the same key but it looped", 
                attackConfig.Style, 
                attackConfig.DisplayName))
                regData.DidALoop = false
                BlockStart(regData.BlockStart)
            else
            --    print(string.format("Block retriggered for  [%s | %s] since we're still in window", attackConfig.Style, attackConfig.DisplayName))
            end

           -- BlockStart(regData.StartTime)
        end
    end
end

local function EvaluateAnimation(anim, character, localCharacter, localRoot, targetRoot, currentActiveIds)
    -- ANIMATION VALIDATION
    if not anim.AnimationId then return end
    local attackConfig = GameConfig[tostring(anim.AnimationId)]
    if not attackConfig then return end
    
    local animKey = anim.Address or anim
    currentActiveIds[animKey] = true
    
    -- ANIMATION REGISTRY & STATE
    local now = os.clock()
    local regData = UpdateAnimationRegistry(animKey, anim, now, anim.TimePosition or 0, attackConfig, character)
    if regData.Processed then return end

    if CheckCharacterDistance(localRoot, targetRoot) > AutoParryRange then return end
    
    -- PARRY FUNCTION OVERRIDE
    if attackConfig.ParryFunction and (now - regData.StartTime) <= (attackConfig.ReactionTime or DefaultReactionTime) + ParryWindow/2 then
        if AutoParryToggle.Get() then  
           attackConfig.ParryFunction({
               RegistryData = regData,
               Mob = character,
               AnimationData = anim,
               AnimationTracker = AnimationTracker,
           }) 
        end
        return
    end
    
    -- DIRECTION CHECKS
    if not CheckAnimationDirection(character, localCharacter, localRoot, targetRoot, attackConfig) then return end
    
    if regData.RandomNum > ProbabilityToParry then
        regData.Processed = true
--        print("Skip b/c PTP", RandomNum, ProbabilityToParry)
        return
    end
    
    -- PARRY EXECUTION
    local BlockExpireTimer = regData.BlockExpire - now
    
    if now >= regData.BlockStart and BlockExpireTimer >= 0 then
    --    if not LastPendingRegData or LastPendingRegData.Proc then
            ExecuteParry(regData, attackConfig)
    --    end
    end
end

local function EvaluateCharacter(character, localCharacter, localRoot, currentActiveIds)
    -- CHARACTER VALIDATION
    local targetRoot = ValidateTargetCharacter(character)
    if not targetRoot then return end
    
    -- CHARACTER DISTANCE & ESP
    local Distance = CheckCharacterDistance(localRoot, targetRoot)
    UpdateCharacterESP(character, Distance)    
    -- ANIMATION LOOP
    local activeAnimations = AnimationTracker:Update(character)
    if not activeAnimations or #activeAnimations == 0 then return end
    
    for _, anim in ipairs(activeAnimations) do
        EvaluateAnimation(anim, character, localCharacter, localRoot, targetRoot, currentActiveIds)
    end
end

local function EvaluateParryTriggers()
    -- SETUP & VALIDATION
    local localCharacter, localRoot = ValidateLocalCharacter()
    if not localCharacter or not localRoot then return end
    
    local currentActiveIds = {}

    -- CHARACTER ITERATION
    for _, character in ipairs(TargetCharacters) do
        EvaluateCharacter(character, localCharacter, localRoot, currentActiveIds)
    end

    -- CLEANUP
    for key, val in pairs(AnimationRegistry) do
        if not currentActiveIds[key] then
            AnimationRegistry[key] = nil
            if LastPendingRegData == val then
                --print("Removed last pending reg data because the animation isnt playing")
                LastPendingRegData = nil
            end
        end
    end
end

-- ==========================================
-- ==========================================

local function ProcessEspAndLogging()
    for i = #TargetCharacters, 1, -1 do
        local character = TargetCharacters[i]
        local tracker = EspTrackers[character]
        
        if tracker and not tracker.ChangeText then 
            EspTrackers[character] = nil 
            table.remove(TargetCharacters, i) -- Safely removes and shifts elements
            continue
        end

        -- Fetch active animations using your AnimationTracker system
        local activeAnimations = AnimationTracker:Update(character) or {}
        local lines = {}
        
        if #activeAnimations == 0 then 
            tracker:ChangeText("CurrentlyPlaying", "None", COLOR_WHITE) 
            continue 
        end 

        for i = 1, #activeAnimations do
            local anim = activeAnimations[i]
            if not anim.AnimationId then continue end        
            
            local assetId = anim.AnimationId
            local numericId = tonumber(string.match(tostring(assetId), "%d+"))
            
            if numericId and table.find(IgnoreIds, numericId) then continue end 
            
            local poolData = GameConfig[tostring(assetId)]
            local resolvedName = poolData and poolData.DisplayName or anim.Name
            
            if not poolData then  
                LogAnimation(assetId, { Name = resolvedName, AnimationId = assetId })
            end

            table.insert(lines, string.format(
                "%s (%s) | ID: %s | Time: %.2f | Timing: %.2f %s | Speed: %.2f",
                tostring(resolvedName),
                poolData and poolData.Style or "???",
                tostring(assetId),
                anim.TimePosition or 0.00,
                poolData and poolData.ReactionTime or DefaultReactionTime,
                poolData and "[Logged]" or "[Unknown]",
                anim.Speed
            ))
        end

        if tracker and tracker.Name then  
            tracker:ChangeText("CurrentlyPlaying", table.concat(lines, "\n"), COLOR_WHITE) 
        end    
    end
end

local function ClearAllEspTrackers()
    for char, tracker in pairs(EspTrackers) do
        if tracker and tracker.Destroy then            
            if ESP_Utility.TrackersToUpdate[tracker] then
                ESP_Utility.TrackersToUpdate[tracker] = nil
            end

            -- 2. Destroy the tracker object
            tracker:Destroy()
        end
    end
    table.clear(EspTrackers) -- Safer than re-assigning {} to preserve table memory references
end

local function UpdateTargetCharacters(charactersList)
    if #charactersList > 0 then
        table.clear(TargetSelectionState.LastSelected)

        for _, character in ipairs(charactersList) do
            TargetSelectionState.LastSelected[#TargetSelectionState.LastSelected + 1] =
                character
        end
    end

    ClearAllEspTrackers()
    ClearSelectedMarkers()
    table.clear(TargetCharacters)

    for _, character in ipairs(charactersList) do
        if character and not IsCharacterWhitelisted(character) then
            table.insert(TargetCharacters, character)

            if character:FindFirstChild("HumanoidRootPart") then
                local tracker = ESP_Utility.NewTracker(
                    character.HumanoidRootPart,
                    character.Name,
                    COLOR_RED
                )

                if tracker and tracker.Name then
                    tracker:AddText("CurrentlyPlaying", nil, "???")
                end

                EspTrackers[character] = tracker
            end

            AddSelectedMarker(character)
        end
    end
end

function CycleEvent(manualCycle)
    local allCharacters = GetAllCharactersInFolder()

    if not SelectedFolder or not allCharacters then
        UpdateTargetCharacters({})
        return
    end

    local localPlayer = game.Players.LocalPlayer
    local localCharacter = localPlayer.Character
    local localRoot =
        localCharacter
        and localCharacter:FindFirstChild("HumanoidRootPart")

    if not localRoot then
        return
    end

    local validCharacters = {}

    for _, char in ipairs(allCharacters) do
        if IsCharacterWhitelisted(char) then
            continue
        end

        -- Keep the existing Include Local Character behavior.
        if char == localCharacter and not IncludeLocalCharacter then
            continue
        end

        local targetRoot = char:FindFirstChild("HumanoidRootPart")

        if targetRoot then
            local distance =
                (localRoot.Position - targetRoot.Position).Magnitude

            if distance <= MaxCycleRange then
                table.insert(validCharacters, {
                    Character = char,
                    Distance = distance,
                })
            end
        end
    end

    if #validCharacters == 0 then
        CurrentIndex = 0
        UpdateTargetCharacters({})

        if manualCycle then
            Notify(
                "Cycle",
                "No targets found in range ["
                    .. tostring(MaxCycleRange)
                    .. " studs]",
                3
            )
        end

        return
    end

    table.sort(validCharacters, function(a, b)
        return a.Distance < b.Distance
    end)

    -- Manual X selection is intentionally independent of Auto Target
    -- and Multiple Targets. Every X press advances exactly one target.
    if manualCycle then
        CurrentIndex = (CurrentIndex % #validCharacters) + 1

        local selectedCharacter =
            validCharacters[CurrentIndex].Character

        UpdateTargetCharacters({ selectedCharacter })

        Notify(
            "Target",
            "Selected "
                .. GetCharacterDisplayName(selectedCharacter)
                .. " ["
                .. tostring(CurrentIndex)
                .. "/"
                .. tostring(#validCharacters)
                .. "]",
            2
        )

        return
    end

    -- Automatic targeting keeps the existing behavior.
    if MultiTarget.Get() then
        local Max = 3
        local finalTargets = {}

        for i = 1, math.min(Max, #validCharacters) do
            table.insert(
                finalTargets,
                validCharacters[i].Character
            )
        end

        UpdateTargetCharacters(finalTargets)
    else
        local selectedCharacter = validCharacters[1].Character
        UpdateTargetCharacters({ selectedCharacter })
    end
end


--==================================================
-- PER-ANIMATION TIMING CONTROLS
--==================================================

local function _sanitizeTimingId(value)
    return tostring(value)
        :gsub("rbxassetid://", "")
        :gsub("[^%w_]", "_")
end

local function BuildTimingControls()
    local grouped = {}

    for animationId, info in pairs(GameConfig or {}) do
        local style = info.Style or "Unknown"

        if not grouped[style] then
            grouped[style] = {}
        end

        table.insert(grouped[style], {
            AnimationId = animationId,
            Info = info
        })
    end

    local styleNames = {}
    for style in pairs(grouped) do
        table.insert(styleNames, style)
    end
    table.sort(styleNames)

    for _, style in ipairs(styleNames) do
        local animations = grouped[style]

        table.sort(animations, function(a, b)
            return tostring(a.Info.DisplayName or a.AnimationId)
                < tostring(b.Info.DisplayName or b.AnimationId)
        end)

        for _, entry in ipairs(animations) do
            local animationId = entry.AnimationId
            local info = entry.Info
            local displayName = info.DisplayName or tostring(animationId)

            -- Function-driven attacks intentionally have no manual timing slider,
            -- matching the behavior of the original Gakuran UI.
            if not info.ParryFunction then
                local currentSeconds =
                    info.ReactionTime
                    or info.DefaultReactionTime
                    or DefaultReactionTime

                local sliderId =
                    "timing_"
                    .. _sanitizeTimingId(style)
                    .. "_"
                    .. _sanitizeTimingId(animationId)

                local slider = SafeAddSlider(ParryConfigTab, {
                    Id = sliderId,
                    Title = style .. " | " .. displayName .. " (ms)",
                    Min = 0,
                    Max = 1000,
                    Default = math.floor((currentSeconds or 0) * 1000 + 0.5),

                    Callback = function(value)
                        local seconds = value / 1000

                        info.ReactionTime = seconds
                        info.DefaultReactionTime = seconds

                        -- Keep the same lookup table used by the combat engine updated.
                        GameConfig[animationId] = info
                    end
                })

                AnimationIdSliders[animationId] = slider
            end
        end
    end
end

BuildTimingControls()

--==================================================
-- WABI CONTROLS FOR GAKURAN RUNTIME VALUES
--==================================================

SafeAddSlider(ParryConfigTab, {
    Id = "auto_parry_range",
    Title = "Auto Parry Range",
    Min = 1,
    Max = 80,
    Default = AutoParryRange,
    Callback = function(value)
        AutoParryRange = value
    end
})

SafeAddSlider(ParryConfigTab, {
    Id = "probability_to_parry",
    Title = "Probability To Parry",
    Min = 1,
    Max = 100,
    Default = ProbabilityToParry,
    Callback = function(value)
        ProbabilityToParry = value
    end
})

SafeAddSlider(ParryConfigTab, {
    Id = "parry_offset_ms",
    Title = "Parry Offset (ms)",
    Min = -100,
    Max = 100,
    Default = math.floor(ParryOffset * 1000),
    Callback = function(value)
        ParryOffset = value / 1000
    end
})

SafeAddSlider(ParryConfigTab, {
    Id = "parry_window_ms",
    Title = "Parry Window (ms)",
    Min = 0,
    Max = 1000,
    Default = math.floor(ParryWindow * 1000),
    Callback = function(value)
        ParryWindow = value / 1000
    end
})

SafeAddSlider(TargetingTab, {
    Id = "max_cycle_range",
    Title = "Max Cycle Range",
    Min = 7,
    Max = 50,
    Default = MaxCycleRange,
    Callback = function(value)
        MaxCycleRange = value
    end
})


local ProcessToggleKeybind = nil
local AddKeybindDropdown = nil
local ToggleKeybinds = {
    ESP = "None",
    Tracers = "None",
    PlayerHealth = "None",
    SelfHealth = "None",

    AutoParry = "None",
    AutoDodge = "None",
    AutoPlay = "None",
    ParryDebug = "None",

    AutoTargetNearest = "None",
    MultipleTargets = "None",
    IncludeLocalCharacter = "None",
    TargetFacingYou = "None",
    YouFacingTarget = "None",

    HeightMultiplier = "None",
    PingCompensation = "None",
}

local function SetupKeybindEngine()
    --==================================================
    -- TOGGLE KEYBINDS
    --==================================================


    local KeybindOptions = {
        "None",

        "Q", "E", "R", "T", "Y", "U", "I", "O", "P",
        "G", "H", "J", "K", "L",
        "Z", "C", "V", "B", "N", "M",

        "One", "Two", "Three", "Four", "Five",
        "Six", "Seven", "Eight", "Nine", "Zero",

        "F1", "F2", "F3", "F4", "F5", "F6",
        "F7", "F8", "F9", "F10", "F11", "F12",

        "LeftShift", "RightShift",
        "LeftControl", "RightControl",
        "LeftAlt", "RightAlt",
        "Insert", "Home", "End",
        "PageUp", "PageDown",
    }

    local function SetUIToggle(control, value)
        if control ~= nil and type(control.Set) == "function" then
            local ok = pcall(function()
                control:Set(value)
            end)

            if ok then
                return true
            end
        end

        return false
    end

    local function ToggleMainState(stateKey, uiControl)
        local newValue = not (state[stateKey] == true)
        state[stateKey] = newValue

        SetUIToggle(uiControl, newValue)

        if stateKey == "ESP" and not newValue then
            hidePoolFrom(espBoxes, 1)
        elseif stateKey == "Tracers" and not newValue then
            hidePoolFrom(tracerLines, 1)
        elseif stateKey == "PlayerHealth" and not newValue then
            hidePoolFrom(healthTexts, 1)
        elseif stateKey == "SelfHealth" and not newValue then
            myHealthText.Visible = false
        end
    end

    local function ToggleValueControl(valueControl, uiControl)
        local oldValue = valueControl.Get()
        local newValue = not (oldValue == true)

        valueControl.Set(newValue)
        SetUIToggle(uiControl, newValue)
    end

    local function ToggleIncludeLocal()
        IncludeLocalCharacter = not IncludeLocalCharacter
        SetUIToggle(UIToggles.IncludeLocalCharacter, IncludeLocalCharacter)
    end

    local ToggleKeybindActions = {
        ESP = function()
            ToggleMainState("ESP", UIToggles.ESP)
        end,

        Tracers = function()
            ToggleMainState("Tracers", UIToggles.Tracers)
        end,

        PlayerHealth = function()
            ToggleMainState("PlayerHealth", UIToggles.PlayerHealth)
        end,

        SelfHealth = function()
            ToggleMainState("SelfHealth", UIToggles.SelfHealth)
        end,

        AutoParry = function()
            ToggleValueControl(AutoParryToggle, UIToggles.AutoParry)
        end,

        AutoDodge = function()
            ToggleValueControl(AutoDodgeToggle, UIToggles.AutoDodge)
        end,

        AutoPlay = function()
            ToggleValueControl(AutoPlayToggle, UIToggles.AutoPlay)
        end,

        ParryDebug = function()
            ToggleValueControl(ParryDebugToggle, UIToggles.ParryDebug)
        end,

        AutoTargetNearest = function()
            ToggleValueControl(AutoTargetNearest, UIToggles.AutoTargetNearest)
        end,

        MultipleTargets = function()
            ToggleValueControl(MultiTarget, UIToggles.MultipleTargets)
        end,

        IncludeLocalCharacter = function()
            ToggleIncludeLocal()
        end,

        TargetFacingYou = function()
            ToggleValueControl(TargetFacingYou, UIToggles.TargetFacingYou)
        end,

        YouFacingTarget = function()
            ToggleValueControl(YouFacingTarget, UIToggles.YouFacingTarget)
        end,

        HeightMultiplier = function()
            ToggleValueControl(HeightToggle, UIToggles.HeightMultiplier)
        end,

        PingCompensation = function()
            ToggleValueControl(PingCompensateToggle, UIToggles.PingCompensation)
        end,
    }

    local function KeyCodeName(input)
        if input == nil or input.KeyCode == nil then
            return nil
        end

        local ok, name = pcall(function()
            return input.KeyCode.Name
        end)

        if ok then
            return name
        end

        return nil
    end

    ProcessToggleKeybind = function(input)
        local pressedName = KeyCodeName(input)

        if pressedName == nil or pressedName == "Unknown" then
            return false
        end

        local triggered = false

        for actionName, keyName in pairs(ToggleKeybinds) do
            if keyName ~= "None" and keyName == pressedName then
                local action = ToggleKeybindActions[actionName]

                if type(action) == "function" then
                    action()
                    triggered = true
                end
            end
        end

        return triggered
    end

    AddKeybindDropdown = function(id, title, actionName)
        SafeAddDropdown(ConfigTab, {
            Id = id,
            Title = title,
            Options = KeybindOptions,
            Default = ToggleKeybinds[actionName],

            Callback = function(value)
                ToggleKeybinds[actionName] = value
                print("[Keybind] " .. title .. " -> " .. tostring(value))
            end
        })
    end
end

SetupKeybindEngine()

local function SetupPresetConfigUI()
    --==================================================
    -- CONFIG / SAVED PRESETS
    --==================================================

    local HttpService = game:GetService("HttpService")
    local PRESET_FILE = "fftm_presets.json"

    local Presets = {}
    local SelectedPresetSlot = "Slot 1"
    local CurrentTheme = "AmethystDark"

    local function CanUsePersistentFiles()
        return type(writefile) == "function"
            and type(readfile) == "function"
            and type(isfile) == "function"
    end

    local function ReadPresetFile()
        if not CanUsePersistentFiles() then
            return
        end

        local okExists, exists = pcall(function()
            return isfile(PRESET_FILE)
        end)

        if not okExists or not exists then
            return
        end

        local okRead, raw = pcall(function()
            return readfile(PRESET_FILE)
        end)

        if not okRead or type(raw) ~= "string" or raw == "" then
            return
        end

        local okDecode, decoded = pcall(function()
            return HttpService:JSONDecode(raw)
        end)

        if okDecode and type(decoded) == "table" then
            Presets = decoded
            print("[Config] Loaded saved preset file.")
        end
    end

    local function WritePresetFile()
        if not CanUsePersistentFiles() then
            return false
        end

        local okEncode, raw = pcall(function()
            return HttpService:JSONEncode(Presets)
        end)

        if not okEncode then
            warn("[Config] Could not encode presets: " .. tostring(raw))
            return false
        end

        local okWrite, err = pcall(function()
            writefile(PRESET_FILE, raw)
        end)

        if not okWrite then
            warn("[Config] Could not save presets: " .. tostring(err))
            return false
        end

        return true
    end

    local function CopyAnimationTimings()
        local timings = {}

        for animationId, info in pairs(GameConfig) do
            if type(info) == "table" then
                local value = info.ReactionTime

                if value == nil then
                    value = info.DefaultReactionTime
                end

                if type(value) == "number" then
                    timings[tostring(animationId)] = value
                end
            end
        end

        return timings
    end

    local function CapturePreset()
        return {
            Theme = CurrentTheme,

            Visuals = {
                ESP = state.ESP,
                Tracers = state.Tracers,
                TracerTransparency = state.TracerTransparency,
                PlayerHealth = state.PlayerHealth,
                SelfHealth = state.SelfHealth,
            },

            Combat = {
                AutoParry = AutoParryToggle.Get(),
                AutoDodge = AutoDodgeToggle.Get(),
                AutoPlay = AutoPlayToggle.Get(),
                ParryDebug = ParryDebugToggle.Get(),
                PingCompensation = PingCompensateToggle.Get(),
                HeightMultiplier = HeightToggle.Get(),

                AutoTargetNearest = AutoTargetNearest.Get(),
                MultipleTargets = MultiTarget.Get(),
                IncludeLocalCharacter = IncludeLocalCharacter,
                TargetFacingYou = TargetFacingYou.Get(),
                YouFacingTarget = YouFacingTarget.Get(),

                AutoParryRange = AutoParryRange,
                MaxCycleRange = MaxCycleRange,
                ProbabilityToParry = ProbabilityToParry,
                ParryOffset = ParryOffset,
                ParryWindow = ParryWindow,
            },

            AnimationTimings = CopyAnimationTimings(),

            Whitelist = CopyWhitelist(),

            Keybinds = {
                ESP = ToggleKeybinds.ESP,
                Tracers = ToggleKeybinds.Tracers,
                PlayerHealth = ToggleKeybinds.PlayerHealth,
                SelfHealth = ToggleKeybinds.SelfHealth,

                AutoParry = ToggleKeybinds.AutoParry,
                AutoDodge = ToggleKeybinds.AutoDodge,
                AutoPlay = ToggleKeybinds.AutoPlay,
                ParryDebug = ToggleKeybinds.ParryDebug,

                AutoTargetNearest = ToggleKeybinds.AutoTargetNearest,
                MultipleTargets = ToggleKeybinds.MultipleTargets,
                IncludeLocalCharacter = ToggleKeybinds.IncludeLocalCharacter,
                TargetFacingYou = ToggleKeybinds.TargetFacingYou,
                YouFacingTarget = ToggleKeybinds.YouFacingTarget,

                HeightMultiplier = ToggleKeybinds.HeightMultiplier,
                PingCompensation = ToggleKeybinds.PingCompensation,
            },
        }
    end

    local function ApplyAnimationTimings(timings)
        if type(timings) ~= "table" then
            return
        end

        for animationId, seconds in pairs(timings) do
            local info = GameConfig[animationId]

            if info == nil then
                local numericId = tonumber(animationId)

                if numericId ~= nil then
                    info = GameConfig[numericId]
                end
            end

            if type(info) == "table" and type(seconds) == "number" then
                info.ReactionTime = seconds
                info.DefaultReactionTime = seconds

                local slider =
                    AnimationIdSliders[animationId]
                    or AnimationIdSliders[tonumber(animationId)]

                if slider ~= nil and type(slider.Set) == "function" then
                    pcall(function()
                        slider:Set(
                            math.floor(seconds * 1000 + 0.5)
                        )
                    end)
                end
            end
        end
    end

    local function ApplyPreset(preset)
        if type(preset) ~= "table" then
            return false
        end

        local visuals = preset.Visuals

        if type(visuals) == "table" then
            if type(visuals.ESP) == "boolean" then
                state.ESP = visuals.ESP
            end

            if type(visuals.Tracers) == "boolean" then
                state.Tracers = visuals.Tracers
            end

            if type(visuals.TracerTransparency) == "number" then
                state.TracerTransparency = visuals.TracerTransparency
            end

            if type(visuals.PlayerHealth) == "boolean" then
                state.PlayerHealth = visuals.PlayerHealth
            end

            if type(visuals.SelfHealth) == "boolean" then
                state.SelfHealth = visuals.SelfHealth
            end
        end

        local combat = preset.Combat

        if type(combat) == "table" then
            if type(combat.AutoParry) == "boolean" then
                AutoParryToggle.Set(combat.AutoParry)
            end

            if type(combat.AutoDodge) == "boolean" then
                AutoDodgeToggle.Set(combat.AutoDodge)
            end

            if type(combat.AutoPlay) == "boolean" then
                AutoPlayToggle.Set(combat.AutoPlay)
            end

            if type(combat.ParryDebug) == "boolean" then
                ParryDebugToggle.Set(combat.ParryDebug)
            end

            if type(combat.PingCompensation) == "boolean" then
                PingCompensateToggle.Set(combat.PingCompensation)
            end

            if type(combat.HeightMultiplier) == "boolean" then
                HeightToggle.Set(combat.HeightMultiplier)
            end

            if type(combat.AutoTargetNearest) == "boolean" then
                AutoTargetNearest.Set(combat.AutoTargetNearest)
            end

            if type(combat.MultipleTargets) == "boolean" then
                MultiTarget.Set(combat.MultipleTargets)
            end

            if type(combat.IncludeLocalCharacter) == "boolean" then
                IncludeLocalCharacter = combat.IncludeLocalCharacter
            end

            if type(combat.TargetFacingYou) == "boolean" then
                TargetFacingYou.Set(combat.TargetFacingYou)
            end

            if type(combat.YouFacingTarget) == "boolean" then
                YouFacingTarget.Set(combat.YouFacingTarget)
            end

            if type(combat.AutoParryRange) == "number" then
                AutoParryRange = combat.AutoParryRange
            end

            if type(combat.MaxCycleRange) == "number" then
                MaxCycleRange = combat.MaxCycleRange
            end

            if type(combat.ProbabilityToParry) == "number" then
                ProbabilityToParry = combat.ProbabilityToParry
            end

            if type(combat.ParryOffset) == "number" then
                ParryOffset = combat.ParryOffset
            end

            if type(combat.ParryWindow) == "number" then
                ParryWindow = combat.ParryWindow
            end
        end

        if type(preset.Theme) == "string" then
            CurrentTheme = preset.Theme

            pcall(function()
                Library:SetTheme(CurrentTheme)
            end)
        end

        ApplyWhitelist(preset.Whitelist)
        ApplyAnimationTimings(preset.AnimationTimings)

        if type(preset.Keybinds) == "table" then
            for actionName, keyName in pairs(preset.Keybinds) do
                if ToggleKeybinds[actionName] ~= nil
                    and type(keyName) == "string" then

                    ToggleKeybinds[actionName] = keyName
                end
            end
        end

        return true
    end

    ReadPresetFile()

    SafeAddDropdown(ConfigTab, {
        Id = "preset_slot",
        Title = "Preset Slot",
        Options = {
            "Slot 1",
            "Slot 2",
            "Slot 3"
        },
        Default = "Slot 1",

        Callback = function(value)
            SelectedPresetSlot = value
        end
    })


    -- Toggle keybinds
    AddKeybindDropdown("kb_esp", "ESP Key", "ESP")
    AddKeybindDropdown("kb_tracers", "Tracers Key", "Tracers")
    AddKeybindDropdown("kb_player_health", "Player Health Key", "PlayerHealth")
    AddKeybindDropdown("kb_self_health", "Self Health Key", "SelfHealth")

    AddKeybindDropdown("kb_auto_parry", "Auto Parry Key", "AutoParry")
    AddKeybindDropdown("kb_auto_dodge", "Auto Dodge Key", "AutoDodge")
    AddKeybindDropdown("kb_auto_play", "Auto Play Key", "AutoPlay")
    AddKeybindDropdown("kb_parry_debug", "Debug Parry Key", "ParryDebug")

    AddKeybindDropdown(
        "kb_auto_target",
        "Auto Target Key",
        "AutoTargetNearest"
    )

    AddKeybindDropdown(
        "kb_multi_target",
        "Multiple Targets Key",
        "MultipleTargets"
    )

    AddKeybindDropdown(
        "kb_include_local",
        "Include Local Key",
        "IncludeLocalCharacter"
    )

    AddKeybindDropdown(
        "kb_target_facing",
        "Target Facing You Key",
        "TargetFacingYou"
    )

    AddKeybindDropdown(
        "kb_you_facing",
        "You Facing Target Key",
        "YouFacingTarget"
    )

    AddKeybindDropdown(
        "kb_height",
        "Height Multiplier Key",
        "HeightMultiplier"
    )

    AddKeybindDropdown(
        "kb_ping",
        "Ping Compensation Key",
        "PingCompensation"
    )

    SafeAddButton(ConfigTab, {
        Title = "Save Selected Preset",

        Callback = function()
            Presets[SelectedPresetSlot] = CapturePreset()

            local persistent = WritePresetFile()

            if persistent then
                Notify(
                    "Config",
                    SelectedPresetSlot .. " saved.",
                    3
                )
            else
                Notify(
                    "Config",
                    SelectedPresetSlot .. " saved for this session.",
                    4
                )
            end

            print("[Config] Saved " .. SelectedPresetSlot)
        end
    })

    SafeAddButton(ConfigTab, {
        Title = "Load Selected Preset",

        Callback = function()
            local preset = Presets[SelectedPresetSlot]

            if type(preset) ~= "table" then
                Notify(
                    "Config",
                    SelectedPresetSlot .. " is empty.",
                    3
                )
                return
            end

            if ApplyPreset(preset) then
                Notify(
                    "Config",
                    SelectedPresetSlot .. " loaded.",
                    3
                )

                print("[Config] Loaded " .. SelectedPresetSlot)
            end
        end
    })

    SafeAddButton(ConfigTab, {
        Title = "Delete Selected Preset",

        Callback = function()
            Presets[SelectedPresetSlot] = nil
            WritePresetFile()

            Notify(
                "Config",
                SelectedPresetSlot .. " deleted.",
                3
            )

            print("[Config] Deleted " .. SelectedPresetSlot)
        end
    })

    SafeAddDropdown(ConfigTab, {
        Id = "config_theme",
        Title = "Theme",
        Options = Library.Themes,
        Default = "AmethystDark",

        Callback = function(value)
            CurrentTheme = value
            Library:SetTheme(value)
        end
    })

    SafeAddButton(ConfigTab, {
        Title = "Clear Drawings",

        Callback = function()
            myHealthText.Visible = false
            hidePoolFrom(espBoxes, 1)
            hidePoolFrom(tracerLines, 1)
            hidePoolFrom(healthTexts, 1)

            Notify(
                "Config",
                "ESP drawings cleared.",
                3
            )
        end
    })

    if CanUsePersistentFiles() then
        print("[Config] Persistent presets enabled: " .. PRESET_FILE)
    else
        print("[Config] File APIs unavailable; presets are session-only.")
    end
end

SetupPresetConfigUI()

local function SetupTargetFolderUI()
    SafeAddButton(TargetingTab, {
        Title = "Cycle Target Now",

        Callback = function()
            print("[Target] UI cycle button pressed")
            CycleEvent(true)
        end
    })

    SafeAddButton(TargetingTab, {
        Title = "Whitelist Selected Target(s)",

        Callback = function()
            if #TargetCharacters == 0 then
                Notify("Whitelist", "No target is currently selected.", 3)
                return
            end

            local names = {}

            for _, character in ipairs(TargetCharacters) do
                if SetCharacterWhitelisted(character, true) then
                    names[#names + 1] = GetCharacterDisplayName(character)
                end
            end

            UpdateTargetCharacters({})
            CycleEvent()

            Notify(
                "Whitelist",
                "Added: " .. table.concat(names, ", "),
                4
            )
        end
    })

    SafeAddButton(TargetingTab, {
        Title = "Remove Last Selected From Whitelist",

        Callback = function()
            local removed = {}

            for _, character in ipairs(TargetSelectionState.LastSelected) do
                if IsCharacterWhitelisted(character) then
                    SetCharacterWhitelisted(character, false)
                    removed[#removed + 1] =
                        GetCharacterDisplayName(character)
                end
            end

            CycleEvent()

            Notify(
                "Whitelist",
                #removed > 0
                    and ("Removed: " .. table.concat(removed, ", "))
                    or "Last selected target(s) were not whitelisted.",
                4
            )
        end
    })

    SafeAddButton(TargetingTab, {
        Title = "Clear Whitelist",

        Callback = function()
            table.clear(TargetSelectionState.Whitelist)
            CycleEvent()
            Notify("Whitelist", "Whitelist cleared.", 3)
        end
    })

    do
        local folders = GetAllFoldersInWorkspace()
        local defaultFolder = nil

        if workspace:FindFirstChild("Players") then
            defaultFolder = "Players"
        elseif workspace:FindFirstChild("Live") then
            defaultFolder = "Live"
        elseif #folders > 0 then
            defaultFolder = folders[1]
        end

        if defaultFolder then
            SelectedFolder = defaultFolder
        end

        SafeAddDropdown(TargetingTab, {
            Id = "live_folder",
            Title = "Live Folder",
            Options = folders,
            Default = defaultFolder,
            Callback = function(value)
                SelectedFolder = value
                CycleEvent()
            end
        })
    end
end

SetupTargetFolderUI()

local function SetupManualTargetContextAction()
    local ok, err = pcall(function()
        ContextActionService:UnbindAction("FFTM_ManualTargetCycle")

        ContextActionService:BindAction(
            "FFTM_ManualTargetCycle",
            function(actionName, inputState, inputObject)
                if inputState == Enum.UserInputState.Begin then
                    print("[Target] ContextActionService detected X")
                    CycleEvent(true)
                end

                return Enum.ContextActionResult.Pass
            end,
            false,
            Enum.KeyCode.X
        )
    end)

    if ok then
        print("[Target] ContextActionService X binding installed")
    else
        warn("[Target] ContextActionService binding failed: " .. tostring(err))
    end
end

SetupManualTargetContextAction()

Library:Notify({
    Title = "Loaded",
    Content = "Wabi visuals + Gakuran dependencies loaded.",
    Duration = 4
})

-- Prime the target list once after the folder dropdown has selected a default.
task.defer(function()
    task.wait(0.25)
    if SelectedFolder then
        CycleEvent()
    end
end)


-- ==========================================
-- Input & Loop
-- ==========================================
UIS.InputBegan:Connect(function(input, gameProcessed)
    -- Manual targeting gets first priority.
    -- RhythmServiceUI used to swallow X before it could reach CycleEvent().
    if input.KeyCode == CycleKeybind then
        if not ManualCycleKeyWasDown then
            print("[Target] X InputBegan fallback -> manual cycle")
            CycleEvent(true)
        end

        ManualCycleKeyWasDown = true
        return
    end

    if gameProcessed then
        return
    end

    local RhythmServiceUI =
        game.Players.LocalPlayer.PlayerGui:FindFirstChild("RhythmServiceUI")

    if RhythmServiceUI then
        return
    end

    if ProcessToggleKeybind(input) then
        return
    end

    if input.KeyCode == Enum.KeyCode.F then 
        local localChar = LocalPlayer.Character
        LocalTracker:Update(localChar) 
        OnInputF()
        --[[if AutoParryToggle.Get() == false and LastPendingRegData then  
            InputRegisteredTime = os.clock()
            
            if (InputRegisteredTime - LastReactionTime) < 1 then  
                 print("probably on cooldown")
            end
            if not LastPendingRegData then return end 
            local Difference = os.clock() - LastPendingRegData.StartTime
            local string = string.format("DETECT: You pressed F at %.2f", os.clock() - LastPendingRegData.StartTime)
--            print(string)
        --end]]
    end
end)


local STATE_MACHINE_TICK = 0.05
local UTILITY_TICK = 0.5 -- Run 2 times per second
local LastCycleCheck = 0

local ManualCycleKeyWasDown = false

local function IsManualCycleKeyDown()
    local down = false

    -- Preferred: normal Roblox physical-key polling.
    local ok = pcall(function()
        down = UIS:IsKeyDown(CycleKeybind)
    end)

    if ok and down then
        return true
    end

    -- Alternate Roblox polling path.
    local keysOk, pressedKeys = pcall(function()
        return UIS:GetKeysPressed()
    end)

    if keysOk and type(pressedKeys) == "table" then
        for _, inputObject in ipairs(pressedKeys) do
            local keyOk, keyCode = pcall(function()
                return inputObject.KeyCode
            end)

            if keyOk and keyCode == CycleKeybind then
                return true
            end
        end
    end

    -- Matcha fallback if UserInputService polling is unavailable.
    if type(iskeypressed) == "function" then
        local fallbackOk, fallbackDown = pcall(function()
            return iskeypressed(string.byte("X"))
        end)

        if fallbackOk and fallbackDown then
            return true
        end
    end

    return false
end

local function PollManualCycleKey()
    local down = IsManualCycleKeyDown()

    if down and not ManualCycleKeyWasDown then
        print("[Target] X polling detected -> manual cycle")
        CycleEvent(true)
    end

    ManualCycleKeyWasDown = down
end

local function MainLoop()
    PollManualCycleKey()

    local now = os.clock()
    local localChar = LocalPlayer.Character
    if not localChar then return end

    local localHumanoid = localChar:FindFirstChildOfClass("Humanoid")
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")

    if not localHumanoid or localHumanoid.Health <= 0 or not localRoot then
        return
    end

   
    LocalTracker:Update(localChar)
    EvaluateParryTriggers()
    ParryTask()
    -- AutoPlay is optional. If the game rhythm UI changes, disable only AutoPlay.
    if AutoPlayToggle.Get() then
        local ok, err = pcall(AutoPlayTask)
        if not ok then
            warn("[AutoPlay] " .. tostring(err))
            AutoPlayToggle.Set(false)
        end
    end
    
    scheduler.update()

    if (now - LastCycleCheck >= UTILITY_TICK) then
        LastCycleCheck = now
        if AutoTargetNearest.Get() then
            CycleEvent(false)
        end

        ProcessEspAndLogging()
    end
end

RunService.RenderStepped:Connect(MainLoop)
--RunService.Heartbeat:Connect(MainLoop)

-- Existing base visual loop
RunService.RenderStepped:Connect(function()
    local players = Players:GetPlayers()
    updateEspTracers(players)
    updateHealth(players)
    UpdateSelectedMarkers()
end)

print("Free Fortnite Cheats TM | Wabi tabs safe-fallback build loaded")
