local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData = require(ServerScriptService.Module.PlayerData)
local SendDataToClient =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("SendDataToClient")

local function WaitForData(player: Player)
	local playerData = PlayerData.GetData(player)

	while not playerData do
		task.wait() -- yield (VERY IMPORTANT)
		playerData = PlayerData.GetData(player)
	end

	return playerData
end

local function SendDataToPlayer(player, data)
	SendDataToClient:FireClient(player, data)
end

Players.PlayerAdded:Connect(function(player)
	local data = WaitForData(player)

	SendDataToPlayer(player, data)
end)
