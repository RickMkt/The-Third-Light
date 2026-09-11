--!strict
-- Local-only body audio: breathing, heartbeat and ear ringing driven by
-- effort and remaining stamina. Intensities (0..1) rise quickly and settle
-- slowly so the body takes a while to calm down after recovery.
-- Sounds are cloned from ReplicatedStorage.Shared.MovementSounds so assets
-- can be swapped in Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local MovementConfig = require(Shared:WaitForChild("MovementConfig"))
local AudioConfig = MovementConfig.Audio
local sourceFolder = Shared:WaitForChild("MovementSounds")

export type BodyState = {
	breathing: number, -- 0..1
	heartbeat: number, -- 0..1
	heartPhase: number, -- 0..1 within the current beat (0 = beat just landed)
}

local MovementAudio = {}

local function cloneSound(name: string): Sound
	local sound = sourceFolder:WaitForChild(name):Clone() :: Sound
	sound.Volume = 0
	sound.Looped = true
	sound.Parent = SoundService
	return sound
end

local breathing = cloneSound("Breathing")
local heartbeat = cloneSound("Heartbeat")
local ringing = cloneSound("Ringing")
ringing.PlaybackSpeed = AudioConfig.RingingPlaybackSpeed

local breathingIntensity = 0
local heartbeatIntensity = 0
local ringingIntensity = 0

local function approach(current: number, target: number, speed: number, dt: number): number
	return current + (target - current) * (1 - math.exp(-speed * dt))
end

-- Moves toward target with different speeds for rising and falling.
local function follow(current: number, target: number, rise: number, fall: number, dt: number): number
	return approach(current, target, if target > current then rise else fall, dt)
end

-- 0 at `start` stamina fraction, 1 at zero stamina.
local function lowStaminaAmount(staminaFraction: number, start: number): number
	return math.clamp((start - staminaFraction) / start, 0, 1)
end

local function applyIntensity(sound: Sound, intensity: number, maxVolume: number)
	if intensity < 0.02 then
		if sound.Playing then
			sound:Stop()
		end
		sound.Volume = 0
		return
	end
	if not sound.Playing then
		sound:Play()
	end
	sound.Volume = maxVolume * intensity
end

function MovementAudio.update(dt: number, staminaFraction: number, exhausted: boolean, sprinting: boolean, moving: boolean): BodyState
	-- Near full stamina the body is quiet: every target drops to zero and the
	-- fade-out is quicker than the usual slow settle.
	local quiet = staminaFraction >= AudioConfig.SilenceAbove and not exhausted

	-- Breathing: effort while sprinting, heavier as stamina drains, full when exhausted.
	local breathTarget = lowStaminaAmount(staminaFraction, AudioConfig.BreathingStart)
	if sprinting then
		breathTarget = math.max(breathTarget, AudioConfig.BreathingSprintFloor)
	end
	if exhausted then
		breathTarget = 1
	end

	-- Heartbeat: same shape, starts earlier and quieter.
	local heartTarget = lowStaminaAmount(staminaFraction, AudioConfig.HeartbeatStart)
	if sprinting then
		heartTarget = math.max(heartTarget, AudioConfig.HeartbeatSprintFloor)
	end
	if exhausted then
		heartTarget = 1
	end

	-- Ringing: creeps in as a background tone near the bottom, peaks when the
	-- player stops to rest while exhausted, and fades as stamina comes back.
	local ringTarget = lowStaminaAmount(staminaFraction, AudioConfig.RingingStart) * AudioConfig.RingingBackgroundLevel
	if exhausted then
		ringTarget = if moving then AudioConfig.RingingExhaustedMovingLevel else 1
	end

	if quiet then
		breathTarget, heartTarget, ringTarget = 0, 0, 0
		breathingIntensity = approach(breathingIntensity, 0, AudioConfig.SilenceFall, dt)
		heartbeatIntensity = approach(heartbeatIntensity, 0, AudioConfig.SilenceFall, dt)
		ringingIntensity = approach(ringingIntensity, 0, AudioConfig.SilenceFall, dt)
	else
		breathingIntensity = follow(breathingIntensity, breathTarget, AudioConfig.BreathingRise, AudioConfig.BreathingFall, dt)
		heartbeatIntensity = follow(heartbeatIntensity, heartTarget, AudioConfig.HeartbeatRise, AudioConfig.HeartbeatFall, dt)
		ringingIntensity = follow(ringingIntensity, ringTarget, AudioConfig.RingingRise, AudioConfig.RingingFall, dt)
	end

	applyIntensity(breathing, breathingIntensity, AudioConfig.BreathingMaxVolume)
	applyIntensity(heartbeat, heartbeatIntensity ^ AudioConfig.HeartbeatVolumeCurve, AudioConfig.HeartbeatMaxVolume)
	applyIntensity(ringing, ringingIntensity, AudioConfig.RingingMaxVolume)

	breathing.PlaybackSpeed = 1 + (AudioConfig.BreathingExhaustedSpeed - 1) * breathingIntensity
	heartbeat.PlaybackSpeed = 1 + AudioConfig.HeartbeatMaxSpeedBoost * heartbeatIntensity

	-- Beat phase derived from the loop position so visuals can throb in time.
	local beatsPerSecond = AudioConfig.HeartbeatBPM / 60
	local heartPhase = if heartbeat.Playing then (heartbeat.TimePosition * beatsPerSecond) % 1 else 0

	return {
		breathing = breathingIntensity,
		heartbeat = heartbeatIntensity,
		heartPhase = heartPhase,
	}
end

function MovementAudio.reset()
	breathingIntensity = 0
	heartbeatIntensity = 0
	ringingIntensity = 0
	applyIntensity(breathing, 0, 0)
	applyIntensity(heartbeat, 0, 0)
	applyIntensity(ringing, 0, 0)
end

return MovementAudio
