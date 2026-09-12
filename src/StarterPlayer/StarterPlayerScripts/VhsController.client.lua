--!strict
-- Soft VHS look, active from the camp: faint scanlines, slight wash-out,
-- an occasional tracking band drifting down and tiny line jitter. Never a
-- field of dots. Intensity rises a little once the player is inside the maze
-- (server sets Player.InMaze). Values live in VisualConfig.Vhs.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local VisualConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("VisualConfig"))
local V = VisualConfig.Vhs

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local camera = workspace.CurrentCamera
local rng = Random.new()

local function inMaze(): boolean
	return player:GetAttribute("InMaze") == true
end

-- overlay -------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "VhsOverlay"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 45
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = playerGui

local lines = Instance.new("Frame")
lines.Name = "Scanlines"
lines.BackgroundTransparency = 1
lines.Size = UDim2.fromScale(1, 1)
lines.Parent = gui

local function shade(name: string, anchorY: number, posY: number, rotation: number)
	local f = Instance.new("Frame")
	f.Name = name
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(0, 0, 0)
	f.AnchorPoint = Vector2.new(0, anchorY)
	f.Position = UDim2.fromScale(0, posY)
	f.Size = UDim2.new(1, 0, 0.12, 0)
	f.ZIndex = 2
	local g = Instance.new("UIGradient")
	g.Rotation = rotation
	g.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, V.EdgeShade), NumberSequenceKeypoint.new(1, 1) })
	g.Parent = f
	f.Parent = gui
end
shade("EdgeTop", 0, 0, 90)
shade("EdgeBottom", 1, 1, -90)

local band = Instance.new("Frame")
band.Name = "TrackingBand"
band.BorderSizePixel = 0
band.BackgroundColor3 = Color3.fromRGB(210, 218, 232)
band.BackgroundTransparency = 1
band.Size = UDim2.new(1, 0, 0, V.TrackingBandHeight)
band.Position = UDim2.fromScale(0, -0.1)
band.ZIndex = 3
local bandGrad = Instance.new("UIGradient")
bandGrad.Rotation = 90
bandGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) })
bandGrad.Parent = band
band.Parent = gui

local lineFrames: { Frame } = {}
local function rebuildScanlines()
	for _, f in ipairs(lineFrames) do
		f:Destroy()
	end
	table.clear(lineFrames)
	local height = camera.ViewportSize.Y
	local alpha = if inMaze() then V.ScanlineTransparencyMaze else V.ScanlineTransparency
	for y = 0, height, V.ScanlineSpacing do
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		f.BackgroundColor3 = Color3.new(0, 0, 0)
		f.BackgroundTransparency = alpha
		f.Size = UDim2.new(1, 0, 0, 1)
		f.Position = UDim2.fromOffset(0, y)
		f.ZIndex = 1
		f.Parent = lines
		table.insert(lineFrames, f)
	end
end

local function applyIntensity()
	local alpha = if inMaze() then V.ScanlineTransparencyMaze else V.ScanlineTransparency
	for _, f in ipairs(lineFrames) do
		f.BackgroundTransparency = alpha
	end
end

rebuildScanlines()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(rebuildScanlines)
player:GetAttributeChangedSignal("InMaze"):Connect(applyIntensity)

-- colour wash + softness --------------------------------------------------------
local color = Instance.new("ColorCorrectionEffect")
color.Name = "VhsColor"
color.Saturation = V.Saturation
color.Contrast = V.Contrast
color.TintColor = V.Tint
color.Parent = Lighting

local soft = Instance.new("BlurEffect")
soft.Name = "VhsSoft"
soft.Size = V.SoftBlur
soft.Parent = Lighting
player:GetAttributeChangedSignal("InMaze"):Connect(function()
	-- the maze entry adds its own persistent blur; avoid stacking two
	soft.Size = if inMaze() then 0 else V.SoftBlur
end)

-- tracking band + jitter + brightness flicker -----------------------------------
task.spawn(function()
	while gui.Parent do
		local interval = if inMaze() then V.TrackingIntervalMaze else V.TrackingInterval
		task.wait(rng:NextNumber(interval[1], interval[2]))
		band.Position = UDim2.new(0, 0, 0, -V.TrackingBandHeight)
		band.BackgroundTransparency = V.TrackingBandTransparency
		local tween = TweenService:Create(band, TweenInfo.new(V.TrackingTravel, Enum.EasingStyle.Linear), { Position = UDim2.new(0, 0, 1, 0) })
		tween:Play()
		tween.Completed:Wait()
		band.BackgroundTransparency = 1
	end
end)

task.spawn(function()
	while gui.Parent do
		task.wait(rng:NextNumber(V.JitterInterval[1], V.JitterInterval[2]))
		local dy = rng:NextInteger(-V.JitterPixels, V.JitterPixels)
		lines.Position = UDim2.fromOffset(0, dy)
		RunService.RenderStepped:Wait()
		RunService.RenderStepped:Wait()
		lines.Position = UDim2.fromOffset(0, 0)
	end
end)

task.spawn(function()
	while gui.Parent do
		color.Brightness = rng:NextNumber(-V.BrightnessFlicker, V.BrightnessFlicker)
		task.wait(V.FlickerInterval)
	end
end)
