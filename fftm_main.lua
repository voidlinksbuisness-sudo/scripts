-- FFTM_MAIN_BUILD = "2026-08-30-BACKGROUND-ASPECT-1"
--// INS UI
local Library = {
    Raw = (function()
        local source = game:HttpGet(
            "https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/506859d3787450b6296254b1bb05a9c6d77ebeb2/uilib.min.lua"
        )
        if type(source) ~= "string" then return nil end

        -- INS normally derives background width from window width, which
        -- stretches the image during resize. Treat BackdropWide as a real
        -- aspect ratio and derive width from the rendered image height.
        local patched, replacements = string.gsub(
            source,
            "local Wide = State%.BackdropWide and State%.BackdropWide %* State%.W or PaneHeight %* 0%.6%s+local Tall = State%.BackdropWide and %(State%.BackdropTall or 1%) %* PaneHeight or PaneHeight",
            "local Tall = (State.BackdropTall or 1) * PaneHeight\n      local Wide = State.BackdropWide and State.BackdropWide * Tall or Tall * 0.6",
            1
        )

        if replacements ~= 1 then
            warn("[UI] Could not apply background aspect-ratio patch.")
            patched = source
        end

        return loadstring(patched)()
    end)() or INSUI
}

Library.BackgroundImageUrl =
    "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/748e48118250bda21774d36a941578a2eba08eb3/assets/fftm-ui-background.png"
Library.BackgroundAspectRatio = 1800 / 900
Library.RawBackgroundImageSetter = Library.Raw.SetBackgroundImage
function Library.Raw:SetBackgroundImage(source, alpha, aspectRatio, heightFraction)
    if source == Library.BackgroundImageUrl and aspectRatio == nil then
        aspectRatio = Library.BackgroundAspectRatio
        heightFraction = 1
    end

    return Library.RawBackgroundImageSetter(
        self,
        source,
        alpha,
        aspectRatio,
        heightFraction
    )
end

Library.Themes = Library.Raw:ThemePresets()

function Library:AdaptRow(row)
    row.SetValue = row.Set
    row.SetState = row.Set
    row.GetValue = row.Get
    return row
end

function Library:CreateWindow(config)
    local rawWindow = self.Raw:CreateWindow({
        title = config.Title,
        subtitle = config.SubTitle,
        size = Vector2.new(760, 560),
        menuKey = "none",
        theme = "Waifu",
        opacity = 1,
        rounding = 1,
        rowLines = true,
        checkboxStyle = false,
        keybindOverlay = true,
        smartFps = true,
        gameInput = true,
        spotlight = true,
        autoSave = false,
        startOpen = true,
    })
    local window = { Raw = rawWindow }

    function window:AddTab(tabConfig)
        local rawTab = self.Raw:Tab(tabConfig.Title, tabConfig.Icon)
        local tab = {
            Raw = rawTab,
            Section = rawTab:Section(tabConfig.Title, "Full")
        }

        function tab:AddToggle(control)
            return Library:AdaptRow(self.Section:Toggle(
                control.Title,
                control.Default,
                function(value)
                    control.Callback(value)
                    Library:NotifyToggleState(control.Title, value)
                end,
                control.Description
            ))
        end

        function tab:AddSlider(control)
            return Library:AdaptRow(self.Section:Slider(
                control.Title,
                control.Default,
                control.Step or 1,
                control.Min,
                control.Max,
                control.Suffix or "",
                control.Callback,
                control.Description
            ))
        end

        function tab:AddDropdown(control)
            local row
            row = self.Section:Dropdown(
                control.Title,
                control.Default == nil and {} or { control.Default },
                control.Options or {},
                false,
                function(values)
                    control.Callback(values and values[1])
                end,
                control.Description,
                true
            )
            row.SetValue = function(_, value)
                return row:Set(value == nil and {} or { value })
            end
            row.SetState = row.SetValue
            row.GetValue = function()
                return row.Value and row.Value[1]
            end
            row.SetOptions = row.UpdateChoices
            row.SetValues = row.UpdateChoices
            return row
        end

        function tab:AddButton(control)
            return Library:AdaptRow(self.Section:Button(
                control.Title,
                control.Callback,
                control.Description
            ))
        end

        function tab:AddKeybind(control)
            local row
            row = self.Section:Keybind(
                control.Title,
                control.Default or "none",
                function(value)
                    -- Native INS config callbacks are value restoration, not
                    -- hotkey presses. Reconcile them after the load completes.
                    if Library.LoadingNativeConfig then return end
                    if type(value) == "boolean" then
                        if value or row.Mode == "Toggle" then
                            control.Callback()
                        end
                    elseif type(value) == "string" then
                        if string.lower(value) == "delete" then
                            row.Value = "none"
                            value = nil
                        end
                        if control.ChangedCallback then
                            control.ChangedCallback(value)
                        end
                    end
                end,
                control.Description
            )

            -- INS polls attached binds for actions. Pointing this keybind row
            -- at itself preserves its dedicated keybind appearance while also
            -- making it participate in that polling path.
            row.Bind = row
            row.Mode = control.Mode or "Hold"
            row.SetValue = function(_, value, mode)
                row.Value = value and string.lower(tostring(value)) or "none"
                row.Mode = mode or row.Mode
                if control.ChangedCallback then
                    control.ChangedCallback(row.Value)
                end
                return row
            end
            row.GetValue = function()
                return row.Value
            end
            return row
        end

        function tab:AddSection(title, side, description)
            return setmetatable({
                Raw = self.Raw,
                Section = self.Raw:Section(title, side, description)
            }, { __index = self })
        end

        return tab
    end

    function window:Destroy()
        self.Raw:Destroy()
    end

    window.Unload = window.Destroy
    return window
end

function Library:Notify(config)
    self.Raw:Notify(
        tostring(config.Title or "Notice"),
        tostring(config.Content or ""),
        config.Duration or 4,
        config.Kind
    )
end

function Library:NotifyToggleState(title, enabled)
    if type(enabled) ~= "boolean"
        or self.LoadingNativeConfig
        or self.SuppressToggleNotifications then

        return false
    end

    self:Notify({
        Title = "Feature changed",
        Content = tostring(title or "Feature")
            .. (enabled and " is enabled." or " is disabled."),
        Duration = 2.5,
        Kind = enabled and "success" or "warning",
    })
    return true
end

function Library:Minimize()
    self.Raw:Toggle()
end

function Library:SetTheme(name)
    local selected = name == "AmethystDark" and "Grape" or name
    self.Raw:ApplyThemePreset(selected)
end

function Library:Unload()
    self.Raw:Destroy()
end

local Window = Library:CreateWindow({
    Title = "Free Fortnite Cheats TM",
    SubTitle = "v1.1 PRESETS",
})

Library.Raw:SetBackgroundImage(
    Library.BackgroundImageUrl,
    0.14
)

Library.Raw:Category("VISUALS")

local Main = Window:AddTab({
    Title = "Main",
    Icon = "house"
})

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local SelectedFolder = nil
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--==================================================
-- FFTM REMOTE SESSION CONTROL
--==================================================
FFTM_MAIN_VERSION = "2026-08-30-BACKGROUND-ASPECT-1"
FFTM_API_URL = "https://fftm-parry-api.voidlinksbuisness.workers.dev"
FFTM_RUNNING = true
FFTM_LAST_HEARTBEAT_AT = -1000000
FFTM_LAST_ADMIN_REFRESH_AT = 0
FFTM_SESSION_ID = nil
FFTM_ADMIN_KEY = nil
FFTM_ADMIN_SESSIONS = {}
FFTM_ADMIN_SELECTED_SESSION = nil

-- Exact server identity used by the heartbeat and Admin panel.
FFTM_SERVER_PLACE_ID = tostring(game.PlaceId or 0)
FFTM_SERVER_JOB_ID = tostring(game.JobId or "")

if FFTM_SERVER_JOB_ID ~= "" then
    FFTM_SERVER_KEY =
        FFTM_SERVER_PLACE_ID .. ":" .. FFTM_SERVER_JOB_ID
else
    FFTM_SERVER_KEY =
        FFTM_SERVER_PLACE_ID .. ":jobid-unavailable"
end

do
    local okGuid, guid = pcall(function()
        return game:GetService("HttpService"):GenerateGUID(false)
    end)

    FFTM_SESSION_ID = okGuid and guid
        or (tostring(LocalPlayer.UserId) .. "-" .. tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999)))

    -- Matcha does not expose getgenv(), so prefer _G.
    -- Keep getgenv() support for executors that do provide it.
    if type(_G) == "table" then
        FFTM_ADMIN_KEY = _G.FFTM_ADMIN_KEY
    end

    if FFTM_ADMIN_KEY == nil and type(getgenv) == "function" then
        local okEnv, env = pcall(getgenv)

        if okEnv and type(env) == "table" then
            FFTM_ADMIN_KEY = env.FFTM_ADMIN_KEY
        end
    end
end

function FFTMUrlEncode(value)
    value = tostring(value or "")

    return value:gsub("([^%w%-_%.~])", function(char)
        return string.format("%%%02X", string.byte(char))
    end)
end

function FFTMGetJson(path, query)
    local parts = {}

    if type(query) == "table" then
        for key, value in pairs(query) do
            table.insert(
                parts,
                FFTMUrlEncode(key) .. "=" .. FFTMUrlEncode(value)
            )
        end
    end

    -- Always make the request unique so intermediary caches cannot return
    -- an old heartbeat/admin response.
    table.insert(
        parts,
        "cb=" .. FFTMUrlEncode(
            tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
        )
    )

    local url = FFTM_API_URL .. path

    if #parts > 0 then
        url = url .. "?" .. table.concat(parts, "&")
    end

    local ok, responseBody = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or type(responseBody) ~= "string" then
        return nil
    end

    local decodeOk, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(responseBody)
    end)

    if not decodeOk or type(decoded) ~= "table" then
        return nil
    end

    return decoded
end

function FFTMSendHeartbeat()
    if not FFTM_RUNNING then
        return
    end

    local data = FFTMGetJson("/heartbeat", {
        session_id = FFTM_SESSION_ID,
        user_id = LocalPlayer.UserId,
        username = LocalPlayer.Name,
        display_name = LocalPlayer.DisplayName,
        version = FFTM_MAIN_VERSION,
        place_id = FFTM_SERVER_PLACE_ID,
        job_id = FFTM_SERVER_JOB_ID,
        server_key = FFTM_SERVER_KEY,
    })

    if type(data) == "table" and data.shutdown == true then
        FFTMShutdown()
    end
end

function FFTMStartBackgroundPolling()
    if FFTM_BACKGROUND_POLLING_STARTED then
        return
    end

    FFTM_BACKGROUND_POLLING_STARTED = true
    FFTM_LAST_HEARTBEAT_AT = os.clock()

    -- Matcha HTTP is synchronous. Yield before each request and keep it off
    -- RenderStepped so a slow response cannot pause combat/visual callbacks.
    task.spawn(function()
        while FFTM_RUNNING do
            wait(10)
            if not FFTM_RUNNING then break end

            FFTM_LAST_HEARTBEAT_AT = os.clock()
            pcall(FFTMSendHeartbeat)

            if type(FFTM_ADMIN_KEY) == "string"
                and FFTM_ADMIN_KEY ~= ""
                and type(FFTMRefreshAdminDropdown) == "function"
                and (os.clock() - FFTM_LAST_ADMIN_REFRESH_AT) >= 30 then

                FFTM_LAST_ADMIN_REFRESH_AT = os.clock()
                pcall(FFTMRefreshAdminDropdown)
            end
        end

        FFTM_BACKGROUND_POLLING_STARTED = false
    end)
end

function FFTMFetchAdminSessions()
    if type(FFTM_ADMIN_KEY) ~= "string" or FFTM_ADMIN_KEY == "" then
        return {}
    end

    local data = FFTMGetJson("/admin/sessions", {
        admin_key = FFTM_ADMIN_KEY,
        place_id = FFTM_SERVER_PLACE_ID,
        job_id = FFTM_SERVER_JOB_ID,
        server_key = FFTM_SERVER_KEY,
    })

    if type(data) ~= "table" then
        Notify(
            "Admin",
            "Admin API returned no valid response.",
            4
        )
        return {}
    end

    if data.ok ~= true then
        Notify(
            "Admin",
            "Admin API error: " .. tostring(data.error or "unknown"),
            4
        )
        return {}
    end

    if type(data.sessions) ~= "table" then
        Notify(
            "Admin",
            "Admin API returned no sessions list.",
            4
        )
        return {}
    end

    FFTM_ADMIN_SESSIONS = data.sessions
    return FFTM_ADMIN_SESSIONS
end

function FFTMAdminCommand(path, sessionId)
    if type(FFTM_ADMIN_KEY) ~= "string" or FFTM_ADMIN_KEY == "" then
        return false
    end

    if type(sessionId) ~= "string" or sessionId == "" then
        return false
    end

    local data = FFTMGetJson(path, {
        admin_key = FFTM_ADMIN_KEY,
        session_id = sessionId,
        place_id = FFTM_SERVER_PLACE_ID,
        job_id = FFTM_SERVER_JOB_ID,
        server_key = FFTM_SERVER_KEY,
    })

    return type(data) == "table" and data.ok == true
end

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
    ESPDistance = 50,
    ESPDistanceSquared = 50 * 50,

    PlayerHealth = false,
    SelfHealth = false,

    PlayerHealthDistance = 50,
    PlayerHealthDistanceSquared = 50 * 50,
}
_G.ESPMaxDistance = 50
_G.ESPMaxDistanceSquared = 50 * 50
_G.HealthESPMaxDistance = 50
_G.HealthESPMaxDistanceSquared = 50 * 50


--// PLAYER HELPERS
local VisualRuntime = {
    Players = {},
    PlayerIndices = {},
    CharacterCache = {},
    HealthTextValues = {},
    EspTracersWereActive = false,
    PlayerHealthWasActive = false,
    HealthHeadOffset = Vector3.new(0, 3, 0),
    PlayerSetChanged = false,
    LastVisualErrorAt = -1000000,
    LastParryEspErrorAt = -1000000,
    AnimationIdEspEnabled = true,
    EspFrame = {},
    HealthFrame = {},
    FrameId = 0,
}

function VisualRuntime.RefreshPlayers()
    local players = VisualRuntime.Players
    local playerIndices = VisualRuntime.PlayerIndices
    local characterCache = VisualRuntime.CharacterCache

    local refreshOk, latestPlayers = pcall(function()
        return Players:GetPlayers()
    end)

    -- Keep the last valid cache when Matcha briefly fails enumeration. An
    -- empty partial rebuild makes every overlay jump or disappear together.
    if not refreshOk or type(latestPlayers) ~= "table" then
        return false
    end
    local playerSetChanged = #players ~= #latestPlayers

    if not playerSetChanged then
        for index, player in ipairs(latestPlayers) do
            if players[index] ~= player then
                playerSetChanged = true
                break
            end
        end
    end

    table.clear(players)
    table.clear(playerIndices)

    for _, player in ipairs(latestPlayers) do
        players[#players + 1] = player
        playerIndices[player] = #players
    end

    if playerSetChanged then
        VisualRuntime.PlayerSetChanged = true
    end

    for player in pairs(characterCache) do
        if not playerIndices[player] then
            characterCache[player] = nil
        end
    end

    return true
end

VisualRuntime.RefreshPlayers()

function VisualRuntime.IsPlayerActive(player)
    return player == LocalPlayer
        or (player ~= nil and player.Parent == Players)
end

local function getCharacterData(player)
    if not VisualRuntime.IsPlayerActive(player) then
        VisualRuntime.CharacterCache[player] = nil
        return nil, nil
    end

    local character = player.Character

    if not character then
        VisualRuntime.CharacterCache[player] = nil
        return nil, nil
    end

    local data = VisualRuntime.CharacterCache[player]

    if not data then
        data = {}
        VisualRuntime.CharacterCache[player] = data
    end

    if data.FrameId ~= VisualRuntime.FrameId then
        data.FrameId = VisualRuntime.FrameId

        local now = os.clock()
        if data.Character ~= character
            or data.Root == nil
            or data.Humanoid == nil
            or now >= (data.NextPartRefreshAt or 0) then

            -- Periodic reacquisition still catches replacement parts whose old
            -- proxy reports a valid Parent, without two lookups per player at
            -- every 30 Hz visual update.
            data.Character = character
            data.Humanoid = character:FindFirstChildOfClass("Humanoid")
            data.Root = character:FindFirstChild("HumanoidRootPart")
            data.NextPartRefreshAt = now + 0.25
        end
    end

    return data.Humanoid, data.Root
end

local function getRoot(player)
    local _, root = getCharacterData(player)
    return root
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

function VisualRuntime.RemoveDrawing(drawing)
    if not drawing then
        return
    end

    pcall(function()
        drawing.Visible = false
        drawing:Remove()
    end)
end

function VisualRuntime.ResetEspSlot(index)
    VisualRuntime.RemoveDrawing(espBoxes[index])
    VisualRuntime.RemoveDrawing(tracerLines[index])
    espBoxes[index] = nil
    tracerLines[index] = nil
end

function VisualRuntime.ResetHealthSlot(index)
    VisualRuntime.RemoveDrawing(healthTexts[index])
    healthTexts[index] = nil
    VisualRuntime.HealthTextValues[index] = nil
end

function VisualRuntime.ResetBaseDrawingPools()
    for _, drawing in pairs(espBoxes) do
        VisualRuntime.RemoveDrawing(drawing)
    end

    for _, drawing in pairs(tracerLines) do
        VisualRuntime.RemoveDrawing(drawing)
    end

    for _, drawing in pairs(healthTexts) do
        VisualRuntime.RemoveDrawing(drawing)
    end

    table.clear(espBoxes)
    table.clear(tracerLines)
    table.clear(healthTexts)
    table.clear(VisualRuntime.HealthTextValues)
end

--// ESP CONFIG
local DEFAULT_ESP_DISTANCE_SQUARED = 50 * 50

local function getEspMaxDistanceSquared()
    local maxDistance = tonumber(_G.ESPMaxDistance)
    if maxDistance then
        maxDistance = math.max(0, maxDistance)
        return maxDistance * maxDistance
    end

    local maxDistanceSquared = tonumber(_G.ESPMaxDistanceSquared)
    if maxDistanceSquared then
        return math.max(0, maxDistanceSquared)
    end

    return state.ESPDistanceSquared
        or DEFAULT_ESP_DISTANCE_SQUARED
end

--// HEALTH CONFIG
local DEFAULT_HEALTH_DISTANCE_SQUARED = 50 * 50

local function getHealthMaxDistanceSquared()
    -- HealthESPMaxDistance is expressed in studs and can change at runtime.
    local maxDistance = tonumber(_G.HealthESPMaxDistance)
    if maxDistance then
        maxDistance = math.max(0, maxDistance)
        return maxDistance * maxDistance
    end

    -- Retain compatibility with integrations that provide a squared value.
    local maxDistanceSquared = tonumber(_G.HealthESPMaxDistanceSquared)
    if maxDistanceSquared then
        return math.max(0, maxDistanceSquared)
    end

    return state.PlayerHealthDistanceSquared
        or DEFAULT_HEALTH_DISTANCE_SQUARED
end

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
    -- Lazy allocation makes these pools sparse. The length operator can stop
    -- at the first hole, leaving later drawings frozen on screen.
    for index, drawing in pairs(pool) do
        if type(index) == "number" and index >= fromIndex and drawing then
            pcall(function()
                if drawing.Visible then
                    drawing.Visible = false
                end
            end)
        end
    end
end

function VisualRuntime.HideAllBaseDrawings()
    pcall(function()
        myHealthText.Visible = false
    end)
    hidePoolFrom(espBoxes, 1)
    hidePoolFrom(tracerLines, 1)
    hidePoolFrom(healthTexts, 1)
end

function VisualRuntime.ReportPlayerVisualError(player, err)
    VisualRuntime.CharacterCache[player] = nil
    -- Rebuild this player's parts on the next visual frame. Keep full roster
    -- scans on their own timer even if one player fails repeatedly.

    local now = os.clock()
    if now - VisualRuntime.LastVisualErrorAt >= 5 then
        VisualRuntime.LastVisualErrorAt = now
        warn("[FFTM Visuals] Skipped one stale player: " .. tostring(err))
    end
end

function VisualRuntime.HideEspSlot(index)
    local box = espBoxes[index]
    local line = tracerLines[index]

    pcall(function()
        if box then box.Visible = false end
        if line then line.Visible = false end
    end)
end

function VisualRuntime.UpdateEspPlayer(player, index)
    local frame = VisualRuntime.EspFrame
    local box = espBoxes[index]
    local line = tracerLines[index]
    local showBox = false
    local showLine = false
    local root = getRoot(player)

    if root then
        local pos = root.Position
        local dx = pos.X - frame.ReferencePos.X
        local dy = pos.Y - frame.ReferencePos.Y
        local dz = pos.Z - frame.ReferencePos.Z
        local distanceSquared = dx * dx + dy * dy + dz * dz

        if distanceSquared <= frame.MaxDistanceSquared
            and not nearSelf(pos, frame.MyPos) then

            local projectionOk, screenPos, onScreen = pcall(function()
                return WorldToScreen(pos)
            end)

            if projectionOk
                and onScreen
                and screenPos
                and screenPos.X >= 0
                and screenPos.X <= frame.Viewport.X
                and screenPos.Y >= 0
                and screenPos.Y <= frame.Viewport.Y then

                if state.ESP then
                    box = box or getEspBox(index)
                    local camDx = pos.X - frame.CameraPos.X
                    local camDy = pos.Y - frame.CameraPos.Y
                    local camDz = pos.Z - frame.CameraPos.Z
                    local distance = math.sqrt(
                        camDx * camDx + camDy * camDy + camDz * camDz
                    )
                    local scale = math.clamp(
                        1500 / math.max(distance, 0.001),
                        8,
                        400
                    )
                    local size = Vector2.new(scale, scale * 1.5)

                    box.Size = size
                    box.Position = Vector2.new(
                        screenPos.X - size.X * 0.5,
                        screenPos.Y - size.Y * 0.5
                    )
                    showBox = true
                end

                if state.Tracers then
                    line = line or getTracer(index)
                    line.From = frame.Origin
                    line.To = screenPos
                    line.Transparency = frame.TracerTransparency
                    showLine = frame.TracerTransparency > 0
                end
            end
        end
    end

    if box and box.Visible ~= showBox then
        box.Visible = showBox
    end
    if line and line.Visible ~= showLine then
        line.Visible = showLine
    end
end

--// ESP + TRACERS
local function updateEspTracers()
    if not state.ESP and not state.Tracers then
        if VisualRuntime.EspTracersWereActive then
            hidePoolFrom(espBoxes, 1)
            hidePoolFrom(tracerLines, 1)
            VisualRuntime.EspTracersWereActive = false
        end
        return
    end

    VisualRuntime.EspTracersWereActive = true
    Camera = workspace.CurrentCamera or Camera

    if not Camera then
        hidePoolFrom(espBoxes, 1)
        hidePoolFrom(tracerLines, 1)
        return
    end

    local viewport = Camera.ViewportSize

    local myRoot = getRoot(LocalPlayer)
    local myPos = myRoot and myRoot.Position

    local frame = VisualRuntime.EspFrame
    frame.Viewport = viewport
    frame.Origin = Vector2.new(viewport.X * 0.5, viewport.Y)
    frame.MyPos = myPos
    frame.CameraPos = Camera.CFrame.Position
    frame.ReferencePos = myPos or frame.CameraPos
    frame.MaxDistanceSquared = getEspMaxDistanceSquared()
    frame.TracerTransparency = 1 - (state.TracerTransparency / 100)
    local count = 0

    for _, player in ipairs(VisualRuntime.Players) do
        if player == LocalPlayer then
            continue
        end

        count += 1

        local ok, err = pcall(VisualRuntime.UpdateEspPlayer, player, count)
        if not ok then
            VisualRuntime.ResetEspSlot(count)
            VisualRuntime.ReportPlayerVisualError(player, err)
        end
    end

    hidePoolFrom(espBoxes, count + 1)
    hidePoolFrom(tracerLines, count + 1)
end

--// HEALTH ESP
function VisualRuntime.HideHealthSlot(index)
    local text = healthTexts[index]
    pcall(function()
        if text then text.Visible = false end
    end)
end

function VisualRuntime.UpdateHealthPlayer(player, index)
    local frame = VisualRuntime.HealthFrame
    local text = healthTexts[index]
    local humanoid, root = getCharacterData(player)
    local visible = false

    if humanoid and root and humanoid.Health > 0 then
        local position = root.Position
        local dx = position.X - frame.MyPosition.X
        local dy = position.Y - frame.MyPosition.Y
        local dz = position.Z - frame.MyPosition.Z
        local distanceSquared = dx * dx + dy * dy + dz * dz

        if distanceSquared <= frame.MaxDistanceSquared then
            local projectionOk, screenPosition, onScreen = pcall(function()
                return WorldToScreen(
                    position + VisualRuntime.HealthHeadOffset
                )
            end)

            if projectionOk
                and onScreen
                and screenPosition
                and screenPosition.X >= 0
                and screenPosition.X <= frame.Viewport.X
                and screenPosition.Y >= 0
                and screenPosition.Y <= frame.Viewport.Y then

                text = text or getHealthText(index)
                text.Position = screenPosition

                local health = math.floor(humanoid.Health)
                if VisualRuntime.HealthTextValues[index] ~= health then
                    VisualRuntime.HealthTextValues[index] = health
                    text.Text = "+ " .. health
                end
                visible = true
            end
        end
    end

    if text and text.Visible ~= visible then
        text.Visible = visible
    end
end

local function updateHealth()
    Camera = workspace.CurrentCamera or Camera

    if not Camera then
        myHealthText.Visible = false
        hidePoolFrom(healthTexts, 1)
        VisualRuntime.PlayerHealthWasActive = false
        return
    end

    local viewport = Camera.ViewportSize
    local myHumanoid, myRoot = getCharacterData(LocalPlayer)

    --==================================================
    -- SELF HEALTH
    --==================================================

    if state.SelfHealth then
        if myHumanoid and myHumanoid.Health > 0 then
            local health = math.floor(myHumanoid.Health)

            if VisualRuntime.LastSelfHealth ~= health then
                VisualRuntime.LastSelfHealth = health
                myHealthText.Text = "+ " .. health
            end

            if VisualRuntime.LastSelfHealthViewport ~= viewport then
                VisualRuntime.LastSelfHealthViewport = viewport
                myHealthText.Position = Vector2.new(
                    viewport.X * 0.5,
                    viewport.Y * 0.5
                )
            end

            myHealthText.Visible = true
        else
            VisualRuntime.LastSelfHealth = nil
            myHealthText.Visible = false
        end
    else
        VisualRuntime.LastSelfHealth = nil
        myHealthText.Visible = false
    end

    --==================================================
    -- OTHER PLAYERS
    --==================================================

    if not state.PlayerHealth then
        if VisualRuntime.PlayerHealthWasActive then
            hidePoolFrom(healthTexts, 1)
            VisualRuntime.PlayerHealthWasActive = false
        end
        return
    end

    if not myRoot then
        hidePoolFrom(healthTexts, 1)
        VisualRuntime.PlayerHealthWasActive = false
        return
    end

    VisualRuntime.PlayerHealthWasActive = true
    local frame = VisualRuntime.HealthFrame
    frame.Viewport = viewport
    frame.MyPosition = myRoot.Position
    frame.MaxDistanceSquared = getHealthMaxDistanceSquared()
    local count = 0

    for _, player in ipairs(VisualRuntime.Players) do
        if player ~= LocalPlayer then
            count += 1

            local ok, err = pcall(VisualRuntime.UpdateHealthPlayer, player, count)
            if not ok then
                VisualRuntime.ResetHealthSlot(count)
                VisualRuntime.ReportPlayerVisualError(player, err)
            end
        end
    end

    -- Hide unused health drawings
    hidePoolFrom(healthTexts, count + 1)
end

function VisualRuntime.UpdateBaseVisuals()
    if VisualRuntime.PlayerSetChanged then
        -- Pool slots are index-based. Clear the previous frame before the new
        -- player order reuses those slots so a departed player cannot persist.
        VisualRuntime.HideAllBaseDrawings()
        VisualRuntime.PlayerSetChanged = false
    end

    updateEspTracers()
    updateHealth()
end

function VisualRuntime.RunBaseVisuals()
    VisualRuntime.FrameId += 1
    local ok, err = pcall(VisualRuntime.UpdateBaseVisuals)
    if ok then
        return true
    end

    -- Never let one stale Roblox instance or projection failure permanently
    -- disconnect RenderStepped with the last frame still visible.
    VisualRuntime.ResetBaseDrawingPools()
    VisualRuntime.HideAllBaseDrawings()

    local now = os.clock()
    if now - VisualRuntime.LastVisualErrorAt >= 5 then
        VisualRuntime.LastVisualErrorAt = now
        warn("[FFTM Visuals] Recovered from: " .. tostring(err))
    end

    return false
end

--==================================================
-- INS VISUAL CONTROLS
--==================================================

local UIToggles = {}

Main.Section.Name = "Player ESP"
Main.Section.Side = "Left"
Main.Section.Desc = "Boxes, tracers, visibility, and render-distance controls."
Main.Health = Main:AddSection(
    "Health Display",
    "Right",
    "Player and local health overlays with independent range control."
)

UIToggles.ESP = Main:AddToggle({
    Id = "esp",
    Title = "ESP",
    Description = "Draws a box around other players within the ESP distance.",
    Default = false,

    Callback = function(value)
        state.ESP = value
        print("ESP:", value)
    end
})

UIToggles.Tracers = Main:AddToggle({
    Id = "tracers",
    Title = "Tracers",
    Description = "Draws a line from the bottom of the screen to visible players.",
    Default = false,

    Callback = function(value)
        state.Tracers = value
        print("Tracers:", value)
    end
})

local TracerTransparencySlider = Main:AddSlider({
    Id = "tracer_transparency",
    Title = "Tracer Transparency",
    Description = "Sets tracer visibility: 0 is solid and 100 is invisible.",
    Min = 0,
    Max = 100,
    Default = 0,

    Callback = function(value)
        state.TracerTransparency = value
        print("Tracer Transparency:", value)
    end
})

local ESPDistanceSlider = Main:AddSlider({
    Id = "esp_distance",
    Title = "ESP Distance",
    Description = "Maximum box and tracer range in studs.",
    Min = 10,
    Max = 500,
    Default = 50,

    Callback = function(value)
        value = tonumber(value) or 50

        state.ESPDistance = value
        state.ESPDistanceSquared = value * value

        _G.ESPMaxDistance = value
        _G.ESPMaxDistanceSquared = value * value
    end
})

--// PLAYER HEALTH

UIToggles.PlayerHealth = Main.Health:AddToggle({
    Id = "player_health",
    Title = "Player Health",
    Description = "Shows each nearby player's current health above their character.",
    Default = false,

    Callback = function(value)
        state.PlayerHealth = value
        print("Player Health:", value)
    end
})

local HealthESPDistanceSlider = Main.Health:AddSlider({
    Id = "player_health_distance",
    Title = "Health ESP Distance",
    Description = "Maximum range for player health labels in studs.",
    Min = 10,
    Max = 500,
    Default = 50,

    Callback = function(value)
        value = tonumber(value) or 50

        state.PlayerHealthDistance = value
        state.PlayerHealthDistanceSquared = value * value

        _G.HealthESPMaxDistance = value
        _G.HealthESPMaxDistanceSquared = value * value
    end
})


UIToggles.SelfHealth = Main.Health:AddToggle({
    Id = "self_health",
    Title = "Self Health",
    Description = "Shows your current health at the center of the screen.",
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

VisualRuntime.AutoParryStatus = Drawing.new("Text")
VisualRuntime.AutoParryStatus.Size = 18
VisualRuntime.AutoParryStatus.Center = true
VisualRuntime.AutoParryStatus.Outline = true
VisualRuntime.AutoParryStatus.Font = Drawing.Fonts.Fortnite
VisualRuntime.AutoParryStatus.Transparency = 1
VisualRuntime.AutoParryStatus.ZIndex = 50
VisualRuntime.AutoParryStatus.Visible = true
VisualRuntime.AutoParryStatusEnabled = true

function VisualRuntime.PositionAutoParryStatus()
    local viewport = Camera.ViewportSize
    if VisualRuntime.AutoParryStatusViewport == viewport then
        return
    end

    VisualRuntime.AutoParryStatusViewport = viewport
    VisualRuntime.AutoParryStatus.Position =
        Vector2.new(viewport.X - 108, viewport.Y - 42)
end

function VisualRuntime.UpdateAutoParryStatus(enabled)
    enabled = enabled == true
    VisualRuntime.AutoParryStatus.Text =
        enabled and "AUTO PARRY: ON" or "AUTO PARRY: OFF"
    VisualRuntime.AutoParryStatus.Color = enabled
        and Color3.fromRGB(90, 255, 130)
        or Color3.fromRGB(255, 90, 90)
    VisualRuntime.AutoParryStatus.Visible =
        VisualRuntime.AutoParryStatusEnabled == true
    VisualRuntime.PositionAutoParryStatus()
end

function VisualRuntime.SetAutoParryStatusVisible(visible)
    VisualRuntime.AutoParryStatusEnabled = visible == true
    VisualRuntime.AutoParryStatus.Visible =
        VisualRuntime.AutoParryStatusEnabled
end

function VisualRuntime.SetAnimationIdEspEnabled(enabled)
    VisualRuntime.AnimationIdEspEnabled = enabled == true

    if type(VisualRuntime.RefreshAnimationIdEspVisibility) == "function" then
        VisualRuntime.RefreshAnimationIdEspVisibility()
    end
end

local IncludeLocalCharacter = false

-- Legacy logger refresh hook. The INS UI version updated text labels here;
-- the Wabi merge keeps the data/cache behavior without those old labels.
local function UpdateClipboardSection()
end

local AutoParryToggle      = NewValueControl(true)
local AutoDodgeToggle      = NewValueControl(true)
AutoCounterToggle          = NewValueControl(false)
AutoAliCounterToggle       = NewValueControl(false)
local AutoTargetNearest    = NewValueControl(false)
local MultiTarget          = NewValueControl(true)
local HeightToggle         = NewValueControl(true)
local TargetFacingYou      = NewValueControl(false)
local YouFacingTarget      = NewValueControl(true)
local ParryDebugToggle     = NewValueControl(false)
local PingCompensateToggle = NewValueControl(true)
local AutoPlayToggle       = NewValueControl(true)

VisualRuntime.AutoParrySet = AutoParryToggle.Set
AutoParryToggle.Set = function(value)
    VisualRuntime.AutoParrySet(value)
    VisualRuntime.UpdateAutoParryStatus(value)
end
VisualRuntime.UpdateAutoParryStatus(AutoParryToggle.Get())

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

Library.Raw:Category("COMBAT")

local AutoParryTab   = SafeAddTab("Auto Parry", "swords")
local TargetingTab   = SafeAddTab("Targeting", "crosshair")
local ParryConfigTab = SafeAddTab("Parry Config", "settings")

Library.Raw:Category("SETTINGS")

local ConfigTab   = SafeAddTab("Config", "settings")
local KeybindsTab = SafeAddTab("Keybinds", "keyboard")

AutoParryTab.Section.Name = "Combat Automation"
AutoParryTab.Section.Side = "Left"
AutoParryTab.Section.Desc = "Automatic defensive and counter responses."
AutoParryTab.Extras = AutoParryTab:AddSection(
    "Extras & Diagnostics",
    "Right",
    "Optional automation and parry debugging controls."
)

TargetingTab.Section.Name = "Target Selection"
TargetingTab.Section.Side = "Left"
TargetingTab.Section.Desc = "Selection behavior, range, folder, and manual cycling."
TargetingTab.Filters = TargetingTab:AddSection(
    "Facing Filters",
    "Right",
    "Direction checks applied before handling normal attacks."
)
TargetingTab.Whitelist = TargetingTab:AddSection(
    "Target Whitelist",
    "Right",
    "Exclude or restore characters from automatic selection."
)

ConfigTab.Section.Name = "Profiles"
ConfigTab.Section.Side = "Left"
ConfigTab.Section.Desc = "Save and restore complete FFTM setting profiles."
ConfigTab.Appearance = ConfigTab:AddSection(
    "Appearance",
    "Right",
    "Change the INS color preset used by this interface."
)
ConfigTab.Utilities = ConfigTab:AddSection(
    "Visual Utilities",
    "Right",
    "Maintenance actions for active Drawing overlays."
)

KeybindsTab.Section.Name = "Interface"
KeybindsTab.Section.Side = "Left"
KeybindsTab.Section.Desc = "Menu and general action shortcuts."
KeybindsTab.Combat = KeybindsTab:AddSection("Combat", "Right", "Combat automation shortcuts.")
KeybindsTab.Targeting = KeybindsTab:AddSection("Targeting", "Left", "Target selection shortcuts.")
KeybindsTab.Parry = KeybindsTab:AddSection("Parry Config", "Right", "Timing modifier shortcuts.")
KeybindsTab.Visuals = KeybindsTab:AddSection("Visuals", "Left", "ESP and health-overlay shortcuts.")

-- Split Parry Config into INS cards like the reference layout. These are
-- presentation-only proxies; every control keeps its original callback and
-- saved-setting handle.
ParryConfigTab.Section.Name = "Core Timing"
ParryConfigTab.Section.Side = "Left"
ParryConfigTab.Section.Desc = "Global range, probability, offset, and timing-window controls."
ParryConfigTab.Modifiers = ParryConfigTab:AddSection(
    "Timing Modifiers",
    "Right",
    "Optional adjustments applied to calculated reaction timing."
)

-- Admin controls are created only when the private loader supplied
-- _G.FFTM_ADMIN_KEY. This avoids brittle username spelling/case checks.
if type(FFTM_ADMIN_KEY) == "string"
    and FFTM_ADMIN_KEY ~= "" then

    Library.Raw:Category("ADMIN")
    FFTMAdminTab = SafeAddTab("Admin", "settings")
    FFTMAdminTab.Section.Name = "Active Sessions"
    FFTMAdminTab.Section.Side = "Left"
    FFTMAdminTab.Section.Desc = "Inspect and refresh active FFTM sessions in this server."
    FFTMAdminTab.Commands = FFTMAdminTab:AddSection(
        "Session Commands",
        "Right",
        "Send administrative commands to the selected session."
    )
    FFTM_ADMIN_OPTION_TO_SESSION = {}
    FFTMAdminDropdown = nil

    function FFTMBuildAdminOptions(sessions)
        local options = {}
        FFTM_ADMIN_OPTION_TO_SESSION = {}

        -- Keep only the newest active session for each Roblox user.
        local newestByUserId = {}

        for _, session in ipairs(sessions or {}) do
            local userId = tostring(session.user_id or "")
            local lastSeen = tonumber(session.last_seen) or 0

            if userId ~= "" then
                local current = newestByUserId[userId]
                local currentLastSeen =
                    current and (tonumber(current.last_seen) or 0) or -1

                if not current or lastSeen > currentLastSeen then
                    newestByUserId[userId] = session
                end
            end
        end

        local newestSessions = {}

        for _, session in pairs(newestByUserId) do
            table.insert(newestSessions, session)
        end

        table.sort(newestSessions, function(a, b)
            return (tonumber(a.last_seen) or 0)
                > (tonumber(b.last_seen) or 0)
        end)

        for _, session in ipairs(newestSessions) do
            local label =
                tostring(session.username or "Unknown")
                .. " | "
                .. tostring(session.user_id or "?")

            if session.display_name
                and tostring(session.display_name) ~= ""
                and tostring(session.display_name) ~= tostring(session.username) then

                label =
                    tostring(session.display_name)
                    .. " (@"
                    .. tostring(session.username)
                    .. ") | "
                    .. tostring(session.user_id or "?")
            end

            if session.shutdown == 1 or session.shutdown == true then
                label = label .. " [SHUTDOWN]"
            end

            table.insert(options, label)

            -- IMPORTANT:
            -- map the visible user entry to ONLY their newest session_id.
            FFTM_ADMIN_OPTION_TO_SESSION[label] =
                tostring(session.session_id or "")
        end

        if #options == 0 then
            table.insert(options, "No FFTM users in this server")
        end

        return options
    end

    function FFTMRefreshAdminDropdown()
        local sessions = FFTMFetchAdminSessions()
        local options = FFTMBuildAdminOptions(sessions)

        FFTM_ADMIN_SELECTED_SESSION =
            FFTM_ADMIN_OPTION_TO_SESSION[options[1]]

        if FFTMAdminDropdown then
            pcall(function()
                if type(FFTMAdminDropdown.SetOptions) == "function" then
                    FFTMAdminDropdown:SetOptions(options)
                elseif type(FFTMAdminDropdown.SetValues) == "function" then
                    FFTMAdminDropdown:SetValues(options)
                elseif type(FFTMAdminDropdown.Refresh) == "function" then
                    FFTMAdminDropdown:Refresh(options)
                end
            end)
        end

        return options, sessions
    end

    local initialSessions = FFTMFetchAdminSessions()
    local initialOptions = FFTMBuildAdminOptions(initialSessions)

    FFTM_ADMIN_SELECTED_SESSION =
        FFTM_ADMIN_OPTION_TO_SESSION[initialOptions[1]]

    FFTMAdminDropdown = SafeAddDropdown(FFTMAdminTab, {
        Id = "admin_active_session",
        Title = "FFTM Users In This Server",
        Description = "Selects a player's newest active FFTM session in this server.",
        Options = initialOptions,
        Default = initialOptions[1],

        Callback = function(value)
            local label = tostring(value)
            FFTM_ADMIN_SELECTED_SESSION =
                FFTM_ADMIN_OPTION_TO_SESSION[label]
        end
    })

    SafeAddButton(FFTMAdminTab, {
        Title = "Refresh Users",
        Description = "Refreshes the list of active FFTM sessions in this server.",

        Callback = function()
            local _, sessions = FFTMRefreshAdminDropdown()

            Notify(
                "Admin",
                "FFTM users in this server: " .. tostring(#sessions),
                3
            )
        end
    })

    SafeAddButton(FFTMAdminTab.Commands, {
        Title = "Shutdown Selected",
        Description = "Queues the selected FFTM session to close on its next heartbeat.",

        Callback = function()
            if not FFTM_ADMIN_SELECTED_SESSION then
                Notify("Admin", "Select an FFTM user first.", 3)
                return
            end

            if FFTMAdminCommand(
                "/admin/shutdown",
                FFTM_ADMIN_SELECTED_SESSION
            ) then
                Notify(
                    "Admin",
                    "Shutdown queued. Their FFTM will close on its next heartbeat.",
                    4
                )

                FFTMRefreshAdminDropdown()
            else
                Notify("Admin", "Shutdown request failed.", 4)
            end
        end
    })

    SafeAddButton(FFTMAdminTab.Commands, {
        Title = "Enable Selected",
        Description = "Re-enables the selected FFTM session after a shutdown command.",

        Callback = function()
            if not FFTM_ADMIN_SELECTED_SESSION then
                Notify("Admin", "Select an FFTM user first.", 3)
                return
            end

            if FFTMAdminCommand(
                "/admin/enable",
                FFTM_ADMIN_SELECTED_SESSION
            ) then
                Notify("Admin", "Session re-enabled.", 3)
                FFTMRefreshAdminDropdown()
            else
                Notify("Admin", "Enable request failed.", 4)
            end
        end
    })
end

UIToggles.AutoParry = SafeAddToggle(AutoParryTab, {
    Id = "auto_parry",
    Title = "Auto Parry",
    Description = "Automatically parries recognized attacks using the configured timing.",
    Default = true,
    Callback = function(value)
        AutoParryToggle.Set(value)
    end
})

UIToggles.AutoDodge = SafeAddToggle(AutoParryTab, {
    Id = "auto_dodge",
    Title = "Auto Dodge / Heavy",
    Description = "Automatically dodges heavy attacks when no counter mode handles them.",
    Default = true,
    Callback = function(value)
        AutoDodgeToggle.Set(value)
    end
})

UIToggles.AutoCounter = SafeAddToggle(AutoParryTab, {
    Id = "auto_counter",
    Title = "Auto Counter",
    Description = "Automatically performs the standard counter against heavy attacks.",
    Default = false,
    Callback = function(value)
        AutoCounterToggle.Set(value)
    end
})

UIToggles.AutoAliCounter = SafeAddToggle(AutoParryTab, {
    Id = "auto_ali_counter",
    Title = "Auto Ali Counter",
    Description = "Moves toward the target and performs the Ali counter against heavy attacks.",
    Default = false,
    Callback = function(value)
        AutoAliCounterToggle.Set(value)
    end
})

UIToggles.AutoPlay = SafeAddToggle(AutoParryTab.Extras, {
    Id = "auto_play",
    Title = "Auto Play",
    Description = "Automatically presses notes during the supported rhythm minigame.",
    Default = true,
    Callback = function(value)
        AutoPlayToggle.Set(value)
    end
})

UIToggles.ParryDebug = SafeAddToggle(AutoParryTab.Extras, {
    Id = "parry_debug",
    Title = "Debug Parry",
    Description = "Prints detailed parry timing and latency diagnostics after a parry.",
    Default = false,
    Callback = function(value)
        ParryDebugToggle.Set(value)
    end
})

UIToggles.ParryStatus = SafeAddToggle(AutoParryTab.Extras, {
    Id = "parry_status",
    Title = "Parry Status",
    Description = "Shows the transparent Auto Parry ON/OFF indicator in the bottom-right corner.",
    Default = true,
    Callback = function(value)
        VisualRuntime.SetAutoParryStatusVisible(value)
    end
})

UIToggles.AnimationIdESP = SafeAddToggle(AutoParryTab.Extras, {
    Id = "animation_id_esp",
    Title = "Animation ID ESP",
    Description = "Shows or hides the live animation names and IDs above selected players while keeping their target status visible.",
    Default = true,
    Callback = function(value)
        VisualRuntime.SetAnimationIdEspEnabled(value)
    end
})

UIToggles.AutoTargetNearest = SafeAddToggle(TargetingTab, {
    Id = "auto_target_nearest",
    Title = "Auto Target Nearest",
    Description = "Continuously refreshes targeting to the nearest valid character(s).",
    Default = false,
    Callback = function(value)
        AutoTargetNearest.Set(value)
    end
})

UIToggles.MultipleTargets = SafeAddToggle(TargetingTab, {
    Id = "multiple_targets",
    Title = "Multiple Targets",
    Description = "Selects up to the three nearest valid characters automatically or around your cursor when targeting manually.",
    Default = true,
    Callback = function(value)
        MultiTarget.Set(value)
    end
})

UIToggles.IncludeLocalCharacter = SafeAddToggle(TargetingTab, {
    Id = "include_local_character",
    Title = "Include Local Character",
    Description = "Allows your own character to be included in the target list.",
    Default = false,
    Callback = function(value)
        IncludeLocalCharacter = value
    end
})

UIToggles.TargetFacingYou = SafeAddToggle(TargetingTab.Filters, {
    Id = "target_facing_you",
    Title = "Target Facing You",
    Description = "Only handles normal attacks when the target is facing toward you.",
    Default = false,
    Callback = function(value)
        TargetFacingYou.Set(value)
    end
})

UIToggles.YouFacingTarget = SafeAddToggle(TargetingTab.Filters, {
    Id = "you_facing_target",
    Title = "You Facing Target",
    Description = "Only handles normal attacks when you are facing toward the target.",
    Default = true,
    Callback = function(value)
        YouFacingTarget.Set(value)
    end
})

UIToggles.HeightMultiplier = SafeAddToggle(ParryConfigTab.Modifiers, {
    Id = "height_multiplier",
    Title = "Height Multiplier",
    Description = "Adjusts reaction timing using the target's current height multiplier.",
    Default = true,
    Callback = function(value)
        HeightToggle.Set(value)
    end
})

UIToggles.PingCompensation = SafeAddToggle(ParryConfigTab.Modifiers, {
    Id = "ping_compensation",
    Title = "Ping Compensation",
    Description = "Starts parries earlier by half of the measured network ping.",
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

                local noteKey = string.byte(Key)
                keypress(noteKey)
                scheduler.delay(0.05, function()
                    keyrelease(noteKey)
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
local HeavyKey = string.byte("R")

local KeyHeld = false
local CounterKeyHeld = false
local CounterReleaseDeadline = 0
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

function FindPlayerForCharacter(character)
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

function GetCharacterWhitelistKey(character)
    if not character then
        return nil
    end

    local player = FindPlayerForCharacter(character)

    if player then
        return "uid:" .. tostring(player.UserId)
    end

    return "name:" .. tostring(character.Name)
end

function GetCharacterDisplayName(character)
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

function IsCharacterWhitelisted(character)
    local key = GetCharacterWhitelistKey(character)
    return key ~= nil and TargetSelectionState.Whitelist[key] == true
end

function SetCharacterWhitelisted(character, enabled)
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

function ClearSelectedMarkers()
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

function AddSelectedMarker(character)
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

function UpdateSelectedMarkers()
    for character, markerText in pairs(TargetSelectionState.Markers) do
        local visible = false
        local characterAlive = false

        pcall(function()
            characterAlive = character ~= nil and character.Parent ~= nil
        end)

        if characterAlive and markerText then
            local ok = pcall(function()
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
            end)

            if not ok then
                pcall(function()
                    markerText.Visible = false
                end)
            end
        elseif markerText then
            pcall(function()
                markerText.Visible = false
                markerText:Remove()
            end)
            TargetSelectionState.Markers[character] = nil
        end
    end
end

function CopyWhitelist()
    local copy = {}

    for key, enabled in pairs(TargetSelectionState.Whitelist) do
        if enabled == true then
            copy[key] = true
        end
    end

    return copy
end

function ApplyWhitelist(saved)
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

InputRegisteredTime = nil
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

MoveKeys = {
    W = string.byte("W"),
    A = string.byte("A"),
    S = string.byte("S"),
    D = string.byte("D"),
}

function GetMoveKeyTowardTarget(targetCharacter)
    local localCharacter = LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")

    if not localRoot or not targetRoot then
        return MoveKeys.W, "W"
    end

    local offset = targetRoot.Position - localRoot.Position
    if offset.Magnitude <= 0.001 then
        return MoveKeys.W, "W"
    end

    -- Roblox maps WASD relative to the camera. Using the character CFrame can
    -- select the opposite dodge direction while shift-lock or a side camera is
    -- active, so compare the target against the camera's planar axes instead.
    Camera = workspace.CurrentCamera or Camera
    local cameraCFrame = Camera and Camera.CFrame or localRoot.CFrame
    local targetDirection = Vector3.new(offset.X, 0, offset.Z)
    local forward = Vector3.new(
        cameraCFrame.LookVector.X,
        0,
        cameraCFrame.LookVector.Z
    )
    local right = Vector3.new(
        cameraCFrame.RightVector.X,
        0,
        cameraCFrame.RightVector.Z
    )

    if targetDirection.Magnitude <= 0.001
        or forward.Magnitude <= 0.001
        or right.Magnitude <= 0.001 then
        return MoveKeys.W, "W"
    end

    targetDirection = targetDirection.Unit
    forward = forward.Unit
    right = right.Unit

    local forwardAmount = targetDirection:Dot(forward)
    local rightAmount = targetDirection:Dot(right)

    if math.abs(rightAmount) > math.abs(forwardAmount) then
        if rightAmount > 0 then
            return MoveKeys.D, "D"
        else
            return MoveKeys.A, "A"
        end
    else
        if forwardAmount > 0 then
            return MoveKeys.W, "W"
        else
            return MoveKeys.S, "S"
        end
    end
end

AliInjectedMoveKey = nil

function ReleaseAliMoveKey()
    if AliInjectedMoveKey then
        pcall(function()
            keyrelease(AliInjectedMoveKey)
        end)

        AliInjectedMoveKey = nil
    end
end

function FFTMShutdown()
    if not FFTM_RUNNING then
        return
    end

    FFTM_RUNNING = false

    pcall(function() AutoParryToggle.Set(false) end)
    pcall(function() AutoDodgeToggle.Set(false) end)
    pcall(function() AutoCounterToggle.Set(false) end)
    pcall(function() AutoAliCounterToggle.Set(false) end)
    pcall(function() AutoPlayToggle.Set(false) end)

    pcall(function() state.ESP = false end)
    pcall(function() state.Tracers = false end)
    pcall(function() state.PlayerHealth = false end)
    pcall(function() state.SelfHealth = false end)

    pcall(BlockEnd)
    pcall(CounterEnd)
    pcall(ReleaseAliMoveKey)
    pcall(ClearSelectedMarkers)

    pcall(function()
        VisualRuntime.HideAllBaseDrawings()
    end)

    pcall(function()
        VisualRuntime.AutoParryStatus.Visible = false
        VisualRuntime.AutoParryStatus:Remove()
    end)

    pcall(function()
        if Window and type(Window.Destroy) == "function" then
            Window:Destroy()
        end
    end)

    pcall(function()
        if Window and type(Window.Unload) == "function" then
            Window:Unload()
        end
    end)

    pcall(function()
        if Library and type(Library.Unload) == "function" then
            Library:Unload()
        end
    end)
end

function AliDodgeIntoTarget(targetCharacter)
    BlockEnd()

    -- Clean up a previous Ali counter first so a direction can never remain held.
    ReleaseAliMoveKey()

    local moveKey, moveName = GetMoveKeyTowardTarget(targetCharacter)
    AliInjectedMoveKey = moveKey

    print("[Auto Ali Counter] " .. moveName .. " DOWN")
    keypress(moveKey)

    -- Let Matcha and Roblox observe the movement direction before Q. A 20 ms
    -- window could begin and end between input samples on lower-FPS clients.
    scheduler.delay(0.05, function()
        print("[Auto Ali Counter] Q DASH")

        for i = 1, 12 do
            keypress(DodgeKey)
            keyrelease(DodgeKey)
        end
    end)

    -- Keep the direction held through the dash input, then release it.
    scheduler.delay(0.18, function()
        print("[Auto Ali Counter] " .. moveName .. " UP")
        ReleaseAliMoveKey()
    end)

    -- Extra fail-safe cleanup in case the first scheduled release is missed.
    scheduler.delay(0.35, function()
        ReleaseAliMoveKey()
    end)
end

function AliDodgeAwayFromTarget(targetCharacter)
    BlockEnd()
    ReleaseAliMoveKey()

    local towardKey, towardName = GetMoveKeyTowardTarget(targetCharacter)
    local moveKey = MoveKeys.S
    local moveName = "S"

    if towardKey == MoveKeys.W then
        moveKey, moveName = MoveKeys.S, "S"
    elseif towardKey == MoveKeys.S then
        moveKey, moveName = MoveKeys.W, "W"
    elseif towardKey == MoveKeys.A then
        moveKey, moveName = MoveKeys.D, "D"
    elseif towardKey == MoveKeys.D then
        moveKey, moveName = MoveKeys.A, "A"
    end

    AliInjectedMoveKey = moveKey
    print("[Boxing M2 Escape] " .. moveName .. " DOWN (away from " .. towardName .. ")")
    keypress(moveKey)

    scheduler.delay(0.05, function()
        print("[Boxing M2 Escape] Q DASH")
        for i = 1, 12 do
            keypress(DodgeKey)
            keyrelease(DodgeKey)
        end
    end)

    scheduler.delay(0.18, function()
        print("[Boxing M2 Escape] " .. moveName .. " UP")
        ReleaseAliMoveKey()
    end)

    scheduler.delay(0.35, function()
        ReleaseAliMoveKey()
    end)
end

function VisualRuntime.IsHeavyAttack(attackConfig)
    local displayName = string.lower(tostring(attackConfig.DisplayName or ""))
    return attackConfig.Heavy == true
        or string.find(displayName, "m2", 1, true) ~= nil
        or string.find(displayName, "heavy", 1, true) ~= nil
end

function Counter(StartTime, HoldFor)
    -- Match Auto Parry's Matcha input behavior:
    -- press once now, then release from ParryTask after a deadline.
    BlockEnd()

    local startTime = StartTime or os.clock()
    local holdFor = HoldFor or BlockHoldTime

    CounterReleaseDeadline = startTime + holdFor
    CounterKeyHeld = true

    print("[Auto Counter] R DOWN")
    keypress(HeavyKey)
end

function CounterEnd()
    if not CounterKeyHeld then
        return
    end

    CounterKeyHeld = false
    CounterReleaseDeadline = 0

    print("[Auto Counter] R UP")
    keyrelease(HeavyKey)
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

    if CounterKeyHeld and os.clock() > CounterReleaseDeadline then
        CounterEnd()
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


local ParryLearningLog = {}  -- {[animId] = {TriggerTime, Style, DisplayName, Count}}

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
    local ok, parent = pcall(function()
        return character and character.Parent
    end)
    if not ok or not parent then return nil end

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

local function CalculateParryTiming(attackConfig, StartTime, Target)
    
    local optimalReactionTime = (attackConfig.ReactionTime or DefaultReactionTime)
    local HeightMultiplier = 1 
    if HeightToggle.Get() then  
       HeightMultiplier = GetHeightMultiplierForCharacter(Target)
    end

    local CompValue = (GetPingValue()/1000) * 0.5

    if PingCompensateToggle.Get() then  
        optimalReactionTime -= CompValue
    end

    local adjustedReactionTime = (optimalReactionTime * HeightMultiplier) + ParryOffset


    local parryWindowStart = adjustedReactionTime
    local parryWindowEnd = adjustedReactionTime + ParryWindow

    local ClockStart = StartTime + parryWindowStart
    local ClockEnd = StartTime + parryWindowEnd
    
    return ClockStart, ClockEnd
end

local ConstLatency = 0.018
local EXECUTE_DEBOUNCE = 0.5

local function UpdateAnimationRegistry(animKey, anim, now, currentTrackTime, attackConfig, TargetCharacter)

    if not AnimationRegistry[animKey] then
        local adjustedNow = now - ConstLatency -- - currentTrackTime
        local BlockStart, BlockExpire = CalculateParryTiming(attackConfig, adjustedNow, TargetCharacter)

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
        }
    end
    
    local regData = AnimationRegistry[animKey]
    
    if regData.CurrentTrackTime and (currentTrackTime < regData.CurrentTrackTime) then
        local BlockStart, BlockExpire = CalculateParryTiming(attackConfig, now - currentTrackTime, TargetCharacter)
        
        regData.Processed = false
        regData.DidALoop = true
        warn("Loop detected")
        regData.BlockStart = BlockStart
        regData.BlockExpire = BlockExpire
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
    local isHeavy = VisualRuntime.IsHeavyAttack(attackConfig)
  --  print(distance)
    
    if not isHeavy then -- and distance > 4 then  
        if TargetFacingYou.Get() and targetRoot.CFrame.LookVector:Dot(-direction) < 0.1 then return false end
        if YouFacingTarget.Get() and localRoot.CFrame.LookVector:Dot(direction) < 0.1 then return false end
    end
    
    return true
end

local function ExecuteParry(regData, attackConfig, targetCharacter)
    local now = os.clock()
    if (now - regData.LastExecuteTime) < EXECUTE_DEBOUNCE then
        return
    end
    regData.LastExecuteTime = now

    local isHeavy = VisualRuntime.IsHeavyAttack(attackConfig)

    if isHeavy and AutoAliCounterToggle.Get() then
        local isBoxingM2 =
            tostring(attackConfig.Style) == "BoxingAnims"
            and string.lower(tostring(attackConfig.DisplayName or "")) == "m2"

        if isBoxingM2 then
            -- Boxing M2 has a delayed custom parry sequence. Auto Ali normally
            -- bypasses custom handlers, so give this one attack a reliable
            -- escape that cannot be retriggered by the same animation.
            regData.Processed = true
            AliDodgeAwayFromTarget(targetCharacter)
        else
            AliDodgeIntoTarget(targetCharacter)
        end

        print(string.format("Ali Counter triggered by [%s | %s]",
            tostring(attackConfig.Style),
            tostring(attackConfig.DisplayName)))
    elseif isHeavy and AutoCounterToggle.Get() then
        Counter(regData.BlockStart)
        print(string.format("Counter triggered by [%s | %s]",
            tostring(attackConfig.Style),
            tostring(attackConfig.DisplayName)))
    elseif attackConfig.Jump then
        keypress(32)
        scheduler.delay(0.06, function()
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
            print(string.format("Block triggered by [%s | %s] " , 
                attackConfig.Style, 
                attackConfig.DisplayName
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
    -- Auto Counter takes priority for M2/heavy attacks, including attacks that
    -- normally have a custom ParryFunction.
    local isHeavy = VisualRuntime.IsHeavyAttack(attackConfig)

    if attackConfig.ParryFunction
        and not (isHeavy and (AutoCounterToggle.Get() or AutoAliCounterToggle.Get()))
        and (now - regData.StartTime) <= (attackConfig.ReactionTime or DefaultReactionTime) + ParryWindow/2 then
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
            ExecuteParry(regData, attackConfig, character)
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

        local characterAlive = false
        pcall(function()
            characterAlive = character ~= nil and character.Parent ~= nil
        end)

        if not characterAlive then
            if type(tracker) == "table" and type(tracker.Destroy) == "function" then
                pcall(function()
                    tracker:Destroy()
                end)
            end

            local marker = TargetSelectionState.Markers[character]
            if marker then
                pcall(function()
                    marker.Visible = false
                    marker:Remove()
                end)
                TargetSelectionState.Markers[character] = nil
            end

            EspTrackers[character] = nil
            table.remove(TargetCharacters, i)
            continue
        end

        -- A missing/destroyed ESP tracker must never remove a valid combat
        -- target. Skip only the optional visual/logging work for this pass.
        if type(tracker) ~= "table"
            or type(tracker.ChangeText) ~= "function" then

            tracker = VisualRuntime.CreateParryTargetTracker(character)

            if type(tracker) ~= "table"
                or type(tracker.ChangeText) ~= "function" then

                continue
            end
        end

        VisualRuntime.ApplyAnimationIdEspVisibility(tracker)

        if not VisualRuntime.AnimationIdEspEnabled then
            continue
        end

        -- Fetch active animations using your AnimationTracker system
        local updateOk, activeAnimations = pcall(function()
            return AnimationTracker:Update(character)
        end)
        if not updateOk or type(activeAnimations) ~= "table" then
            activeAnimations = {}
        end

        local lines = {}
        
        if #activeAnimations == 0 then 
            pcall(function()
                tracker:ChangeText("CurrentlyPlaying", "None", COLOR_WHITE)
            end)
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
            pcall(function()
                tracker:ChangeText("CurrentlyPlaying", table.concat(lines, "\n"), COLOR_WHITE)
            end)
        end    
    end
end

function VisualRuntime.ClearParryTargetTrackers()
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

function VisualRuntime.ApplyAnimationIdEspVisibility(tracker)
    local textData = tracker
        and tracker.Drawings
        and tracker.Drawings.CurrentlyPlaying

    if not textData then
        return
    end

    textData.Visible = VisualRuntime.AnimationIdEspEnabled

    if not VisualRuntime.AnimationIdEspEnabled and textData.Drawing then
        textData.Drawing.Visible = false
    end
end

function VisualRuntime.RefreshAnimationIdEspVisibility()
    for _, tracker in pairs(EspTrackers) do
        VisualRuntime.ApplyAnimationIdEspVisibility(tracker)
    end
end

function VisualRuntime.CreateParryTargetTracker(character)
    if not character
        or IsCharacterWhitelisted(character) then

        return nil
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil
    end

    local tracker = ESP_Utility.NewTracker(
        root,
        character.Name,
        COLOR_RED
    )

    if tracker and tracker.Name then
        tracker:AddText("CurrentlyPlaying", nil, "???")
        VisualRuntime.ApplyAnimationIdEspVisibility(tracker)
    end

    EspTrackers[character] = tracker
    return tracker
end

function VisualRuntime.RefreshParryTargetTrackers()
    VisualRuntime.ClearParryTargetTrackers()

    for _, character in ipairs(TargetCharacters) do
        VisualRuntime.CreateParryTargetTracker(character)
    end
end

local function UpdateTargetCharacters(charactersList)
    if #charactersList > 0 then
        table.clear(TargetSelectionState.LastSelected)

        for _, character in ipairs(charactersList) do
            TargetSelectionState.LastSelected[#TargetSelectionState.LastSelected + 1] =
                character
        end
    end

    VisualRuntime.ClearParryTargetTrackers()
    ClearSelectedMarkers()
    table.clear(TargetCharacters)

    for _, character in ipairs(charactersList) do
        if character and not IsCharacterWhitelisted(character) then
            table.insert(TargetCharacters, character)

            AddSelectedMarker(character)
        end
    end

    VisualRuntime.RefreshParryTargetTrackers()
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
    local mouseLocation = nil

    if manualCycle then
        -- Matcha support differs between Roblox mouse APIs. Prefer the
        -- viewport-aligned LocalPlayer mouse, then fall back to UIS.
        local playerMouseOk, playerMouse = pcall(function()
            return LocalPlayer:GetMouse()
        end)

        if playerMouseOk and playerMouse then
            local positionOk, playerMouseLocation = pcall(function()
                return Vector2.new(playerMouse.X, playerMouse.Y)
            end)

            if positionOk then
                mouseLocation = playerMouseLocation
            end
        end

        if not mouseLocation then
            local inputMouseOk, inputMouseLocation = pcall(function()
                return UIS:GetMouseLocation()
            end)

            if inputMouseOk then
                mouseLocation = inputMouseLocation
            end
        end
    end

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
                local candidate = {
                    Character = char,
                    Distance = distance,
                    OnScreen = false,
                    CursorDistanceSquared = math.huge,
                }

                if mouseLocation then
                    local projectionOk, screenPosition, onScreen = pcall(function()
                        return WorldToScreen(targetRoot.Position)
                    end)

                    if projectionOk and onScreen and screenPosition then
                        local cursorOffsetX = screenPosition.X - mouseLocation.X
                        local cursorOffsetY = screenPosition.Y - mouseLocation.Y

                        candidate.OnScreen = true
                        candidate.CursorDistanceSquared =
                            cursorOffsetX * cursorOffsetX
                            + cursorOffsetY * cursorOffsetY
                    end
                end

                table.insert(validCharacters, candidate)
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

    if manualCycle then
        table.sort(validCharacters, function(a, b)
            if a.OnScreen ~= b.OnScreen then
                return a.OnScreen
            end

            if a.OnScreen
                and a.CursorDistanceSquared ~= b.CursorDistanceSquared then

                return a.CursorDistanceSquared < b.CursorDistanceSquared
            end

            return a.Distance < b.Distance
        end)

        CurrentIndex = 1

        local selectedCharacter =
            validCharacters[1].Character

        if MultiTarget.Get() then
            local selectedCharacters = {}

            -- A single manual activation selects the three candidates nearest
            -- the cursor, matching the automatic multi-target count.
            for index = 1, math.min(3, #validCharacters) do
                selectedCharacters[index] =
                    validCharacters[index].Character
            end

            UpdateTargetCharacters(selectedCharacters)

            Notify(
                "Target",
                "Selected "
                    .. tostring(#selectedCharacters)
                    .. " cursor-nearest target(s)",
                2
            )
        else
            UpdateTargetCharacters({ selectedCharacter })

            Notify(
                "Target",
                "Selected "
                    .. GetCharacterDisplayName(selectedCharacter)
                    .. " [nearest cursor]",
                2
            )
        end

        return
    end

    table.sort(validCharacters, function(a, b)
        return a.Distance < b.Distance
    end)

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

function _sanitizeTimingId(value)
    return tostring(value)
        :gsub("rbxassetid://", "")
        :gsub("[^%w_]", "_")
end

function BuildTimingControls()
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

    for styleIndex, style in ipairs(styleNames) do
        local animations = grouped[style]
        local sectionTitle = tostring(style)
            :gsub("Anims$", "")
            :gsub("Other", " Other")
            .. " Timings"
        local styleSection = ParryConfigTab:AddSection(
            sectionTitle,
            styleIndex % 2 == 1 and "Left" or "Right",
            "Reaction delays for " .. sectionTitle:gsub(" Timings$", "") .. " attacks."
        )

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

                local slider = SafeAddSlider(styleSection, {
                    Id = sliderId,
                    Title = displayName .. " (ms)",
                    Description = "Sets the reaction delay for this animation in milliseconds.",
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
-- INS CONTROLS FOR GAKURAN RUNTIME VALUES
--==================================================

local AutoParryRangeSlider = SafeAddSlider(ParryConfigTab, {
    Id = "auto_parry_range",
    Title = "Auto Parry Range",
    Description = "Maximum distance in studs at which attacks can trigger Auto Parry.",
    Min = 1,
    Max = 80,
    Default = AutoParryRange,
    Callback = function(value)
        AutoParryRange = value
    end
})

local ProbabilityToParrySlider = SafeAddSlider(ParryConfigTab, {
    Id = "probability_to_parry",
    Title = "Probability To Parry",
    Description = "Percentage chance that a valid detected attack will be handled.",
    Min = 1,
    Max = 100,
    Default = ProbabilityToParry,
    Callback = function(value)
        ProbabilityToParry = value
    end
})

local ParryOffsetSlider = SafeAddSlider(ParryConfigTab, {
    Id = "parry_offset_ms",
    Title = "Parry Offset (ms)",
    Description = "Shifts every parry earlier with negative values or later with positive values.",
    Min = -100,
    Max = 100,
    Default = math.floor(ParryOffset * 1000),
    Callback = function(value)
        ParryOffset = value / 1000
    end
})

local ParryWindowSlider = SafeAddSlider(ParryConfigTab, {
    Id = "parry_window_ms",
    Title = "Parry Window (ms)",
    Description = "How long after the calculated start time a parry may still execute.",
    Min = 0,
    Max = 1000,
    Default = math.floor(ParryWindow * 1000),
    Callback = function(value)
        ParryWindow = value / 1000
    end
})

local MaxCycleRangeSlider = SafeAddSlider(TargetingTab, {
    Id = "max_cycle_range",
    Title = "Max Cycle Range",
    Description = "Maximum distance in studs for manual and automatic target selection.",
    Min = 7,
    Max = 50,
    Default = MaxCycleRange,
    Callback = function(value)
        MaxCycleRange = value
    end
})


--==================================================
-- KEYBINDS
--==================================================

local KeybindSpecs = {}
local KeybindSpecsById = {}
local KeybindControls = {}

local function ToggleMenuVisibility()
    if Library and type(Library.Minimize) == "function" then
        Library:Minimize()
        return
    end

    Notify("Keybinds", "Could not locate the menu UI.", 3)
end

local function SyncUIControl(control, value)
    if not control then
        return false
    end

    for _, methodName in ipairs({ "SetValue", "Set", "SetState" }) do
        if type(control[methodName]) == "function" then
            local ok = pcall(function()
                control[methodName](control, value)
            end)
            return ok
        end
    end

    return false
end

local function SyncUIToggle(toggleName, value)
    return SyncUIControl(UIToggles[toggleName], value)
end

local function RegisterActionKeybind(id, title, defaultKeyCode, action)
    local spec = {
        Id = id,
        Title = title,
        KeyName = defaultKeyCode and defaultKeyCode.Name or nil,
        Action = action,
    }

    table.insert(KeybindSpecs, spec)
    KeybindSpecsById[id] = spec
    return spec
end

local function RegisterToggleKeybind(id, title, toggleName, getter, setter)
    local spec = {
        Id = id,
        Title = title,
        ToggleName = toggleName,
        KeyName = nil,
        Get = getter,
        Set = setter,
    }

    table.insert(KeybindSpecs, spec)
    KeybindSpecsById[id] = spec
    return spec
end

local function TriggerManualCycle()
    CycleEvent(true)
end

RegisterActionKeybind(
    "menu_toggle",
    "Open / Close Menu",
    Enum.KeyCode.M,
    ToggleMenuVisibility
)

RegisterActionKeybind(
    "cycle_target",
    "Select Cursor Target",
    nil,
    TriggerManualCycle
)

RegisterToggleKeybind("auto_parry", "Auto Parry", "AutoParry",
    AutoParryToggle.Get, AutoParryToggle.Set)
RegisterToggleKeybind("auto_dodge", "Auto Dodge / Heavy", "AutoDodge",
    AutoDodgeToggle.Get, AutoDodgeToggle.Set)
RegisterToggleKeybind("auto_counter", "Auto Counter", "AutoCounter",
    AutoCounterToggle.Get, AutoCounterToggle.Set)
RegisterToggleKeybind("auto_ali_counter", "Auto Ali Counter", "AutoAliCounter",
    AutoAliCounterToggle.Get, AutoAliCounterToggle.Set)
RegisterToggleKeybind("auto_play", "Auto Play", "AutoPlay",
    AutoPlayToggle.Get, AutoPlayToggle.Set)
RegisterToggleKeybind("parry_debug", "Debug Parry", "ParryDebug",
    ParryDebugToggle.Get, ParryDebugToggle.Set)
RegisterToggleKeybind("parry_status", "Parry Status", "ParryStatus",
    function() return VisualRuntime.AutoParryStatusEnabled end,
    VisualRuntime.SetAutoParryStatusVisible)
RegisterToggleKeybind("animation_id_esp", "Animation ID ESP", "AnimationIdESP",
    function() return VisualRuntime.AnimationIdEspEnabled end,
    VisualRuntime.SetAnimationIdEspEnabled)

RegisterToggleKeybind("auto_target_nearest", "Auto Target Nearest", "AutoTargetNearest",
    AutoTargetNearest.Get, AutoTargetNearest.Set)
RegisterToggleKeybind("multiple_targets", "Multiple Targets", "MultipleTargets",
    MultiTarget.Get, MultiTarget.Set)
RegisterToggleKeybind("include_local_character", "Include Local Character", "IncludeLocalCharacter",
    function() return IncludeLocalCharacter end,
    function(value) IncludeLocalCharacter = value end)
RegisterToggleKeybind("target_facing_you", "Target Facing You", "TargetFacingYou",
    TargetFacingYou.Get, TargetFacingYou.Set)
RegisterToggleKeybind("you_facing_target", "You Facing Target", "YouFacingTarget",
    YouFacingTarget.Get, YouFacingTarget.Set)

RegisterToggleKeybind("height_multiplier", "Height Multiplier", "HeightMultiplier",
    HeightToggle.Get, HeightToggle.Set)
RegisterToggleKeybind("ping_compensation", "Ping Compensation", "PingCompensation",
    PingCompensateToggle.Get, PingCompensateToggle.Set)

RegisterToggleKeybind("esp", "ESP", "ESP",
    function() return state.ESP end,
    function(value) state.ESP = value end)
RegisterToggleKeybind("tracers", "Tracers", "Tracers",
    function() return state.Tracers end,
    function(value) state.Tracers = value end)
RegisterToggleKeybind("player_health", "Player Health", "PlayerHealth",
    function() return state.PlayerHealth end,
    function(value) state.PlayerHealth = value end)
RegisterToggleKeybind("self_health", "Self Health", "SelfHealth",
    function() return state.SelfHealth end,
    function(value) state.SelfHealth = value end)

local function SetKeybind(spec, value, preserveIfUnbound)
    if typeof(value) == "EnumItem" then
        value = value.Name
    end

    if type(value) == "string" then
        value = value:match("^%s*(.-)%s*$")
        if value == "" or string.lower(value) == "none" then
            value = nil
        end
    else
        value = nil
    end

    -- Only config loading protects shortcuts. Manual clearing
    -- through the Keybinds page must still work normally.
    if preserveIfUnbound and value == nil then
        return false
    end

    spec.KeyName = value
    return true
end

local function AddKeybindControl(spec)
    local targetTab = KeybindsTab

    if spec.Id == "cycle_target"
        or spec.Id == "auto_target_nearest"
        or spec.Id == "multiple_targets"
        or spec.Id == "include_local_character"
        or spec.Id == "target_facing_you"
        or spec.Id == "you_facing_target" then

        targetTab = KeybindsTab.Targeting
    elseif spec.Id == "height_multiplier"
        or spec.Id == "ping_compensation" then

        targetTab = KeybindsTab.Parry
    elseif spec.Id == "esp"
        or spec.Id == "tracers"
        or spec.Id == "player_health"
        or spec.Id == "self_health" then

        targetTab = KeybindsTab.Visuals
    elseif spec.Id ~= "menu_toggle" then
        targetTab = KeybindsTab.Combat
    end

    local control = SafeControl(targetTab, "AddKeybind", {
        Id = "keybind_" .. spec.Id,
        Title = spec.Title,
        Description = spec.Id == "menu_toggle"
            and "Key used to minimize or restore the menu. Press Delete to clear it."
            or spec.Id == "cycle_target"
            and "Selects the in-range character nearest your cursor, or up to three when Multiple Targets is enabled. Press Delete to clear it."
            or "Pressing this key toggles the matching feature. Press Delete to clear it.",
        Default = spec.KeyName,
        Mode = "Toggle",

        Callback = function()
            if spec.Action then
                spec.Action()
            else
                local newValue = not spec.Get()
                spec.Set(newValue)
                if not SyncUIToggle(spec.ToggleName, newValue) then
                    Library:NotifyToggleState(spec.Title, newValue)
                end
            end
        end,

        ChangedCallback = function(keyName)
            SetKeybind(spec, keyName)
        end
    })

    KeybindControls[spec.Id] = control
end

for _, spec in ipairs(KeybindSpecs) do
    AddKeybindControl(spec)
end

local function CaptureKeybindConfig()
    local config = {}

    for _, spec in ipairs(KeybindSpecs) do
        local control = KeybindControls[spec.Id]
        if control and type(control.GetValue) == "function" then
            -- Native INS loads can assign the row after its callback fires.
            -- Save the actual displayed/live binding, not a stale mirror.
            SetKeybind(spec, control:GetValue())
        end
        config[spec.Id] = spec.KeyName or "None"
    end

    return config
end

local function ApplyKeybindConfig(config)
    if type(config) ~= "table" then
        return
    end

    for id, value in pairs(config) do
        local resolvedId = id == "auto_parry_esp"
            and "animation_id_esp"
            or id
        local spec = KeybindSpecsById[resolvedId]

        if spec and type(value) == "string" and SetKeybind(
            spec,
            value,
            true
        ) then
            local control = KeybindControls[resolvedId]
            if control and type(control.SetValue) == "function" then
                pcall(function()
                    control:SetValue(spec.KeyName, "Toggle")
                end)
            end
        end
    end
end

-- INS also has its own profile/autoload entry point. Protect that path as
-- well as FFTM's Load button; empty bindings must not erase any live shortcut.
function Library:ProtectNativeConfigKeybinds()
    if self.NativeLoadConfig or type(self.Raw.LoadConfig) ~= "function" then
        return
    end

    self.NativeLoadConfig = self.Raw.LoadConfig
    self.Raw.LoadConfig = function(raw, ...)
        local previous = CaptureKeybindConfig()
        Library.LoadingNativeConfig = true
        local ok, result = pcall(Library.NativeLoadConfig, raw, ...)
        Library.LoadingNativeConfig = false

        for id, control in pairs(KeybindControls) do
            local spec = KeybindSpecsById[id]
            local value = control:GetValue()
            if not ok or not SetKeybind(spec, value, true) then
                SetKeybind(spec, previous[id])
            end
            -- INS may restore its attached-bind data after the row callback.
            -- Re-sync both the live row and our save-state after that finishes.
            control:SetValue(spec.KeyName, "Toggle")
        end

        if not ok then error(result, 0) end
        return result
    end
end

Library:ProtectNativeConfigKeybinds()

function SetupPresetConfigUI()
    --==================================================
    -- CONFIG / PERSISTENT LOCAL PROFILES
    --==================================================

    local HttpService = game:GetService("HttpService")

    -- Matcha's writefile/readfile APIs write into its persistent workspace.
    -- Keeping everything under one folder prevents the configs from being
    -- tied only to the current script session.
    local CONFIG_FOLDER = "FFTM"
    local CONFIG_FILE = CONFIG_FOLDER .. "/configs.json"
    local LEGACY_CONFIG_FILE = "fftm_presets.json"

    local Configs = {}
    local SelectedConfig = "Config 1"
    local CurrentTheme = "Waifu"

    local ConfigNames = {
        "Config 1",
        "Config 2",
        "Config 3",
        "Config 4",
        "Config 5",
    }

    local function HasFileAPI()
        return type(writefile) == "function"
            and type(readfile) == "function"
            and type(isfile) == "function"
    end

    local function EnsureConfigFolder()
        if type(makefolder) ~= "function" then
            return true
        end

        local exists = false

        if type(isfolder) == "function" then
            local ok, result = pcall(function()
                return isfolder(CONFIG_FOLDER)
            end)

            exists = ok and result == true
        end

        if exists then
            return true
        end

        local ok, err = pcall(function()
            makefolder(CONFIG_FOLDER)
        end)

        if not ok then
            -- Some executors error when the folder already exists.
            if type(isfolder) == "function" then
                local verifyOk, verify = pcall(function()
                    return isfolder(CONFIG_FOLDER)
                end)

                if verifyOk and verify then
                    return true
                end
            end

            warn("[Config] Could not create config folder: " .. tostring(err))
            return false
        end

        return true
    end

    local function DecodeConfigFile(path)
        local okExists, exists = pcall(function()
            return isfile(path)
        end)

        if not okExists or not exists then
            return nil
        end

        local okRead, raw = pcall(function()
            return readfile(path)
        end)

        if not okRead or type(raw) ~= "string" or raw == "" then
            return nil
        end

        local okDecode, decoded = pcall(function()
            return HttpService:JSONDecode(raw)
        end)

        if okDecode and type(decoded) == "table" then
            return decoded
        end

        return nil
    end

    local function SaveConfigFile()
        if not HasFileAPI() then
            Notify(
                "Config",
                "Matcha file APIs are unavailable, so configs cannot persist after closing Matcha.",
                5
            )
            return false
        end

        if not EnsureConfigFolder() then
            return false
        end

        local payload = {
            Version = 2,
            Configs = Configs,
        }

        local okEncode, raw = pcall(function()
            return HttpService:JSONEncode(payload)
        end)

        if not okEncode then
            warn("[Config] JSON encode failed: " .. tostring(raw))
            return false
        end

        local okWrite, err = pcall(function()
            writefile(CONFIG_FILE, raw)
        end)

        if not okWrite then
            warn("[Config] Could not write " .. CONFIG_FILE .. ": " .. tostring(err))
            return false
        end

        print("[Config] Persisted configs to " .. CONFIG_FILE)
        return true
    end

    local function LoadConfigFile()
        if not HasFileAPI() then
            print("[Config] Matcha file APIs unavailable.")
            return
        end

        EnsureConfigFolder()

        local decoded = DecodeConfigFile(CONFIG_FILE)

        if type(decoded) == "table" then
            if type(decoded.Configs) == "table" then
                Configs = decoded.Configs
            else
                -- Accept an older flat table if one was manually placed here.
                Configs = decoded
            end

            print("[Config] Loaded persistent configs from " .. CONFIG_FILE)
            return
        end

        -- One-time migration from the previous session/preset filename.
        local legacy = DecodeConfigFile(LEGACY_CONFIG_FILE)

        if type(legacy) == "table" then
            for oldName, config in pairs(legacy) do
                local mappedName = oldName

                if oldName == "Slot 1" then
                    mappedName = "Config 1"
                elseif oldName == "Slot 2" then
                    mappedName = "Config 2"
                elseif oldName == "Slot 3" then
                    mappedName = "Config 3"
                end

                Configs[mappedName] = config
            end

            if SaveConfigFile() then
                print("[Config] Migrated old fftm_presets.json into " .. CONFIG_FILE)
            end
        end
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

    local function CaptureConfig()
        return {
            Theme = CurrentTheme,

            Visuals = {
                ESP = state.ESP,
                Tracers = state.Tracers,
                TracerTransparency = state.TracerTransparency,
                ESPDistance = state.ESPDistance,
                PlayerHealth = state.PlayerHealth,
                PlayerHealthDistance = state.PlayerHealthDistance,
                SelfHealth = state.SelfHealth,
            },

            Combat = {
                AutoParry = AutoParryToggle.Get(),
                AutoDodge = AutoDodgeToggle.Get(),
                AutoCounter = AutoCounterToggle.Get(),
                AutoAliCounter = AutoAliCounterToggle.Get(),
                AutoPlay = AutoPlayToggle.Get(),
                ParryDebug = ParryDebugToggle.Get(),
                ParryStatus = VisualRuntime.AutoParryStatusEnabled,
                AnimationIdESP = VisualRuntime.AnimationIdEspEnabled,
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

            Keybinds = CaptureKeybindConfig(),
            AnimationTimings = CopyAnimationTimings(),
            Whitelist = CopyWhitelist(),
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

                SyncUIControl(
                    slider,
                    math.floor(seconds * 1000 + 0.5)
                )
            end
        end
    end

    local function ApplyToggleControl(toggleName, value, setter)
        if type(value) ~= "boolean" then
            return
        end

        setter(value)
        local wasSuppressed = Library.SuppressToggleNotifications
        Library.SuppressToggleNotifications = true
        SyncUIToggle(toggleName, value)
        Library.SuppressToggleNotifications = wasSuppressed
    end

    local function ApplyConfig(config)
        if type(config) ~= "table" then
            return false
        end

        local visuals = config.Visuals

        if type(visuals) == "table" then
            ApplyToggleControl("ESP", visuals.ESP, function(value)
                state.ESP = value
            end)
            ApplyToggleControl("Tracers", visuals.Tracers, function(value)
                state.Tracers = value
            end)

            if type(visuals.TracerTransparency) == "number" then
                local transparency = math.clamp(visuals.TracerTransparency, 0, 100)
                state.TracerTransparency = transparency
                SyncUIControl(TracerTransparencySlider, transparency)
            end

            if type(visuals.ESPDistance) == "number" then
                local distance = math.clamp(visuals.ESPDistance, 10, 500)
                state.ESPDistance = distance
                state.ESPDistanceSquared = distance * distance
                _G.ESPMaxDistance = distance
                _G.ESPMaxDistanceSquared = state.ESPDistanceSquared
                SyncUIControl(ESPDistanceSlider, distance)
            end

            ApplyToggleControl("PlayerHealth", visuals.PlayerHealth, function(value)
                state.PlayerHealth = value
            end)

            if type(visuals.PlayerHealthDistance) == "number" then
                local distance = math.clamp(visuals.PlayerHealthDistance, 10, 500)
                state.PlayerHealthDistance = distance
                state.PlayerHealthDistanceSquared = distance * distance
                _G.HealthESPMaxDistance = distance
                _G.HealthESPMaxDistanceSquared = state.PlayerHealthDistanceSquared
                SyncUIControl(HealthESPDistanceSlider, distance)
            end

            ApplyToggleControl("SelfHealth", visuals.SelfHealth, function(value)
                state.SelfHealth = value
            end)
        end

        local combat = config.Combat

        if type(combat) == "table" then
            ApplyToggleControl("AutoParry", combat.AutoParry, AutoParryToggle.Set)
            ApplyToggleControl("AutoDodge", combat.AutoDodge, AutoDodgeToggle.Set)
            ApplyToggleControl("AutoCounter", combat.AutoCounter, AutoCounterToggle.Set)
            ApplyToggleControl("AutoAliCounter", combat.AutoAliCounter, AutoAliCounterToggle.Set)
            ApplyToggleControl("AutoPlay", combat.AutoPlay, AutoPlayToggle.Set)
            ApplyToggleControl("ParryDebug", combat.ParryDebug, ParryDebugToggle.Set)
            ApplyToggleControl(
                "ParryStatus",
                combat.ParryStatus,
                VisualRuntime.SetAutoParryStatusVisible
            )
            local animationIdEsp = combat.AnimationIdESP
            if type(animationIdEsp) ~= "boolean" then
                animationIdEsp = combat.AutoParryESP
            end

            ApplyToggleControl(
                "AnimationIdESP",
                animationIdEsp,
                VisualRuntime.SetAnimationIdEspEnabled
            )
            ApplyToggleControl(
                "PingCompensation",
                combat.PingCompensation,
                PingCompensateToggle.Set
            )
            ApplyToggleControl("HeightMultiplier", combat.HeightMultiplier, HeightToggle.Set)

            ApplyToggleControl(
                "AutoTargetNearest",
                combat.AutoTargetNearest,
                AutoTargetNearest.Set
            )
            ApplyToggleControl("MultipleTargets", combat.MultipleTargets, MultiTarget.Set)
            ApplyToggleControl(
                "IncludeLocalCharacter",
                combat.IncludeLocalCharacter,
                function(value)
                    IncludeLocalCharacter = value
                end
            )
            ApplyToggleControl("TargetFacingYou", combat.TargetFacingYou, TargetFacingYou.Set)
            ApplyToggleControl("YouFacingTarget", combat.YouFacingTarget, YouFacingTarget.Set)

            if type(combat.AutoParryRange) == "number" then
                AutoParryRange = combat.AutoParryRange
                SyncUIControl(AutoParryRangeSlider, AutoParryRange)
            end
            if type(combat.MaxCycleRange) == "number" then
                MaxCycleRange = combat.MaxCycleRange
                SyncUIControl(MaxCycleRangeSlider, MaxCycleRange)
            end
            if type(combat.ProbabilityToParry) == "number" then
                ProbabilityToParry = combat.ProbabilityToParry
                SyncUIControl(ProbabilityToParrySlider, ProbabilityToParry)
            end
            if type(combat.ParryOffset) == "number" then
                ParryOffset = combat.ParryOffset
                SyncUIControl(ParryOffsetSlider, math.floor(ParryOffset * 1000 + 0.5))
            end
            if type(combat.ParryWindow) == "number" then
                ParryWindow = combat.ParryWindow
                SyncUIControl(ParryWindowSlider, math.floor(ParryWindow * 1000 + 0.5))
            end
        end

        if type(config.Theme) == "string" then
            CurrentTheme = config.Theme

            pcall(function()
                Library:SetTheme(CurrentTheme)
            end)
        end

        ApplyWhitelist(config.Whitelist)
        ApplyAnimationTimings(config.AnimationTimings)
        ApplyKeybindConfig(config.Keybinds)

        return true
    end

    LoadConfigFile()

    -- One compact profile selector for all saved configs.
    SafeAddDropdown(ConfigTab, {
        Id = "config_profile",
        Title = "Config",
        Description = "Selects which local preset slot Save and Load will use.",
        Options = ConfigNames,
        Default = SelectedConfig,

        Callback = function(value)
            SelectedConfig = value
            print("[Config] Selected " .. tostring(value))
        end
    })

    SafeAddButton(ConfigTab, {
        Title = "Save",
        Description = "Saves the current toggles, sliders, theme, whitelist, and keybinds.",

        Callback = function()
            Configs[SelectedConfig] = CaptureConfig()

            if SaveConfigFile() then
                Notify(
                    "Config",
                    SelectedConfig .. " saved locally.",
                    3
                )
            else
                Notify(
                    "Config",
                    "Could not save " .. SelectedConfig .. " to disk.",
                    4
                )
            end
        end
    })

    SafeAddButton(ConfigTab, {
        Title = "Load",
        Description = "Loads the selected preset. Blank keybind entries keep all your current shortcuts; clear binds manually on the Keybinds page.",

        Callback = function()
            -- Re-read the disk copy first. This makes Load use the persisted
            -- version even after reopening/re-executing Matcha.
            LoadConfigFile()

            local config = Configs[SelectedConfig]

            if type(config) ~= "table" or next(config) == nil then
                Notify(
                    "Config",
                    SelectedConfig .. " is empty.",
                    3
                )
                return
            end

            if ApplyConfig(config) then
                Notify(
                    "Config",
                    SelectedConfig .. " loaded.",
                    3
                )
                print("[Config] Loaded " .. SelectedConfig)
            end
        end
    })

    -- Keep the existing keybind controls below the compact config controls.



    SafeAddDropdown(ConfigTab.Appearance, {
        Id = "config_theme",
        Title = "Theme",
        Description = "Changes the menu's colors and visual style immediately.",
        Options = Library.Themes,
        Default = "Waifu",

        Callback = function(value)
            CurrentTheme = value
            Library:SetTheme(value)
        end
    })

    SafeAddButton(ConfigTab.Utilities, {
        Title = "Clear Drawings",
        Description = "Immediately hides all base ESP, tracer, and health Drawing objects.",

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

    if HasFileAPI() then
        print("[Config] Persistent local configs enabled: " .. CONFIG_FILE)
    else
        warn("[Config] Matcha does not expose writefile/readfile/isfile in this environment.")
    end
end

SetupPresetConfigUI()

function SetupTargetFolderUI()
    SafeAddButton(TargetingTab, {
        Title = "Select Cursor Target Now",
        Description = "Selects the in-range character nearest your cursor, or up to three when Multiple Targets is enabled.",

        Callback = function()
            print("[Target] UI cycle button pressed")
            CycleEvent(true)
        end
    })

    SafeAddButton(TargetingTab.Whitelist, {
        Title = "Whitelist Selected Target(s)",
        Description = "Excludes the currently selected target(s) from future selection.",

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

    SafeAddButton(TargetingTab.Whitelist, {
        Title = "Remove Last Selected From Whitelist",
        Description = "Allows the last selected target(s) to be selected again.",

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

    SafeAddButton(TargetingTab.Whitelist, {
        Title = "Clear Whitelist",
        Description = "Removes every target from the exclusion list.",

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
            Description = "Chooses the workspace folder that contains target characters.",
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

Library:Notify({
    Title = "Loaded",
    Content = "INS visuals + Gakuran dependencies loaded.",
    Duration = 4
})

-- Prime the target list once after the folder dropdown has selected a default.
-- Matcha cannot yield with task.wait() from this execution context.
scheduler.delay(0.25, function()
    if SelectedFolder then
        CycleEvent()
    end
end)


-- ==========================================
-- Input & Loop
-- ==========================================
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    local RhythmServiceUI =
        game.Players.LocalPlayer.PlayerGui:FindFirstChild("RhythmServiceUI")

    if RhythmServiceUI then
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

function MainLoop()
    if not FFTM_RUNNING then
        return
    end

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

        local espOk, espErr = pcall(ProcessEspAndLogging)
        if not espOk and now - VisualRuntime.LastParryEspErrorAt >= 5 then
            VisualRuntime.LastParryEspErrorAt = now
            warn("[Auto Parry ESP] Recovered from: " .. tostring(espErr))
        end
    end
end

-- Register/log this session immediately, then continue with 10-second checks.
FFTMSendHeartbeat()
FFTMStartBackgroundPolling()

RunService.RenderStepped:Connect(MainLoop)
--RunService.Heartbeat:Connect(MainLoop)

-- Base visuals do not need to perform projection and Drawing work at the
-- monitor's full refresh rate. Auto Parry keeps its original loop above.
VisualRuntime.UpdateRate = math.clamp(
    tonumber(_G.FFTMVisualUpdateRate) or 30,
    1,
    120
)
VisualRuntime.UpdateInterval = 1 / VisualRuntime.UpdateRate
VisualRuntime.OverlayInterval = math.max(VisualRuntime.UpdateInterval, 1 / 30)
VisualRuntime.MinimumUpdateRate = math.min(12, VisualRuntime.UpdateRate)
VisualRuntime.Accumulator = VisualRuntime.UpdateInterval
VisualRuntime.OverlayAccumulator = VisualRuntime.UpdateInterval
VisualRuntime.BaseVisualsWereEnabled = false
VisualRuntime.PlayerRefreshInterval = 1
VisualRuntime.NextPlayerRefreshAt = 0

function VisualRuntime.RefreshUpdateInterval()
    local rate = VisualRuntime.UpdateRate

    if _G.FFTMAdaptiveVisuals ~= false
        and (state.ESP or state.Tracers or state.PlayerHealth) then

        local otherPlayers = math.max(0, #VisualRuntime.Players - 1)
        local loadFactor = 1 + math.max(0, otherPlayers - 8) / 16
        rate = math.max(VisualRuntime.MinimumUpdateRate, rate / loadFactor)
    end

    VisualRuntime.EffectiveUpdateRate = rate
    VisualRuntime.UpdateInterval = 1 / rate
    VisualRuntime.OverlayInterval = math.max(VisualRuntime.UpdateInterval, 1 / 30)
end

function VisualRuntime.StepBaseVisuals(deltaTime)
    if not FFTM_RUNNING then
        return
    end

    local baseVisualsEnabled =
        state.ESP
        or state.Tracers
        or state.PlayerHealth
        or state.SelfHealth

    if not baseVisualsEnabled then
        if VisualRuntime.BaseVisualsWereEnabled then
            VisualRuntime.RunBaseVisuals()
        end

        VisualRuntime.BaseVisualsWereEnabled = false
        VisualRuntime.UpdateInterval = 1 / VisualRuntime.UpdateRate
        VisualRuntime.OverlayInterval = math.max(
            VisualRuntime.UpdateInterval,
            1 / 30
        )
        return
    end

    if not VisualRuntime.BaseVisualsWereEnabled then
        VisualRuntime.NextPlayerRefreshAt = 0
        VisualRuntime.Accumulator = VisualRuntime.UpdateInterval
    end
    VisualRuntime.BaseVisualsWereEnabled = true

    local now = os.clock()
    if now >= VisualRuntime.NextPlayerRefreshAt then

        VisualRuntime.NextPlayerRefreshAt =
            now + VisualRuntime.PlayerRefreshInterval
        VisualRuntime.RefreshPlayers()
        VisualRuntime.RefreshUpdateInterval()
    end

    VisualRuntime.Accumulator += deltaTime

    if VisualRuntime.Accumulator < VisualRuntime.UpdateInterval then
        return
    end

    VisualRuntime.Accumulator %= VisualRuntime.UpdateInterval
    VisualRuntime.RunBaseVisuals()
end

RunService.RenderStepped:Connect(function(deltaTime)
    -- Guard the entire frame, including enumeration/timers. Failures before
    -- RunBaseVisuals used to leave the last drawn frame frozen on screen.
    local ok, err = pcall(VisualRuntime.StepBaseVisuals, deltaTime)
    if not ok then
        VisualRuntime.ResetBaseDrawingPools()
        VisualRuntime.HideAllBaseDrawings()
        VisualRuntime.LastFrameError = tostring(err)
    end

    -- Optional overlays do not need the monitor's full render rate. Capping
    -- them to the same visual interval avoids excess projections at high FPS.
    VisualRuntime.OverlayAccumulator += deltaTime
    if VisualRuntime.OverlayAccumulator >= VisualRuntime.OverlayInterval then
        VisualRuntime.OverlayAccumulator %= VisualRuntime.OverlayInterval
        pcall(VisualRuntime.PositionAutoParryStatus)
        pcall(UpdateSelectedMarkers)
    end
end)

print("Free Fortnite Cheats TM | Wabi tabs safe-fallback build loaded")
