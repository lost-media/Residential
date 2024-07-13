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
	ProfileStoreName = "ResidentialDataStore_v1",
	PlayerProfileScope = "Player",
	PlotProfileScope = "Plot",
}

----- Types -----

type PlayerSchema = {
	Plots: { [string]: string },
	UserId: number,
	LastPlotIdUsed: string,
	Version: number,
}

type PlotSchema = {
	PlotData: string,
	UserId: number,
	Version: number,
}

----- Private variables -----

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine)

local dir_Modules = script.Parent.Parent.Modules

---@type ProfileService
local ProfileService = LMEngine.GetModule("ProfileService")

local PlayerStore = ProfileService.GetProfileStore({
	Name = SETTINGS.ProfileStoreName,
	Scope = SETTINGS.PlayerProfileScope,
}, {})

local PlotStore = ProfileService.GetProfileStore({
	Name = SETTINGS.ProfileStoreName,
	Scope = SETTINGS.PlotProfileScope,
}, {})

local RetryAsync = require(LMEngine.SharedDir.RetryAsync)
local Signal = require(LMEngine.SharedDir.Signal)

local MigrationManager = require(dir_Modules.MigrationManager)

---@class DataService
local DataService = LMEngine.CreateService({
	Name = "DataService",
	Client = {
		CreatePlot = LMEngine.CreateSignal(),
		LoadPlot = LMEngine.CreateSignal(),
		PlayerPlotsLoaded = LMEngine.CreateSignal(),

		GetPlayerCredits = LMEngine.CreateSignal(),
	},

	---@type table<Player, any>
	_profiles = {},

	---@type table<Player, any>
	_plots = {},

	-- Events
	PlotLoaded = Signal.new(),
})

---@type RateLimiter
local RateLimiter = LMEngine.GetModule("RateLimiter")

local CreatePlotRateLimiter = RateLimiter.NewRateLimiter(1)

----- Private functions -----

----- Public functions -----

function DataService:Start()
	---@type PlayerService
	local PlayerService = LMEngine.GetService("PlayerService")

	---@type PlotService
	local PlotService = LMEngine.GetService("PlotService")

	PlayerService:RegisterPlayerAdded(function(player)
		-- Create leaderstats
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		local roadbucks = Instance.new("IntValue")
		roadbucks.Name = "Roadbucks"
		roadbucks.Parent = leaderstats

		local profile = PlayerStore:LoadProfileAsync(tostring(player.UserId))

		if profile == nil then
			-- Other servers are trying to load this profile at the same time
			player:Kick("[DataService] Failed to load profile")
			return
		end

		profile:AddUserId(player.UserId)

		profile:ListenToRelease(function()
			self._profiles[player] = nil

			player:Kick("[DataService]: Profile released")
		end)

		if player:IsDescendantOf(Players) == true then
			-- First, migrate the profile
			profile = MigrationManager.MigratePlayerProfile(player, profile)

			self._profiles[player] = profile

			self.Client.PlayerPlotsLoaded:Fire(
				player,
				profile.Data.Plots,
				profile.Data.LastPlotIdUsed
			)
		else
			profile:Release()
		end
		self._profiles[player] = profile
	end, "URGENT")

	PlayerService:RegisterPlayerRemoved(function(player)
		local profile = self._profiles[player]

		if profile == nil then
			warn("[DataService]: Player does not have a profile")
			return
		end

		if profile ~= nil then
			profile:Release()
		end

		local plot_profile = self._plots[player]

		if plot_profile ~= nil then
			-- check if the tutorial is completed
			if
				plot_profile.Data.CompletedQuests
				and plot_profile.Data.CompletedQuests["Tutorial"] == nil
			then
				-- reset the plot
				plot_profile.Data.PlotData = PlotService:GetEmptyPlotDataString()

				-- quests are reset
				plot_profile.Data.Quests = {}
				plot_profile.Data.CompletedQuests = {}
			end

			plot_profile:Release()
			self._plots[player] = nil
		end
	end, "LOW")
end

function DataService:GetPlayerCredits(player: Player)
	local profile = self._profiles[player]

	if profile == nil then
		warn("[DataService]: Player does not have a profile")
		return
	end

	-- find the players plot
	local plot_profile = self._plots[player]

	if plot_profile == nil then
		warn("[DataService]: Player does not have a plot")
		return
	end

	return plot_profile.Data.Credits
end

function DataService.Client:GetPlayerCredits(player: Player)
	return self.Server:GetPlayerCredits(player)
end

function DataService:LoadPlot(player: Player, plot_uuid: string)
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

	local plot_profile = self._plots[player]

	if plot_profile == nil then
		plot_profile = PlotStore:LoadProfileAsync(plot_uuid)
		self._plots[player] = plot_profile

		plot_profile:AddUserId(player.UserId)

		plot_profile:ListenToRelease(function()
			self._plots[player] = nil
		end)

		if player:IsDescendantOf(Players) == false then
			plot_profile:Release()
			self._plots[player] = nil
		end

		plot_profile.Data.Version = 0

		-- Migrate the plot profile
		plot_profile = MigrationManager.MigratePlotProfile(player, plot_profile)
	end

	plot_profile.Data.UUID = plot_uuid
	profile.Data.LastPlotIdUsed = plot_uuid

	-- load the plot from PlotService
	---@type PlotService
	local PlotService = LMEngine.GetService("PlotService")

	PlotService:LoadPlotData(player, plot_profile.Data, plot_uuid)
	self.PlotLoaded:Fire(player, plot_profile.Data)

	return plot_profile.Data
end

function DataService.Client:LoadPlot(player: Player, plot_uuid: string)
	return self.Server:LoadPlot(player, plot_uuid)
end

function DataService:UpdatePlotData(player: Player, plot_uuid: string, plot_data: string)
	local profile = self._profiles[player]

	if profile == nil then
		warn("[DataService]: Player does not have a profile")
		return
	end

	if plot_data == nil then
		warn("[DataService]: Plot data is nil")
		return
	end

	local plot_profile = self._plots[player]

	if plot_profile == nil then
		warn("[DataService]: Plot does not exist")
		return
	end

	if plot_profile.Data.UserId ~= player.UserId then
		warn("[DataService]: Player does not own this plot")
		return
	end

	if plot_profile.Data.UUID ~= plot_uuid then
		warn("[DataService]: Plot UUID does not match")
		return
	end

	plot_profile.Data.PlotData = plot_data

	print("[DataService]: Updated plot for player: " .. player.Name)
end

function DataService:GetProfile(player: Player)
	return self._profiles[player]
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

function DataService:CreatePlot(player: Player, name: string)
	local profile = self._profiles[player]

	if profile == nil then
		warn("[DataService]: Player does not have a profile")
		return
	end

	-- check if the player already has a plot
	for uuid, plot in self._plots do
		if plot.Data.UserId == player.UserId then
			warn("[DataService]: Player already has a plot")
			return
		end
	end

	-- check if the user is allowed to create a plot (gamepass, etc)

	-- Generate a UUID for the plot
	local plot_uuid = HttpService:GenerateGUID(false)

	local plot_profile = PlotStore:LoadProfileAsync(plot_uuid)

	plot_profile:AddUserId(player.UserId)

	plot_profile:ListenToRelease(function()
		self._plots[player] = nil
	end)

	if player:IsDescendantOf(Players) == false then
		plot_profile:Release()
		self._plots[player] = nil
	end

	-- Migrate the plot profile
	plot_profile = MigrationManager.MigratePlotProfile(player, plot_profile)

	self._plots[player] = plot_profile

	-- Add the plot to the player's profile
	profile.Data.Plots[plot_uuid] = name

	print("[DataService]: Created plot for player: " .. player.Name .. " with UUID: " .. plot_uuid)

	-- Load the plot
	self:LoadPlot(player, plot_uuid)
	return plot_profile.Data
end

function DataService.Client:CreatePlot(player: Player, name: string)
	assert(
		CreatePlotRateLimiter:CheckRate(player) == true,
		"[DataService] CreatePlot: Rate limited"
	)
	assert(name ~= nil, "[DataService] CreatePlot: Name is nil")

	return self.Server:CreatePlot(player, name)
end

function DataService:GetPlot(player: Player)
	return self._plots[player]
end

function DataService:IsQuestCompleted(player: Player, questId: string)
	local plot_profile = self._plots[player]

	if plot_profile == nil then
		warn("[DataService]: Plot does not exist")
		return false
	end

	if plot_profile.Data.CompletedQuests and plot_profile.Data.CompletedQuests[questId] then
		return true
	end

	return false
end

function DataService:IsQuestStarted(player: Player, questId: string)
	local plot_profile = self._plots[player]

	if plot_profile == nil then
		warn("[DataService]: Plot does not exist")
		return false
	end

	if plot_profile.Data.Quests and plot_profile.Data.Quests[questId] then
		return true
	end

	return false
end

function DataService:SetQuestCompleted(player: Player, questId: string)
	local plot_profile = self._plots[player]

	if plot_profile == nil then
		warn("[DataService]: Plot does not exist")
		return
	end

	if plot_profile.Data.CompletedQuests == nil then
		plot_profile.Data.CompletedQuests = {}
	end

	plot_profile.Data.CompletedQuests[questId] = true
	plot_profile.Data.Quests[questId] = nil
end

function DataService:UpdateQuestProgress(player: Player, questId: string, progressData: any)
	local plot_profile = self._plots[player]

	if plot_profile == nil then
		warn("[DataService]: Plot does not exist")
		return
	end

	plot_profile.Data.Quests[questId] = progressData
end

return DataService
