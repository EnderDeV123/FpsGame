-- local Players = game:GetService("Players")
-- local RunService = game:GetService("RunService")
-- local UserInputService = game:GetService("UserInputService")

-- local Camera = workspace.CurrentCamera
-- local player = Players.LocalPlayer

-- -------------------------------------------------
-- -- SETTINGS
-- -------------------------------------------------
-- local mouseSensitivity = 0.3
-- local xRotation = 0
-- local yRotation = 0

-- local isMouseLocked = true

-- -------------------------------------------------
-- -- CHARACTER
-- -------------------------------------------------
-- -- local character, head, humanoid, rootPart

-- -- local function forceHideCharacter(char)
-- -- 	for _, v in ipairs(char:GetDescendants()) do
-- -- 		if v:IsA("BasePart") then
-- -- 			-- 🔥 don't hide tools
-- -- 			if not v:IsDescendantOf(player.Backpack) then
-- -- 				v.LocalTransparencyModifier = 1
-- -- 			end
-- -- 		elseif v:IsA("Decal") or v:IsA("Texture") then
-- -- 			v.Transparency = 1
-- -- 		end
-- -- 	end
-- -- end

-- -- local function setupCharacter(char)
-- -- 	character = char
-- -- 	head = char:WaitForChild("Head")
-- -- 	humanoid = char:WaitForChild("Humanoid")
-- -- 	rootPart = char:WaitForChild("HumanoidRootPart")

-- -- 	humanoid.AutoRotate = false

-- -- 	forceHideCharacter(char)
-- -- end

-- -- setupCharacter(player.Character or player.CharacterAdded:Wait())
-- -- player.CharacterAdded:Connect(setupCharacter)

-- -------------------------------------------------
-- -- CAMERA INIT
-- -------------------------------------------------
-- -- Camera.CameraType = Enum.CameraType.Scriptable
-- -- UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
-- -- UserInputService.MouseIconEnabled = false

-- UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
-- 	if gameProcessedEvent then
-- 		return
-- 	end

-- 	if input.KeyCode == Enum.KeyCode.Tab then
-- 		isMouseLocked = false

-- 		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
-- 		UserInputService.MouseIconEnabled = true
-- 	end
-- end)

-- UserInputService.InputEnded:Connect(function(input)
-- 	if input.KeyCode == Enum.KeyCode.Tab then
-- 		isMouseLocked = true

-- 		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
-- 		UserInputService.MouseIconEnabled = false
-- 	end
-- end)

-- -------------------------------------------------
-- -- MAIN LOOP
-- -------------------------------------------------
-- -- RunService.RenderStepped:Connect(function()
-- -- 	if not character or not head or not rootPart then
-- -- 		return
-- -- 	end

-- -- 	-- keep character hidden
-- -- 	forceHideCharacter(character)

-- -- 	if not isMouseLocked then
-- -- 		return
-- -- 	end

-- -- 	local delta = UserInputService:GetMouseDelta()

-- -- 	xRotation -= delta.Y * mouseSensitivity
-- -- 	yRotation -= delta.X * mouseSensitivity
-- -- 	xRotation = math.clamp(xRotation, -80, 80)

-- -- 	-- 🔥 smoother rotation (less jitter)
-- -- 	local rootPos = rootPart.Position
-- -- 	rootPart.CFrame = CFrame.new(rootPos) * CFrame.Angles(0, math.rad(yRotation), 0)

-- -- 	-- camera
-- -- 	local camCF = CFrame.new(head.Position)
-- -- 		* CFrame.Angles(0, math.rad(yRotation), 0)
-- -- 		* CFrame.Angles(math.rad(xRotation), 0, 0)

-- -- 	Camera.CFrame = camCF
-- -- end)
