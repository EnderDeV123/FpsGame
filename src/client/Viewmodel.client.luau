local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationService = require(ReplicatedStorage.Shared.Services.AnimationService)

local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local ViewModelsFolder = ReplicatedStorage:WaitForChild("GFX"):WaitForChild("ViewModels")
local RemotesFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local GetDebounceBindable: BindableEvent = RemotesFolder:WaitForChild("GetDebounceBindable")
local GetShootBindable: BindableEvent = RemotesFolder:WaitForChild("GetShootBindable")
local currentViewModel = nil
local primaryPart = nil

-- Settings
local offset = CFrame.new(0, 0, 0)
local swayAmount = 0.05
local currentSway = CFrame.new()

local function loadViewModel(toolName)
	-- Remove old
	if currentViewModel then
		currentViewModel:Destroy()
		currentViewModel = nil
	end

	local template = ViewModelsFolder:FindFirstChild(toolName)
	if not template then
		warn("No ViewModel for:", toolName)
		return
	end

	local vm = template:Clone()
	vm.Parent = Camera

	currentViewModel = vm
	primaryPart = vm.PrimaryPart
end

local function onCharacterAdded(char)
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			loadViewModel(child.Name)
		end
	end)

	char.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			-- remove viewmodel when unequipped
			if currentViewModel then
				currentViewModel:Destroy()
				currentViewModel = nil
				primaryPart = nil
			end
		end
	end)
end

-- Init
if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

--------------------------------------------------
-- 🔥 RENDER LOOP
--------------------------------------------------
RunService.RenderStepped:Connect(function()
	if not primaryPart then
		return
	end

	local camCF = Camera.CFrame

	-- Sway
	local swayX = math.sin(tick() * 5) * swayAmount
	local swayY = math.cos(tick() * 5) * swayAmount

	currentSway = currentSway:Lerp(CFrame.new(swayX, swayY, 0), 0.1)

	currentViewModel:SetPrimaryPartCFrame(camCF * offset * currentSway)
end)

GetDebounceBindable.Event:Connect(function(DebounceAnimationId)
	task.wait(0.3)
	local Humanoide = currentViewModel:WaitForChild("Humanoid")
	local Animator = Humanoide:WaitForChild("Animator")
	AnimationService:PlayAnimations(DebounceAnimationId, Animator)
end)

GetShootBindable.Event:Connect(function(ShootAnimationId)
	local Humanoide = currentViewModel:WaitForChild("Humanoid")
	local Animator = Humanoide:WaitForChild("Animator")
	AnimationService:PlayAnimations(ShootAnimationId, Animator)
end)
