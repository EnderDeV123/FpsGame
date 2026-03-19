local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShootService = require(ReplicatedStorage.Shared.Services.ShootService)

local ShootServer = {}

function ShootServer:Shoot(player: Player, origin: Vector3, direction: Vector3, maxDistance: number, damage: number, rayparams: RaycastParams)

	if typeof(origin) ~= "Vector3" then return end
	if typeof(direction) ~= "Vector3" then return end

	local character = player.Character
	if not character then return end

	direction = direction.Unit -- 🔥 FIX

	if not rayparams then
		rayparams = RaycastParams.new()
		rayparams.FilterType = Enum.RaycastFilterType.Blacklist
		rayparams.IgnoreWater = true
		rayparams.FilterDescendantsInstances = {character}
	end

	local result = ShootService:Shoot(origin, direction, maxDistance, rayparams)

	if result then
		print(player.Name .. " hit:", result.Instance.Name)

		local hitPart = result.Instance
		local character = hitPart:FindFirstAncestorWhichIsA("Model")

		if character then
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")
			if humanoid then
				print("Damage applied:", damage)
				humanoid:TakeDamage(damage)
			end
		end
	end

	return result
end

return ShootServer