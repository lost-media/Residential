--!strict

--[[
{Lost Media}

-[PlotService] Service
    Central service that manages the plots in the game.
	This service is responsible for assigning plots to players
	and serializing the plot data to the client.

	Members:

		PlotService._plots   [table] -- Player -> Plot
			Stores the mapping of players to plots

	Methods [PlotService]:

		PlotService:AssignPlot(player: Player, plot: Instance) -- Assigns a plot to a player
			player [Player]
			plot   [Instance]
--]]

local SETTINGS = {
	PLOTS_LOCATION = workspace.Plots :: Folder,
	MAX_RETRIES = 5,
}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine)

---@type RetryAsync
local RetryAsync = LMEngine.GetShared("RetryAsync")

local Plot = require(script.Parent.Parent.Modules.Plot)

type Plot = Plot.Plot

---@class PlotService
local PlotService = LMEngine.CreateService({
	Name = "PlotService",
	Client = {
		PlotAssigned = LMEngine.CreateSignal(),
		Test = LMEngine.CreateSignal(),
		--PlaceStructure = Knit.CreateSignal();
	},

	---@type Plot[]
	_plots = {},

	---@type table<Player, Plot>
	_players = {},
})

----- Private functions -----

local function GetPlots()
	return SETTINGS.PLOTS_LOCATION:GetChildren()
end

local function GetRandomFreePlot(plots: { Plot }): Plot?
	assert(plots, "[PlotService] GetRandomFreePlot: Free plots is nil")
	assert(#plots > 0, "[PlotService] GetRandomFreePlot: No free plots available")

	local random = plots[math.random(1, #plots)]

	return random
end

local function CreatePlotObjects()
	local plots = GetPlots()
	local plot_objects: { Plot } = {}

	for _, plot in ipairs(plots) do
		local success, err = pcall(function()
			local plot_object = Plot.new(plot)
			table.insert(plot_objects, plot_object)
		end)

		if not success then
			warn("[PlotService] Failed to create plot: " .. err)
		end
	end

	return plot_objects
end

----- Public functions -----

function PlotService:Init()
	print("[PlotService] initialized")

	self._plots = CreatePlotObjects()
end

function PlotService:Start()
	print("[PlotService] started")

	---@type PlayerService
	local PlayerService = LMEngine.GetService("PlayerService")

	PlayerService:RegisterPlayerAdded(function(player)
		local success, data = RetryAsync(function()
			local plot = GetRandomFreePlot(self._plots)
			self:AssignPlot(player, plot)
		end, SETTINGS.MAX_RETRIES)

		if not success then
			warn("[PlotService] Failed to assign plot to player: " .. data)
			return
		end

		print("[PlotService] Assigned plot to player: " .. player.Name)
	end)

	PlayerService:RegisterPlayerRemoved(function(player)
		local success, data = RetryAsync(function()
			self:UnassignPlot(player)
		end, SETTINGS.MAX_RETRIES)

		if not success then
			warn("[PlotService] Failed to unassign plot from player: " .. data)
			return
		end

		print("[PlotService] Unassigned plot from player: " .. player.Name)
	end)
end

function PlotService:AssignPlot(player: Player, plot: Plot)
	assert(player, "[PlotService] AssignPlot: Player is nil")
	assert(plot, "[PlotService] AssignPlot: Plot is nil")
	assert(plot:GetAttribute("Occupied") ~= true, "[PlotService] AssignPlot: Plot is already occupied")

	plot:AssignPlayer(player)

	self._players[player] = plot
	PlotService.Client.PlotAssigned:Fire(player, plot:GetModel())
end

function PlotService:UnassignPlot(player: Player)
	assert(player ~= nil, "[PlotService] UnassignPlot: Player is nil")
	assert(self._players[player] ~= nil, "[PlotService] UnassignPlot: Player does not have a plot assigned")

	---@type Plot
	local plot: Plot = self._players[player]

	plot:UnassignPlayer()

	self._players[player] = nil
end

return PlotService
