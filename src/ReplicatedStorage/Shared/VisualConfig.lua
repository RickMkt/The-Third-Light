--!strict
-- Local visual treatment. Values stay subtle so atmosphere never hides play.

local VisualConfig = {
	MazeEntry = {
		PersistentBlur = 2.0, -- extra softness inside the maze (stacks with the base look blur)
	},
	-- Soft "VHS" treatment, active from the camp. Scanlines are drawn as thin
	-- frames (no texture upload needed); values are transparencies (1 = invisible).
	Vhs = {
		ScanlineSpacing = 3, -- px between lines
		ScanlineTransparency = 0.90, -- camp
		ScanlineTransparencyMaze = 0.86,
		EdgeShade = 0.80, -- top/bottom soft darkening at the very edge
		TrackingBandHeight = 26, -- px
		TrackingBandTransparency = 0.955,
		TrackingInterval = { 9, 16 }, -- seconds between bands (camp)
		TrackingIntervalMaze = { 5, 10 },
		TrackingTravel = 2.6, -- seconds to cross the screen
		JitterInterval = { 0.35, 1.4 }, -- seconds between 1-frame line jitters
		JitterPixels = 2,
		Saturation = -0.12,
		Contrast = -0.05,
		Tint = Color3.fromRGB(226, 232, 244),
		BrightnessFlicker = 0.012, -- +/- applied every FlickerInterval
		FlickerInterval = 0.12,
		SoftBlur = 0.8, -- camp; inside the maze MazeEntry.PersistentBlur takes over
	},
}

return VisualConfig
