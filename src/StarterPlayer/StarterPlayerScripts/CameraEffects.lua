--!strict
-- Purely visual camera feedback for movement: dynamic FOV, positional head
-- bob, rotational sway, landing impact, out-of-breath motion and a soft
-- fatigue blur.
--
-- Two passes are bound around Roblox's own camera update:
--   pre  (Camera-1): restore last frame's untouched CFrame so the native
--                    camera never reads our rotation back (no drift), then
--                    simulate FOV and Humanoid.CameraOffset.
--   post (Camera+1): apply our small pitch/roll on top of the fresh CFrame.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local MovementConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MovementConfig"))
local Bob = MovementConfig.Bob
local Sway = MovementConfig.Sway
local Fatigue = MovementConfig.Fatigue
local Look = MovementConfig.Look

-- Post-processing created on the client, so it only affects this player.
local baseLook = Instance.new("ColorCorrectionEffect")
baseLook.Name = "MovementBaseLook"
baseLook.Saturation = Look.Saturation
baseLook.Contrast = Look.Contrast
baseLook.Brightness = Look.Brightness
baseLook.TintColor = Look.Tint
baseLook.Parent = Lighting

local blur = Instance.new("BlurEffect")
blur.Name = "MovementFatigueBlur"
blur.Size = Look.BaseBlur
blur.Parent = Lighting

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Name = "MovementFatigueColor"
colorCorrection.Parent = Lighting

export type MovementState = {
	moving: boolean,
	sprinting: boolean,
	exhausted: boolean,
	fatigue: number, -- 0..1, how out of breath the player is
	heartbeat: number, -- 0..1, how hard the heart is pounding
	heartPhase: number, -- 0..1 within the current beat
}

local CameraEffects = {}

local humanoid: Humanoid? = nil
local state: MovementState = { moving = false, sprinting = false, exhausted = false, fatigue = 0, heartbeat = 0, heartPhase = 0 }
local vignetteBars: { Frame } = {}

local phase = 0 -- step cycle, radians (unbounded; one step per 2*pi)
local lastStepIndex = 0
local stepCallback: ((foot: number) -> ())? = nil
local breathPhase = 0
local moveBlend = 0
local sprintBlend = 0
local exhaustBlend = 0
local fovKick = 0
local wasSprinting = false
local landingImpulse = 0
local strafeLean = 0
local turnLean = 0
local lastYaw: number? = nil
local fatigueBlend = 0 -- smoothed 0..1 for blur/color
local beatBlend = 0 -- smoothed heartbeat blink
local tremorTime = 0

-- Rotation we applied last frame, and the CFrame we applied it to.
local baseCFrame: CFrame? = nil
local pitchDeg = 0
local rollDeg = 0

local function approach(current: number, target: number, speed: number, dt: number): number
	return current + (target - current) * (1 - math.exp(-speed * dt))
end

local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function yawOf(cframe: CFrame): number
	local look = cframe.LookVector
	return math.atan2(-look.X, -look.Z)
end

local function shortestAngle(delta: number): number
	return (delta + math.pi) % (math.pi * 2) - math.pi
end

local function setVignetteAmount(amount: number)
	for _, bar in ipairs(vignetteBars) do
		bar.BackgroundTransparency = 1 - amount
	end
end

function CameraEffects.setHumanoid(newHumanoid: Humanoid?)
	if humanoid and humanoid ~= newHumanoid then
		humanoid.CameraOffset = Vector3.zero
	end
	humanoid = newHumanoid
	phase = 0
	lastStepIndex = 0
	moveBlend = 0
	sprintBlend = 0
	exhaustBlend = 0
	fovKick = 0
	wasSprinting = false
	landingImpulse = 0
	strafeLean = 0
	turnLean = 0
	lastYaw = nil
	baseCFrame = nil
	fatigueBlend = 0
	beatBlend = 0
	blur.Size = Look.BaseBlur
	colorCorrection.Saturation = 0
	colorCorrection.Brightness = 0
	colorCorrection.Contrast = 0
	setVignetteAmount(0)
end

function CameraEffects.setState(newState: MovementState)
	state = newState
end

-- Container whose child frames darken the screen edges as fatigue builds.
function CameraEffects.setVignette(container: Frame)
	vignetteBars = {}
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Frame") then
			table.insert(vignetteBars, child)
		end
	end
end

function CameraEffects.onLanded()
	landingImpulse = 1
end

-- Called each time a foot lands (the low point of the bob), with 1 or 2
-- alternating so footstep audio can stay coherent with the camera.
function CameraEffects.setStepCallback(callback: ((foot: number) -> ())?)
	stepCallback = callback
end

local function preCameraStep(dt: number)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	-- Undo last frame's rotation before the native camera reads the CFrame.
	if baseCFrame then
		camera.CFrame = baseCFrame
		baseCFrame = nil
	end

	-- FOV: settle toward sprint/normal, with a short kick when sprint begins.
	if state.sprinting and not wasSprinting then
		fovKick = MovementConfig.SprintFOVKick
	end
	wasSprinting = state.sprinting
	fovKick = approach(fovKick, 0, MovementConfig.FOVKickDecay, dt)
	local targetFOV = if state.sprinting then MovementConfig.SprintFOV + fovKick else MovementConfig.NormalFOV
	camera.FieldOfView = approach(camera.FieldOfView, targetFOV, MovementConfig.FOVLerpSpeed, dt)

	local currentHumanoid = humanoid
	if not currentHumanoid then
		pitchDeg = 0
		rollDeg = 0
		return
	end

	local grounded = currentHumanoid.FloorMaterial ~= Enum.Material.Air
	moveBlend = approach(moveBlend, if (state.moving and grounded) then 1 else 0, Bob.BlendSpeed, dt)
	sprintBlend = approach(sprintBlend, if state.sprinting then 1 else 0, Bob.BlendSpeed, dt)
	exhaustBlend = approach(exhaustBlend, if state.exhausted then 1 else 0, 3, dt)
	landingImpulse = approach(landingImpulse, 0, Sway.LandingRecovery, dt)

	-- Fatigue post-processing: eases in past BlurStart, sways with the breath
	-- and throbs on each heartbeat (sharp on the beat, easing off after it).
	local fatigueTarget = math.clamp((state.fatigue - Fatigue.BlurStart) / (1 - Fatigue.BlurStart), 0, 1)
	fatigueBlend = approach(fatigueBlend, fatigueTarget, Fatigue.Smoothing, dt)
	local breathSway = 1 - Fatigue.BreathPulse * (0.5 - 0.5 * math.sin(breathPhase))
	-- Beat shape: quick soft rise on the beat, gentle release; smoothed so the
	-- audio's coarse time steps never show up as flicker.
	local beatRaw = math.exp(-state.heartPhase * 3) * state.heartbeat * fatigueBlend
	beatBlend = approach(beatBlend, beatRaw, Fatigue.ThrobSmoothing, dt)
	local fatigueBlur = Fatigue.BlurMax * fatigueBlend + Fatigue.ExhaustedBlurBonus * exhaustBlend
	blur.Size = Look.BaseBlur + fatigueBlur * breathSway * (1 + Fatigue.HeartThrob * beatBlend)
	colorCorrection.Saturation = Fatigue.Saturation * fatigueBlend
	colorCorrection.Brightness = Fatigue.Brightness * fatigueBlend
	colorCorrection.Contrast = Fatigue.Contrast * fatigueBlend
	setVignetteAmount(math.clamp(Fatigue.Vignette * fatigueBlend * (1 + Fatigue.VignetteThrob * beatBlend), 0, 1))

	-- Nervous micro-tremor: a few incommensurate sines so it never looks periodic.
	tremorTime += dt
	local tremor = Fatigue.Tremor * fatigueBlend
	local tremorPitch = (math.sin(tremorTime * 7.3) * 0.5 + math.sin(tremorTime * 11.9) * 0.3 + math.sin(tremorTime * 4.1) * 0.2) * tremor
	local tremorRoll = (math.sin(tremorTime * 6.1 + 1.3) * 0.5 + math.sin(tremorTime * 13.7) * 0.3 + math.sin(tremorTime * 3.3) * 0.2) * tremor

	local frequency = lerp(Bob.WalkFrequency, Bob.SprintFrequency, sprintBlend)
	local ampY = lerp(Bob.WalkVerticalAmplitude, Bob.SprintVerticalAmplitude, sprintBlend)
	local ampX = lerp(Bob.WalkHorizontalAmplitude, Bob.SprintHorizontalAmplitude, sprintBlend)
	local rollAmp = lerp(Sway.WalkRoll, Sway.SprintRoll, sprintBlend)
	local pitchAmp = lerp(Sway.WalkPitch, Sway.SprintPitch, sprintBlend)

	-- Step cycle only advances while moving so everything eases out in place.
	phase += dt * frequency * math.pi * 2 * moveBlend
	-- A foot lands at the bottom of each vertical cycle (phase = 3/2 pi + 2k pi).
	local stepIndex = math.floor((phase - math.pi * 1.5) / (math.pi * 2))
	if stepIndex > lastStepIndex then
		lastStepIndex = stepIndex
		if stepCallback and moveBlend > 0.5 then
			stepCallback(stepIndex % 2 + 1)
		end
	elseif stepIndex < lastStepIndex then
		lastStepIndex = stepIndex
	end

	-- Slow breathing motion scaled by fatigue.
	breathPhase += dt * Sway.BreathFrequency * math.pi * 2 * math.max(state.fatigue, 0.35)
	if breathPhase > math.pi * 2 then
		breathPhase -= math.pi * 2
	end

	-- Leaning: into strafes and into fast turns.
	local right = camera.CFrame.RightVector
	local strafe = Vector3.new(right.X, 0, right.Z).Unit:Dot(currentHumanoid.MoveDirection)
	strafeLean = approach(strafeLean, -strafe * Sway.StrafeLean, Sway.LeanSmoothing, dt)

	local yaw = yawOf(camera.CFrame)
	local yawSpeedDeg = 0
	if lastYaw and dt > 0 then
		yawSpeedDeg = math.deg(shortestAngle(yaw - lastYaw)) / dt
	end
	lastYaw = yaw
	local turnTarget = math.clamp(yawSpeedDeg * Sway.TurnLeanPerDegPerSec, -Sway.TurnLeanMax, Sway.TurnLeanMax)
	turnLean = approach(turnLean, turnTarget, Sway.LeanSmoothing, dt)

	-- Positional part (through the humanoid so it composes with the native camera).
	local y = math.sin(phase) * ampY * moveBlend
	local x = math.sin(phase * 0.5) * ampX * moveBlend
	local dip = Bob.ExhaustedDip * exhaustBlend - Sway.LandingDip * landingImpulse
	currentHumanoid.CameraOffset = Vector3.new(x, y + dip, 0)

	-- Rotational part, applied in the post-camera pass.
	local stepRoll = math.sin(phase * 0.5) * rollAmp * moveBlend
	local stepPitch = math.sin(phase) * pitchAmp * moveBlend
	local breath = math.sin(breathPhase) * Sway.BreathPitch * state.fatigue
	rollDeg = stepRoll + strafeLean + turnLean + tremorRoll
	pitchDeg = stepPitch + breath + tremorPitch - Sway.LandingPitch * landingImpulse
end

local function postCameraStep()
	local camera = workspace.CurrentCamera
	if not camera or not humanoid then
		return
	end
	baseCFrame = camera.CFrame
	camera.CFrame = baseCFrame * CFrame.Angles(math.rad(pitchDeg), 0, math.rad(rollDeg))
end

RunService:BindToRenderStep("MovementCameraPre", Enum.RenderPriority.Camera.Value - 1, preCameraStep)
RunService:BindToRenderStep("MovementCameraPost", Enum.RenderPriority.Camera.Value + 1, postCameraStep)

return CameraEffects
