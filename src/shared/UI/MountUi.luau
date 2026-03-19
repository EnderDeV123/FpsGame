local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local RootUi = require(ReplicatedStorage.Shared.app.RootUi)

return function()
	local player = Players.LocalPlayer
	local PlayerGui = player.PlayerGui
	local Container = Instance.new("ScreenGui")
	Container.Name = "React"
	Container.IgnoreGuiInset = true
	Container.ResetOnSpawn = false
	Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	Container.ClipToDeviceSafeArea = true
	Container.Parent = PlayerGui

	local root = ReactRoblox.createRoot(Container)
	local app = React.createElement(RootUi)

	root:render(app)
end
