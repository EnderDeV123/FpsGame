local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ShootServer = require(ServerScriptService.Services.ShootServiceServer)
local GunConfig = require(ReplicatedStorage.Shared.Configs.GunConfig)

local RemotesFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local ShootEvent = RemotesFolder:WaitForChild("ShootEvent")
local ReloadEvent = RemotesFolder:WaitForChild("ReloadEvent")
local UpdateAmmoEvent = RemotesFolder:WaitForChild("UpdateAmmoEvent")
local UpdateAmmoRequestEvent = RemotesFolder:WaitForChild("UpdateAmmoRequestEvent")

-------------------------------------------------
-- GUN LOOKUP
-------------------------------------------------
local GunLookup = {}
for _, v in pairs(GunConfig.Guns) do
	GunLookup[v.Id] = v
end

local function GetGunById(id)
	return GunLookup[id]
end

-------------------------------------------------
-- PLAYER AMMO
-------------------------------------------------
local PlayerAmmo = {}

local function InitGunAmmo(player, gunId)
	PlayerAmmo[player] = PlayerAmmo[player] or {}

	if not PlayerAmmo[player][gunId] then
		local gunData = GetGunById(gunId)
		if not gunData then
			return
		end

		PlayerAmmo[player][gunId] = {
			Current = gunData.actualGun.MaxAmmo,
			Reserve = gunData.actualGun.Totalammo,
		}
	end

	return PlayerAmmo[player][gunId]
end

-------------------------------------------------
-- SEND AMMO
-------------------------------------------------
local function SendAmmo(player, gunId)
	local gunData = GetGunById(gunId)
	local ammoData = InitGunAmmo(player, gunId)

	if gunData and ammoData then
		UpdateAmmoEvent:FireClient(player, ammoData.Current, ammoData.Reserve, gunData.actualGun.Name)
	end
end

-------------------------------------------------
-- RELOAD
-------------------------------------------------
local function ReloadGun(player, gunId)
	local gunData = GetGunById(gunId)
	if not gunData then
		return
	end

	local ammoData = InitGunAmmo(player, gunId)
	if not ammoData then
		return
	end

	local maxAmmo = gunData.actualGun.MaxAmmo
	local needed = maxAmmo - ammoData.Current

	if needed <= 0 or ammoData.Reserve <= 0 then
		return
	end

	local toLoad = math.min(needed, ammoData.Reserve)

	ammoData.Current += toLoad
	ammoData.Reserve -= toLoad

	SendAmmo(player, gunId)
end

-------------------------------------------------
-- SHOOT
-------------------------------------------------
ShootEvent.OnServerEvent:Connect(function(player, origin, direction, gunId)
	if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
		return
	end

	local gunData = GetGunById(gunId)
	if not gunData then
		return
	end

	local ammoData = InitGunAmmo(player, gunId)
	if not ammoData then
		return
	end

	-- 🔥 HARD BLOCK
	if ammoData.Current <= 0 then
		if ammoData.Reserve > 0 then
			ReloadGun(player, gunId)
		end
		return
	end

	-- 🔥 CONSUME AMMO
	ammoData.Current -= 1

	local char = player.Character
	if not char then
		return
	end

	local damage = gunData.actualGun.Damage or 10

	-- shoot logic
	ShootServer:Shoot(player, origin, direction, 1000, damage)

	-- visuals
	ShootEvent:FireAllClients(origin, direction)

	-- update UI
	SendAmmo(player, gunId)

	-- auto reload
	if ammoData.Current <= 0 and ammoData.Reserve > 0 then
		task.delay(1.5, function()
			ReloadGun(player, gunId)
		end)
	end
end)

-------------------------------------------------
-- RELOAD EVENT
-------------------------------------------------
ReloadEvent.OnServerEvent:Connect(function(player, gunId)
	task.delay(1.5, function()
		ReloadGun(player, gunId)
	end)
end)

-------------------------------------------------
-- REQUEST AMMO
-------------------------------------------------
UpdateAmmoRequestEvent.OnServerEvent:Connect(function(player, tool)
	if not tool or not tool:IsA("Tool") then
		return
	end

	local gunId = tool:GetAttribute("Id")
	if not gunId then
		return
	end

	SendAmmo(player, gunId)
end)

-------------------------------------------------
-- PLAYER CLEANUP
-------------------------------------------------
Players.PlayerRemoving:Connect(function(player)
	PlayerAmmo[player] = nil
end)
