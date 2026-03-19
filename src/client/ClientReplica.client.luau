local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BulletTrailService = require(ReplicatedStorage.Shared.Services.BulletTrailService)
local RemoteFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")

local ShootEvent: RemoteEvent = RemoteFolder:WaitForChild("ShootEvent")

ShootEvent.OnClientEvent:Connect(function(origin, direction)
	local Bullet = ReplicatedStorage:WaitForChild("GFX"):WaitForChild("BulletTrail"):Clone()
	Bullet.Parent = workspace
	BulletTrailService:MoveBullet(Bullet, origin, direction)
end)
