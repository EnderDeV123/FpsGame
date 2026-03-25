local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationServiceUtils = require(ReplicatedStorage.Shared.Utils.AnimationServiceUtils)
local AnimationService = {}

function AnimationService.init()
	AnimationServiceUtils:CreateUtils()
end

function AnimationService:PlayAnimations(AnimationId: number, Animator: Animator)
	local Animation = Instance.new("Animation")
	Animation.AnimationId = "rbxassetid://" .. AnimationId

	local Track = Animator:LoadAnimation(Animation)
	Track:Play()
	Track.Ended:Connect(function()
		Animation:Destroy()
	end)
end

AnimationService.init()

return AnimationService
