--!strict
-- For the local player the flashlight is invisible in first person and its
-- beam is driven from the camera: the position follows the eye instantly, the
-- direction lags behind like a hand that takes a moment to catch up, with a
-- soft three-cone edge. The tool's own lights stay on for everyone else.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SoundConfig"))
local MovementConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MovementConfig"))
local Flashlight = SoundConfig.Lights.Flashlight

local player = Players.LocalPlayer

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
local cones = {
	makeSpot("Spot", Flashlight.SpotRange, Flashlight.SpotAngle, Flashlight.SpotBrightness, true),
	makeSpot("Mid", Flashlight.MidRange, Flashlight.MidAngle, Flashlight.MidBrightness, false),
	makeSpot("Spill", Flashlight.SpillRange, Flashlight.SpillAngle, Flashlight.SpillBrightness, false),
}

local activeTool: Tool? = nil
local toolConnections: { RBXScriptConnection } = {}
local characterConnections: { RBXScriptConnection } = {}
local beamRotation: CFrame? = nil
local swayTime = 0

local function setLocalBeam(enabled: boolean)
	for _, cone in ipairs(cones) do
		cone.Enabled = enabled
	end
end

-- The tool's replicated lights are for other players; hide them for us while lit.
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
	beamRotation = nil
	setLocalBeam(false)
end

local function adopt(tool: Tool)
	release()
	activeTool = tool
	table.insert(toolConnections, tool:GetAttributeChangedSignal("Lit"):Connect(refresh))
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

-- In first person the held tool stays hidden (the camera fades the body; we
-- make sure the tool goes with it).
local function hideHeldTool()
	local character = player.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	if not tool then
		return
	end
	for _, descendant in ipairs(tool:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.LocalTransparencyModifier = 1
		end
	end
end

RunService:BindToRenderStep("FlashlightBeam", Enum.RenderPriority.Camera.Value + 3, function(dt)
	hideHeldTool()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	if carrier.Parent ~= camera then
		carrier.Parent = camera
	end
	if not cones[1].Enabled then
		beamRotation = nil
		return
	end

	-- Position follows the eye; direction eases toward the view.
	local viewRotation = camera.CFrame.Rotation
	if beamRotation then
		local alpha = 1 - math.exp(-Flashlight.RotationLag * dt)
		beamRotation = beamRotation:Lerp(viewRotation, alpha)
	else
		beamRotation = viewRotation
	end

	-- Slow hand drift while moving (a lantern held by a person, not a turret).
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local moving = humanoid ~= nil and humanoid.MoveDirection.Magnitude > 0
	local sprinting = moving and humanoid ~= nil and humanoid.WalkSpeed >= MovementConfig.SprintSpeed - 0.5
	swayTime += dt * (if moving then 1 else 0.35)
	local swayMultiplier = if sprinting then Flashlight.SwaySprintMultiplier elseif moving then 1 else Flashlight.SwayIdleMultiplier
	local sway = math.rad(Flashlight.SwayAmount) * swayMultiplier
	local drift = CFrame.Angles(math.sin(swayTime * 1.7) * sway, math.sin(swayTime * 1.3 + 0.8) * sway, 0)

	local origin = (camera.CFrame * CFrame.new(Flashlight.HandOffset)).Position
	carrier.CFrame = CFrame.new(origin) * (beamRotation :: CFrame) * drift
end)

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
	onCharacterAdded(player.Character)
end
