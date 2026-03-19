local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Gun = require(ReplicatedStorage.Shared.Classes.Gun)
local GunConfig = require(ReplicatedStorage.Shared.Configs.GunConfig)

local RemotesFolder = ReplicatedStorage.Shared.Remotes
local ReloadEvent = RemotesFolder:WaitForChild("ReloadEvent")
local UpdateAmmoEvent = RemotesFolder:WaitForChild("UpdateAmmoEvent")

local Player = game.Players.LocalPlayer

-------------------------------------------------
-- CHARACTER UPDATE (FIX)
-------------------------------------------------
local Char

local function UpdateChar()
	Char = Player.Character or Player.CharacterAdded:Wait()
end

UpdateChar()
Player.CharacterAdded:Connect(UpdateChar)

-------------------------------------------------
-- HELPERS
-------------------------------------------------
local function GetGunTool()
	for _, v in ipairs(Char:GetChildren()) do
		if v:IsA("Tool") and v:GetAttribute("isGun") then
			return v
		end
	end
end

local function GetGunFromConfig(GunTool)
	for _, v in pairs(GunConfig.Guns) do
		if GunTool:GetAttribute("Id") == v.Id then
			return v
		end
	end
end

-------------------------------------------------
-- HOLD SHOOT
-------------------------------------------------
local Holding = false

local function ShootLoop()
	while Holding do
		local GunTool = GetGunTool()

		if not GunTool or GunTool.Parent ~= Char then
			break
		end

		local GunData = GetGunFromConfig(GunTool)
		if not GunData then break end

		local gun = Gun.new(GunData.actualGun)
		gun:Fire(GunTool)

		task.wait(GunData.actualGun.DebounceTime or 0.2)
	end
end

-------------------------------------------------
-- INPUT
-------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if Holding then return end
		Holding = true
		task.spawn(ShootLoop)
	end

	if input.KeyCode == Enum.KeyCode.R then
		local GunTool = GetGunTool()
		if not GunTool then return end

		local gunId = GunTool:GetAttribute("Id")
		ReloadEvent:FireServer(gunId)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Holding = false
	end
end)

-------------------------------------------------
-- AMMO UI
-------------------------------------------------
UpdateAmmoEvent.OnClientEvent:Connect(function(current, reserve, gunname)
	print(gunname .. " | Ammo: " .. current .. "/" .. reserve)
end)