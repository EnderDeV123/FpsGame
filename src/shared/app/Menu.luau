local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

type MenuProps = {
	Text: string,
	Color: Color3,
	Position: UDim,
}

local function Menu(props: MenuProps)
	local counter, setCounter = React.useState(0)
	return e("Frame", {
		Size = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = props.Position,
		BackgroundColor3 = props.Color,
	}, {
		Button = e("TextButton", {
			Text = "Pressed " .. counter .. " times",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.95),
			Size = UDim2.fromScale(0.19, 0.19),
			[React.Event.Activated] = function()
				setCounter(counter + 1)
			end,
		}),
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),

		Stroke = e("UIStroke", {
			Thickness = 4,
		}),
		TextLabel = e("TextLabel", {
			Size = UDim2.fromScale(1, 0.25),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = props.Text,
		}),
	})
end

return function(props: MenuProps)
	local shown, setShown = React.useState(false)
	React.useEffect(function()
		local conn = UserInputService.InputBegan:Connect(function(input, proccess)
			if proccess then
				return
			end

			if input.KeyCode == Enum.KeyCode.E then
				setShown(not shown)
			end
		end)

		return function()
			conn:Disconnect()
		end
	end, { shown })

	if shown then
		return e(Menu, props)
	else
		return nil
	end
end
