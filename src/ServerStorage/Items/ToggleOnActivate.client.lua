--!strict
-- Left click toggles this light; the server owns the actual state.
-- (LocalScript inside the Tools "Lanterna" and "Lampião" in ServerStorage/Items)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToggleLight = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SoundRemotes"):WaitForChild("ToggleLight") :: RemoteEvent
local tool = script.Parent :: Tool
tool.Activated:Connect(function()
	ToggleLight:FireServer(tool)
end)
