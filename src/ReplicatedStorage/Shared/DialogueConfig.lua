--!strict
-- Lines the player character "says" (subtitle) with an optional recorded
-- voice clip. Leave VoiceId empty until a recording exists; the subtitle
-- still shows. Text is shown in italics-like lowercase quotes by the UI.

export type Line = {
	Text: string,
	VoiceId: string, -- "rbxassetid://..." or ""
	Duration: number, -- seconds on screen (ignored if a voice clip is longer)
	Once: boolean, -- only the first time per player per round
}

local DialogueConfig: { [string]: Line } = {
	MazeEntrance = {
		Text = "Eu sinto calafrios na minha espinha...",
		VoiceId = "",
		Duration = 4.5,
		Once = true,
	},
}

return DialogueConfig
