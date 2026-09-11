--!strict
-- Central tuning values for player movement, stamina, camera and UI.
-- Everything here is a test baseline and is meant to be adjusted freely.

local MovementConfig = {
	-- Speeds (studs/s)
	WalkSpeed = 11,
	SprintSpeed = 17,

	-- Jump
	JumpPower = 35,
	JumpCooldown = 0.6, -- seconds after landing before another jump is allowed

	-- Stamina
	MaxStamina = 100,
	SprintDrainPerSecond = 18,
	StaminaRegenPerSecond = 14,
	RegenDelay = 1.25, -- seconds after sprint stops before regen starts
	ExhaustionThreshold = 20, -- stamina needed to sprint again after hitting zero

	-- Camera FOV
	NormalFOV = 72,
	SprintFOV = 80,
	SprintFOVKick = 3, -- extra degrees punched in the instant sprint starts, then settles
	FOVKickDecay = 3, -- how fast the kick settles back to SprintFOV
	FOVLerpSpeed = 6, -- higher = faster transition (~300ms at 6)

	-- Head bob (studs). Keep these small: the goal is to feel it, not see it.
	Bob = {
		WalkFrequency = 1.7, -- steps per second
		SprintFrequency = 2.3,
		WalkVerticalAmplitude = 0.035,
		WalkHorizontalAmplitude = 0.02,
		SprintVerticalAmplitude = 0.06,
		SprintHorizontalAmplitude = 0.03,
		BlendSpeed = 8, -- how fast bob fades in/out when starting/stopping
		ExhaustedDip = -0.08, -- slight camera sink while exhausted
	},

	-- Rotational view sway (degrees). Applied on top of the native camera.
	Sway = {
		WalkRoll = 0.35, -- side-to-side tilt per step
		SprintRoll = 0.7,
		WalkPitch = 0.2, -- nod per step
		SprintPitch = 0.4,
		StrafeLean = 0.6, -- lean into sideways movement
		TurnLeanPerDegPerSec = 0.008, -- lean into fast mouse turns
		TurnLeanMax = 1.2,
		LeanSmoothing = 6,
		LandingDip = 0.12, -- studs the camera sinks on landing
		LandingPitch = 1.2, -- degrees the camera nods on landing
		LandingRecovery = 7,
		BreathPitch = 0.35, -- slow nod while out of breath
		BreathFrequency = 0.45, -- breaths per second at full fatigue
	},

	-- Always-on look: takes the edge off Roblox's clean, bright default so the
	-- image reads as horror even with nothing happening.
	Look = {
		BaseBlur = 1, -- constant softness (BlurEffect.Size)
		Saturation = -0.2,
		Contrast = 0.06,
		Brightness = -0.03,
		Tint = Color3.fromRGB(236, 240, 248), -- slightly cold
	},

	-- Screen-space fatigue: soft blur, washed color and a light tunnel vision,
	-- with a subtle blink on every heartbeat. Driven by the breathing fatigue.
	Fatigue = {
		BlurStart = 0.3, -- fatigue (0..1) at which blur begins
		BlurMax = 8, -- BlurEffect.Size added at full fatigue
		ExhaustedBlurBonus = 3, -- extra blur while actually exhausted (the "peak")
		BreathPulse = 0.1, -- fraction of blur that sways with the breathing
		HeartThrob = 0.12, -- fraction of blur that blinks with each heartbeat
		ThrobSmoothing = 14, -- softens the beat so it reads as a blink, not a flicker
		Saturation = -0.3, -- ColorCorrection at full fatigue
		Brightness = -0.06,
		Contrast = -0.08,
		Vignette = 0.35, -- edge darkening (tunnel vision) at full fatigue
		VignetteThrob = 0.08,
		Tremor = 0.12, -- degrees of nervous micro-shake at full fatigue
		Smoothing = 2.5,
	},

	-- Input
	ToggleMouseKey = Enum.KeyCode.M,

	-- Breathing / heartbeat feedback. Intensities are 0..1 and smoothed so
	-- the body takes a while to calm down after recovering stamina.
	Audio = {
		-- Above this stamina fraction every body sound is forced to fade out.
		SilenceAbove = 0.9,
		SilenceFall = 1.5, -- fade-out speed once above SilenceAbove

		-- Breathing: builds with effort, heavy near the bottom, slow to settle.
		BreathingStart = 0.6, -- stamina fraction below which breathing starts
		BreathingSprintFloor = 0.25, -- minimum intensity while sprinting
		BreathingMaxVolume = 0.55,
		BreathingExhaustedSpeed = 1.08, -- slightly faster loop when gasping
		BreathingRise = 1.2,
		BreathingFall = 0.4,

		-- Heartbeat: audible early but quiet, pounding when exhausted.
		HeartbeatStart = 0.7,
		HeartbeatSprintFloor = 0.3,
		HeartbeatMaxVolume = 0.45,
		HeartbeatVolumeCurve = 1.6, -- >1 keeps it subtle until intensity is high
		HeartbeatBPM = 96, -- tempo of the source loop at speed 1
		HeartbeatMaxSpeedBoost = 0.35, -- up to 1.35x (~130 bpm) when exhausted
		HeartbeatRise = 1.5,
		HeartbeatFall = 0.5,

		-- Ringing: faint in the background when nearly spent, peaks when the
		-- player stops to rest while exhausted, then fades with the recovery.
		RingingStart = 0.3,
		RingingBackgroundLevel = 0.4, -- intensity reached just before exhaustion
		RingingExhaustedMovingLevel = 0.75,
		RingingMaxVolume = 0.2,
		RingingPlaybackSpeed = 1.5, -- pitches the base tone up into ear-ringing range
		RingingRise = 2.5,
		RingingFall = 0.45,
	},

	-- Stamina bar
	UI = {
		FillSmoothSpeed = 10, -- bar value interpolation
		FadeSpeed = 4, -- bar opacity interpolation
		HideDelay = 1.5, -- seconds at full stamina before the bar fades out
		TrackTransparency = 0.55,
		FillTransparency = 0.15,
		FillColor = Color3.fromRGB(196, 190, 178),
		ExhaustedFillColor = Color3.fromRGB(168, 118, 108),
	},
}

return MovementConfig
