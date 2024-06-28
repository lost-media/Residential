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
	Client = {
		LoadPlot = LMEngine.CreateSignal(),
		PlayerPlotsLoaded = LMEngine.CreateSignal(),
	},

	---@type table<Player, any>
	_profiles = {},

	---@type table<Player, any>
	_plots = {},

	-- Events
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

			self.Client.PlayerPlotsLoaded:Fire(player, profile.Data.Plots)
			-- Migrate the profile
			--profile = MigrationManager.MigratePlayerProfile(player, profile)
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

function DataService:LoadPlot(player: Player, plot_uuid: string)
	print(plot_uuid)
	local profile = self._profiles[player]

	if profile == nil then
		warn("[DataService]: Player does not have a profile")
		return
	end

	local plot_exists = profile.Data.Plots[plot_uuid]

	if plot_exists == nil then
		warn("[DataService]: Player does not have plot with UUID: " .. plot_uuid)
		return
	end

	local plot_profile = self._plots[plot_uuid]

	if plot_profile == nil then
		plot_profile = PlotStore:LoadProfileAsync(SETTINGS.PLOT_PROFILE_PREFIX .. plot_uuid)
		self._plots[plot_uuid] = plot_profile

		plot_profile:AddUserId(player.UserId)
		plot_profile:Reconcile()

		plot_profile:ListenToRelease(function()
			self._plots[plot_uuid] = nil
		end)

		if player:IsDescendantOf(Players) == false then
			plot_profile:Release()
			self._plots[plot_uuid] = nil
		end

		-- Migrate the plot profile
		--plot_profile = MigrationManager.MigratePlotProfile(player, plot_profile)
	end

	print("[DataService]: Loaded plot for player: " .. player.Name)

	-- load the plot from PlotService
	---@type PlotService
	local PlotService = LMEngine.GetService("PlotService")

	PlotService:LoadPlotData(player, plot_profile.Data)

	return plot_profile.Data
end

function DataService.Client:LoadPlot(player: Player, plot_uuid: string)
	return self.Server:LoadPlot(player, plot_uuid)
end

function DataService:UpdatePlotData(player: Player, plot_data: string)
	local profile = self._profiles[player]

	if profile == nil then
		warn("[DataService]: Player does not have a profile")
		return
	end

	if plot_data == nil then
		warn("[DataService]: Plot data is nil")
		return
	end

	-- find if the player has a plot
	for plot_uuid, plot_name in profile.Data.Plots do
		local plot_profile = self._plots[plot_uuid]

		if plot_profile == nil then
			warn("[DataService]: Plot does not exist")
			return
		end

		local user_id = plot_profile.Data.UserId

		if user_id ~= player.UserId then
			warn("[DataService]: Player does not own plot")
			return
		end

		-- Update the plot data
		plot_profile.Data.PlotData = plot_data

		print("[DataService]: Updated plot for player: " .. player.Name)
	end
end

function DataService:GetProfile(player: Player)
	return self._profiles[player]
end

function DataService:GetPlot(plot_uuid: string)
	return self._plots[plot_uuid]
end

function DataService:GetPlayerPlots(player: Player)
	local profile = self._profiles[player]

	if profile == nil then
		warn("[DataService]: Player does not have a profile")
		return
	end

	return profile.Data.Plots
end

function DataService.Client:GetPlayerPlots(player: Player)
	return self.Server:GetPlayerPlots(player)
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
