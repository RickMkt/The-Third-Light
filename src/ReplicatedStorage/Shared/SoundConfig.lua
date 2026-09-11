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
	Forest = {
		MinInterval = 9,
		MaxInterval = 26,
		MinDistance = 18, -- from the chosen player
		MaxDistance = 60,
		-- relative weights
		Weights = { BranchSnap = 5, Foliage = 4, Owl = 2 },
		OwlHeight = 14, -- owls come from up in the trees
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
			SpotRange = 62,
			SpotAngle = 24,
			SpotBrightness = 2.6,
			SpillRange = 28,
			SpillAngle = 72,
			SpillBrightness = 0.45,
			Color = Color3.fromRGB(228, 236, 255),
			FollowLag = 14, -- higher = beam sticks closer to the view
			HandOffset = Vector3.new(0.35, -0.3, 0), -- where the beam originates relative to the eye
		},
	},
}

return SoundConfig
