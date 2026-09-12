--!strict
-- Tuning for footsteps, forest one-shots and light sources.

local SoundConfig = {
	Footsteps = {
		WalkVolume = 0.35,
		SprintVolume = 0.6,
		LandingVolume = 0.7,
		PitchJitter = 0.06, -- +/- playback speed variation per step
		-- Humanoid.FloorMaterial -> library group under SoundLibrary.Footsteps
		MaterialGroups = {
			[Enum.Material.Grass] = "Grass",
			[Enum.Material.LeafyGrass] = "Grass",
			[Enum.Material.Ground] = "Dirt",
			[Enum.Material.Mud] = "Dirt",
			[Enum.Material.Sand] = "Dirt",
			[Enum.Material.Rock] = "Dirt",
			[Enum.Material.Wood] = "Wood",
			[Enum.Material.WoodPlanks] = "Wood",
		},
		DefaultGroup = "Dirt",
	},

	-- Random positional sounds around players (branches, foliage, owls).
	-- Each sector has its own rhythm and mix; the player's AmbientState
	-- (AmbienceConfig.States[...].Events) stretches the interval (0 = none).
	Forest = {
		CanopyLoopVolume = 0.28,
		MinDistance = 18, -- from the chosen player
		MaxDistance = 60,
		OwlHeight = 14, -- owls come from up in the trees
		Sectors = {
			-- camp / Sector 1: a living forest
			Camp = { Interval = { 8, 16 }, Weights = { BranchSnap = 3, Foliage = 6, Owl = 2 } },
			Sector1 = { Interval = { 8, 16 }, Weights = { BranchSnap = 4, Foliage = 6, Owl = 1.5 } },
			-- Sector 2: fewer insects, more silence between events, events read as "something"
			Sector2 = { Interval = { 12, 24 }, Weights = { BranchSnap = 5, Foliage = 4, Owl = 0.6 } },
			-- Sector 3: emptier, rarer, harder to place
			Sector3 = { Interval = { 18, 34 }, Weights = { BranchSnap = 5, Foliage = 2, Owl = 0.25 } },
		},
	},

	Lights = {
		-- Kerosene lantern: a bright warm core close to the glass and a soft,
		-- slightly cooler halo that dies within a few steps.
		Lantern = {
			CoreRange = 9,
			CoreBrightness = 1.4,
			CoreColor = Color3.fromRGB(255, 168, 92),
			HaloRange = 19,
			HaloBrightness = 0.35,
			HaloColor = Color3.fromRGB(255, 196, 140),
			Flicker = 0.12, -- fraction of brightness that wavers
			FlickerSpeed = 9,
		},
		-- Handheld flashlight: a tight hot spot plus a wide dim spill. For the
		-- holder the beam follows the camera (with a little lag) so it does not
		-- swing with the arm animation.
		Flashlight = {
			-- three nested cones so the edge of the beam fades instead of cutting
			SpotRange = 68,
			SpotAngle = 18,
			SpotBrightness = 2.8,
			MidRange = 48,
			MidAngle = 36,
			MidBrightness = 1.15,
			SpillRange = 30,
			SpillAngle = 74,
			SpillBrightness = 0.42,
			-- Wide cone aimed only forward: it reveals the nearby walking surface
			-- without making the player's body emit light in every direction.
			ForwardFillRange = 32,
			ForwardFillAngle = 100,
			ForwardFillBrightness = 1.8,
			ForwardFillDistance = 4,
			ForwardFillDrop = 1,
			Color = Color3.fromRGB(226, 234, 255),
			RotationLag = 10, -- small hand-like delay without making aiming feel sluggish
			HandOffset = Vector3.new(0.35, -0.3, 0), -- where the beam originates relative to the eye
			SwayAmount = 0.26, -- base degrees of hand drift
			SwayIdleMultiplier = 0.25,
			SwaySprintMultiplier = 1.55,
		},
	},
}

return SoundConfig
