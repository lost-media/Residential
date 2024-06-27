--!strict

--[[
{Lost Media}

-[DataService] Service
    Central service that manages the plots in the game.
	This service is responsible for assigning plots to players
	and serializing the plot data to the client.

	Members:

		DataService._plots   [table] -- Player -> Plot
			Stores the mapping of players to plots

	Methods [DataService]:

		DataService:AssignPlot(player: Player, plot: Instance) -- Assigns a plot to a player
			player [Player]
			plot   [Instance]
--]]

local SETTINGS = {
	MAIN_PROFILE_PREFIX = "Player_",

	MainProfileTemplate = {
		Money = 0,
		Storage = {},
		Plot = "",
	},
}

----- Private variables -----

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine)

local dir_Modules = script.Parent.Parent.Modules

local PlotTypes = require(dir_Modules.Plot2.Types)

---@type ProfileService
local ProfileService = LMEngine.GetModule("ProfileService")

local ProfileStore = ProfileService.GetProfileStore("PlayerData", SETTINGS.MainProfileTemplate)

---@type RetryAsync
local RetryAsync = LMEngine.GetShared("RetryAsync")

---@class DataService
local DataService = LMEngine.CreateService({
	Name = "DataService",

	---@type table<Player, any>
	_profiles = {},
})

----- Private functions -----

----- Public functions -----

function DataService:Start()
	---@type PlayerService
	local PlayerService = LMEngine.GetService("PlayerService")

	PlayerService:RegisterPlayerAdded(function(player)
		local profile = ProfileStore:LoadProfileAsync(SETTINGS.MAIN_PROFILE_PREFIX .. player.UserId)

		if profile == nil then
			-- Other servers are trying to load this profile at the same time
			player:Kick("[DataService] Failed to load profile")
			return
		end

		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			self._profiles[player] = nil

			player:Kick("[DataService]: Profile released")
		end)

		if player:IsDescendantOf(Players) == true then
			self._profiles[player] = profile
		else
			profile:Release()
		end
		self._profiles[player] = profile
	end, "URGENT")

	PlayerService:RegisterPlayerRemoved(function(player)
		local profile = self._profiles[player]

		if profile ~= nil then
			profile:Release()
		end
	end, "LOW")
end

function DataService:UpdatePlot(player: Player, plot: string)
	if plot == nil then
		warn("[DataService]: Attempted to update plot with nil value")
		return
	end

	local profile = self._profiles[player]

	if profile == nil then
		profile = ProfileStore:LoadProfileAsync(SETTINGS.MAIN_PROFILE_PREFIX .. player.UserId)
		self._profiles[player] = profile
	end

	profile.Data.Plot = plot

	print("[DataService]: Updated plot for player: " .. player.Name)
end

function DataService:GetProfile(player: Player)
	return self._profiles[player]
end

function DataService:GetPlot(player: Player)
	local profile = self._profiles[player]

	if profile == nil then
		return nil
	end

	return profile.Data.Plot
end

return DataService
