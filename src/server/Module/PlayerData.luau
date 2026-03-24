local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Profilestore = require(ServerScriptService.ServerPackages.Profilestore)
local PlayerDataTemplate = require(ReplicatedStorage.Shared.PlayerData.PlayerData)

-- 🔹 DataStore Key
local DATA_STORE_KEY = "Production"
if RunService:IsStudio() then
	DATA_STORE_KEY = "Test"
end

local PlayerStore = Profilestore.New(DATA_STORE_KEY, PlayerDataTemplate.DEFAULT_PLAYER_DATA)

-- 🔹 Active profiles
local Profiles: { [Player]: any } = {}

local Local = {}
local Shared = {}

-------------------------------------------------
-- START
-------------------------------------------------
function Local.OnStart()
	-- Load existing players
	for _, player in Players:GetPlayers() do
		task.spawn(function()
			Local.LoadProfile(player)
		end)
	end

	-- Player joins
	Players.PlayerAdded:Connect(function(player)
		Local.LoadProfile(player)
	end)

	-- Player leaves
	Players.PlayerRemoving:Connect(function(player)
		Local.RemoveProfile(player)
	end)
end

-------------------------------------------------
-- LOAD PROFILE
-------------------------------------------------
function Local.LoadProfile(player: Player)
	local profile = PlayerStore:StartSessionAsync(tostring(player.UserId), {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if not profile then
		player:Kick("Profile failed to load. Please rejoin.")
		return
	end

	-- Store profile
	Profiles[player] = profile

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	-- Session end handling
	profile.OnSessionEnd:Connect(function()
		Profiles[player] = nil

		if player.Parent == Players then
			player:Kick("Session ended. Please rejoin.")
		end
	end)
end

-------------------------------------------------
-- REMOVE PROFILE
-------------------------------------------------
function Local.RemoveProfile(player: Player)
	local profile = Profiles[player]

	if profile then
		profile:EndSession()
		Profiles[player] = nil
	end
end

-------------------------------------------------
-- GET DATA
-------------------------------------------------
function Shared.GetData(player: Player)
	local profile = Profiles[player]
	if profile then
		return profile.Data
	end
	return nil
end

-------------------------------------------------
-- INIT
-------------------------------------------------
Local.OnStart()

return Shared
