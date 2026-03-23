local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local RemotesFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")

local UpdateAmmoEvent = RemotesFolder:WaitForChild("UpdateAmmoEvent")

local e = React.createElement

local function AmmoLevel()
	local ammo, setAmmo = React.useState(0)
	local totalAmmo, setTotalAmmo = React.useState(0)

	React.useEffect(function()
		local conn = UpdateAmmoEvent.OnClientEvent:Connect(function(current, reserve, gunname)
			setAmmo(current)
			setTotalAmmo(reserve)
		end)

		return function()
			conn:Disconnect()
		end
	end, {})

	return e("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		TextScaled = true,
		BackgroundTransparency = 1,
		Text = "Ammo: " .. ammo .. "/" .. totalAmmo,
	})
end

return AmmoLevel
