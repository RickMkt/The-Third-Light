--!strict
-- Trigger zones (Gameplay.Interactions.Triggers): invisible parts with a
-- "LineId" attribute. When a player's character enters one, the matching
-- dialogue line is sent to that player. Lines marked Once fire one time per
-- player per round.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local DialogueConfig = require(Shared:WaitForChild("DialogueConfig"))
local ShowLine = Shared:WaitForChild("DialogueRemotes"):WaitForChild("ShowLine") :: RemoteEvent
local Triggers = workspace:WaitForChild("TheThirdLight"):WaitForChild("Gameplay"):WaitForChild("Interactions"):WaitForChild("Triggers")
local Spawns = workspace:WaitForChild("TheThirdLight"):WaitForChild("Gameplay"):WaitForChild("SpawnPoints")
local campSpawn = Spawns:WaitForChild("CampSpawn") :: SpawnLocation
local mazeRespawn = Spawns:WaitForChild("MazeRespawn") :: SpawnLocation

local fired: { [Player]: { [string]: boolean } } = {}
local lastFire: { [Player]: { [string]: number } } = {}

local function resolveLineId(player: Player, triggerLineId: string): string
	if triggerLineId == "MazeEntrance" then
		-- Stable per player: a party hears different reactions without relying on join order.
		return string.format("MazeEntrance%d", (math.abs(player.UserId) % 4) + 1)
	end
	return triggerLineId
end

local function onTouched(zone: BasePart, hit: BasePart)
	local lineId = zone:GetAttribute("LineId")
	if typeof(lineId) ~= "string" then
		return
	end
	local character = hit:FindFirstAncestorOfClass("Model")
	local player = character and Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	local resolvedLineId = resolveLineId(player, lineId)
	local line = DialogueConfig[resolvedLineId]
	if not line then
		return
	end
	fired[player] = fired[player] or {}
	lastFire[player] = lastFire[player] or {}
	if line.Once and fired[player][lineId] then
		return
	end
	local now = os.clock()
	if now - (lastFire[player][lineId] or -math.huge) < 8 then
		return
	end
	fired[player][lineId] = true
	lastFire[player][lineId] = now
	if lineId == "MazeEntrance" then
		player:SetAttribute("InMaze", true)
		player.RespawnLocation = mazeRespawn
	end
	ShowLine:FireClient(player, resolvedLineId)
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

Players.PlayerRemoving:Connect(function(player)
	fired[player] = nil
	lastFire[player] = nil
end)

local function onPlayerAdded(player: Player)
	player:SetAttribute("InMaze", false)
	player.RespawnLocation = campSpawn
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
