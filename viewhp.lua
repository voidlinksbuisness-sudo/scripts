local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Visuals are capped independently of render FPS to reduce projection and Drawing work.
-- Set _G.HealthESPUpdateRate before loading to override the 30 Hz default.
local UPDATE_RATE = math.max(1, tonumber(_G.HealthESPUpdateRate) or 30)
local UPDATE_INTERVAL = 1 / UPDATE_RATE
local CHARACTER_REFRESH_INTERVAL = 1
local DEFAULT_MAX_DISTANCE_SQUARED = 50 * 50
local HEAD_OFFSET = Vector3.new(0, 3, 0)

local function getMaxDistanceSquared()
	return tonumber(_G.HealthESPMaxDistanceSquared) or DEFAULT_MAX_DISTANCE_SQUARED
end

--// DRAWINGS
local function makeText()
	local text = Drawing.new("Text")
	text.Size = 20
	text.Outline = true
	text.Font = Drawing.Fonts.Fortnite
	text.ZIndex = 20
	text.Transparency = 1
	text.Color = Color3.new(0, 1, 0)
	text.Visible = false
	text.Center = true
	return text
end

local myHealthText = makeText()

--// PLAYER CACHE
local playersCache = {}
local playerData = {}

local function addPlayer(player)
	if player == LocalPlayer or playerData[player] then
		return
	end

	playersCache[#playersCache + 1] = player
	playerData[player] = {
		Character = nil,
		Humanoid = nil,
		Root = nil,
		LastHealth = nil,
		Text = nil,
	}
end

local function removePlayer(player)
	for index, cachedPlayer in ipairs(playersCache) do
		if cachedPlayer == player then
			table.remove(playersCache, index)
			break
		end
	end

	local data = playerData[player]
	if data and data.Text then
		data.Text.Visible = false
		data.Text:Remove()
	end

	playerData[player] = nil
end

local function refreshCharacters()
	for _, player in ipairs(playersCache) do
		local data = playerData[player]
		local character = player.Character

		if data.Character ~= character then
			data.Character = character
			data.Humanoid = character and character:FindFirstChildOfClass("Humanoid") or nil
			data.Root = character and character:FindFirstChild("HumanoidRootPart") or nil
			data.LastHealth = nil
		elseif character then
			if not data.Humanoid or data.Humanoid.Parent ~= character then
				data.Humanoid = character:FindFirstChildOfClass("Humanoid")
				data.LastHealth = nil
			end

			if not data.Root or data.Root.Parent ~= character then
				data.Root = character:FindFirstChild("HumanoidRootPart")
			end
		end
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	addPlayer(player)
end

Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removePlayer)
refreshCharacters()

--// LOCAL PLAYER CACHE
local localCharacter
local localHumanoid
local localRoot
local localLastHealth

local function refreshLocalCharacter()
	local character = LocalPlayer.Character

	if character ~= localCharacter then
		localCharacter = character
		localHumanoid = character and character:FindFirstChildOfClass("Humanoid") or nil
		localRoot = character and character:FindFirstChild("HumanoidRootPart") or nil
		localLastHealth = nil
	elseif character then
		if not localHumanoid or localHumanoid.Parent ~= character then
			localHumanoid = character:FindFirstChildOfClass("Humanoid")
			localLastHealth = nil
		end

		if not localRoot or localRoot.Parent ~= character then
			localRoot = character:FindFirstChild("HumanoidRootPart")
		end
	end
end

refreshLocalCharacter()

local function hideOtherHealth()
	for _, data in pairs(playerData) do
		if data.Text and data.Text.Visible then
			data.Text.Visible = false
		end
	end
end

--// MAIN LOOP
local updateTimer = UPDATE_INTERVAL
local characterTimer = CHARACTER_REFRESH_INTERVAL
local lastViewport

RunService.RenderStepped:Connect(function(deltaTime)
	updateTimer += deltaTime
	characterTimer += deltaTime

	if characterTimer >= CHARACTER_REFRESH_INTERVAL then
		characterTimer = 0
		refreshLocalCharacter()
		refreshCharacters()
	end

	if updateTimer < UPDATE_INTERVAL then
		return
	end
	updateTimer = 0

	Camera = workspace.CurrentCamera or Camera
	if not Camera then
		myHealthText.Visible = false
		hideOtherHealth()
		return
	end

	local viewport = Camera.ViewportSize
	if viewport ~= lastViewport then
		lastViewport = viewport
		myHealthText.Position = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	end

	if localHumanoid and localHumanoid.Health > 0 then
		local health = math.floor(localHumanoid.Health)
		if localLastHealth ~= health then
			localLastHealth = health
			myHealthText.Text = "+ " .. health
		end
		myHealthText.Visible = true
	else
		myHealthText.Visible = false
	end

	if not localRoot then
		hideOtherHealth()
		return
	end

	local myPosition = localRoot.Position
	local maxDistanceSquared = getMaxDistanceSquared()

	for _, player in ipairs(playersCache) do
		local data = playerData[player]
		local humanoid = data.Humanoid
		local root = data.Root
		local visible = false

		if humanoid and root and humanoid.Health > 0 then
			local position = root.Position
			local dx = position.X - myPosition.X
			local dy = position.Y - myPosition.Y
			local dz = position.Z - myPosition.Z
			local distanceSquared = dx * dx + dy * dy + dz * dz

			if distanceSquared <= maxDistanceSquared then
				local screenPosition, onScreen = WorldToScreen(position + HEAD_OFFSET)
				visible = onScreen
					and screenPosition.X >= 0
					and screenPosition.X <= viewport.X
					and screenPosition.Y >= 0
					and screenPosition.Y <= viewport.Y

				if visible then
					local text = data.Text
					if not text then
						text = makeText()
						data.Text = text
					end

					text.Position = Vector2.new(screenPosition.X, screenPosition.Y)
					local health = math.floor(humanoid.Health)
					if data.LastHealth ~= health then
						data.LastHealth = health
						text.Text = "+ " .. health
					end
					text.Visible = true
				end
			end
		end

		if not visible and data.Text and data.Text.Visible then
			data.Text.Visible = false
		end
	end
end)

print("Optimized Health ESP loaded")
