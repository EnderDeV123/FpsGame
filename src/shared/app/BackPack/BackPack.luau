local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local BackPackSlot = require(script.Parent.BackPackSlot)
local React = require(ReplicatedStorage.Packages.React)

local SendDataToClient: RemoteEvent =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("SendDataToClient")

local e = React.createElement
local useState = React.useState
local useEffect = React.useEffect

type BackPackProps = {
	Player: Player,
}

local function BackPack(props: BackPackProps)
	------------------------------------
	-- STATE
	------------------------------------
	local selectedSlot, setSelectedSlot = useState(1)
	local data, setData = useState(nil)
	local backpack, setBackpack = useState(nil)

	------------------------------------
	-- BACKPACK INIT (NO YIELD)
	------------------------------------
	useEffect(function()
		local bp = props.Player:FindFirstChild("Backpack")
		if bp then
			setBackpack(bp)
		else
			local conn
			conn = props.Player.ChildAdded:Connect(function(child)
				if child.Name == "Backpack" then
					setBackpack(child)
					conn:Disconnect()
				end
			end)
		end
	end, { props.Player })

	------------------------------------
	-- SERVER DATA
	------------------------------------
	useEffect(function()
		local connection = SendDataToClient.OnClientEvent:Connect(function(receivedData)
			setData(receivedData)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	------------------------------------
	-- HELPERS
	------------------------------------
	local function getTool(toolName: string?)
		if not toolName or not backpack then
			return nil
		end
		return backpack:FindFirstChild(toolName)
	end

	local function equipTool(tool: Tool?)
		if not tool then
			return
		end

		local char = props.Player.Character
		if not char then
			return
		end

		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:EquipTool(tool)
		end
	end

	local function selectSlot(index: number)
		setSelectedSlot(index)
	end

	------------------------------------
	-- INPUT (FIXED)
	------------------------------------
	useEffect(function()
		local connection = UserInputService.InputBegan:Connect(function(input, gp)
			if gp then
				return
			end
			if not data then
				return
			end

			if input.UserInputType == Enum.UserInputType.Keyboard then
				local keyValue = input.KeyCode.Value
				local oneValue = Enum.KeyCode.One.Value
				local threeValue = Enum.KeyCode.Three.Value

				if keyValue >= oneValue and keyValue <= threeValue then
					local index = keyValue - oneValue + 1
					selectSlot(index)

					local items = {
						getTool(data.GunInventory.MainGun), -- Sniper
						getTool(data.GunInventory.SecondaryGun), -- Pistol
						getTool(data.GunInventory.MedKit), -- MedKit
					}

					equipTool(items[index])
				end
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, { data, backpack })

	------------------------------------
	-- EARLY RETURN
	------------------------------------
	if not data then
		return e("Frame", { BackgroundTransparency = 1 })
	end

	------------------------------------
	-- FIXED ORDER (SNIPER → PISTOL → MEDKIT)
	------------------------------------
	local items = {
		{ name = data.GunInventory.MainGun },
		{ name = data.GunInventory.SecondaryGun },
		{ name = data.GunInventory.MedKit },
	}

	------------------------------------
	-- UI BUILD
	------------------------------------
	local children = {
		Grid = e("UIGridLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			FillDirectionMaxCells = 3,

			SortOrder = Enum.SortOrder.LayoutOrder,

			CellPadding = UDim2.new(0, 5, 0, 5),
			CellSize = UDim2.fromScale(0.25, 1), -- ✅ FIX

			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
	}

	for i, item in ipairs(items) do
		children["Slot_" .. i] = e(BackPackSlot, {
			Name = item.name,
			LayoutOrder = i,
			Selected = selectedSlot == i,
			OnClick = function()
				selectSlot(i)
				equipTool(getTool(item.name))
			end,
			Tool = getTool(item.name),
		})
	end

	------------------------------------
	-- ROOT FRAME (SMALL HEIGHT)
	------------------------------------
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),

		Size = UDim2.fromScale(0.5, 0.13), -- ✅ SMALL HEIGHT (FPS STYLE)

		BackgroundTransparency = 1,
	}, children)
end

return BackPack
