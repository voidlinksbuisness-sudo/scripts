local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// CONFIG
local MAX_DISTANCE = 50
local MAX_DISTANCE_SQUARED = MAX_DISTANCE * MAX_DISTANCE

-- How often to refresh Players:GetPlayers()
local PLAYER_REFRESH_INTERVAL = 5

-- How often to refresh Character/Humanoid/Root references
local CHARACTER_REFRESH_INTERVAL = 1

--// DRAWING POOL
local healthTexts = {}

local myHealthText = Drawing.new("Text")
myHealthText.Size = 20
myHealthText.Outline = true
myHealthText.Font = Drawing.Fonts.Fortnite
myHealthText.ZIndex = 20
myHealthText.Transparency = 1
myHealthText.Color = Color3.new(0, 1, 0)
myHealthText.Visible = true
myHealthText.Center = true

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

local function getText(index)
	local text = healthTexts[index]

	if not text then
		text = makeText()
		healthTexts[index] = text
	end

	return text
end

--// PLAYER CACHE
local playersCache = {}
local characterCache = {}

local function refreshPlayers()
	playersCache = Players:GetPlayers()

	-- Remove cache entries for players that no longer exist.
	local activePlayers = {}

	for _, player in ipairs(playersCache) do
		activePlayers[player] = true
	end

	for player in pairs(characterCache) do
		if not activePlayers[player] then
			characterCache[player] = nil
		end
	end
end

local function refreshCharacters()
	for _, player in ipairs(playersCache) do
		if player ~= LocalPlayer then
			local character = player.Character
			local data = characterCache[player]

			if character then
				-- Character changed or wasn't cached.
				if not data or data.Character ~= character then
					characterCache[player] = {
						Character = character,
						Humanoid = character:FindFirstChildOfClass("Humanoid"),
						Root = character:FindFirstChild("HumanoidRootPart"),
						LastHealth = nil
					}
				else
					-- Only repair missing references.
					if not data.Humanoid
						or data.Humanoid.Parent ~= character then

						data.Humanoid =
							character:FindFirstChildOfClass("Humanoid")
					end

					if not data.Root
						or data.Root.Parent ~= character then

						data.Root =
							character:FindFirstChild("HumanoidRootPart")
					end
				end
			else
				characterCache[player] = nil
			end
		end
	end
end

-- Initial cache.
refreshPlayers()
refreshCharacters()

--// LOCAL PLAYER CACHE
local localCharacter = nil
local localHumanoid = nil
local localRoot = nil
local localLastHealth = nil

local function refreshLocalCharacter()
	local character = LocalPlayer.Character

	if character ~= localCharacter then
		localCharacter = character
		localLastHealth = nil

		if character then
			localHumanoid =
				character:FindFirstChildOfClass("Humanoid")

			localRoot =
				character:FindFirstChild("HumanoidRootPart")
		else
			localHumanoid = nil
			localRoot = nil
		end
	else
		if character then
			if not localHumanoid
				or localHumanoid.Parent ~= character then

				localHumanoid =
					character:FindFirstChildOfClass("Humanoid")
			end

			if not localRoot
				or localRoot.Parent ~= character then

				localRoot =
					character:FindFirstChild("HumanoidRootPart")
			end
		end
	end
end

refreshLocalCharacter()

--// TIMERS
local playerRefreshTimer = 0
local characterRefreshTimer = 0

-- Reused offset instead of constructing it every frame.
local HEAD_OFFSET = Vector3.new(0, 3, 0)

--// HELPERS
local function hideHealthTexts(startIndex)
	for i = startIndex, #healthTexts do
		if healthTexts[i].Visible then
			healthTexts[i].Visible = false
		end
	end
end

--// MAIN LOOP
RunService.RenderStepped:Connect(function(deltaTime)

	--==================================================
	-- CACHE REFRESH
	--==================================================

	playerRefreshTimer += deltaTime
	characterRefreshTimer += deltaTime

	if playerRefreshTimer >= PLAYER_REFRESH_INTERVAL then
		playerRefreshTimer = 0
		refreshPlayers()
	end

	if characterRefreshTimer >= CHARACTER_REFRESH_INTERVAL then
		characterRefreshTimer = 0
		refreshLocalCharacter()
		refreshCharacters()
	end

	--==================================================
	-- CAMERA / VIEWPORT
	--==================================================

	local viewport = Camera.ViewportSize

	--==================================================
	-- MY HEALTH
	--==================================================

	if localHumanoid and localHumanoid.Health > 0 then
		local health = math.floor(localHumanoid.Health)

		-- Only change the Drawing text when HP changes.
		if localLastHealth ~= health then
			localLastHealth = health
			myHealthText.Text = "+ " .. health
		end

		local centerX = viewport.X * 0.5
		local centerY = viewport.Y * 0.5

		myHealthText.Position = Vector2.new(centerX, centerY)

		if not myHealthText.Visible then
			myHealthText.Visible = true
		end
	else
		if myHealthText.Visible then
			myHealthText.Visible = false
		end
	end

	--==================================================
	-- LOCAL ROOT CHECK
	--==================================================

	if not localRoot then
		hideHealthTexts(1)
		return
	end

	local myPosition = localRoot.Position
	local count = 0

	--==================================================
	-- OTHER PLAYERS
	--==================================================

	for _, player in ipairs(playersCache) do
		if player ~= LocalPlayer then

			count += 1

			local text = getText(count)
			local data = characterCache[player]

			local visible = false

			if data then
				local humanoid = data.Humanoid
				local root = data.Root

				if humanoid
					and root
					and humanoid.Health > 0 then

					local position = root.Position

					-- Squared distance check.
					local dx = position.X - myPosition.X
					local dy = position.Y - myPosition.Y
					local dz = position.Z - myPosition.Z

					local distanceSquared =
						dx * dx +
						dy * dy +
						dz * dz

					-- Don't project players outside ESP range.
					if distanceSquared <= MAX_DISTANCE_SQUARED then

						local screenPosition, onScreen =
							WorldToScreen(position + HEAD_OFFSET)

						if onScreen
							and screenPosition.X >= 0
							and screenPosition.X <= viewport.X
							and screenPosition.Y >= 0
							and screenPosition.Y <= viewport.Y then

							text.Position = Vector2.new(
								screenPosition.X,
								screenPosition.Y
							)

							local health =
								math.floor(humanoid.Health)

							-- Only change text when HP changed.
							if data.LastHealth ~= health then
								data.LastHealth = health
								text.Text = "+ " .. health
							end

							visible = true
						end
					end
				end
			end

			if text.Visible ~= visible then
				text.Visible = visible
			end
		end
	end

	--==================================================
	-- HIDE UNUSED DRAWINGS
	--==================================================

	hideHealthTexts(count + 1)
end)

print("Optimized Health ESP loaded")
