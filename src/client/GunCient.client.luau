local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Gun = require(ReplicatedStorage.Shared.Classes.Gun)
local GunConfig = require(ReplicatedStorage.Shared.Configs.GunConfig)

local RemotesFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local ShootEvent = RemotesFolder:WaitForChild("ShootEvent")
local ReloadEvent = RemotesFolder:WaitForChild("ReloadEvent")
local UpdateAmmoEvent = RemotesFolder:WaitForChild("UpdateAmmoEvent")
local UpdateAmmoRequestEvent = RemotesFolder:WaitForChild("UpdateAmmoRequestEvent")
local GetDebounceBindable = RemotesFolder:WaitForChild("GetDebounceBindable")
local GetShootBindable = RemotesFolder:WaitForChild("GetShootBindable")
local GetReloadBindable = RemotesFolder:WaitForChild("GetReloadBindable")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-------------------------------------------------
-- STATE
-------------------------------------------------
local CurrentAmmo = 0
local ReserveAmmo = 0

local CurrentGunObject = nil
local CurrentGunId = nil
local gunData = nil

local Holding = false
local Reloading = false
local CanShoot = true

-- 🔥 NEW (IMPORTANT)
local TriedToShootEmpty = false

-------------------------------------------------
-- CHARACTER
-------------------------------------------------
local Char = Player.Character or Player.CharacterAdded:Wait()

Player.CharacterAdded:Connect(function(c)
	Char = c
	CurrentGunObject = nil
	CurrentGunId = nil
end)

-------------------------------------------------
-- AMMO SYNC
-------------------------------------------------
UpdateAmmoEvent.OnClientEvent:Connect(function(current, reserve)
	CurrentAmmo = current or 0
	ReserveAmmo = reserve or 0
end)

-------------------------------------------------
-- HELPERS
-------------------------------------------------
local function GetGunTool()
	if not Char then
		return nil
	end

	for _, v in ipairs(Char:GetChildren()) do
		if v:IsA("Tool") and v:GetAttribute("isGun") then
			return v
		end
	end

	return nil
end

local function GetGunFromConfig(tool)
	if not tool then
		return nil
	end

	local id = tool:GetAttribute("Id")
	if not id then
		return nil
	end

	for _, v in pairs(GunConfig.Guns) do
		if v.Id == id then
			return v
		end
	end

	return nil
end

-------------------------------------------------
-- RECOIL
-------------------------------------------------
local function ApplyRecoil(amount)
	local recoilX = math.rad(-amount * 5)
	local recoilY = math.rad(math.random(-amount * 2, amount * 2))
	Camera.CFrame = Camera.CFrame * CFrame.Angles(recoilX, recoilY, 0)
end

-------------------------------------------------
-- RELOAD FUNCTION (CLIENT CONTROLLED)
-------------------------------------------------
local function StartReload(gunId)
	if Reloading then
		return
	end
	if not gunData then
		return
	end
	if CurrentAmmo >= gunData.actualGun.MaxAmmo then
		return
	end
	if ReserveAmmo <= 0 then
		return
	end

	Reloading = true
	CanShoot = false
	TriedToShootEmpty = false

	local reloadTime = gunData.actualGun.ReloadTime or 1.5

	GetReloadBindable:Fire(gunData.actualGun.Animations.ReloadAnimation)

	task.delay(reloadTime, function()
		if not Player.Character then
			return
		end

		ReloadEvent:FireServer(gunId)

		Reloading = false
		CanShoot = true
	end)
end

-------------------------------------------------
-- SHOOT LOOP
-------------------------------------------------
local function ShootLoop()
	while Holding do
		local tool = GetGunTool()
		if not tool then
			break
		end

		gunData = GetGunFromConfig(tool)
		if not gunData or not gunData.actualGun then
			break
		end

		local gunId = tool:GetAttribute("Id")
		if not gunId then
			break
		end

		if not CurrentGunObject or CurrentGunId ~= gunId then
			CurrentGunObject = Gun.new(gunData.actualGun)
			CurrentGunId = gunId
		end

		-- 🔥 EMPTY MAG LOGIC (FIXED)
		if CurrentAmmo <= 0 then
			if not TriedToShootEmpty then
				-- first click → just mark
				TriedToShootEmpty = true
			else
				-- second click → reload
				if ReserveAmmo > 0 then
					StartReload(gunId)
				end
			end

			break
		end

		if not CanShoot then
			task.wait()
			continue
		end

		CanShoot = false
		TriedToShootEmpty = false

		-- FIRE
		if CurrentGunObject and CurrentGunObject.Fire then
			CurrentGunObject:Fire(tool)
			GetShootBindable:Fire(gunData.actualGun.Animations.ShootAnimation)
		end

		local origin = Camera.CFrame.Position
		local direction = Camera.CFrame.LookVector

		ShootEvent:FireServer(origin, direction, gunId)

		ApplyRecoil(gunData.actualGun.recoil or 0.2)

		GetDebounceBindable:Fire(gunData.actualGun.Animations.DebounceAnimation)

		task.delay(gunData.actualGun.DebounceTime or 0.2, function()
			CanShoot = true
		end)

		task.wait()
	end
end

-------------------------------------------------
-- INPUT
-------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then
		return
	end

	-- SHOOT
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if Holding then
			return
		end

		Holding = true
		task.spawn(ShootLoop)
	end

	-- RELOAD (MANUAL)
	if input.KeyCode == Enum.KeyCode.R then
		local tool = GetGunTool()
		if not tool then
			return
		end

		local gunId = tool:GetAttribute("Id")
		if not gunId then
			return
		end

		StartReload(gunId)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Holding = false
	end
end)

-------------------------------------------------
-- TOOL EQUIP
-------------------------------------------------
Char.ChildAdded:Connect(function(child)
	if child:IsA("Tool") and child:GetAttribute("isGun") then
		CurrentGunObject = nil
		CurrentGunId = nil
		TriedToShootEmpty = false

		local gunId = child:GetAttribute("Id")
		if gunId then
			UpdateAmmoRequestEvent:FireServer(child)
		end
	end
end)
