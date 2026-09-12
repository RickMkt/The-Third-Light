--!strict
-- Local mix targets for the camp and maze sectors, plus the small set of
-- ambient states the future Director (Moon Man) can put a player in. Final
-- volume of each layer = Area[layer] * State[layer] * (1 - ForestSilence).
-- It is the same forest slowly going wrong, never three different tracks.

local AmbienceConfig = {
	UpdateInterval = 0.25,
	FadeSpeed = 1.4,
	SilenceAttribute = "ForestSilence", -- 0..1 scalar, full suppression at 1
	StateAttribute = "AmbientState", -- one of States below (server-owned)
	StateFadeSpeed = 0.6, -- states drift in slowly; the ear notices the change, not the cut
	Sector2StartZ = -300,
	Sector3StartZ = -500, -- Maze V2-B adds one 40-stud band to Sector 2.
	Groups = {
		Wind = "MazeWind",
		Canopy = "MazeCanopy",
		Bed = "MazeBed",
		Spatial = "MazeSpatial",
	},
	-- Sector 1: living forest (insects, canopy). Sector 2: fewer insects, more
	-- spaced positional events. Sector 3: emptier, deeper wind, less life.
	Areas = {
		Camp = { Wind = 0.55, Canopy = 0.8, Bed = 1, Spatial = 0.7 },
		Sector1 = { Wind = 0.7, Canopy = 0.9, Bed = 0.8, Spatial = 0.85 },
		Sector2 = { Wind = 0.8, Canopy = 0.9, Bed = 0.55, Spatial = 1 },
		Sector3 = { Wind = 0.9, Canopy = 0.7, Bed = 0.25, Spatial = 0.8 },
	},
	-- Events = multiplier on the frequency of positional one-shots (0 = none).
	States = {
		Normal = { Wind = 1, Canopy = 1, Bed = 1, Spatial = 1, Events = 1 },
		Uneasy = { Wind = 0.9, Canopy = 0.8, Bed = 0.6, Spatial = 1.1, Events = 0.8 },
		Silent = { Wind = 0.25, Canopy = 0.1, Bed = 0, Spatial = 0.5, Events = 0 },
		MoonNear = { Wind = 0.6, Canopy = 0.45, Bed = 0.15, Spatial = 0.9, Events = 0.35 },
		Chase = { Wind = 1, Canopy = 0.9, Bed = 0.3, Spatial = 1, Events = 0.2 },
	},
}

return AmbienceConfig
