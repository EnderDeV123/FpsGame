local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

type CrossHairProps = {
	Thickness: number?, -- line thickness
	Length: number?, -- line length
	Gap: number?, -- space from center
	Color: Color3?,
}

local function CrossHair(props: CrossHairProps)
	local thickness = props.Thickness or 2
	local length = props.Length or 10
	local gap = props.Gap or 6
	local color = props.Color or Color3.new(1, 1, 1)

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(0, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
	}, {

		-- TOP
		Top = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Size = UDim2.fromOffset(thickness, length),
			Position = UDim2.fromOffset(0, -gap),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}),

		-- BOTTOM
		Bottom = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.fromOffset(thickness, length),
			Position = UDim2.fromOffset(0, gap),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}),

		-- LEFT
		Left = e("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.fromOffset(length, thickness),
			Position = UDim2.fromOffset(-gap, 0),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}),

		-- RIGHT
		Right = e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromOffset(length, thickness),
			Position = UDim2.fromOffset(gap, 0),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}),
	})
end

return CrossHair
