--!strict
-- Client side of the 3-slot inventory: hides Roblox's hotbar, renders the
-- slots from the Tools in Backpack/Character, and maps 1/2/3 to equip and
-- G to drop the held item.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local InventoryConfig = require(Shared:WaitForChild("InventoryConfig"))
local Remotes = Shared:WaitForChild("InventoryRemotes")
local DropItem = Remotes:WaitForChild("DropItem") :: RemoteEvent
local InventoryMessage = Remotes:WaitForChild("InventoryMessage") :: RemoteEvent

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local inventoryGui = playerGui:WaitForChild("InventoryGui") :: ScreenGui
local slotsBar = inventoryGui:WaitForChild("Slots") :: Frame
local messageLabel = inventoryGui:WaitForChild("Message") :: TextLabel

local slotFrames: { Frame } = {}
for i = 1, InventoryConfig.MaxSlots do
	slotFrames[i] = slotsBar:WaitForChild("Slot" .. i) :: Frame
end

-- Roblox's own hotbar would fight ours (and binds 1-9 itself).
local function disableCoreBackpack()
	local ok = pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)
	if not ok then
		task.delay(1, disableCoreBackpack)
	end
end
disableCoreBackpack()

local humanoid: Humanoid? = nil
local characterConnections: { RBXScriptConnection } = {}
local backpackConnections: { RBXScriptConnection } = {}
local lastChange = -math.huge
local barBrightness = 0
local lastMessage = -math.huge
local messageAlpha = 0

local function approach(current: number, target: number, speed: number, dt: number): number
	return current + (target - current) * (1 - math.exp(-speed * dt))
end

local function toolsBySlot(): { [number]: Tool }
	local result = {}
	local function scan(container: Instance?)
		if not container then
			return
		end
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("Tool") then
				local slot = child:GetAttribute("Slot")
				if typeof(slot) == "number" then
					result[slot] = child
				end
			end
		end
	end
	scan(player:FindFirstChildOfClass("Backpack"))
	scan(player.Character)
	return result
end

local function equippedTool(): Tool?
	local character = player.Character
	return if character then character:FindFirstChildOfClass("Tool") else nil
end

local function refresh()
	local tools = toolsBySlot()
	local held = equippedTool()
	for i, frame in ipairs(slotFrames) do
		local tool = tools[i]
		local label = frame:FindFirstChild("ItemName") :: TextLabel
		local outline = frame:FindFirstChild("Outline") :: UIStroke
		label.Text = if tool then tool.Name else ""
		local isHeld = tool ~= nil and tool == held
		outline.Thickness = if isHeld then 1.5 else 1
		outline.Transparency = if isHeld then 0.1 else 0.65
		frame.BackgroundTransparency = if isHeld then 0.35 else 0.55
	end
	lastChange = os.clock()
end

local function onSlotKey(index: number)
	local currentHumanoid = humanoid
	if not currentHumanoid or currentHumanoid.Health <= 0 then
		return
	end
	local tool = toolsBySlot()[index]
	if not tool then
		return
	end
	if tool == equippedTool() then
		currentHumanoid:UnequipTools()
	else
		currentHumanoid:EquipTool(tool)
	end
end

local function onDropKey()
	local tool = equippedTool()
	if tool then
		DropItem:FireServer(tool.Name)
	end
end

local function onAction(actionName: string, inputState: Enum.UserInputState): Enum.ContextActionResult
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if actionName == "InventoryDrop" then
		onDropKey()
	else
		local index = tonumber(string.match(actionName, "InventorySlot(%d+)"))
		if index then
			onSlotKey(index)
		end
	end
	return Enum.ContextActionResult.Sink
end

local function watch(container: Instance, connections: { RBXScriptConnection })
	table.insert(connections, container.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			refresh()
		end
	end))
	table.insert(connections, container.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			refresh()
		end
	end))
end

local function disconnectAll(connections: { RBXScriptConnection })
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)
end

local function onCharacterAdded(character: Model)
	disconnectAll(characterConnections)
	disconnectAll(backpackConnections)
	humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	if player.Character ~= character then
		return
	end
	watch(character, characterConnections)
	local backpack = player:WaitForChild("Backpack", 10)
	if backpack then
		watch(backpack, backpackConnections)
	end
	refresh()
end

local function onRenderStep(dt: number)
	local active = os.clock() - lastChange < InventoryConfig.ActiveHoldSeconds
	barBrightness = approach(barBrightness, if active then 1 else 0, InventoryConfig.FadeSpeed, dt)
	-- Fade the whole bar between its idle and active look.
	local idle = InventoryConfig.IdleTransparency
	for _, frame in ipairs(slotFrames) do
		local label = frame:FindFirstChild("ItemName") :: TextLabel
		local key = frame:FindFirstChild("Key") :: TextLabel
		label.TextTransparency = 0.15 + idle * (1 - barBrightness)
		key.TextTransparency = 0.5 + (idle * 0.6) * (1 - barBrightness)
	end

	local showMessage = os.clock() - lastMessage < InventoryConfig.ActiveHoldSeconds
	messageAlpha = approach(messageAlpha, if showMessage then 1 else 0, InventoryConfig.FadeSpeed, dt)
	messageLabel.TextTransparency = 1 - 0.85 * messageAlpha
end

for i, keyCode in ipairs(InventoryConfig.SlotKeys) do
	ContextActionService:BindAction("InventorySlot" .. i, onAction, false, keyCode)
end
ContextActionService:BindAction("InventoryDrop", onAction, false, InventoryConfig.DropKey)

InventoryMessage.OnClientEvent:Connect(function(text: string)
	messageLabel.Text = text
	lastMessage = os.clock()
	lastChange = os.clock()
end)

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
	onCharacterAdded(player.Character)
end
RunService.RenderStepped:Connect(onRenderStep)
