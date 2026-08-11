local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// CONFIG
local MAX_DISTANCE = 50
local MAX_DISTANCE_SQUARED = MAX_DISTANCE * MAX_DISTANCE

--// DRAWING POOL
local healthTexts = {}

--// MY HEALTH TEXT
local myHealthText = Drawing.new("Text")
myHealthText.Size = 20
myHealthText.Outline = true
myHealthText.Font = Drawing.Fonts.Fortnite
myHealthText.ZIndex = 20
myHealthText.Transparency = 1
myHealthText.Color = Color3.new(0, 1, 0)
myHealthText.Visible = true
myHealthText.Center = true

local function makeText(size, zIndex)
	local text = Drawing.new("Text")

	text.Size = size
	text.Outline = true
	text.Font = Drawing.Fonts.Fortnite
	text.ZIndex = zIndex
	text.Transparency = 1
	text.Color = Color3.new(0, 1, 0)
	text.Visible = false
	text.Center = true

	return text
end

local function getText(index)
	local text = healthTexts[index]

	if not text then
		text = makeText(20, 20)
		healthTexts[index] = text
	end

	return text
end

--// CHARACTER CACHE
local cache = {}

local function getCharacterData(player)
	local character = player.Character

	if not character then
		return nil, nil
	end

	local data = cache[player]

	if not data or data.Character ~= character then
		data = {
			Character = character,
			Humanoid = character:FindFirstChildOfClass("Humanoid"),
			Root = character:FindFirstChild("HumanoidRootPart"),
		}

		cache[player] = data
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

--// MAIN LOOP
RunService.RenderStepped:Connect(function()
	local viewport = Camera.ViewportSize

	--==================================================
	-- MY HEALTH
	--==================================================

	local myCharacter = LocalPlayer.Character
	local myHumanoid = myCharacter
		and myCharacter:FindFirstChildOfClass("Humanoid")

	if myHumanoid and myHumanoid.Health > 0 then
		myHealthText.Text = "+ " .. math.floor(myHumanoid.Health)

		myHealthText.Position = Vector2.new(
			viewport.X / 2,
			viewport.Y / 2
		)

		myHealthText.Visible = true
	else
		myHealthText.Visible = false
	end

	--==================================================
	-- OTHER PLAYERS
	--==================================================

	if not myCharacter then
		for i = 1, #healthTexts do
			healthTexts[i].Visible = false
		end

		return
	end

	local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")

	if not myRoot then
		for i = 1, #healthTexts do
			healthTexts[i].Visible = false
		end

		return
	end

	local myPosition = myRoot.Position
	local players = Players:GetPlayers()
	local count = 0

	for _, player in ipairs(players) do
		if player ~= LocalPlayer then
			count += 1

			local text = getText(count)
			local humanoid, root = getCharacterData(player)

			local visible = false

			if humanoid and root and humanoid.Health > 0 then
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

						text.Text = "+ " .. math.floor(humanoid.Health)

						visible = true
					end
				end
			end

			text.Visible = visible
		end
	end

	-- Hide unused Drawing objects
	for i = count + 1, #healthTexts do
		healthTexts[i].Visible = false
	end
end)

print("Health ESP loaded")