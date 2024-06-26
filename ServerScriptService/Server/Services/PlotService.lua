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

	MAX_RATE_PER_SECOND = 10,
}

----- Private variables -----

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine)

local dir_Modules = script.Parent.Parent.Modules

---@type RetryAsync
local RetryAsync = LMEngine.GetShared("RetryAsync")

---@type RateLimiter
local RateLimiter = LMEngine.GetModule("RateLimiter")

local Base64 = require(ReplicatedStorage.LMEngine.Shared.Base64)

local PlotServiceRateLimiter = RateLimiter.NewRateLimiter(SETTINGS.MAX_RATE_PER_SECOND)

local Plot = require(dir_Modules.Plot2)
local PlotTypes = require(dir_Modules.Plot2.Types)

local StructureFactory = require(ReplicatedStorage.Game.Shared.Structures.StructureFactory)

type Plot = PlotTypes.Plot

---@class PlotService
local PlotService = LMEngine.CreateService({
	Name = "PlotService",
	Client = {
		PlotAssigned = LMEngine.CreateSignal(),
		Test = LMEngine.CreateSignal(),
		PlaceStructure = LMEngine.CreateSignal(),
	},

	---@type Plot2[]
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

local function EncodePlot(plot: Plot): string
	local plot_data = plot:Serialize()
	local serialized_data = HttpService:JSONEncode(plot_data)

	-- base64 encode the data
	local base64_data = Base64.ToBase64(serialized_data)

	return base64_data
end

----- Public functions -----

function PlotService:Init()
	self._plots = CreatePlotObjects()
end

function PlotService:Start()
	---@type PlayerService
	local PlayerService = LMEngine.GetService("PlayerService")

	---@type DataService
	local DataService = LMEngine.GetService("DataService")

	PlayerService:RegisterPlayerAdded(function(player)
		local success, data = RetryAsync(function()
			local plot = GetRandomFreePlot(self._plots)
			self:AssignPlot(player, plot)

			local plot_data = DataService:GetPlot(player)

			if plot_data == nil then
				return
			end

			-- Decode the test data
			local decoded_data = Base64.FromBase64(plot_data)

			local success, err = pcall(function()
				local data = HttpService:JSONDecode(decoded_data)

				plot:Load(data)
			end)
		end, SETTINGS.MAX_RETRIES)

		if not success then
			warn("[PlotService] Failed to assign plot to player: " .. data)
			return
		end

		print("[PlotService] Assigned plot to player: " .. player.Name)
	end)

	PlayerService:RegisterPlayerRemoved(function(player)
		local success, data = RetryAsync(function()
			-- Serialize the plot data

			local plot = self._players[player]
			assert(plot, "[PlotService]: Player does not have a plot assigned")

			-- Encode the plot data
			local encoded_data = EncodePlot(plot)

			DataService:UpdatePlot(player, encoded_data)

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

function PlotService:PlaceStructure(player: Player, structure_id: string, cframe: CFrame): boolean
	assert(player ~= nil, "[PlotService] PlaceStructure: Player is nil")
	assert(structure_id ~= nil, "[PlotService] PlaceStructure: Structure ID is nil")
	assert(cframe ~= nil, "[PlotService] PlaceStructure: CFrame is nil")

	local plot = self._players[player]
	assert(plot, "[PlotService] PlaceStructure: Player does not have a plot assigned")

	local success, err = pcall(function()
		-- Create the structure
		local structure = StructureFactory.MakeStructure(structure_id)
		assert(structure ~= nil, "[PlotService] PlaceStructure: Structure not found")

		local place_successful = plot:PlaceStructure(structure, cframe)

		return place_successful
	end)

	if success ~= true then
		warn("[PlotService] Failed to place structure: " .. err)
		return false
	end

	if err == true then
		---@type DataService
		--local DataService = LMEngine.GetService("DataService");

		--DataService:UpdatePlot(player, plot);
	end

	return err
end

function PlotService.Client:PlaceStructure(player: Player, structure_id: string, cframe: CFrame): boolean
	-- Rate limit the function
	assert(PlotServiceRateLimiter:CheckRate(player) == true, "[PlotService] PlaceStructure: Rate limited")
	assert(structure_id ~= nil, "[PlotService] PlaceStructure: Structure ID is nil")
	assert(cframe ~= nil, "[PlotService] PlaceStructure: CFrame is nil")

	return self.Server:PlaceStructure(player, structure_id, cframe) :: boolean
end

return PlotService
