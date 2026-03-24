local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Gun = require(ReplicatedStorage.Shared.Classes.Gun)
local GunConfig = require(ReplicatedStorage.Shared.Configs.GunConfig)

local RemotesFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local ReloadEvent = RemotesFolder:WaitForChild("ReloadEvent")
local UpdateAmmoEvent = RemotesFolder:WaitForChild("UpdateAmmoEvent")

local UpdateAmmoRequestEvent: RemoteEvent = RemotesFolder:WaitForChild("UpdateAmmoRequestEvent")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-------------------------------------------------
-- STATE
-------------------------------------------------
local CurrentAmmo = 30 -- default so gun works instantly
local ReserveAmmo = 90
local CurrentGunName = ""

local Holding = false
local Reloading = false
local CurrentGunObject = nil

-------------------------------------------------
-- CHARACTER
-------------------------------------------------
local Char = Player.Character or Player.CharacterAdded:Wait()

local function UpdateChar()
	Char = Player.Character or Player.CharacterAdded:Wait()
end

UpdateChar()
Player.CharacterAdded:Connect(UpdateChar)

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

local function GetGunFromConfig(GunTool)
	if not GunTool then
		return nil
	end

	for _, v in pairs(GunConfig.Guns) do
		if GunTool:GetAttribute("Id") == v.Id then
			return v
		end
	end

	return nil
end

-------------------------------------------------
-- 🔥 RECOIL (FIXED)
-------------------------------------------------
local recoilOffset = Vector2.new(0, 0)
local recoilRecoverySpeed = 10

RunService.RenderStepped:Connect(function(dt)
	recoilOffset = recoilOffset:Lerp(Vector2.new(0, 0), dt * recoilRecoverySpeed)

	local recoilCFrame = CFrame.Angles(math.rad(recoilOffset.Y), math.rad(recoilOffset.X), 0)

	Camera.CFrame = Camera.CFrame * recoilCFrame
end)

local function ApplyRecoil(amount)
	local randomX = (math.random() - 0.5) * 2
	recoilOffset += Vector2.new(randomX * amount * 0.5, amount)
end

-------------------------------------------------
-- SHOOT LOOP
-------------------------------------------------
local function ShootLoop()
	while Holding do
		local GunTool = GetGunTool()
		if not GunTool or GunTool.Parent ~= Char then
			break
		end

		local GunData = GetGunFromConfig(GunTool)
		if not GunData then
			break
		end

		-- create gun once
		if not CurrentGunObject then
			CurrentGunObject = Gun.new(GunData.actualGun)
		end

		-- ❌ NO AMMO
		if CurrentAmmo <= 0 then
			if ReserveAmmo > 0 and not Reloading then
				Reloading = true
				ReloadEvent:FireServer(GunTool:GetAttribute("Id"))

				task.delay(1, function()
					Reloading = false
				end)
			end
			break
		end

		-- 🔥 FIRE
		print("Firing bullet")

		CurrentGunObject:Fire(GunTool)

		-- 🔥 RECOIL
		ApplyRecoil(GunData.actualGun.recoil or 0.2)

		task.wait(GunData.actualGun.DebounceTime or 0.2)
	end
end

-------------------------------------------------
-- INPUT
-------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if Holding then
			return
		end

		Holding = true
		task.spawn(ShootLoop)
	end

	if input.KeyCode == Enum.KeyCode.R then
		if Reloading then
			return
		end

		local GunTool = GetGunTool()
		if not GunTool then
			return
		end

		Reloading = true
		ReloadEvent:FireServer(GunTool:GetAttribute("Id"))

		task.delay(1, function()
			Reloading = false
		end)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Holding = false
	end
end)

Char.ChildAdded:Connect(function(child)
	if child:IsA("Tool") and child:GetAttribute("isGun") then
		UpdateAmmoRequestEvent:FireServer(child)
	end
end)
