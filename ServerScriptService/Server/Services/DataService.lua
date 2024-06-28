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
	PLOT_PROFILE_PREFIX = "Plot_",

	MainProfileTemplate = {
		Plots = {},
		Version = 0,
	},

	PlotProfileTemplate = {
		Name = "",
		UserId = -1,
		PlotData = "",
		Storage = {},
		Version = 0,
	},
}

----- Private variables -----

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine)

local dir_Modules = script.Parent.Parent.Modules

---@type ProfileService
local ProfileService = LMEngine.GetModule("ProfileService")

local ProfileStore = ProfileService.GetProfileStore("PlayerData", SETTINGS.MainProfileTemplate)
local PlotStore = ProfileService.GetProfileStore("PlotData", SETTINGS.PlotProfileTemplate)

---@type RetryAsync
local RetryAsync = LMEngine.GetShared("RetryAsync")

local MigrationManager = require(dir_Modules.MigrationManager)

---@class DataService
local DataService = LMEngine.CreateService({
	Name = "DataService",

	---@type table<Player, any>
	_profiles = {},

	---@type table<Player, any>
	_plots = {},
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
			profile.Data.Version = 0 -- trigger migration

			-- Migrate the profile
			profile = MigrationManager.MigratePlayerProfile(player, profile)
		else
			profile:Release()
		end
		self._profiles[player] = profile
	end, "URGENT")

	PlayerService:RegisterPlayerRemoved(function(player)
		local profile = self._profiles[player]

		local plots = profile.Data.Plots

		if profile ~= nil then
			profile:Release()
		end

		if plots ~= nil then
			for plot_uuid, plot_name in plots do
				local plot_profile = self._plots[plot_uuid]

				if plot_profile ~= nil then
					print("[DataService]: Releasing plot for player: " .. player.Name)
					plot_profile:Release()
				end
			end
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

function DataService:GetPlot(plot_uuid: string)
	return self._plots[plot_uuid]
end

function DataService:LoadPlotIfNotLoaded(plot_uuid: string)
	local plot_profile = self._plots[plot_uuid]

	if plot_profile == nil then
		plot_profile = PlotStore:LoadProfileAsync(SETTINGS.PLOT_PROFILE_PREFIX .. plot_uuid)
		self._plots[plot_uuid] = plot_profile
	end

	return plot_profile.Data
end

function DataService:CreatePlotProfile(player: Player, plot_uuid: string, plot_data: any)
	assert(self._profiles[player] ~= nil, "[DataService]: Player does not have a profile")
	assert(self._plots[plot_uuid] == nil, "[DataService]: Plot already exists")

	local plot_profile = PlotStore:LoadProfileAsync(SETTINGS.PLOT_PROFILE_PREFIX .. plot_uuid)

	-- iterate over the plot data and set the values
	if plot_data ~= nil then
		for key, value in plot_data do
			plot_profile.Data[key] = value
		end
	end

	-- add UID and reconcile
	plot_profile:AddUserId(player.UserId)
	plot_profile:Reconcile()

	-- Add the plot to the player's profile
	local profile = self._profiles[player]
	profile.Data.Plots[plot_uuid] = plot_data.Name

	self._plots[plot_uuid] = plot_profile
end

return DataService
