--// WABI SABI UI
loadstring(game:HttpGet("https://scripts.wabisabi.mom/wabi-sabi-ui-lib.lua"))()

local Library = WabiSabi

local Window = Library:CreateWindow({
    Title = "Free Fortnite Cheats TM",
    SubTitle = "v1.0",
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

Main:AddToggle({
    Id = "esp",
    Title = "ESP",
    Default = false,

    Callback = function(value)
        state.ESP = value
        print("ESP:", value)
    end
})

Main:AddToggle({
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

Main:AddToggle({
    Id = "player_health",
    Title = "Player Health",
    Default = false,

    Callback = function(value)
        state.PlayerHealth = value
        print("Player Health:", value)
    end
})

--// SELF HEALTH

Main:AddToggle({
    Id = "self_health",
    Title = "Self Health",
    Default = false,

    Callback = function(value)
        state.SelfHealth = value
        print("Self Health:", value)
    end
})

--// THEME DROPDOWN

Main:AddDropdown({
    Id = "theme",
    Title = "Theme",
    Options = Library.Themes,
    Default = "Vynixu",

    Callback = function(value)
        Library:SetTheme(value)
        print("Theme:", value)
    end
})

--// NOTIFICATION
Library:Notify({
    Title = "Loaded",
    Content = "Visuals menu ready.",
    Duration = 4
})

--// MAIN LOOP
RunService.RenderStepped:Connect(function()
    local players = Players:GetPlayers()

    updateEspTracers(players)
    updateHealth(players)
end)

print("Visuals loaded | Wabi Sabi UI")