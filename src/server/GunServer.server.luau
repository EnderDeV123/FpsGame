local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local ShootServiceUtils = require(ServerScriptService.Utils.ShootServiceUtils)
local ShootServer = require(ServerScriptService.Services.ShootServiceServer)
local GunConfig = require(ReplicatedStorage.Shared.Configs.GunConfig)

local RemotesFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")

local ShootEvent = ShootServiceUtils:CreateUtils()
local ReloadEvent = RemotesFolder:WaitForChild("ReloadEvent")
local UpdateAmmoEvent = RemotesFolder:WaitForChild("UpdateAmmoEvent")

-------------------------------------------------
-- LOOKUP
-------------------------------------------------
local GunLookup = {}
for _, v in pairs(GunConfig.Guns) do
	GunLookup[v.Id] = v
end

local function GetGunById(id)
	return GunLookup[id]
end

-------------------------------------------------
-- AMMO STORAGE (MAG + RESERVE)
-------------------------------------------------
local PlayerAmmo = {}

local function InitGunAmmo(player, gunId)
	PlayerAmmo[player] = PlayerAmmo[player] or {}

	if not PlayerAmmo[player][gunId] then
		local gunData = GetGunById(gunId)
		if not gunData then return end

		PlayerAmmo[player][gunId] = {
			Current = gunData.actualGun.MaxAmmo,
			Reserve = gunData.actualGun.Totalammo
		}
	end

	return PlayerAmmo[player][gunId]
end


local function ReloadGun(player, gunId)
	local gunData = GetGunById(gunId)
	if not gunData then return end

	local ammoData = InitGunAmmo(player, gunId)
	if not ammoData then return end

	local maxAmmo = gunData.actualGun.MaxAmmo

	local needed = maxAmmo - ammoData.Current
	if needed <= 0 then return end
	if ammoData.Reserve <= 0 then return end

	local toLoad = math.min(needed, ammoData.Reserve)

	ammoData.Current += toLoad
	ammoData.Reserve -= toLoad

	UpdateAmmoEvent:FireClient(
		player,
		ammoData.Current,
		ammoData.Reserve,
		gunData.actualGun.Name
	)
end

-------------------------------------------------
-- SHOOT
-------------------------------------------------
ShootEvent.OnServerEvent:Connect(function(player, origin, direction, gunId)

	if typeof(origin) ~= "Vector3" then return end
	if typeof(direction) ~= "Vector3" then return end

	local gunData = GetGunById(gunId)
	if not gunData then return end

	local ammoData = InitGunAmmo(player, gunId)
	if not ammoData then return end

	-- ❌ EMPTY MAG → AUTO RELOAD
	if ammoData.Current <= 0 then
		if ammoData.Reserve > 0 then
			ReloadGun(player, gunId)
		end
		return
	end

	-- 🔥 USE BULLET
	ammoData.Current -= 1

	local damage = gunData.actualGun.Damage or 10
	ShootServer:Shoot(player, origin, direction, 1000, damage)

	-- UPDATE UI AFTER SHOT
	UpdateAmmoEvent:FireClient(
		player,
		ammoData.Current,
		ammoData.Reserve,
		gunData.actualGun.Name
	)

	-- 🔁 AUTO RELOAD AFTER LAST BULLET
	if ammoData.Current <= 0 and ammoData.Reserve > 0 then
		task.delay(1.5, function()
	        ReloadGun(player, gunId)
        end)
	end
end)

-------------------------------------------------
-- RELOAD
-------------------------------------------------
ReloadEvent.OnServerEvent:Connect(function(player, gunId)
	task.delay(1.5, function()
	    ReloadGun(player, gunId)
    end)
end)

-------------------------------------------------
-- CLEANUP
-------------------------------------------------
Players.PlayerRemoving:Connect(function(player)
	PlayerAmmo[player] = nil
end)