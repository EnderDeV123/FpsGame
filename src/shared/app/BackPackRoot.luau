local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local BackPack = require(ReplicatedStorage.Shared.app.BackPack.BackPack)

local e = React.createElement

return function()
	return e(BackPack, {
		Player = Players.LocalPlayer,
		SlotAmount = 4,
		BackPack = Players.LocalPlayer.Backpack,
	})
end
