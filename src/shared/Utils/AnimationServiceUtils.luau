local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemotesFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")

local AnimationServiceUtils = {}

function AnimationServiceUtils:CreateUtils()
	local GetDebounceBindable = Instance.new("BindableEvent")
	GetDebounceBindable.Name = "GetDebounceBindable"
	GetDebounceBindable.Parent = RemotesFolder

	local GetShootBindable = Instance.new("BindableEvent")
	GetShootBindable.Name = "GetShootBindable"
	GetShootBindable.Parent = RemotesFolder

	local GetReloadBindable = Instance.new("BindableEvent")
	GetReloadBindable.Name = "GetReloadBindable"
	GetReloadBindable.Parent = RemotesFolder
end

return AnimationServiceUtils
