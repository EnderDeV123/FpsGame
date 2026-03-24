local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BackPackSlot = require(script.Parent.BackPackSlot)
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement
local useState = React.useState

local function BackPack()
	local selectedSlot, setSelectedSlot = useState(1) -- default selected

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.877, 0.583),
		Size = UDim2.fromScale(0.3, 0.4),
		BackgroundTransparency = 1,
	}, {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5),
		}),

		Slot1 = e(BackPackSlot, {
			Name = "Sniper",
			LayoutOrder = 1,
			Selected = selectedSlot == 1,
			OnClick = function()
				setSelectedSlot(1)
			end,
		}),

		Slot2 = e(BackPackSlot, {
			Name = "Pistol",
			LayoutOrder = 2,
			Selected = selectedSlot == 2,
			OnClick = function()
				setSelectedSlot(2)
			end,
		}),

		Slot3 = e(BackPackSlot, {
			Name = "Medkit",
			LayoutOrder = 3,
			Selected = selectedSlot == 3,
			OnClick = function()
				setSelectedSlot(3)
			end,
		}),

		Slot4 = e(BackPackSlot, {
			Name = "Empty",
			LayoutOrder = 4,
			Selected = selectedSlot == 4,
			OnClick = function()
				setSelectedSlot(4)
			end,
		}),
	})
end

return BackPack
