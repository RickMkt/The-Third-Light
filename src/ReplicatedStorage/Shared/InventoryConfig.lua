--!strict
-- Tuning for the 3-slot inventory.

local InventoryConfig = {
	MaxSlots = 3,
	SlotKeys = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three },
	DropKey = Enum.KeyCode.G,

	-- World pickups
	PickupKey = Enum.KeyCode.E,
	PickupDistance = 7, -- prompt activation range (studs)
	PickupHoldSeconds = 0.2,
	ServerPickupRange = 12, -- server-side sanity check

	-- UI
	IdleTransparency = 0.45, -- how faded the bar sits when nothing changes
	ActiveHoldSeconds = 2.5, -- time the bar stays bright after a change
	FadeSpeed = 5,
}

return InventoryConfig
