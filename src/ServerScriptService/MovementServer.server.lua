--!strict
-- Applies base movement values to every character and mirrors the client's
-- sprint state onto the server-side Humanoid. The client can only ask for
-- "sprinting" or "not sprinting"; the actual speeds come from MovementConfig.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local MovementConfig = require(Shared:WaitForChild("MovementConfig"))
local SprintState = Shared:WaitForChild("SprintState") :: RemoteEvent

local function getHumanoid(player: Player): Humanoid?
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChildOfClass("Humanoid")
end

local function setupCharacter(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	if not humanoid then
		return
	end

	if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		warn("[MovementServer] Expected R6 rig, got " .. tostring(humanoid.RigType) .. ". Set Game Settings > Avatar > Avatar Type to R6.")
	end

	humanoid.WalkSpeed = MovementConfig.WalkSpeed
	humanoid.UseJumpPower = true
	humanoid.JumpPower = MovementConfig.JumpPower
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(setupCharacter)
	if player.Character then
		setupCharacter(player.Character)
	end
end

SprintState.OnServerEvent:Connect(function(player: Player, sprinting: unknown)
	if typeof(sprinting) ~= "boolean" then
		return
	end
	local humanoid = getHumanoid(player)
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	humanoid.WalkSpeed = if sprinting then MovementConfig.SprintSpeed else MovementConfig.WalkSpeed
end)

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
