--!strict
-- Voice reactions: the character's inner voice — a breath put into words,
-- never a line delivered to someone. Heard only by the local player (2D),
-- shown as a small subtitle. SoundId stays "" until a recorded clip exists;
-- the subtitle still shows, so the system works before any audio is uploaded.
--
-- Direction for the recordings (ElevenLabs or real voice): young adult,
-- scared, keeping control, low volume, almost talking to themself. Pauses and
-- hesitation are welcome. Not a narrator, not a trailer, not a hero.

export type Line = {
	Text: string,
	SoundId: string, -- "rbxassetid://..." or ""
	Volume: number,
	PlaybackSpeed: number,
	SubtitleDuration: number, -- seconds on screen (a longer clip extends it)
}

export type Event = {
	Once: boolean, -- one time per player per round
	Cooldown: number, -- seconds before the same event may fire again (when not Once)
	Delay: { number }, -- random delay range after the trigger, so a party never speaks in unison
	Lines: { Line },
}

local function line(text: string, duration: number): Line
	return { Text = text, SoundId = "", Volume = 0.55, PlaybackSpeed = 1, SubtitleDuration = duration }
end

local VoiceConfig = {
	-- [Studio only] print "[VoiceReaction] <event>: "<text>"" while there is no audio to hear
	DebugLog = true,

	Subtitle = {
		TextSize = 16,
		BottomOffset = 74, -- px above the bottom edge
		MaxWidth = 640,
		Color = Color3.fromRGB(198, 192, 180),
		MinTransparency = 0.10, -- never fully white/opaque
		FadeIn = 0.55,
		FadeOut = 1.1,
		Rise = 6, -- px it drifts up while fading in
	},

	-- 2D playback chain. Effects are prepared but off until real clips exist,
	-- then judged by ear: if they hurt the naturalness, the voice stays clean.
	Processing = {
		Enabled = false,
		Equalizer = { LowGain = -3, MidGain = 0, HighGain = -2.5 },
		Reverb = { DecayTime = 0.55, Density = 0.4, Diffusion = 0.6, WetLevel = -22, DryLevel = 0 },
	},

	-- Event id -> pool. The event fires locally; a round reset (RoundId attribute)
	-- clears Once flags. Future events (first Moon sight, Sector 3 entry, gate,
	-- house) are added here, not as new systems. Silence matters more than lines.
	Events = {
		MazeEntry = {
			Once = true,
			Cooldown = 0,
			Delay = { 0.9, 1.9 }, -- entry: mist + darkness first, then the thought
			Lines = {
				line("I feel like something's watching me.", 3.4),
				line("I've got a bad feeling about this place.", 3.6),
				line("Something's moving between the trees.", 3.5),
				line("I don't think we're alone in here.", 3.4),
				line("I've got chills running down my spine.", 3.5),
				line("I swear I saw something move.", 3.0),
				line("Why did it suddenly get so quiet?", 3.2),
				line("Something feels wrong here.", 2.8),
			},
		} :: Event,
	} :: { [string]: Event },
}

return VoiceConfig
