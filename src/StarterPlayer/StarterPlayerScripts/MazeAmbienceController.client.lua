--!strict
-- Crossfades the forest layers by sector, then by the ambient state the
-- server puts this player in (AmbienceConfig.States), plus one scalar hook
-- (ForestSilence) for controlled silence. One mixer, no extra tracks.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AmbienceConfig"))
local player = Players.LocalPlayer

local groups = {
	Wind = SoundService:WaitForChild(Config.Groups.Wind) :: SoundGroup,
	Canopy = SoundService:WaitForChild(Config.Groups.Canopy) :: SoundGroup,
	Bed = SoundService:WaitForChild(Config.Groups.Bed) :: SoundGroup,
	Spatial = SoundService:WaitForChild(Config.Groups.Spatial) :: SoundGroup,
}

local target = Config.Areas.Camp
local state = { Wind = 1, Canopy = 1, Bed = 1, Spatial = 1 } -- smoothed state multipliers
local accumulator = 0

local function currentState()
	local name = player:GetAttribute(Config.StateAttribute)
	return (typeof(name) == "string" and Config.States[name]) or Config.States.Normal
end

local function areaForZ(z: number)
	if z > -126 then return Config.Areas.Camp end
	if z > Config.Sector2StartZ then return Config.Areas.Sector1 end
	if z > Config.Sector3StartZ then return Config.Areas.Sector2 end
	return Config.Areas.Sector3
end

RunService.Heartbeat:Connect(function(dt)
	accumulator += dt
	if accumulator >= Config.UpdateInterval then
		accumulator %= Config.UpdateInterval
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			target = areaForZ(root.Position.Z)
		end
	end

	local silence = math.clamp(player:GetAttribute(Config.SilenceAttribute) or 0, 0, 1)
	local alpha = 1 - math.exp(-Config.FadeSpeed * dt)
	local stateAlpha = 1 - math.exp(-Config.StateFadeSpeed * dt)
	local wanted = currentState()
	for name, group in groups do
		state[name] += (wanted[name] - state[name]) * stateAlpha
		local desired = target[name] * state[name] * (1 - silence)
		group.Volume += (desired - group.Volume) * alpha
	end
end)
