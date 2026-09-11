--!strict
-- Client-side movement foundation: sprint input, stamina, exhaustion,
-- jump cooldown, stamina bar, crosshair / mouse mode, camera feedback and
-- body audio. Lives in PlayerScripts so
-- it survives respawn; per-character connections are rebuilt on each spawn.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local MovementConfig = require(Shared:WaitForChild("MovementConfig"))
local SprintState = Shared:WaitForChild("SprintState") :: RemoteEvent
local CameraEffects = require(script.Parent:WaitForChild("CameraEffects"))
local MovementAudio = require(script.Parent:WaitForChild("MovementAudio"))

local UIConfig = MovementConfig.UI

local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")
local movementGui = playerGui:WaitForChild("MovementGui") :: ScreenGui
local staminaTrack = movementGui:WaitForChild("StaminaBar") :: Frame
local staminaFill = staminaTrack:WaitForChild("Fill") :: Frame
local crosshair = movementGui:WaitForChild("Crosshair") :: Frame
CameraEffects.setVignette(movementGui:WaitForChild("FatigueVignette") :: Frame)

-- Character state
local humanoid: Humanoid? = nil
local characterConnections: { RBXScriptConnection } = {}
local jumpToken = 0

-- Movement state
local stamina = MovementConfig.MaxStamina
local sprintHeld = false
local sprinting = false
local exhausted = false
local lastSprintTime = -math.huge
local mouseReleased = false -- true while the cursor is free (M)

-- UI state
local displayedStamina = MovementConfig.MaxStamina
local barVisibility = 0
local exhaustedTint = 0
local fullSince: number? = nil

local function approach(current: number, target: number, speed: number, dt: number): number
	return current + (target - current) * (1 - math.exp(-speed * dt))
end

local function setSprinting(value: boolean)
	if sprinting == value then
		return
	end
	sprinting = value
	if humanoid then
		humanoid.WalkSpeed = if sprinting then MovementConfig.SprintSpeed else MovementConfig.WalkSpeed
	end
	SprintState:FireServer(sprinting)
end

local function humanoidAllowsSprint(currentHumanoid: Humanoid): boolean
	if currentHumanoid.Health <= 0 then
		return false
	end
	local state = currentHumanoid:GetState()
	return state ~= Enum.HumanoidStateType.Seated
		and state ~= Enum.HumanoidStateType.PlatformStanding
		and state ~= Enum.HumanoidStateType.Physics
		and state ~= Enum.HumanoidStateType.Dead
end

local function updateStamina(dt: number, now: number, currentHumanoid: Humanoid?)
	local moving = currentHumanoid ~= nil and currentHumanoid.MoveDirection.Magnitude > 0
	local wantSprint = sprintHeld
		and moving
		and not exhausted
		and stamina > 0
		and currentHumanoid ~= nil
		and humanoidAllowsSprint(currentHumanoid)

	if wantSprint then
		stamina = math.max(0, stamina - MovementConfig.SprintDrainPerSecond * dt)
		lastSprintTime = now
		if stamina <= 0 then
			exhausted = true
			wantSprint = false
		end
	elseif now - lastSprintTime >= MovementConfig.RegenDelay then
		stamina = math.min(MovementConfig.MaxStamina, stamina + MovementConfig.StaminaRegenPerSecond * dt)
	end

	if exhausted and stamina >= MovementConfig.ExhaustionThreshold then
		exhausted = false
	end

	setSprinting(wantSprint)
end

local function updateUI(dt: number, now: number)
	displayedStamina = approach(displayedStamina, stamina, UIConfig.FillSmoothSpeed, dt)
	staminaFill.Size = UDim2.fromScale(displayedStamina / MovementConfig.MaxStamina, 1)

	local visibilityTarget = 1
	if stamina < MovementConfig.MaxStamina or sprinting then
		fullSince = nil
	else
		if not fullSince then
			fullSince = now
		end
		if now - (fullSince :: number) >= UIConfig.HideDelay then
			visibilityTarget = 0
		end
	end
	barVisibility = approach(barVisibility, visibilityTarget, UIConfig.FadeSpeed, dt)
	exhaustedTint = approach(exhaustedTint, if exhausted then 1 else 0, UIConfig.FadeSpeed, dt)

	staminaTrack.BackgroundTransparency = 1 - (1 - UIConfig.TrackTransparency) * barVisibility
	staminaFill.BackgroundTransparency = 1 - (1 - UIConfig.FillTransparency) * barVisibility
	staminaFill.BackgroundColor3 = UIConfig.FillColor:Lerp(UIConfig.ExhaustedFillColor, exhaustedTint)
end

local function onRenderStep(dt: number)
	local now = os.clock()
	local currentHumanoid = humanoid

	updateStamina(dt, now, currentHumanoid)
	updateUI(dt, now)

	local moving = currentHumanoid ~= nil and currentHumanoid.MoveDirection.Magnitude > 0
	local body = MovementAudio.update(dt, stamina / MovementConfig.MaxStamina, exhausted, sprinting, moving)
	CameraEffects.setState({
		moving = moving,
		sprinting = sprinting,
		exhausted = exhausted,
		fatigue = body.breathing,
		heartbeat = body.heartbeat,
		heartPhase = body.heartPhase,
	})
end

-- Jump cooldown: block a new jump for a short window after landing so the
-- player cannot bunny hop.
local function onHumanoidStateChanged(currentHumanoid: Humanoid, newState: Enum.HumanoidStateType)
	if newState ~= Enum.HumanoidStateType.Landed then
		return
	end
	CameraEffects.onLanded()
	jumpToken += 1
	local token = jumpToken
	currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	task.delay(MovementConfig.JumpCooldown, function()
		if token == jumpToken and currentHumanoid == humanoid then
			currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end
	end)
end

local function clearCharacter()
	for _, connection in ipairs(characterConnections) do
		connection:Disconnect()
	end
	table.clear(characterConnections)
	sprinting = false
	humanoid = nil
	CameraEffects.setHumanoid(nil)
end

local function onCharacterAdded(character: Model)
	clearCharacter()

	local newHumanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	if not newHumanoid or player.Character ~= character then
		return
	end

	humanoid = newHumanoid
	newHumanoid.WalkSpeed = MovementConfig.WalkSpeed

	-- Fresh body, fresh lungs.
	stamina = MovementConfig.MaxStamina
	displayedStamina = MovementConfig.MaxStamina
	exhausted = false
	lastSprintTime = -math.huge
	fullSince = nil

	workspace.CurrentCamera.FieldOfView = MovementConfig.NormalFOV
	CameraEffects.setHumanoid(newHumanoid)
	MovementAudio.reset()

	table.insert(characterConnections, newHumanoid.StateChanged:Connect(function(_, newState)
		onHumanoidStateChanged(newHumanoid, newState)
	end))
	table.insert(characterConnections, newHumanoid.Died:Connect(clearCharacter))
end

-- Mouse mode. The native first-person camera re-locks the cursor every
-- frame, so while released we override it right after the camera step;
-- with the cursor free the mouse reports no delta and the view stays still.
local function setMouseReleased(released: boolean)
	mouseReleased = released
	crosshair.Visible = not released
	UserInputService.MouseIconEnabled = released
end

local function enforceMouseMode()
	if mouseReleased then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
	if UserInputService.MouseIconEnabled ~= mouseReleased then
		UserInputService.MouseIconEnabled = mouseReleased
	end
end

local function onToggleMouseAction(_: string, inputState: Enum.UserInputState): Enum.ContextActionResult
	if inputState == Enum.UserInputState.Begin then
		setMouseReleased(not mouseReleased)
	end
	return Enum.ContextActionResult.Sink
end

local function onSprintAction(_: string, inputState: Enum.UserInputState): Enum.ContextActionResult
	if inputState == Enum.UserInputState.Begin then
		sprintHeld = true
	elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
		sprintHeld = false
	end
	return Enum.ContextActionResult.Pass
end

ContextActionService:BindAction("Sprint", onSprintAction, false, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift)
ContextActionService:BindAction("ToggleMouse", onToggleMouseAction, false, MovementConfig.ToggleMouseKey)
setMouseReleased(false)

player.CharacterAdded:Connect(onCharacterAdded)
player.CharacterRemoving:Connect(clearCharacter)
if player.Character then
	onCharacterAdded(player.Character)
end

RunService.RenderStepped:Connect(onRenderStep)
RunService:BindToRenderStep("MovementMouseMode", Enum.RenderPriority.Camera.Value + 2, enforceMouseMode)
