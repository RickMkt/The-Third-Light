--!strict
-- Footsteps by surface material. Steps are timed by the camera bob (a foot
-- lands at the low point), played locally at once and relayed so other
-- players hear them positioned on this character.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local SoundConfig = require(Shared:WaitForChild("SoundConfig"))
local MovementConfig = require(Shared:WaitForChild("MovementConfig"))
local CameraEffects = require(script.Parent:WaitForChild("CameraEffects"))
local Library = Shared:WaitForChild("SoundLibrary"):WaitForChild("Footsteps")
local FootstepRemote = Shared:WaitForChild("SoundRemotes"):WaitForChild("Footstep") :: RemoteEvent

local Steps = SoundConfig.Footsteps
local player = Players.LocalPlayer
local rng = Random.new()

local humanoid: Humanoid? = nil
local rootPart: BasePart? = nil
local characterConnections: { RBXScriptConnection } = {}
local lastIndexByGroup: { [string]: number } = {}

-- Roblox's CoreScript still drops its stock character sounds into the root
-- part (plastic footsteps, jump, land...). They are local-only, so muting
-- them here removes them completely for this player.
local STOCK_SOUNDS = {
	Running = true, Jumping = true, Landing = true, FreeFalling = true, Climbing = true,
	Swimming = true, Splash = true, GettingUp = true, Died = true,
}

local function muteStockSound(sound: Instance)
	if not sound:IsA("Sound") or not STOCK_SOUNDS[sound.Name] then
		return
	end
	sound.Volume = 0
	table.insert(characterConnections, sound:GetPropertyChangedSignal("Volume"):Connect(function()
		if sound.Volume ~= 0 then
			sound.Volume = 0
		end
	end))
end

local function groupFor(material: Enum.Material): string
	return Steps.MaterialGroups[material] or Steps.DefaultGroup
end

-- Picks a variation, never the same one twice in a row.
local function pickVariation(groupName: string): (Sound?, number)
	local group = Library:FindFirstChild(groupName)
	if not group then
		return nil, 0
	end
	local sounds = group:GetChildren()
	if #sounds == 0 then
		return nil, 0
	end
	local index = rng:NextInteger(1, #sounds)
	if #sounds > 1 and index == lastIndexByGroup[groupName] then
		index = index % #sounds + 1
	end
	lastIndexByGroup[groupName] = index
	return sounds[index] :: Sound, index
end

local function playAt(part: BasePart, groupName: string, index: number, volume: number)
	local group = Library:FindFirstChild(groupName)
	local template = group and group:FindFirstChild(groupName .. index)
	if not template or not template:IsA("Sound") then
		return
	end
	local sound = template:Clone()
	sound.Volume = volume
	sound.PlaybackSpeed = 1 + rng:NextNumber(-Steps.PitchJitter, Steps.PitchJitter)
	sound.Parent = part
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	sound:Play()
end

local function step(volume: number)
	local currentHumanoid, currentRoot = humanoid, rootPart
	if not currentHumanoid or not currentRoot or currentHumanoid.Health <= 0 then
		return
	end
	if currentHumanoid.FloorMaterial == Enum.Material.Air then
		return
	end
	local groupName = groupFor(currentHumanoid.FloorMaterial)
	local _, index = pickVariation(groupName)
	if index == 0 then
		return
	end
	playAt(currentRoot, groupName, index, volume)
	FootstepRemote:FireServer(groupName, index, volume)
end

local function onStep(_foot: number)
	local currentHumanoid = humanoid
	if not currentHumanoid then
		return
	end
	local sprinting = currentHumanoid.WalkSpeed >= MovementConfig.SprintSpeed - 0.01
	step(if sprinting then Steps.SprintVolume else Steps.WalkVolume)
end

local function clearCharacter()
	for _, connection in ipairs(characterConnections) do
		connection:Disconnect()
	end
	table.clear(characterConnections)
	humanoid = nil
	rootPart = nil
end

local function onCharacterAdded(character: Model)
	clearCharacter()
	local newHumanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	local newRoot = character:WaitForChild("HumanoidRootPart", 10) :: BasePart?
	if not newHumanoid or not newRoot or player.Character ~= character then
		return
	end
	humanoid = newHumanoid
	rootPart = newRoot
	for _, child in ipairs(newRoot:GetChildren()) do
		muteStockSound(child)
	end
	table.insert(characterConnections, newRoot.ChildAdded:Connect(muteStockSound))
	table.insert(characterConnections, newHumanoid.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Landed then
			step(Steps.LandingVolume)
		end
	end))
	table.insert(characterConnections, newHumanoid.Died:Connect(clearCharacter))
end

-- Other players' steps, positioned on their character.
FootstepRemote.OnClientEvent:Connect(function(character: Model, groupName: string, index: number, volume: number)
	if character == player.Character then
		return
	end
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		playAt(root, groupName, index, volume)
	end
end)

CameraEffects.setStepCallback(onStep)
player.CharacterAdded:Connect(onCharacterAdded)
player.CharacterRemoving:Connect(clearCharacter)
if player.Character then
	onCharacterAdded(player.Character)
end
