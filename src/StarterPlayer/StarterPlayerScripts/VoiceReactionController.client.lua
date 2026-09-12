--!strict
-- The character's inner voice. Everything is local: the trigger is observed
-- here (Player attributes or the Voice remote), the line is spoken as a 2D
-- sound in SoundService and shown as a small subtitle. Other players never
-- hear it. Pools, delays and processing live in VoiceConfig.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local VoiceConfig = require(Shared:WaitForChild("VoiceConfig"))
local TriggerRemote = Shared:WaitForChild("VoiceRemotes"):WaitForChild("Trigger") :: RemoteEvent

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local rng = Random.new()
local Sub = VoiceConfig.Subtitle

-- subtitle -----------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "VoiceGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 40 -- under the VHS overlay so the text belongs to the picture
gui.Parent = playerGui

local label = Instance.new("TextLabel")
label.Name = "Line"
label.AnchorPoint = Vector2.new(0.5, 1)
label.Position = UDim2.new(0.5, 0, 1, -Sub.BottomOffset)
label.Size = UDim2.new(0, Sub.MaxWidth, 0, 24)
label.AutomaticSize = Enum.AutomaticSize.Y
label.BackgroundTransparency = 1
label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
label.TextSize = Sub.TextSize
label.TextWrapped = true
label.TextColor3 = Sub.Color
label.TextTransparency = 1
label.Text = ""
label.Parent = gui
local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(8, 8, 10)
stroke.Transparency = 1
stroke.Parent = label

local restPosition = label.Position
local token = 0

local function fadeTo(alpha: number, seconds: number, easing: Enum.EasingDirection)
	local info = TweenInfo.new(seconds, Enum.EasingStyle.Sine, easing)
	TweenService:Create(label, info, { TextTransparency = alpha }):Play()
	TweenService:Create(stroke, info, { Transparency = 0.35 + alpha * 0.65 }):Play()
end

local function showSubtitle(text: string, hold: number)
	token += 1
	local myToken = token
	label.Text = text
	label.Position = restPosition + UDim2.fromOffset(0, Sub.Rise)
	TweenService:Create(label, TweenInfo.new(Sub.FadeIn * 1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Position = restPosition }):Play()
	fadeTo(Sub.MinTransparency, Sub.FadeIn, Enum.EasingDirection.Out)
	task.delay(hold, function()
		if token == myToken then
			fadeTo(1, Sub.FadeOut, Enum.EasingDirection.In)
		end
	end)
end

-- 2D voice ------------------------------------------------------------------
local group = Instance.new("SoundGroup")
group.Name = "Voice"
group.Volume = 1
group.Parent = SoundService

local eq = Instance.new("EqualizerSoundEffect")
eq.LowGain = VoiceConfig.Processing.Equalizer.LowGain
eq.MidGain = VoiceConfig.Processing.Equalizer.MidGain
eq.HighGain = VoiceConfig.Processing.Equalizer.HighGain
eq.Enabled = VoiceConfig.Processing.Enabled
eq.Priority = 1
eq.Parent = group

local reverb = Instance.new("ReverbSoundEffect")
for name, value in pairs(VoiceConfig.Processing.Reverb) do
	(reverb :: any)[name] = value
end
reverb.Enabled = VoiceConfig.Processing.Enabled
reverb.Priority = 0
reverb.Parent = group

local voice = Instance.new("Sound")
voice.Name = "VoiceReaction"
voice.SoundGroup = group
voice.Parent = SoundService -- no parent part: plays 2D, centred, only for this client

-- events -----------------------------------------------------------------------
local firedThisRound: { [string]: boolean } = {}
local lastFired: { [string]: number } = {}

local function pickLine(eventId: string, pool: { any })
	-- The server may pre-assign an index (VoiceLine_<event>) so a party does not
	-- share the same thought; otherwise pick locally.
	local assigned = player:GetAttribute("VoiceLine_" .. eventId)
	if typeof(assigned) == "number" and pool[assigned] then
		return pool[assigned]
	end
	return pool[rng:NextInteger(1, #pool)]
end

local function speak(eventId: string, line: any)
	local hold = line.SubtitleDuration
	if line.SoundId ~= "" then
		voice:Stop()
		voice.SoundId = line.SoundId
		voice.Volume = line.Volume
		voice.PlaybackSpeed = line.PlaybackSpeed
		voice:Play()
		if voice.IsLoaded and voice.TimeLength > 0 then
			hold = math.max(hold, voice.TimeLength / line.PlaybackSpeed + 0.4)
		end
	end
	if VoiceConfig.DebugLog and RunService:IsStudio() then
		print(string.format('[VoiceReaction] %s: "%s"', eventId, line.Text))
	end
	showSubtitle(line.Text, hold)
end

local function trigger(eventId: string)
	local event = VoiceConfig.Events[eventId]
	if not event or #event.Lines == 0 then
		return
	end
	if event.Once and firedThisRound[eventId] then
		return
	end
	local now = os.clock()
	if now - (lastFired[eventId] or -math.huge) < event.Cooldown then
		return
	end
	firedThisRound[eventId] = true
	lastFired[eventId] = now
	local line = pickLine(eventId, event.Lines)
	task.delay(rng:NextNumber(event.Delay[1], event.Delay[2]), function()
		speak(eventId, line)
	end)
end

-- Maze entry: the true boundary is when the server flips InMaze. Respawns keep
-- the attribute true, so the thought never repeats inside the same round.
player:GetAttributeChangedSignal("InMaze"):Connect(function()
	if player:GetAttribute("InMaze") == true then
		trigger("MazeEntry")
	end
end)

-- A new round (future round system bumps RoundId) clears the Once flags.
player:GetAttributeChangedSignal("RoundId"):Connect(function()
	table.clear(firedThisRound)
end)

-- Future server-driven moments (first Moon sight, gate, house...).
TriggerRemote.OnClientEvent:Connect(function(eventId: unknown)
	if typeof(eventId) == "string" then
		trigger(eventId)
	end
end)
