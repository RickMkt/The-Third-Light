--!strict
-- Server-authoritative 3-slot inventory built on Roblox Tools.
--  * Item templates live in ServerStorage.Items (Tool with a Handle).
--  * World pickups are parts under Workspace.Environment.Items carrying an
--    "ItemName" attribute and a ProximityPrompt.
--  * Picking up clones the template into the player's Backpack and assigns a
--    stable "Slot" attribute; dropping turns the Tool back into a pickup.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local InventoryConfig = require(Shared:WaitForChild("InventoryConfig"))
local Remotes = Shared:WaitForChild("InventoryRemotes")
local DropItem = Remotes:WaitForChild("DropItem") :: RemoteEvent
local InventoryMessage = Remotes:WaitForChild("InventoryMessage") :: RemoteEvent

local ItemTemplates = ServerStorage:WaitForChild("Items")
local Gameplay = workspace:WaitForChild("TheThirdLight"):WaitForChild("Gameplay")
local WorldItems = Gameplay:WaitForChild("Items")
local ItemSpawns = Gameplay:WaitForChild("Interactions"):WaitForChild("ItemSpawns")

local function getTools(player: Player): { Tool }
	local tools = {}
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, child in ipairs(backpack:GetChildren()) do
			if child:IsA("Tool") then
				table.insert(tools, child)
			end
		end
	end
	if player.Character then
		for _, child in ipairs(player.Character:GetChildren()) do
			if child:IsA("Tool") then
				table.insert(tools, child)
			end
		end
	end
	return tools
end

local function firstFreeSlot(tools: { Tool }): number?
	local used = {}
	for _, tool in ipairs(tools) do
		local slot = tool:GetAttribute("Slot")
		if typeof(slot) == "number" then
			used[slot] = true
		end
	end
	for slot = 1, InventoryConfig.MaxSlots do
		if not used[slot] then
			return slot
		end
	end
	return nil
end

-- World-space lowest point of a model (parts may be rotated, so sample corners).
local function lowestPoint(model: Model): number
	local minY = math.huge
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local half = part.Size / 2
			for _, sx in ipairs({ -1, 1 }) do
				for _, sy in ipairs({ -1, 1 }) do
					for _, sz in ipairs({ -1, 1 }) do
						local y = (part.CFrame * CFrame.new(half.X * sx, half.Y * sy, half.Z * sz)).Position.Y
						if y < minY then
							minY = y
						end
					end
				end
			end
		end
	end
	return minY
end

local function rootPosition(player: Player): Vector3?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root.Position else nil
end

-- Creates a world pickup for `itemName` resting on the ground at `position`.
-- The pickup is a Model holding copies of the tool's parts (so multi-part
-- tools keep their shape), with the prompt on the Handle copy.
local function spawnPickup(itemName: string, position: Vector3): Model?
	local template = ItemTemplates:FindFirstChild(itemName)
	local handle = template and template:FindFirstChild("Handle")
	if not template or not handle or not handle:IsA("BasePart") then
		return nil
	end

	local model = Instance.new("Model")
	model.Name = itemName
	model:SetAttribute("ItemName", itemName)
	local part: BasePart? = nil
	for _, child in ipairs(template:GetChildren()) do
		if child:IsA("BasePart") then
			local copy = child:Clone()
			for _, sub in ipairs(copy:GetChildren()) do
				if sub:IsA("WeldConstraint") or sub:IsA("Sound") or sub:IsA("Light") then
					sub:Destroy()
				end
			end
			copy.Anchored = true
			copy.CanCollide = false
			copy.CanTouch = false
			copy.Parent = model
			if child.Name == "Handle" then
				part = copy
			end
		end
	end
	if not part then
		model:Destroy()
		return nil
	end
	model.PrimaryPart = part

	local ignore: { Instance } = { WorldItems }
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			table.insert(ignore, player.Character)
		end
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignore
	local hit = workspace:Raycast(position + Vector3.new(0, 3, 0), Vector3.new(0, -30, 0), params)
	local groundY = if hit then hit.Position.Y else position.Y
	-- Orientation per item (PickupRotation, degrees; default: on its side) and
	-- optional PickupScale, then lift so the lowest point touches the ground.
	local rotation = template:GetAttribute("PickupRotation")
	local angles = if typeof(rotation) == "Vector3"
		then CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
		else CFrame.Angles(math.pi / 2, math.random() * math.pi * 2, 0)
	local scale = template:GetAttribute("PickupScale")
	if typeof(scale) == "number" and scale > 0 then
		model:ScaleTo(scale)
	end
	model:PivotTo(CFrame.new(position.X, groundY + 2, position.Z) * angles)
	model:PivotTo(model:GetPivot() + Vector3.new(0, groundY - lowestPoint(model) + 0.02, 0))

	local prompt = Instance.new("ProximityPrompt")
	prompt.Style = Enum.ProximityPromptStyle.Custom
	prompt.ActionText = "Pegar"
	prompt.ObjectText = itemName
	prompt.KeyboardKeyCode = InventoryConfig.PickupKey
	prompt.HoldDuration = InventoryConfig.PickupHoldSeconds
	prompt.MaxActivationDistance = InventoryConfig.PickupDistance
	prompt.RequiresLineOfSight = false
	prompt.Parent = part

	model.Parent = WorldItems
	return model
end

local function tryPickup(player: Player, pickup: Model)
	local itemName = pickup:GetAttribute("ItemName")
	if typeof(itemName) ~= "string" or not pickup.Parent then
		return
	end
	local position = rootPosition(player)
	if not position or (position - pickup:GetPivot().Position).Magnitude > InventoryConfig.ServerPickupRange then
		return
	end

	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then
		return
	end
	local slot = firstFreeSlot(getTools(player))
	if not slot then
		InventoryMessage:FireClient(player, "Você não consegue carregar mais nada.")
		return
	end
	local template = ItemTemplates:FindFirstChild(itemName)
	if not template then
		return
	end

	-- Claim the pickup first so two players cannot both take it.
	pickup.Parent = nil
	local tool = template:Clone()
	tool:SetAttribute("Slot", slot)
	tool.Parent = backpack
	pickup:Destroy()

	-- What you just grabbed is in your hand.
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid:EquipTool(tool)
	end
end

local function hookPickup(pickup: Instance)
	if not pickup:IsA("Model") then
		return
	end
	local prompt = pickup:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then
		return
	end
	prompt.Triggered:Connect(function(player)
		tryPickup(player, pickup)
	end)
end

local function onDrop(player: Player, toolName: unknown)
	if typeof(toolName) ~= "string" then
		return
	end
	local tool: Tool? = nil
	for _, candidate in ipairs(getTools(player)) do
		if candidate.Name == toolName then
			tool = candidate
			break
		end
	end
	local position = rootPosition(player)
	if not tool or not position then
		return
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local forward = if root then root.CFrame.LookVector else Vector3.zAxis
	local dropAt = position + forward * 2.5

	if spawnPickup(tool.Name, dropAt) then
		tool:Destroy()
	end
end

WorldItems.ChildAdded:Connect(hookPickup)
for _, part in ipairs(WorldItems:GetChildren()) do
	hookPickup(part)
end
DropItem.OnServerEvent:Connect(onDrop)

-- Items start on the spawn markers (Gameplay.Interactions.ItemSpawns): each
-- marker part carries an "ItemName" attribute saying what appears there.
for _, marker in ipairs(ItemSpawns:GetChildren()) do
	local itemName = marker:GetAttribute("ItemName")
	if marker:IsA("BasePart") and typeof(itemName) == "string" then
		spawnPickup(itemName, marker.Position)
	end
end
