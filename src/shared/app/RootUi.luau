local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menu = require(script.Parent.Menu)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement
local function RootUI()
	return e(Menu, {
		Text = "custome Menu by ract",
		Color = Color3.fromRGB(60, 133, 55),
		Position = UDim2.fromScale(0.5, 0.5),
	})
end

return RootUI
