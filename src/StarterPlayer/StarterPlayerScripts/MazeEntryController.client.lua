--!strict
-- When this player crosses into the maze the way back closes for them and
-- the night gets much darker: a local invisible wall, a thick mist curtain
-- over the opening (the camp blurs away behind it), a short blur pulse and a
-- slow tween of the local Lighting toward "moonlight barely reaches the
-- floor". Everything here is client-side, so each player gets their own
-- moment and players still in the camp keep the camp's light.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local ShowLine = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DialogueRemotes"):WaitForChild("ShowLine") :: RemoteEvent
local Triggers = workspace:WaitForChild("TheThirdLight"):WaitForChild("Gameplay"):WaitForChild("Interactions"):WaitForChild("Triggers")
local VisualConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("VisualConfig"))
local MazeVisual = VisualConfig.MazeEntry

local player = Players.LocalPlayer
local closed = false

-- Maze darkness (local Lighting overrides). Camp values are restored on respawn.
local MAZE_LIGHTING = {
	Brightness = 0.72,
	ExposureCompensation = -0.58,
	Ambient = Color3.fromRGB(10, 12, 19),
	OutdoorAmbient = Color3.fromRGB(22, 27, 39),
}
local MAZE_ATMOSPHERE = { Density = 0.74, Haze = 10.5, Offset = 0.48, Color = Color3.fromRGB(65, 72, 92), Decay = Color3.fromRGB(12, 16, 26) }
local campLighting: { [string]: any } = {}
local campAtmosphere: { [string]: any } = {}

local function rememberCamp()
	for name in pairs(MAZE_LIGHTING) do
		campLighting[name] = (Lighting :: any)[name]
	end
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		for name in pairs(MAZE_ATMOSPHERE) do
			campAtmosphere[name] = (atmosphere :: any)[name]
		end
	end
end

local function applyLighting(values: { [string]: any }, atmosphereValues: { [string]: any }, seconds: number)
	local info = TweenInfo.new(seconds, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	TweenService:Create(Lighting, info, values):Play()
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		TweenService:Create(atmosphere, info, atmosphereValues):Play()
	end
end

local function clearMazeVisuals()
	local blur = Lighting:FindFirstChild("MazeAtmosphereBlur")
	if blur then
		blur:Destroy()
	end
end

local function closeEntrance()
	if closed then
		return
	end
	closed = true
	local zone = Triggers:FindFirstChild("MazeEntrance")
	local center = if zone and zone:IsA("BasePart") then zone.Position else Vector3.new(0, 10, -62)

	local wall = Instance.new("Part")
	wall.Name = "MazeEntryWall"
	wall.Anchored = true
	wall.Transparency = 1
	wall.CanQuery = false
	wall.Size = Vector3.new(40, 40, 3)
	wall.Position = Vector3.new(center.X, 20, center.Z + 7)
	wall.Parent = workspace.CurrentCamera -- camera children are local-only

	local curtain = Instance.new("Part")
	curtain.Name = "MazeEntryMist"
	curtain.Anchored = true
	curtain.CanCollide = false
	curtain.CanQuery = false
	curtain.Transparency = 1
	curtain.Size = Vector3.new(26, 16, 4)
	curtain.Position = Vector3.new(center.X, 10, center.Z + 6)
	curtain.Parent = workspace.CurrentCamera
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	emitter.Rate = 16
	emitter.Lifetime = NumberRange.new(6, 10)
	emitter.Speed = NumberRange.new(0.2, 0.6)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 18) })
	emitter.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.4), NumberSequenceKeypoint.new(0.8, 0.45), NumberSequenceKeypoint.new(1, 1) })
	emitter.Color = ColorSequence.new(Color3.fromRGB(100, 108, 130))
	emitter.LightEmission = 0
	emitter.LightInfluence = 1
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-3, 3)
	emitter.Drag = 0.4
	emitter.Parent = curtain

	clearMazeVisuals()

	local blur = Instance.new("BlurEffect")
	blur.Name = "MazeAtmosphereBlur"
	blur.Size = 0
	blur.Parent = Lighting
	TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = 14 }):Play()
	task.delay(0.6, function()
		if blur.Parent then
			TweenService:Create(blur, TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = MazeVisual.PersistentBlur }):Play()
		end
	end)

	-- the moon stops reaching the floor
	rememberCamp()
	applyLighting(MAZE_LIGHTING, MAZE_ATMOSPHERE, 6)
end

ShowLine.OnClientEvent:Connect(function(lineId: string)
	if string.match(lineId, "^MazeEntrance%d$") then
		closeEntrance()
	end
end)

-- A player who crossed the entrance respawns inside the maze, so the local
-- treatment and one-way entrance must survive their character replacement.
player.CharacterAdded:Connect(function()
	if player:GetAttribute("InMaze") == true then
		if not closed then
			closeEntrance()
		end
		return
	end
	if not closed then
		return
	end
	closed = false
	clearMazeVisuals()
	local camera = workspace.CurrentCamera
	if camera then
		for _, name in ipairs({ "MazeEntryWall", "MazeEntryMist" }) do
			local inst = camera:FindFirstChild(name)
			if inst then
				inst:Destroy()
			end
		end
	end
	if next(campLighting) then
		applyLighting(campLighting, campAtmosphere, 1.5)
	end
end)
