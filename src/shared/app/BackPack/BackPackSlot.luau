local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type SlotProps = {
	Name: string?,
	Tool: Tool?, -- optional Tool instance this slot represents
	OnClick: (() -> ())?,
	Selected: boolean?,
}

local function Slot(props: SlotProps)
	local displayName = props.Name or (props.Tool and props.Tool.Name) or "Empty"

	return e("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = props.Selected and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(40, 40, 40),
		[React.Event.Activated] = function()
			if props.Tool then
				-- Equip the tool when clicked
				local player = Players.LocalPlayer
				local character = player.Character
				if character then
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						humanoid:EquipTool(props.Tool)
					end
				end
			end
			if props.OnClick then
				props.OnClick()
			end
		end,
	}, {
		NameLabel = e("TextLabel", {
			Text = displayName,
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
		}),
	})
end

return Slot
