--!strict
-- Trigger zones (Gameplay.Interactions.Triggers): invisible parts with an
-- "EventId" attribute. The server only owns state: crossing MazeEntry flips
-- Player.InMaze (the true boundary every local system reacts to), moves the
-- respawn inside the maze and pre-assigns a voice line so a party of four
-- does not share the same thought. Sound, subtitle and visuals are local.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local VoiceConfig = require(Shared:WaitForChild("VoiceConfig"))
local Triggers = workspace:WaitForChild("TheThirdLight"):WaitForChild("Gameplay"):WaitForChild("Interactions"):WaitForChild("Triggers")
local Spawns = workspace:WaitForChild("TheThirdLight"):WaitForChild("Gameplay"):WaitForChild("SpawnPoints")
local campSpawn = Spawns:WaitForChild("CampSpawn") :: SpawnLocation
local mazeRespawn = Spawns:WaitForChild("MazeRespawn") :: SpawnLocation

-- Voice line balancing: the least-used line of the pool among players
-- currently in this round (ties broken at random).
local function assignVoiceLine(player: Player, eventId: string)
	local event = VoiceConfig.Events[eventId]
	if not event or #event.Lines == 0 then
		return
	end
	local attribute = "VoiceLine_" .. eventId
	local used: { [number]: number } = {}
	for _, other in ipairs(Players:GetPlayers()) do
		local index = other:GetAttribute(attribute)
		if other ~= player and typeof(index) == "number" then
			used[index] = (used[index] or 0) + 1
		end
	end
	local best, bestCount = {}, math.huge
	for index = 1, #event.Lines do
		local count = used[index] or 0
		if count < bestCount then
			best, bestCount = { index }, count
		elseif count == bestCount then
			table.insert(best, index)
		end
	end
	player:SetAttribute(attribute, best[math.random(1, #best)])
end

local function onTouched(zone: BasePart, hit: BasePart)
	local eventId = zone:GetAttribute("EventId")
	if typeof(eventId) ~= "string" then
		return
	end
	local character = hit:FindFirstAncestorOfClass("Model")
	local player = character and Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	if eventId == "MazeEntry" and player:GetAttribute("InMaze") ~= true then
		assignVoiceLine(player, eventId)
		player.RespawnLocation = mazeRespawn
		player:SetAttribute("InMaze", true)
	end
end

local function hook(zone: Instance)
	if zone:IsA("BasePart") then
		zone.Touched:Connect(function(hit)
			onTouched(zone, hit)
		end)
	end
end

for _, zone in ipairs(Triggers:GetChildren()) do
	hook(zone)
end
Triggers.ChildAdded:Connect(hook)

local function onPlayerAdded(player: Player)
	player:SetAttribute("RoundId", 1) -- the future round system increments this; clients clear their once-per-round flags
	player:SetAttribute("AmbientState", "Normal") -- Director hook (AmbienceConfig.States)
	player:SetAttribute("InMaze", false)
	player.RespawnLocation = campSpawn
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
