--!strict
-- Shows the character's inner lines as a quiet subtitle and plays the
-- recorded voice clip when one exists.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local DialogueConfig = require(Shared:WaitForChild("DialogueConfig"))
local ShowLine = Shared:WaitForChild("DialogueRemotes"):WaitForChild("ShowLine") :: RemoteEvent

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("DialogueGui") :: ScreenGui
local label = gui:WaitForChild("Line") :: TextLabel
local stroke = label:FindFirstChildOfClass("UIStroke")

local FADE_IN = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local FADE_OUT = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

local voice = Instance.new("Sound")
voice.Name = "Voice"
voice.Volume = 0.8
voice.Parent = SoundService

local token = 0

local function fade(alpha: number, info: TweenInfo)
	TweenService:Create(label, info, { TextTransparency = alpha }):Play()
	if stroke then
		TweenService:Create(stroke, info, { Transparency = 0.3 + alpha * 0.7 }):Play()
	end
end

local function show(lineId: string)
	local line = DialogueConfig[lineId]
	if not line then
		return
	end
	token += 1
	local myToken = token
	label.Text = "“" .. line.Text .. "”"
	fade(0.08, FADE_IN)

	local hold = line.Duration
	if line.VoiceId ~= "" then
		voice:Stop()
		voice.SoundId = line.VoiceId
		voice:Play()
		if voice.IsLoaded and voice.TimeLength > 0 then
			hold = math.max(hold, voice.TimeLength + 0.6)
		end
	end

	task.delay(hold, function()
		if token == myToken then
			fade(1, FADE_OUT)
		end
	end)
end

ShowLine.OnClientEvent:Connect(show)
