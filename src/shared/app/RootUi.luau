local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

local AmmoHUD = require(script.Parent.AmmoHUD)
local BackPackRoot = require(script.Parent.BackPackRoot)
local Crosshair = require(script.Parent.Crosshair)

local function RootUI()
	return e(React.Fragment, nil, {
		Ammorhud = e(AmmoHUD),
		Hotbar = e(BackPackRoot),
		Crosshair = e(Crosshair, {
			Thickness = 2,
			Length = 12,
			Gap = 0,
			Color = Color3.fromRGB(255, 255, 255),
		}),
	})
end

return RootUI
