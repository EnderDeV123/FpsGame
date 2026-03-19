local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BulletTrailService = require(ReplicatedStorage.Shared.Services.BulletTrailService)

local RemotesFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")

local Gun = {}
Gun.__index = Gun

function Gun.new(newTable)
	local NewGun = setmetatable(newTable or {}, Gun)
	NewGun.Name = NewGun.Name or "Pistol"
	NewGun.DebounceTime = NewGun.DebounceTime or 0.1
	NewGun.Damage = NewGun.Damage or 10
	NewGun.recoil = NewGun.recoil or 0.5
	return NewGun
end

function Gun:Fire(GunModel: Tool)
	local player = Players.LocalPlayer
	if not player then
		return
	end

	local ShootEvent = RemotesFolder:WaitForChild("ShootEvent")

	local camera = workspace.CurrentCamera
	local mouse = player:GetMouse()

	local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y)

	local origin = unitRay.Origin
	local direction = unitRay.Direction

	-- ✅ FIX: SEND gunId
	local gunId = GunModel:GetAttribute("Id")
	if not gunId then
		warn("Gun has no Id attribute")
		return
	end

	ShootEvent:FireServer(origin, direction, gunId)

	self:PlayGfx(GunModel, direction)
end

function Gun:PlayGfx(Gunmodel: Tool, direction)
	local BulletGFX = ReplicatedStorage:WaitForChild("GFX"):WaitForChild("BulletTrail"):Clone()
	BulletGFX.Anchored = true
	BulletGFX.Parent = workspace

	local BulletPos = Gunmodel:FindFirstChild("BulletPos") or Gunmodel:FindFirstChild("Handle")
	if not BulletPos then
		warn("No BulletPos or Handle found")
		return
	end

	local origin = BulletPos.Position
	BulletTrailService:MoveBullet(BulletGFX, origin, direction)
	--make sure this script is here
end

return Gun
