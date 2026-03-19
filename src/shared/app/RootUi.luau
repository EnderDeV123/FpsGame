local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menu = require(script.Parent.Menu)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement
local function RootUI()
	return e(React.Fragment, nil, {

		Menu1 = e(Menu, {
			Text = "custome Menu by ract",
			Color = Color3.fromRGB(60, 133, 55),
			Position = UDim2.fromScale(0.5, 0.25),
		}),

		Menu2 = e(Menu, {
			Text = "custome Menu by ract",
			Color = Color3.fromRGB(132, 55, 133),
			Position = UDim2.fromScale(0.5, 0.75),
		}),
	})
end

return RootUI
