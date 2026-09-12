--!strict
-- Crossfades the forest layers by sector and exposes one scalar hook for the
-- future Director to create controlled silence without replacing this mixer.

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
local accumulator = 0

local function areaForZ(z: number)
	if z > -126 then return Config.Areas.Camp end
	if z > -300 then return Config.Areas.Sector1 end
	if z > -460 then return Config.Areas.Sector2 end
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
	for name, group in groups do
		local desired = target[name] * (1 - silence)
		group.Volume += (desired - group.Volume) * alpha
	end
end)
