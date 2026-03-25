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
local GetDebounceBindable: BindableEvent = RemotesFolder:WaitForChild("GetDebounceBindable")
local GetShootBindable: BindableEvent = RemotesFolder:WaitForChild("GetShootBindable")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-------------------------------------------------
-- STATE
-------------------------------------------------
local CurrentAmmo = 0
local ReserveAmmo = 0
local CurrentGunObject = nil
local CurrentGunId = nil

local Holding = false
local Reloading = false
local CanShoot = true

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
-- RECOIL (FIXED)
-------------------------------------------------
local function ApplyRecoil(amount)
	if not Camera then
		return
	end

	local recoilX = math.rad(-amount * 5)
	local recoilY = math.rad(math.random(-amount * 2, amount * 2))

	Camera.CFrame = Camera.CFrame * CFrame.Angles(recoilX, recoilY, 0)
end

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
-- SHOOT LOOP (FULLY SAFE)
-------------------------------------------------
local function ShootLoop()
	while Holding do
		local tool = GetGunTool()
		if not tool then
			break
		end

		local gunData = GetGunFromConfig(tool)
		if not gunData or not gunData.actualGun then
			break
		end

		local gunId = tool:GetAttribute("Id")
		if not gunId then
			break
		end

		-- create gun only if changed
		if not CurrentGunObject or CurrentGunId ~= gunId then
			CurrentGunObject = Gun.new(gunData.actualGun)
			CurrentGunId = gunId
		end

		-- no ammo → auto reload
		if CurrentAmmo <= 0 then
			if ReserveAmmo > 0 and not Reloading then
				Reloading = true
				ReloadEvent:FireServer(gunId)

				task.delay(1.5, function()
					Reloading = false
				end)
			end
			break
		end

		-- debounce
		if not CanShoot then
			task.wait()
			continue
		end

		CanShoot = false

		-- SAFE FIRE
		if CurrentGunObject and CurrentGunObject.Fire then
			CurrentGunObject:Fire(tool)
			local AnimationId = gunData.actualGun.Animations.ShootAnimation
			GetShootBindable:Fire(AnimationId)
		end

		-- SEND TO SERVER
		local origin = Camera.CFrame.Position
		local direction = Camera.CFrame.LookVector

		ShootEvent:FireServer(origin, direction, gunId)

		-- recoil
		ApplyRecoil(gunData.actualGun.recoil or 0.2)
		local DebounceAnimationId = gunData.actualGun.Animations.DebounceAnimation
		GetDebounceBindable:Fire(DebounceAnimationId)
		-- debounce reset
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

	-- RELOAD
	if input.KeyCode == Enum.KeyCode.R then
		if Reloading then
			return
		end

		local tool = GetGunTool()
		if not tool then
			return
		end

		local gunId = tool:GetAttribute("Id")
		if not gunId then
			return
		end

		Reloading = true
		ReloadEvent:FireServer(gunId)

		task.delay(1.5, function()
			Reloading = false
		end)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Holding = false
	end
end)

-------------------------------------------------
-- TOOL EQUIP (FIXED)
-------------------------------------------------
Char.ChildAdded:Connect(function(child)
	if child:IsA("Tool") and child:GetAttribute("isGun") then
		CurrentGunObject = nil
		CurrentGunId = nil

		local gunId = child:GetAttribute("Id")
		if gunId then
			UpdateAmmoRequestEvent:FireServer(child)
		end
	end
end)
