local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MoveService = require(ReplicatedStorage.Shared.Services.MoveService)
local BulletTrailService = {}

function BulletTrailService:MoveBullet(bulletGfx:Instance,origin:Vector3,direction:Vector3)
    MoveService.MoveLinear(bulletGfx,origin,direction,1000,function()
        bulletGfx:Destroy()
    end)
end

return BulletTrailService