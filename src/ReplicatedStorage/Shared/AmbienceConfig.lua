--!strict
-- Local mix targets for the camp and maze sectors. ForestSilence is reserved
-- for the future Director; 0 is normal ambience and 1 is full suppression.

local AmbienceConfig = {
	UpdateInterval = 0.25,
	FadeSpeed = 1.4,
	SilenceAttribute = "ForestSilence",
	Groups = {
		Wind = "MazeWind",
		Canopy = "MazeCanopy",
		Bed = "MazeBed",
		Spatial = "MazeSpatial",
	},
	Areas = {
		Camp = { Wind = 0.55, Canopy = 0.8, Bed = 1, Spatial = 0.7 },
		Sector1 = { Wind = 0.7, Canopy = 0.9, Bed = 0.75, Spatial = 0.85 },
		Sector2 = { Wind = 0.8, Canopy = 1, Bed = 0.6, Spatial = 1 },
		Sector3 = { Wind = 0.85, Canopy = 0.85, Bed = 0.3, Spatial = 0.75 },
	},
}

return AmbienceConfig
