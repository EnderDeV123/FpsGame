local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local RemotesFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local UpdateAmmoEvent = RemotesFolder:WaitForChild("UpdateAmmoEvent")

local e = React.createElement

local function AmmoLevel()
	local ammo, setAmmo = React.useState(0)
	local totalAmmo, setTotalAmmo = React.useState(0)
	local gunName, setGunName = React.useState("")

	React.useEffect(function()
		local conn = UpdateAmmoEvent.OnClientEvent:Connect(function(current, reserve, gunname)
			setAmmo(current)
			setTotalAmmo(reserve)
			setGunName(gunname or "")
		end)

		return function()
			conn:Disconnect()
		end
	end, {})

	return e("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.9), -- moved to bottom (better UX)
		Size = UDim2.fromScale(0.3, 0.08),
		TextScaled = true,
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = " | Ammo: " .. ammo .. "/" .. totalAmmo .. " " .. gunName,
	})
end

return AmmoLevel
