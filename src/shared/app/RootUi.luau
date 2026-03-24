local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

-- local AmmoHUD = require(script.Parent.AmmoHUD)
local BackPackRoot = require(script.Parent.BackPackRoot)

local function RootUI()
	return e(React.Fragment, nil, {
		-- Ammorhud = e(AmmoHUD),
		Hotbar = e(BackPackRoot),
	})
end

return RootUI
