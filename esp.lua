local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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
local state = {
	ESP = false,
	Tracers = false,
	TracerTransparency = 0,
}

--// GUI SETTINGS
local PX, PY = 50, 120
local PW = 290

local HEAD_H = 42
local ROW_H = 34
local SLIDER_H = 45
local FOOT_H = 26

local PH = HEAD_H + (ROW_H * 2) + SLIDER_H + FOOT_H + 10

local menuVisible = true
local menuDirty = true

local function setDirty()
	menuDirty = true
end

--// DRAWING HELPERS
local function mkSquare(z)
	local s = Drawing.new("Square")
	s.ZIndex = z
	s.Transparency = 1
	s.Visible = false
	return s
end

local function mkText(sz, z)
	local t = Drawing.new("Text")
	t.Size = sz
	t.Outline = true
	t.ZIndex = z
	t.Transparency = 1
	t.Visible = false
	return t
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

--// ESP ROW
local espIndicator = mkSquare(10)
local espLabel = mkText(16, 12)

--// TRACER ROW
local tracerIndicator = mkSquare(10)
local tracerLabel = mkText(16, 12)

--// TRANSPARENCY SLIDER
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

--// FOOTER
local footer = mkText(12, 12)
footer.Color = C.sub
footer.Text = "1 ESP   |   2 Tracers   |   M Hide"

--// MENU UPDATE
local function updateMenu()
	if not menuDirty then
		return
	end

	menuDirty = false

	shadow.Visible = menuVisible
	panel.Visible = menuVisible
	border.Visible = menuVisible
	logo.Visible = menuVisible
	title.Visible = menuVisible
	divider.Visible = menuVisible
	footer.Visible = menuVisible

	espIndicator.Visible = menuVisible
	espLabel.Visible = menuVisible

	tracerIndicator.Visible = menuVisible
	tracerLabel.Visible = menuVisible

	transparencyLabel.Visible = menuVisible
	transparencyBar.Visible = menuVisible
	transparencyFill.Visible = menuVisible
	transparencyKnob.Visible = menuVisible

	if not menuVisible then
		return
	end

	--// ESP
	local espY = PY + HEAD_H + 5

	espIndicator.Position = Vector2.new(
		PX + 16,
		espY + 5
	)

	espIndicator.Size = Vector2.new(16, 16)
	espIndicator.Corner = 4
	espIndicator.Filled = state.ESP
	espIndicator.Color = state.ESP and C.on or C.off

	espLabel.Position = Vector2.new(
		PX + 42,
		espY + 4
	)

	espLabel.Text = "ESP"
	espLabel.Color = state.ESP and C.text or C.sub

	--// TRACERS
	local tracerY = PY + HEAD_H + ROW_H + 5

	tracerIndicator.Position = Vector2.new(
		PX + 16,
		tracerY + 5
	)

	tracerIndicator.Size = Vector2.new(16, 16)
	tracerIndicator.Corner = 4
	tracerIndicator.Filled = state.Tracers
	tracerIndicator.Color = state.Tracers and C.on or C.off

	tracerLabel.Position = Vector2.new(
		PX + 42,
		tracerY + 4
	)

	tracerLabel.Text = "Tracers"
	tracerLabel.Color = state.Tracers and C.text or C.sub

	--// TRANSPARENCY
	local sliderY = PY + HEAD_H + (ROW_H * 2) + 3

	transparencyLabel.Position = Vector2.new(
		PX + 16,
		sliderY
	)

	transparencyLabel.Text =
		"Tracer Transparency  " ..
		state.TracerTransparency ..
		"%"

	local barX = PX + 16
	local barY = sliderY + 19
	local barW = PW - 32
	local barH = 5

	transparencyBar.Position = Vector2.new(
		barX,
		barY
	)

	transparencyBar.Size = Vector2.new(
		barW,
		barH
	)

	-- 0% = full visible
	-- 100% = invisible
	local percentage = state.TracerTransparency / 100

	transparencyFill.Position = Vector2.new(
		barX,
		barY
	)

	transparencyFill.Size = Vector2.new(
		barW * percentage,
		barH
	)

	local knobX = barX + (barW * percentage)

	transparencyKnob.Position = Vector2.new(
		knobX - 4,
		barY - 3
	)

	transparencyKnob.Size = Vector2.new(
		8,
		11
	)

	--// FOOTER
	footer.Position = Vector2.new(
		PX + 16,
		PY + PH - FOOT_H + 3
	)
end

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

	local dx = pos.X - myPos.X
	local dy = pos.Y - myPos.Y
	local dz = pos.Z - myPos.Z

	if dx < 0 then
		dx = -dx
	end

	if dy < 0 then
		dy = -dy
	end

	if dz < 0 then
		dz = -dz
	end

	return dx < SELF_RADIUS
		and dy < SELF_RADIUS
		and dz < SELF_RADIUS
end

--// DRAWING POOLS
local espBoxes = {}
local tracerLines = {}

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

	local camPos = Camera.Position

	local count = #players

	for i, player in ipairs(players) do
		local box = getEspBox(i)
		local line = getTracer(i)

		local showBox = false
		local showLine = false

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

						-- 0 = solid
						-- 100 = invisible
						line.Transparency =
							1 - (state.TracerTransparency / 100)

						showLine = true
					end
				end
			end
		end

		box.Visible = showBox
		line.Visible = showLine
	end

	hidePoolFrom(
		espBoxes,
		count + 1
	)

	hidePoolFrom(
		tracerLines,
		count + 1
	)
end

--// MOUSE
local mouse

local clickEnabled = pcall(function()
	mouse = LocalPlayer:GetMouse()
end) and mouse ~= nil

if clickEnabled then
	clickEnabled = pcall(function()
		return ismouse1pressed()
	end)
end

local wasPressed = false

local function updateClicks()
	if not (clickEnabled and menuVisible) then
		return
	end

	local pressed = ismouse1pressed()

	if pressed and not wasPressed then
		local mx = mouse.X
		local my = mouse.Y

		--// ESP ROW
		local espY = PY + HEAD_H + 5

		if mx >= PX
			and mx <= PX + PW
			and my >= espY
			and my <= espY + ROW_H then

			state.ESP = not state.ESP
			setDirty()
		end

		--// TRACER ROW
		local tracerY = PY + HEAD_H + ROW_H + 5

		if mx >= PX
			and mx <= PX + PW
			and my >= tracerY
			and my <= tracerY + ROW_H then

			state.Tracers = not state.Tracers
			setDirty()
		end

		--// TRANSPARENCY SLIDER
		local sliderY =
			PY + HEAD_H + (ROW_H * 2) + 3

		local barX = PX + 16
		local barY = sliderY + 19
		local barW = PW - 32
		local barH = 10

		if mx >= barX
			and mx <= barX + barW
			and my >= barY - 3
			and my <= barY + barH then

			local percentage =
				(mx - barX) / barW

			percentage = math.clamp(
				percentage,
				0,
				1
			)

			state.TracerTransparency =
				math.floor(percentage * 100)

			setDirty()
		end
	end

	wasPressed = pressed
end

--// KEYBINDS
UserInputService.InputBegan:Connect(function(input)
	local kc = input.KeyCode

	-- M = hide/show menu
	if kc == Enum.KeyCode.M then
		menuVisible = not menuVisible
		setDirty()

		return
	end

	-- 1 = ESP
	if kc == Enum.KeyCode.One then
		state.ESP = not state.ESP
		setDirty()

		return
	end

	-- 2 = Tracers
	if kc == Enum.KeyCode.Two then
		state.Tracers = not state.Tracers
		setDirty()

		return
	end
end)

--// MAIN LOOP
RunService.RenderStepped:Connect(function()
	updateMenu()
	updateClicks()

	local players = Players:GetPlayers()

	updateEspTracers(players)
end)

print("Visuals loaded | 1 ESP | 2 Tracers | M Menu")