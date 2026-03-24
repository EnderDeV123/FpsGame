local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement
local useEffect = React.useEffect

type SlotProps = {
	Name: string?,
	Selected: boolean?,
	OnClick: (() -> ())?,
	Tool: Tool?,
}

local function Slot(props: SlotProps)
	local displayName = props.Name or "Empty"

	-- ------------------------
	-- EFFECT: Auto-equip when selected
	-- ------------------------
	useEffect(function()
		if props.Selected and props.Tool then
			local player = Players.LocalPlayer
			local char = player.Character or player.CharacterAdded:Wait()
			local humanoid = char:WaitForChild("Humanoid")

			humanoid:EquipTool(props.Tool)
		end
	end, { props.Selected, props.Tool }) -- run effect whenever Selected or Tool changes

	return e("TextButton", {
		Size = UDim2.new(1, 0, 0, 50),
		Text = "",
		BackgroundColor3 = props.Selected and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(40, 40, 40),

		[React.Event.Activated] = function()
			if props.OnClick then
				props.OnClick()
			end
		end,
	}, {
		NameLabel = e("TextLabel", {
			Text = displayName,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
		}),
	})
end

return Slot
