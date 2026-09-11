--!strict
-- Custom look for ProximityPrompts (Style = Custom): a small key badge that
-- fills while held, next to "Action · Object" in the game's bone tone.

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local BONE = Color3.fromRGB(196, 190, 178)
local INK = Color3.fromRGB(8, 8, 10)
local FADE_IN = TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local FADE_OUT = TweenInfo.new(0.14, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

local active: { [ProximityPrompt]: { gui: BillboardGui, group: CanvasGroup, fill: Frame, badge: Frame } } = {}

local function keyLabel(prompt: ProximityPrompt, inputType: Enum.ProximityPromptInputType): string
	if inputType == Enum.ProximityPromptInputType.Gamepad then
		return string.gsub(prompt.GamepadKeyCode.Name, "Button", "")
	elseif inputType == Enum.ProximityPromptInputType.Touch then
		return "•"
	end
	local keyCode = prompt.KeyboardKeyCode
	local text = UserInputService:GetStringForKeyCode(keyCode)
	return if text ~= "" then text else keyCode.Name
end

local function build(prompt: ProximityPrompt, inputType: Enum.ProximityPromptInputType)
	local gui = Instance.new("BillboardGui")
	gui.Name = "InteractionPrompt"
	gui.Adornee = prompt.Parent :: any
	gui.Size = UDim2.fromOffset(240, 40)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 1.3, 0)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.ResetOnSpawn = false

	local group = Instance.new("CanvasGroup")
	group.Size = UDim2.fromScale(1, 1)
	group.BackgroundTransparency = 1
	group.GroupTransparency = 1
	group.Parent = gui

	local row = Instance.new("Frame")
	row.AnchorPoint = Vector2.new(0.5, 0.5)
	row.Position = UDim2.fromScale(0.5, 0.5)
	row.AutomaticSize = Enum.AutomaticSize.X
	row.Size = UDim2.fromOffset(0, 20)
	row.BackgroundTransparency = 1
	row.Parent = group
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	layout.Parent = row

	-- Key badge: outlined square that fills from the bottom while held.
	local badge = Instance.new("Frame")
	badge.LayoutOrder = 1
	badge.Size = UDim2.fromOffset(20, 20)
	badge.BackgroundColor3 = INK
	badge.BackgroundTransparency = 0.35
	badge.BorderSizePixel = 0
	badge.ClipsDescendants = true
	badge.Parent = row
	local stroke = Instance.new("UIStroke")
	stroke.Color = BONE
	stroke.Thickness = 1
	stroke.Transparency = 0.2
	stroke.Parent = badge

	local fill = Instance.new("Frame")
	fill.AnchorPoint = Vector2.new(0, 1)
	fill.Position = UDim2.fromScale(0, 1)
	fill.Size = UDim2.fromScale(1, 0)
	fill.BackgroundColor3 = BONE
	fill.BackgroundTransparency = 0.25
	fill.BorderSizePixel = 0
	fill.ZIndex = 1
	fill.Parent = badge

	local key = Instance.new("TextLabel")
	key.Size = UDim2.fromScale(1, 1)
	key.BackgroundTransparency = 1
	key.Font = Enum.Font.GothamMedium
	key.TextSize = 11
	key.TextColor3 = BONE
	key.Text = keyLabel(prompt, inputType)
	key.ZIndex = 2
	key.Parent = badge

	local label = Instance.new("TextLabel")
	label.LayoutOrder = 2
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.fromOffset(0, 20)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 11
	label.TextColor3 = BONE
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = if prompt.ObjectText ~= "" then prompt.ActionText .. "  ·  " .. prompt.ObjectText else prompt.ActionText
	label.Parent = row
	local shadow = Instance.new("UIStroke")
	shadow.Color = INK
	shadow.Thickness = 1
	shadow.Transparency = 0.4
	shadow.Parent = label

	gui.Parent = playerGui
	TweenService:Create(group, FADE_IN, { GroupTransparency = 0.1 }):Play()
	return { gui = gui, group = group, fill = fill, badge = badge }
end

local function hide(prompt: ProximityPrompt)
	local entry = active[prompt]
	if not entry then
		return
	end
	active[prompt] = nil
	local tween = TweenService:Create(entry.group, FADE_OUT, { GroupTransparency = 1 })
	tween.Completed:Once(function()
		entry.gui:Destroy()
	end)
	tween:Play()
end

ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
	if prompt.Style ~= Enum.ProximityPromptStyle.Custom then
		return
	end
	if active[prompt] then
		hide(prompt)
	end
	active[prompt] = build(prompt, inputType)
end)

ProximityPromptService.PromptHidden:Connect(hide)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
	local entry = active[prompt]
	if entry then
		TweenService:Create(entry.fill, TweenInfo.new(prompt.HoldDuration, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(1, 1) }):Play()
	end
end)

ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt)
	local entry = active[prompt]
	if entry then
		TweenService:Create(entry.fill, TweenInfo.new(0.1), { Size = UDim2.fromScale(1, 0) }):Play()
	end
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt)
	local entry = active[prompt]
	if entry then
		-- small confirmation pulse before it goes away
		TweenService:Create(entry.badge, TweenInfo.new(0.08, Enum.EasingStyle.Sine), { Size = UDim2.fromOffset(24, 24) }):Play()
	end
end)
