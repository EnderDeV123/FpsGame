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
local GetReloadBindable: BindableEvent = RemotesFolder:WaitForChild("GetReloadBindable")

--------------------------------------------------
-- STATE
--------------------------------------------------
local currentViewModel = nil
local primaryPart = nil

--------------------------------------------------
-- SETTINGS
--------------------------------------------------
local offset = CFrame.new(0, 0, 0)
local swayAmount = 0.05
local currentSway = CFrame.new()

--------------------------------------------------
-- LOAD VIEWMODEL
--------------------------------------------------
local function loadViewModel(toolName)
	-- Remove old
	if currentViewModel then
		currentViewModel:Destroy()
		currentViewModel = nil
		primaryPart = nil
	end

	local template = ViewModelsFolder:FindFirstChild(toolName)
	if not template then
		warn("❌ No ViewModel for:", toolName)
		return
	end

	local vm = template:Clone()
	vm.Name = "ViewModel"
	vm.Parent = workspace -- safer than Camera

	if not vm.PrimaryPart then
		warn("❌ ViewModel missing PrimaryPart:", toolName)
		vm:Destroy()
		return
	end

	currentViewModel = vm
	primaryPart = vm.PrimaryPart
end

--------------------------------------------------
-- REMOVE VIEWMODEL
--------------------------------------------------
local function removeViewModel()
	if currentViewModel then
		currentViewModel:Destroy()
		currentViewModel = nil
		primaryPart = nil
	end
end

--------------------------------------------------
-- TOOL SETUP (IMPORTANT)
--------------------------------------------------
local function setupTool(tool)
	if not tool:IsA("Tool") then
		return
	end

	-- EQUIP
	tool.Equipped:Connect(function()
		loadViewModel(tool.Name)
	end)

	-- UNEQUIP
	tool.Unequipped:Connect(function()
		removeViewModel()
	end)
end

--------------------------------------------------
-- CHARACTER SETUP
--------------------------------------------------
local function onCharacterAdded(char)
	-- Handle existing tools
	for _, tool in ipairs(char:GetChildren()) do
		setupTool(tool)

		-- If already equipped
		if tool:IsA("Tool") then
			loadViewModel(tool.Name)
		end
	end

	char.ChildAdded:Connect(setupTool)

	-- Backpack tools
	local backpack = player:WaitForChild("Backpack")

	for _, tool in ipairs(backpack:GetChildren()) do
		setupTool(tool)
	end

	backpack.ChildAdded:Connect(setupTool)
end

--------------------------------------------------
-- INIT
--------------------------------------------------
if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)

--------------------------------------------------
-- RENDER LOOP
--------------------------------------------------
RunService.RenderStepped:Connect(function()
	if not currentViewModel or not primaryPart then
		return
	end

	local camCF = Camera.CFrame

	-- SWAY
	local swayX = math.sin(tick() * 5) * swayAmount
	local swayY = math.cos(tick() * 5) * swayAmount

	currentSway = currentSway:Lerp(CFrame.new(swayX, swayY, 0), 0.1)

	currentViewModel:SetPrimaryPartCFrame(camCF * offset * currentSway)
end)

--------------------------------------------------
-- ANIMATIONS
--------------------------------------------------
local function getAnimator()
	if not currentViewModel then
		return nil
	end

	local humanoid = currentViewModel:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil
	end

	return humanoid:FindFirstChildOfClass("Animator")
end

GetDebounceBindable.Event:Connect(function(animId)
	task.wait(0.3)

	local animator = getAnimator()
	if animator then
		AnimationService:PlayAnimations(animId, animator)
	end
end)

GetShootBindable.Event:Connect(function(animId)
	local animator = getAnimator()
	if animator then
		AnimationService:PlayAnimations(animId, animator)
	end
end)

GetReloadBindable.Event:Connect(function(animId)
	local animator = getAnimator()
	if animator then
		AnimationService:PlayAnimations(animId, animator)
	end
end)
