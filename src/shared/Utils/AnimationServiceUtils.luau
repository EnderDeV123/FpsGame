local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemotesFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")

local AnimationServiceUtils = {}

function AnimationServiceUtils:CreateUtils()
	local GetDebounceBindable = Instance.new("BindableEvent")
	GetDebounceBindable.Name = "GetDebounceBindable"
	GetDebounceBindable.Parent = RemotesFolder
end

return AnimationServiceUtils
