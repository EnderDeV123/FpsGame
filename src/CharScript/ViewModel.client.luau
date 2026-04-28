local RunService = game:GetService("RunService")
local PhysicService = game:GetService("PhysicsService")

local Camera = workspace.CurrentCamera
if Camera:FindFirstChild("ViewModel") then
	Camera.ViewModel:Destroy()
end

local Character = script.Parent
local Animator = Character:WaitForChild("Humanoid"):WaitForChild("Animator")

Character.Archivable = true
local ViewModel = Character:Clone()
ViewModel.Parent = Camera
ViewModel.Name = "ViewModel"
Character.Archivable = false

local ViewModelAnimator = ViewModel.Humanoid.Animator -- // Used to play animations on the ViewModel.
ViewModel.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None -- // Disable name display.
ViewModel.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff -- // Disable health display.
ViewModel.Humanoid.BreakJointsOnDeath = false

ViewModel.Head.Anchored = true
ViewModel.PrimaryPart = ViewModel.Head
ViewModel:SetPrimaryPartCFrame(CFrame.new(0, 5, 10))

for _, Part in pairs(ViewModel:GetDescendants()) do
	if Part:IsA("BasePart") then
		Part.CastShadow = false -- // If it's a part, then disable it's shadow.
		PhysicService:SetPartCollisionGroup(Part, "ViewModel")

		local LowerName = Part.Name:lower() -- // Get the lowercase part name
		if LowerName:match("leg") or LowerName:match("foot") then
			Part:Destroy() -- // If this is a leg/foot part then delete it, since it's useless.
		elseif not (LowerName:match("arm") or LowerName:match("hand")) then
			Part.Transparency = 1 -- // If this part isn't a part of the arms then it should be invisible.
		end
	elseif Part:IsA("Decal") then
		Part:Destroy() -- // Delete all decals (Face).
	elseif Part:IsA("Accessory") then
		Part:Destroy() -- // Delete all accessories.
	elseif Part:IsA("LocalScript") then
		Part:Destroy() -- // Destroy all scripts.
	end
end

local LoadedAnimations = {}
Animator.AnimationPlayed:Connect(function(AnimationTrack)
	if AnimationTrack:GetAttribute("ViewModelAnimation") ~= true then
		return
	end -- // Skip animation if it isn't supposed to play on ViewModel.
	if not LoadedAnimations[AnimationTrack] then -- // Indexing using the animation track.
		-- // If this animation was not already laoded then load it.
		LoadedAnimations[AnimationTrack] = ViewModelAnimator:LoadAnimation(AnimationTrack.Animation) -- // Load animation on the ViewModel.
	end
end)

local function updateAnimations()
	for CharAnim, Anim in pairs(LoadedAnimations) do
		if CharAnim.IsPlaying ~= Anim.IsPlaying then
			if CharAnim.IsPlaying then
				Anim:Play()
			else
				Anim:Stop()
			end
		end

		Anim.TimePosition = CharAnim.TimePosition
		Anim:AdjustWeight(CharAnim.WeightCurrent, 0) -- // 0 Fade time so it's instantly set.
	end
end

RunService.RenderStepped:Connect(function(dl)
	updateAnimations()
	-- ViewModel:SetPrimaryPartCFrame(Camera.CFrame)
	local ViewModelShirt = ViewModel:FindFirstChildWhichIsA("Shirt") or Instance.new("Shirt", ViewModel) -- // Create a shirt if there is no shirt found.
	local CharacterShirt = Character:FindFirstChildWhichIsA("Shirt")
	if CharacterShirt then
		-- // If a shirt was found in the player's character, then set the ViewModel's shirt to the same shirt.
		ViewModelShirt.ShirtTemplate = CharacterShirt.ShirtTemplate
	end

	for _, Part in pairs(ViewModel:GetChildren()) do
		if Part:IsA("BasePart") then
			-- // Set the color of each part of the ViewModel to the color of the part with same name in the character.
			Part.Color = Character[Part.Name].Color
		end
	end
end)

Character.DescendantAdded:Connect(function(Obj)
	if Obj:IsA("Weld") and Obj.Name == "RightGrip" then
		task.wait()
		Obj.Part0 = ViewModel[Obj.Part0.Name]
	end
end)
