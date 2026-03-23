local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BackPackSlot = require(script.Parent.BackPackSlot)
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

type BackPackProps = {
	Player: Player, -- The player whose backpack we are showing
	SlotAmount: number, -- Total number of slots in the backpack
	BackPacl: Backpack,
}

local function BackPack(props: BackPackProps)
	local player = props.Player
	local backpack = player:WaitForChild("Backpack")

	-- React state to force re-render when backpack changes
	local useState = React.useState
	local _, setUpdate = useState(0)

	-- Function to refresh GUI
	local function refresh()
		setUpdate(os.clock()) -- triggers re-render
	end

	-- Listen to backpack changes (add/remove tools)
	React.useEffect(function()
		-- Child added/removed in backpack
		local addedConn = backpack.ChildAdded:Connect(refresh)
		local removedConn = backpack.ChildRemoved:Connect(refresh)

		-- Also listen to StarterGear changes (when player respawns)
		local starterConn
		if player:FindFirstChild("StarterGear") then
			starterConn = player.StarterGear.ChildAdded:Connect(function(tool)
				-- Wait a tiny delay for tool to clone to backpack
				task.delay(0.1, refresh)
			end)
		end

		-- Cleanup on unmount
		return function()
			addedConn:Disconnect()
			removedConn:Disconnect()
			if starterConn then
				starterConn:Disconnect()
			end
		end
	end, {}) -- run only on mount

	-- Build slots based on current tools
	local slots = {}

	-- Fill remaining slots
	local remainingSlots = props.SlotAmount - #slots
	for i = 1, remainingSlots do
		table.insert(slots, e(BackPackSlot, {}))
	end

	-- Add UIGridLayout for neat arrangement
	local gridLayout = e("UIGridLayout", {
		CellSize = UDim2.new(0, 50, 0, 50),
		CellPadding = UDim2.new(0, 5, 0, 5),
	})

	return e("Frame", {
		Size = UDim2.new(0, 300, 0, 300),
		BackgroundTransparency = 1,
	}, { gridLayout, table.unpack(slots) })
end

return BackPack
