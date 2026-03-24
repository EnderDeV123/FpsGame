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
-- PLAYER AMMO STORAGE
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
-- SEND INITIAL AMMO
-------------------------------------------------
local function UpdateAllAmmo(player)
	for _, gunData in pairs(GunConfig.Guns) do
		local ammoData = InitGunAmmo(player, gunData.Id)
		if ammoData then
			UpdateAmmoEvent:FireClient(player, ammoData.Current, ammoData.Reserve, gunData.actualGun.Name)
		end
	end
end

-------------------------------------------------
-- RELOAD FUNCTION
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

	UpdateAmmoEvent:FireClient(player, ammoData.Current, ammoData.Reserve, gunData.actualGun.Name)
end

-------------------------------------------------
-- GET BULLET ORIGIN
-------------------------------------------------
local function GetGunBulletPos(Char)
	for _, tool in ipairs(Char:GetChildren()) do
		if tool:IsA("Tool") then
			return tool:FindFirstChild("BulletPos") or tool:FindFirstChild("Handle")
		end
	end
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

	-- AUTO RELOAD IF EMPTY
	if ammoData.Current <= 0 and ammoData.Reserve > 0 then
		ReloadGun(player, gunId)
		return
	end

	-- FIRE BULLET
	ammoData.Current -= 1

	local damage = gunData.actualGun.Damage or 10
	local Char = player.Character
	if not Char then
		return
	end

	local BulletPart = GetGunBulletPos(Char)
	local bulletOrigin = BulletPart and BulletPart.CFrame.Position or origin

	-- Server handles shooting/damage
	ShootServer:Shoot(player, bulletOrigin, direction, 1000, damage)

	-- Notify clients for visuals
	ShootEvent:FireAllClients(bulletOrigin, direction)

	-- Update player's UI
	UpdateAmmoEvent:FireClient(player, ammoData.Current, ammoData.Reserve, gunData.actualGun.Name)

	-- AUTO RELOAD AFTER LAST BULLET
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
-- EQUIP LISTENER: Update ammo when player equips tool
-------------------------------------------------
local function SetupEquipListener(player)
	local function onChar(char)
		local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
		if not humanoid then
			return
		end

		humanoid.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				local gunName = child.Name
				for _, gunData in pairs(GunConfig.Guns) do
					if gunData.actualGun.Name == gunName then
						local ammoData = InitGunAmmo(player, gunData.Id)
						if ammoData then
							UpdateAmmoEvent:FireClient(player, ammoData.Current, ammoData.Reserve, gunName)
						end
						break
					end
				end
			end
		end)
	end

	if player.Character then
		onChar(player.Character)
	end
	player.CharacterAdded:Connect(onChar)
end

-------------------------------------------------
-- HANDLE CLIENT REQUEST FOR AMMO
-------------------------------------------------
UpdateAmmoRequestEvent.OnServerEvent:Connect(function(player, gunTool)
	if not gunTool or not gunTool:IsA("Tool") then
		return
	end

	local gunId = gunTool:GetAttribute("Id")
	if not gunId then
		return
	end

	local ammoData = InitGunAmmo(player, gunId)
	if ammoData then
		UpdateAmmoEvent:FireClient(player, ammoData.Current, ammoData.Reserve, gunTool.Name)
	end
end)

-------------------------------------------------
-- PLAYER JOIN
-------------------------------------------------
Players.PlayerAdded:Connect(function(player)
	UpdateAllAmmo(player)
	SetupEquipListener(player)
end)

for _, player in pairs(Players:GetPlayers()) do
	UpdateAllAmmo(player)
	SetupEquipListener(player)
end

-------------------------------------------------
-- CLEANUP
-------------------------------------------------
Players.PlayerRemoving:Connect(function(player)
	PlayerAmmo[player] = nil
end)
