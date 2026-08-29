local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Visuals are intentionally updated independently of the game's render rate.
-- Raise _G.ESPUpdateRate before loading if a smoother (but more expensive) refresh is desired.
local UPDATE_RATE = math.max(1, tonumber(_G.ESPUpdateRate) or 30)
local UPDATE_INTERVAL = 1 / UPDATE_RATE
local CHARACTER_REFRESH_INTERVAL = 1
local MIN_ESP_DISTANCE = 10
local MAX_ESP_DISTANCE = 500
local DEFAULT_ESP_DISTANCE = 50

--// COLORS
local C = {
	shadow = Color3.fromRGB(0, 0, 0),
	panel = Color3.fromRGB(18, 19, 25),
	border = Color3.fromRGB(55, 58, 72),
	accent = Color3.fromRGB(130, 160, 255),
	text = Color3.fromRGB(236, 239, 248),
	sub = Color3.fromRGB(138, 142, 158),
	on = Color3.fromRGB(95, 225, 140),
	off = Color3.fromRGB(110, 114, 130),
	box = Color3.fromRGB(255, 70, 70),
	line = Color3.fromRGB(255, 255, 255),
}

--// STATE
local initialEspDistance = math.clamp(
	tonumber(_G.ESPMaxDistance) or DEFAULT_ESP_DISTANCE,
	MIN_ESP_DISTANCE,
	MAX_ESP_DISTANCE
)

local state = {
	ESP = false,
	Tracers = false,
	TracerTransparency = 0,
	ESPDistance = initialEspDistance,
}

_G.ESPMaxDistance = initialEspDistance
_G.ESPMaxDistanceSquared = initialEspDistance * initialEspDistance

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

	return state.ESPDistance * state.ESPDistance
end

--// GUI SETTINGS
local PX, PY = 50, 120
local PW = 290
local HEAD_H = 42
local ROW_H = 34
local SLIDER_H = 45
local FOOT_H = 26
local PH = HEAD_H + (ROW_H * 2) + (SLIDER_H * 2) + FOOT_H + 10

local menuVisible = true
local menuDirty = true

local function setDirty()
	menuDirty = true
end

--// DRAWING HELPERS
local function mkSquare(z)
	local square = Drawing.new("Square")
	square.ZIndex = z
	square.Transparency = 1
	square.Visible = false
	return square
end

local function mkText(size, z)
	local text = Drawing.new("Text")
	text.Size = size
	text.Outline = true
	text.ZIndex = z
	text.Transparency = 1
	text.Visible = false
	return text
end

--// GUI
local shadow = mkSquare(7)
shadow.Filled = true
shadow.Color = C.shadow
shadow.Corner = 10
shadow.Position = Vector2.new(PX + 5, PY + 6)
shadow.Size = Vector2.new(PW, PH)

local panel = mkSquare(8)
panel.Filled = true
panel.Color = C.panel
panel.Corner = 10
panel.Position = Vector2.new(PX, PY)
panel.Size = Vector2.new(PW, PH)

local border = mkSquare(9)
border.Filled = false
border.Thickness = 1
border.Color = C.border
border.Corner = 10
border.Position = Vector2.new(PX, PY)
border.Size = Vector2.new(PW, PH)

local logo = mkSquare(10)
logo.Filled = true
logo.Color = C.accent
logo.Corner = 3
logo.Position = Vector2.new(PX + 16, PY + 14)
logo.Size = Vector2.new(12, 12)

local title = mkText(19, 12)
title.Color = C.text
title.Position = Vector2.new(PX + 36, PY + 11)
title.Text = "Visuals"

local divider = mkSquare(9)
divider.Filled = true
divider.Color = C.border
divider.Position = Vector2.new(PX, PY + HEAD_H - 1)
divider.Size = Vector2.new(PW, 1)

local espIndicator = mkSquare(10)
local espLabel = mkText(16, 12)
local tracerIndicator = mkSquare(10)
local tracerLabel = mkText(16, 12)

local distanceLabel = mkText(13, 12)
distanceLabel.Color = C.sub

local distanceBar = mkSquare(10)
distanceBar.Filled = true
distanceBar.Color = C.border
distanceBar.Corner = 3

local distanceFill = mkSquare(11)
distanceFill.Filled = true
distanceFill.Color = C.accent
distanceFill.Corner = 3

local distanceKnob = mkSquare(12)
distanceKnob.Filled = true
distanceKnob.Color = C.text
distanceKnob.Corner = 5

local transparencyLabel = mkText(13, 12)
transparencyLabel.Color = C.sub

local transparencyBar = mkSquare(10)
transparencyBar.Filled = true
transparencyBar.Color = C.border
transparencyBar.Corner = 3

local transparencyFill = mkSquare(11)
transparencyFill.Filled = true
transparencyFill.Color = C.accent
transparencyFill.Corner = 3

local transparencyKnob = mkSquare(12)
transparencyKnob.Filled = true
transparencyKnob.Color = C.text
transparencyKnob.Corner = 5

local footer = mkText(12, 12)
footer.Color = C.sub
footer.Text = "1 ESP   |   2 Tracers   |   M Hide"

local menuDrawings = {
	shadow,
	panel,
	border,
	logo,
	title,
	divider,
	espIndicator,
	espLabel,
	tracerIndicator,
	tracerLabel,
	distanceLabel,
	distanceBar,
	distanceFill,
	distanceKnob,
	transparencyLabel,
	transparencyBar,
	transparencyFill,
	transparencyKnob,
	footer,
}

--// MENU UPDATE
local function updateMenu()
	if not menuDirty then
		return
	end

	menuDirty = false

	for _, drawing in ipairs(menuDrawings) do
		drawing.Visible = menuVisible
	end

	if not menuVisible then
		return
	end

	local espY = PY + HEAD_H + 5
	espIndicator.Position = Vector2.new(PX + 16, espY + 5)
	espIndicator.Size = Vector2.new(16, 16)
	espIndicator.Corner = 4
	espIndicator.Filled = state.ESP
	espIndicator.Color = state.ESP and C.on or C.off
	espLabel.Position = Vector2.new(PX + 42, espY + 4)
	espLabel.Text = "ESP"
	espLabel.Color = state.ESP and C.text or C.sub

	local tracerY = PY + HEAD_H + ROW_H + 5
	tracerIndicator.Position = Vector2.new(PX + 16, tracerY + 5)
	tracerIndicator.Size = Vector2.new(16, 16)
	tracerIndicator.Corner = 4
	tracerIndicator.Filled = state.Tracers
	tracerIndicator.Color = state.Tracers and C.on or C.off
	tracerLabel.Position = Vector2.new(PX + 42, tracerY + 4)
	tracerLabel.Text = "Tracers"
	tracerLabel.Color = state.Tracers and C.text or C.sub

	local sliderY = PY + HEAD_H + (ROW_H * 2) + 3
	local barX = PX + 16
	local barY = sliderY + 19
	local barW = PW - 32
	local distancePercentage =
		(state.ESPDistance - MIN_ESP_DISTANCE) /
		(MAX_ESP_DISTANCE - MIN_ESP_DISTANCE)

	distanceLabel.Position = Vector2.new(PX + 16, sliderY)
	distanceLabel.Text = "ESP Distance  " .. state.ESPDistance
	distanceBar.Position = Vector2.new(barX, barY)
	distanceBar.Size = Vector2.new(barW, 5)
	distanceFill.Position = Vector2.new(barX, barY)
	distanceFill.Size = Vector2.new(barW * distancePercentage, 5)
	distanceKnob.Position = Vector2.new(barX + (barW * distancePercentage) - 4, barY - 3)
	distanceKnob.Size = Vector2.new(8, 11)

	local transparencyY = sliderY + SLIDER_H
	local transparencyBarY = transparencyY + 19
	local transparencyPercentage = state.TracerTransparency / 100

	transparencyLabel.Position = Vector2.new(PX + 16, transparencyY)
	transparencyLabel.Text = "Tracer Transparency  " .. state.TracerTransparency .. "%"
	transparencyBar.Position = Vector2.new(barX, transparencyBarY)
	transparencyBar.Size = Vector2.new(barW, 5)
	transparencyFill.Position = Vector2.new(barX, transparencyBarY)
	transparencyFill.Size = Vector2.new(barW * transparencyPercentage, 5)
	transparencyKnob.Position = Vector2.new(
		barX + (barW * transparencyPercentage) - 4,
		transparencyBarY - 3
	)
	transparencyKnob.Size = Vector2.new(8, 11)
	footer.Position = Vector2.new(PX + 16, PY + PH - FOOT_H + 3)
end

--// PLAYER CACHE
local playersCache = {}
local characterCache = {}
local drawingsByPlayer = {}

local function addPlayer(player)
	if player == LocalPlayer or characterCache[player] then
		return
	end

	playersCache[#playersCache + 1] = player
	characterCache[player] = {
		Character = nil,
		Root = nil,
	}
end

local function removeDrawing(drawing)
	if drawing then
		pcall(function()
			drawing.Visible = false
			drawing:Remove()
		end)
	end
end

local function removePlayer(player)
	for index, cachedPlayer in ipairs(playersCache) do
		if cachedPlayer == player then
			table.remove(playersCache, index)
			break
		end
	end

	characterCache[player] = nil

	local drawings = drawingsByPlayer[player]
	if drawings then
		removeDrawing(drawings.Box)
		removeDrawing(drawings.Tracer)
		drawingsByPlayer[player] = nil
	end
end

local function refreshCharacters()
	for _, player in ipairs(playersCache) do
		local data = characterCache[player]
		local character = data and player.Character

		if data and data.Character ~= character then
			data.Character = character
			data.Root = character and character:FindFirstChild("HumanoidRootPart") or nil
		elseif data and character and (not data.Root or data.Root.Parent ~= character) then
			data.Root = character:FindFirstChild("HumanoidRootPart")
		end
	end
end

local function reconcilePlayers()
	local activePlayers = {}

	for _, player in ipairs(Players:GetPlayers()) do
		activePlayers[player] = true
		addPlayer(player)
	end

	for index = #playersCache, 1, -1 do
		local player = playersCache[index]
		if not activePlayers[player] then
			removePlayer(player)
		end
	end
end

-- Matcha does not consistently expose PlayerAdded/PlayerRemoving. Polling once
-- per second also guarantees departed players and their Drawing objects are
-- reconciled even when an event is missed.
reconcilePlayers()
refreshCharacters()

--// LAZY DRAWINGS
local function getPlayerDrawings(player)
	local drawings = drawingsByPlayer[player]
	if not drawings then
		drawings = {}
		drawingsByPlayer[player] = drawings
	end
	return drawings
end

local function getEspBox(drawings)
	if not drawings.Box then
		local box = Drawing.new("Square")
		box.Filled = false
		box.Thickness = 2
		box.Color = C.box
		box.Transparency = 1
		box.Visible = false
		box.ZIndex = 2
		drawings.Box = box
	end
	return drawings.Box
end

local function getTracer(drawings)
	if not drawings.Tracer then
		local line = Drawing.new("Line")
		line.Thickness = 2
		line.Color = C.line
		line.Transparency = 1
		line.Visible = false
		line.ZIndex = 1
		drawings.Tracer = line
	end
	return drawings.Tracer
end

local function hideAllVisuals()
	for _, drawings in pairs(drawingsByPlayer) do
		if drawings.Box then
			drawings.Box.Visible = false
		end
		if drawings.Tracer then
			drawings.Tracer.Visible = false
		end
	end
end

--// ESP + TRACERS
local function updateEspTracers()
	Camera = workspace.CurrentCamera or Camera
	if not Camera then
		hideAllVisuals()
		return
	end

	local viewport = Camera.ViewportSize
	local origin = Vector2.new(viewport.X * 0.5, viewport.Y)
	local camPos = Camera.CFrame.Position
	local maxDistanceSquared = getEspMaxDistanceSquared()
	local tracerTransparency = 1 - (state.TracerTransparency / 100)

	for _, player in ipairs(playersCache) do
		local drawings = drawingsByPlayer[player]
		local root = characterCache[player].Root
		local visible = false
		local screenPos
		local distanceSquared

		if root then
			local position = root.Position
			local dx = position.X - camPos.X
			local dy = position.Y - camPos.Y
			local dz = position.Z - camPos.Z
			distanceSquared = dx * dx + dy * dy + dz * dz

			if distanceSquared <= maxDistanceSquared then
				screenPos, visible = WorldToScreen(position)
				visible = visible
					and screenPos.X >= 0
					and screenPos.X <= viewport.X
					and screenPos.Y >= 0
					and screenPos.Y <= viewport.Y
			end
		end

		if state.ESP and visible then
			drawings = drawings or getPlayerDrawings(player)
			local box = getEspBox(drawings)
			local distance = math.sqrt(distanceSquared)
			local scale = math.clamp(1500 / math.max(distance, 0.001), 8, 400)
			local size = Vector2.new(scale, scale * 1.5)

			box.Size = size
			box.Position = Vector2.new(screenPos.X - size.X * 0.5, screenPos.Y - size.Y * 0.5)
			box.Visible = true
		elseif drawings and drawings.Box then
			drawings.Box.Visible = false
		end

		if state.Tracers and visible then
			drawings = drawings or getPlayerDrawings(player)
			local line = getTracer(drawings)
			line.From = origin
			line.To = screenPos
			line.Transparency = tracerTransparency
			line.Visible = tracerTransparency > 0
		elseif drawings and drawings.Tracer then
			drawings.Tracer.Visible = false
		end
	end
end

--// INPUT
local mouse
pcall(function()
	mouse = LocalPlayer:GetMouse()
end)

local function handleMenuClick(mx, my)
	if not menuVisible then
		return
	end

	local espY = PY + HEAD_H + 5
	if mx >= PX and mx <= PX + PW and my >= espY and my <= espY + ROW_H then
		state.ESP = not state.ESP
		setDirty()
		return
	end

	local tracerY = PY + HEAD_H + ROW_H + 5
	if mx >= PX and mx <= PX + PW and my >= tracerY and my <= tracerY + ROW_H then
		state.Tracers = not state.Tracers
		setDirty()
		return
	end

	local sliderY = PY + HEAD_H + (ROW_H * 2) + 3
	local barX = PX + 16
	local barY = sliderY + 19
	local barW = PW - 32

	if mx >= barX and mx <= barX + barW and my >= barY - 3 and my <= barY + 10 then
		local percentage = math.clamp((mx - barX) / barW, 0, 1)
		state.ESPDistance = math.floor(
			MIN_ESP_DISTANCE +
			(percentage * (MAX_ESP_DISTANCE - MIN_ESP_DISTANCE)) +
			0.5
		)
		_G.ESPMaxDistance = state.ESPDistance
		_G.ESPMaxDistanceSquared = state.ESPDistance * state.ESPDistance
		setDirty()
		return
	end

	local transparencyBarY = barY + SLIDER_H
	if mx >= barX
		and mx <= barX + barW
		and my >= transparencyBarY - 3
		and my <= transparencyBarY + 10 then

		state.TracerTransparency = math.floor(
			math.clamp((mx - barX) / barW, 0, 1) * 100
		)
		setDirty()
	end
end

UserInputService.InputBegan:Connect(function(input)
	local keyCode = input.KeyCode

	if keyCode == Enum.KeyCode.M then
		menuVisible = not menuVisible
		setDirty()
	elseif keyCode == Enum.KeyCode.One then
		state.ESP = not state.ESP
		setDirty()
	elseif keyCode == Enum.KeyCode.Two then
		state.Tracers = not state.Tracers
		setDirty()
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 and mouse then
		handleMenuClick(mouse.X, mouse.Y)
	end
end)

--// MAIN LOOP
local visualTimer = UPDATE_INTERVAL
local characterTimer = CHARACTER_REFRESH_INTERVAL
local visualsWereActive = false
local lastVisualErrorAt = -1000000

local function updateVisualFrame(deltaTime)
	updateMenu()

	local visualsActive = state.ESP or state.Tracers
	if not visualsActive then
		if visualsWereActive then
			hideAllVisuals()
		end
		visualsWereActive = false
		return
	end

	if not visualsWereActive then
		reconcilePlayers()
		refreshCharacters()
		characterTimer = 0
	end

	visualsWereActive = true
	characterTimer += deltaTime
	visualTimer += deltaTime

	if characterTimer >= CHARACTER_REFRESH_INTERVAL then
		characterTimer = 0
		reconcilePlayers()
		refreshCharacters()
	end

	if visualTimer < UPDATE_INTERVAL then
		return
	end

	visualTimer = 0
	updateEspTracers()
end

RunService.RenderStepped:Connect(function(deltaTime)
	local ok, err = pcall(updateVisualFrame, deltaTime)
	if ok then
		return
	end

	-- A transient destroyed-instance error must not kill the render connection
	-- and leave the last successful ESP frame frozen on screen.
	hideAllVisuals()

	local now = os.clock()
	if now - lastVisualErrorAt >= 5 then
		lastVisualErrorAt = now
		warn("[ESP] Recovered from: " .. tostring(err))
	end
end)

updateMenu()
print("Optimized visuals loaded | 1 ESP | 2 Tracers | M Menu")
