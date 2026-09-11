--!strict
-- When this player crosses into the maze, the way back closes for them:
-- a local invisible wall, a thick curtain of mist over the opening (the camp
-- blurs away behind it) and a short blur pulse on screen. Local-only, so
-- each player gets their own moment and the server is not involved.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local ShowLine = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DialogueRemotes"):WaitForChild("ShowLine") :: RemoteEvent
local Triggers = workspace:WaitForChild("TheThirdLight"):WaitForChild("Gameplay"):WaitForChild("Interactions"):WaitForChild("Triggers")

local player = Players.LocalPlayer
local closed = false

local function closeEntrance()
	if closed then
		return
	end
	closed = true
	local zone = Triggers:FindFirstChild("MazeEntrance")
	local center = if zone and zone:IsA("BasePart") then zone.Position else Vector3.new(0, 10, -62)
	-- wall just on the camp side of the zone (local part: collides only with this client's character)
	local wall = Instance.new("Part")
	wall.Name = "MazeEntryWall"
	wall.Anchored = true
	wall.Transparency = 1
	wall.CanQuery = false
	wall.Size = Vector3.new(40, 40, 3)
	wall.Position = Vector3.new(center.X, 20, center.Z + 7)
	wall.Parent = workspace.CurrentCamera -- camera children are local-only

	-- mist curtain across the opening
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
	emitter.Rate = 14
	emitter.Lifetime = NumberRange.new(6, 10)
	emitter.Speed = NumberRange.new(0.2, 0.6)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 18) })
	emitter.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.45), NumberSequenceKeypoint.new(0.8, 0.5), NumberSequenceKeypoint.new(1, 1) })
	emitter.Color = ColorSequence.new(Color3.fromRGB(110, 118, 140))
	emitter.LightEmission = 0
	emitter.LightInfluence = 1
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-3, 3)
	emitter.Drag = 0.4
	emitter.Parent = curtain

	-- screen blur pulse while the line lands
	local blur = Instance.new("BlurEffect")
	blur.Name = "MazeEntryBlur"
	blur.Size = 0
	blur.Parent = Lighting
	TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = 14 }):Play()
	task.delay(0.6, function()
		local out = TweenService:Create(blur, TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = 0 })
		out.Completed:Once(function()
			blur:Destroy()
		end)
		out:Play()
	end)
end

ShowLine.OnClientEvent:Connect(function(lineId: string)
	if lineId == "MazeEntrance" then
		closeEntrance()
	end
end)

-- A new round (respawn) reopens nothing: the wall persists for this session.
