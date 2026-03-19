local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Gun = require(ReplicatedStorage.Shared.Classes.Gun)
local GunConfig = require(ReplicatedStorage.Shared.Configs.GunConfig)

local RemotesFolder = ReplicatedStorage.Shared.Remotes
local ReloadEvent = RemotesFolder:WaitForChild("ReloadEvent")
local UpdateAmmoEvent = RemotesFolder:WaitForChild("UpdateAmmoEvent")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CurrentAmmo = 0
local ReserveAmmo = 0
local CurrentGunName = ""

-------------------------------------------------
-- CHARACTER UPDATE
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
-- 🔥 RECOIL SYSTEM
-------------------------------------------------
local recoilOffset = Vector2.new(0, 0)
local recoilRecoverySpeed = 8 -- higher = faster recovery

game:GetService("RunService").RenderStepped:Connect(function(dt)
	-- smooth recovery
	recoilOffset = recoilOffset:Lerp(Vector2.new(0, 0), dt * recoilRecoverySpeed)

	-- apply to camera
	Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(recoilOffset.Y), math.rad(recoilOffset.X), 0)
end)

local function ApplyRecoil(amount)
	-- random side movement
	local randomX = (math.random() - 0.5) * 2

	recoilOffset += Vector2.new(randomX * amount * 0.5, amount)
end

local Holding = false

-- Shoots bullet on the client
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

		-- ❌ STOP IF NO AMMO
		if CurrentAmmo <= 0 then
			-- optional: auto reload trigger
			local gunId = GunTool:GetAttribute("Id")
			if ReserveAmmo > 0 then
				ReloadEvent:FireServer(gunId)
			end
			break
		end

		local gun = Gun.new(GunData.actualGun)
		gun:Fire(GunTool)

		-- 🔥 APPLY RECOIL
		local recoilAmount = GunData.actualGun.recoil or 0.2
		ApplyRecoil(recoilAmount)

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
		local GunTool = GetGunTool()
		if not GunTool then
			return
		end

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
	CurrentAmmo = current
	ReserveAmmo = reserve
	CurrentGunName = gunname

	print(gunname .. " | Ammo: " .. current .. "/" .. reserve)
end)
