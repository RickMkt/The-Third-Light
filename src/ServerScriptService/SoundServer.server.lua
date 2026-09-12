--!strict
-- Server side of the soundscape:
--  * relays footsteps to other clients (positioned on the walker)
--  * spawns random positional forest one-shots around players
--  * toggles light sources on carried tools

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local SoundConfig = require(Shared:WaitForChild("SoundConfig"))
local Library = Shared:WaitForChild("SoundLibrary")
local Remotes = Shared:WaitForChild("SoundRemotes")
local FootstepRemote = Remotes:WaitForChild("Footstep") :: RemoteEvent
local ToggleLight = Remotes:WaitForChild("ToggleLight") :: RemoteEvent
local Emitters = workspace:WaitForChild("TheThirdLight"):WaitForChild("Gameplay"):WaitForChild("SoundEmitters")

local Forest = SoundConfig.Forest
local canopyLoop = SoundService:FindFirstChild("CanopyRustle", true)
if canopyLoop and canopyLoop:IsA("Sound") then
	canopyLoop.Volume = Forest.CanopyLoopVolume
end
local rng = Random.new()
local SpatialGroup = SoundService:WaitForChild("MazeSpatial") :: SoundGroup

-- Footstep relay -----------------------------------------------------------

local lastFootstep: { [Player]: number } = {}

FootstepRemote.OnServerEvent:Connect(function(player: Player, groupName: unknown, index: unknown, volume: unknown)
	if typeof(groupName) ~= "string" or typeof(index) ~= "number" or typeof(volume) ~= "number" then
		return
	end
	local now = os.clock()
	if now - (lastFootstep[player] or 0) < 0.12 then
		return
	end
	lastFootstep[player] = now
	local character = player.Character
	if not character then
		return
	end
	FootstepRemote:FireAllClients(character, groupName, math.floor(index), math.clamp(volume, 0, 1))
end)

Players.PlayerRemoving:Connect(function(player)
	lastFootstep[player] = nil
end)

-- Forest one-shots ---------------------------------------------------------

local groundParams = RaycastParams.new()
groundParams.FilterType = Enum.RaycastFilterType.Include
groundParams.FilterDescendantsInstances = { workspace.Terrain }

local function pickGroup(): string
	local total = 0
	for _, weight in pairs(Forest.Weights) do
		total += weight
	end
	local roll = rng:NextNumber(0, total)
	for name, weight in pairs(Forest.Weights) do
		roll -= weight
		if roll <= 0 then
			return name
		end
	end
	return "BranchSnap"
end

local function emitAt(position: Vector3, groupName: string)
	local group = Library:FindFirstChild("Forest") and Library.Forest:FindFirstChild(groupName)
	if not group then
		return
	end
	local variations = group:GetChildren()
	if #variations == 0 then
		return
	end
	local template = variations[rng:NextInteger(1, #variations)] :: Sound

	local emitter = Instance.new("Part")
	emitter.Name = groupName
	emitter.Size = Vector3.new(0.5, 0.5, 0.5)
	emitter.Transparency = 1
	emitter.Anchored = true
	emitter.CanCollide = false
	emitter.CanQuery = false
	emitter.CanTouch = false
	emitter.Position = position
	emitter.Parent = Emitters

	local sound = template:Clone()
	sound.PlaybackSpeed = 1 + rng:NextNumber(-0.05, 0.05)
	sound.SoundGroup = SpatialGroup
	sound.Parent = emitter
	sound.Ended:Once(function()
		emitter:Destroy()
	end)
	sound:Play()
end

local function forestLoop()
	while true do
		task.wait(rng:NextNumber(Forest.MinInterval, Forest.MaxInterval))
		local players = Players:GetPlayers()
		if #players == 0 then
			continue
		end
		local target = players[rng:NextInteger(1, #players)]
		local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		if not root or not root:IsA("BasePart") then
			continue
		end

		local groupName = pickGroup()
		local angle = rng:NextNumber(0, math.pi * 2)
		local distance = rng:NextNumber(Forest.MinDistance, Forest.MaxDistance)
		local x = root.Position.X + math.cos(angle) * distance
		local z = root.Position.Z + math.sin(angle) * distance
		local hit = workspace:Raycast(Vector3.new(x, root.Position.Y + 60, z), Vector3.new(0, -140, 0), groundParams)
		local y = if hit then hit.Position.Y else root.Position.Y
		if groupName == "Owl" then
			y += Forest.OwlHeight
		else
			y += 1
		end
		emitAt(Vector3.new(x, y, z), groupName)
	end
end

task.spawn(forestLoop)

-- Carried lights -----------------------------------------------------------

ToggleLight.OnServerEvent:Connect(function(player: Player, tool: unknown)
	if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
		return
	end
	-- Only a tool the player is actually holding can be switched.
	if tool.Parent ~= player.Character then
		return
	end
	local lit = not tool:GetAttribute("Lit")
	tool:SetAttribute("Lit", lit)
	for _, descendant in ipairs(tool:GetDescendants()) do
		if descendant:IsA("Light") then
			descendant.Enabled = lit
		elseif descendant:IsA("BasePart") and descendant:GetAttribute("LitPart") then
			-- glowing element (wick, bulb) follows the light
			descendant.Material = if lit then Enum.Material.Neon else Enum.Material.SmoothPlastic
			descendant.Transparency = if lit then 0.2 else 0
			local color = descendant:GetAttribute(if lit then "LitColor" else "UnlitColor")
			if typeof(color) == "Color3" then
				descendant.Color = color
			end
		end
	end
	local click = tool:FindFirstChild("Click", true)
	if click and click:IsA("Sound") then
		click:Play()
	end
end)
