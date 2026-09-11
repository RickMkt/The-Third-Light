--!strict
-- For the local player, a lit flashlight's beam is driven from the camera
-- (with a touch of lag) instead of the swinging hand. The tool's own lights
-- stay on for everyone else and are hidden locally while we take over.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SoundConfig"))
local Flashlight = SoundConfig.Lights.Flashlight

local player = Players.LocalPlayer

-- Local-only carrier part living under the camera.
local carrier = Instance.new("Part")
carrier.Name = "FlashlightCarrier"
carrier.Size = Vector3.new(0.2, 0.2, 0.2)
carrier.Transparency = 1
carrier.Anchored = true
carrier.CanCollide = false
carrier.CanQuery = false
carrier.CanTouch = false
carrier.CastShadow = false

local function makeSpot(name: string, range: number, angle: number, brightness: number, shadows: boolean): SpotLight
	local light = Instance.new("SpotLight")
	light.Name = name
	light.Face = Enum.NormalId.Front
	light.Range = range
	light.Angle = angle
	light.Brightness = brightness
	light.Color = Flashlight.Color
	light.Shadows = shadows
	light.Enabled = false
	light.Parent = carrier
	return light
end
local spot = makeSpot("Spot", Flashlight.SpotRange, Flashlight.SpotAngle, Flashlight.SpotBrightness, true)
local spill = makeSpot("Spill", Flashlight.SpillRange, Flashlight.SpillAngle, Flashlight.SpillBrightness, false)

local activeTool: Tool? = nil
local toolConnections: { RBXScriptConnection } = {}
local characterConnections: { RBXScriptConnection } = {}
local beamCFrame: CFrame? = nil

local function setLocalBeam(enabled: boolean)
	spot.Enabled = enabled
	spill.Enabled = enabled
end

-- Hide the tool's replicated lights for us while our camera beam is on.
local function syncToolLights(tool: Tool, hidden: boolean)
	for _, descendant in ipairs(tool:GetDescendants()) do
		if descendant:IsA("Light") then
			descendant.Enabled = if hidden then false else (tool:GetAttribute("Lit") == true)
		end
	end
end

local function refresh()
	local tool = activeTool
	local lit = tool ~= nil and tool:GetAttribute("Lit") == true
	setLocalBeam(lit)
	if tool then
		syncToolLights(tool, lit)
	end
end

local function release()
	for _, connection in ipairs(toolConnections) do
		connection:Disconnect()
	end
	table.clear(toolConnections)
	if activeTool then
		syncToolLights(activeTool, false)
	end
	activeTool = nil
	beamCFrame = nil
	setLocalBeam(false)
end

local function adopt(tool: Tool)
	release()
	activeTool = tool
	table.insert(toolConnections, tool:GetAttributeChangedSignal("Lit"):Connect(refresh))
	-- The server re-replicates Enabled on every toggle; keep ours in charge.
	for _, descendant in ipairs(tool:GetDescendants()) do
		if descendant:IsA("Light") then
			table.insert(toolConnections, descendant:GetPropertyChangedSignal("Enabled"):Connect(function()
				if activeTool == tool and tool:GetAttribute("Lit") == true and descendant.Enabled then
					descendant.Enabled = false
				end
			end))
		end
	end
	refresh()
end

local function onToolChanged(character: Model)
	local tool = character:FindFirstChildOfClass("Tool")
	if tool and tool:GetAttribute("LightMode") == "Flashlight" then
		if tool ~= activeTool then
			adopt(tool)
		end
	else
		release()
	end
end

local function onCharacterAdded(character: Model)
	for _, connection in ipairs(characterConnections) do
		connection:Disconnect()
	end
	table.clear(characterConnections)
	release()
	table.insert(characterConnections, character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			onToolChanged(character)
		end
	end))
	table.insert(characterConnections, character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			onToolChanged(character)
		end
	end))
	onToolChanged(character)
end

-- In first person Roblox fades the whole character each frame; keep the held
-- tool and the arm holding it visible so the player sees what they carry.
local function keepToolVisible()
	local character = player.Character
	if not character then
		return
	end
	local tool = character:FindFirstChildOfClass("Tool")
	if not tool then
		return
	end
	for _, descendant in ipairs(tool:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Transparency < 1 then
			descendant.LocalTransparencyModifier = 0
		end
	end
	local arm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
	if arm and arm:IsA("BasePart") then
		arm.LocalTransparencyModifier = 0
	end
end

RunService:BindToRenderStep("FlashlightBeam", Enum.RenderPriority.Camera.Value + 3, function(dt)
	keepToolVisible()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	if carrier.Parent ~= camera then
		carrier.Parent = camera
	end
	if not spot.Enabled then
		beamCFrame = nil
		return
	end
	-- Beam origin sits a little low and to the right of the eye, aimed with the view.
	local target = camera.CFrame * CFrame.new(Flashlight.HandOffset)
	if beamCFrame then
		local alpha = 1 - math.exp(-Flashlight.FollowLag * dt)
		beamCFrame = beamCFrame:Lerp(target, alpha)
	else
		beamCFrame = target
	end
	carrier.CFrame = beamCFrame :: CFrame
end)

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
	onCharacterAdded(player.Character)
end
