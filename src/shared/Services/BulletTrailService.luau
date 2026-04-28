local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MoveService = require(ReplicatedStorage.Shared.Services.MoveService)
local BulletTrailService = {}

function BulletTrailService:MoveBullet(bulletGfx: Instance, origin: Vector3, direction: Vector3)
	MoveService.MoveLinear(bulletGfx, origin, direction, 1000, {
		LifeTime = 1,
		Spin = Vector3.new(0, 360, 0),
		OnFinish = function()
			bulletGfx:Destroy()
		end,
	})
end

return BulletTrailService
