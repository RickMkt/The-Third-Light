--!strict
-- Wavers every light tagged "FlickerLight" locally (flame-like, never a
-- strobe). Runs on each client so nothing about the flicker crosses the net.

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local TAG = "FlickerLight"
local lights: { [Light]: number } = {} -- light -> noise seed
local nextSeed = 1

local function track(instance: Instance)
	if instance:IsA("Light") then
		lights[instance] = nextSeed * 17.31
		nextSeed += 1
	end
end

local function untrack(instance: Instance)
	if instance:IsA("Light") then
		lights[instance] = nil
	end
end

for _, instance in ipairs(CollectionService:GetTagged(TAG)) do
	track(instance)
end
CollectionService:GetInstanceAddedSignal(TAG):Connect(track)
CollectionService:GetInstanceRemovedSignal(TAG):Connect(untrack)

RunService.Heartbeat:Connect(function()
	local t = os.clock()
	for light, seed in pairs(lights) do
		if not light.Enabled or not light.Parent then
			continue
		end
		local base = light:GetAttribute("BaseBrightness")
		local amount = light:GetAttribute("Flicker")
		local speed = light:GetAttribute("FlickerSpeed")
		if typeof(base) ~= "number" or typeof(amount) ~= "number" or typeof(speed) ~= "number" then
			continue
		end
		-- Two noise octaves: a slow breathing of the flame plus a faster sputter.
		local slow = math.noise(t * speed * 0.35, seed)
		local fast = math.noise(t * speed * 1.7, seed + 3.7) * 0.4
		light.Brightness = base * (1 + amount * (slow + fast))
	end
end)
