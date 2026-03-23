local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local RootUi = require(ReplicatedStorage.Shared.app.RootUi)

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

return function()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ReactUI"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui

	local root = ReactRoblox.createRoot(screenGui)
	root:render(React.createElement(RootUi))
end
