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
	-- ------------------------
	-- HOOKS (always at top)
	-- ------------------------
	local selectedSlot, setSelectedSlot = useState(1)
	local data, setData = useState(nil)
	local backpack = props.Player:WaitForChild("Backpack")

	-- ------------------------
	-- EFFECT: Listen for server data
	-- ------------------------
	useEffect(function()
		local connection = SendDataToClient.OnClientEvent:Connect(function(receivedData)
			setData(receivedData)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	-- ------------------------
	-- HELPER: Get tool by name
	-- ------------------------
	local function getTool(toolName: string?)
		if not toolName then
			return nil
		end
		return backpack:FindFirstChild(toolName)
	end

	-- ------------------------
	-- HELPER: Select slot
	-- ------------------------
	local function selectSlot(index: number)
		setSelectedSlot(index)
	end

	-- ------------------------
	-- HELPER: Equip tool safely
	-- ------------------------
	local function equipTool(tool: Tool?)
		if not tool then
			return
		end

		local char = props.Player.Character or props.Player.CharacterAdded:Wait()
		if not char then
			return
		end

		local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
		if humanoid then
			humanoid:EquipTool(tool)
		end
	end

	-- ------------------------
	-- NUMERIC KEYS INPUT
	-- ------------------------
	useEffect(function()
		local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				local keyValue = input.KeyCode.Value
				local oneValue = Enum.KeyCode.One.Value
				local threeValue = Enum.KeyCode.Three.Value -- only 1-3

				if keyValue >= oneValue and keyValue <= threeValue then
					local numberPressed = keyValue - oneValue + 1
					selectSlot(numberPressed)

					if not data then
						return
					end
					local items = {
						getTool(data.GunInventory.MainGun),
						getTool(data.GunInventory.SecondaryGun),
						getTool(data.GunInventory.MedKit),
					}

					equipTool(items[numberPressed])
				end
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	-- ------------------------
	-- EARLY RETURN IF DATA NOT READY
	-- ------------------------
	if not data then
		return e("Frame", { BackgroundTransparency = 1 })
	end

	-- ------------------------
	-- PRIORITY & ITEMS
	-- ------------------------
	local priority = { MainGun = 1, SecondaryGun = 2, MedKit = 3 }
	local items = {
		{ name = data.GunInventory.MainGun, key = "MainGun" },
		{ name = data.GunInventory.SecondaryGun, key = "SecondaryGun" },
		{ name = data.GunInventory.MedKit, key = "MedKit" },
	}

	-- ------------------------
	-- BUILD UI
	-- ------------------------
	local children = {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),
	}

	for i, item in ipairs(items) do
		local layoutOrder = priority[item.key] or 999
		children["Slot_" .. i] = e(BackPackSlot, {
			Name = item.name,
			LayoutOrder = layoutOrder,
			Selected = selectedSlot == i,
			OnClick = function()
				selectSlot(i)
				equipTool(getTool(item.name))
			end,
			Tool = getTool(item.name),
		})
	end

	-- ------------------------
	-- RETURN ROOT FRAME
	-- ------------------------
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.877, 0.583),
		Size = UDim2.fromScale(0.3, 0.4),
		BackgroundTransparency = 1,
	}, children)
end

return BackPack
