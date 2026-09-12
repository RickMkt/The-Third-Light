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
	MazeEntrance1 = {
		Text = "I feel like something's watching me.",
		VoiceId = "",
		Duration = 3.4,
		Once = true,
	},
	MazeEntrance2 = {
		Text = "I've got a bad feeling about this place.",
		VoiceId = "",
		Duration = 3.6,
		Once = true,
	},
	MazeEntrance3 = {
		Text = "Something's moving between the trees.",
		VoiceId = "",
		Duration = 3.5,
		Once = true,
	},
	MazeEntrance4 = {
		Text = "I don't think we're alone in here.",
		VoiceId = "",
		Duration = 3.5,
		Once = true,
	},
}

return DialogueConfig
