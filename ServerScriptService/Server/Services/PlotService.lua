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

local Base64 = require(LMEngine.SharedDir.Base64)
local RetryAsync = require(LMEngine.SharedDir.RetryAsync)
local Signal = require(LMEngine.SharedDir.Signal)

---@type RateLimiter
local RateLimiter = LMEngine.GetModule("RateLimiter")

local PlotServiceRateLimiter = RateLimiter.NewRateLimiter(SETTINGS.MAX_RATE_PER_SECOND)

local Plot = require(dir_Modules.Plot2)
local PlotTypes = require(dir_Modules.Plot2.Types)

local StructureFactory = require(ReplicatedStorage.Game.Shared.Structures.StructureFactory)

type Plot = PlotTypes.Plot

---@class PlotService
local PlotService = LMEngine.CreateService({
	Name = "PlotService",
	Client = {
		DeleteStructure = LMEngine.CreateSignal(),
		PlotAssigned = LMEngine.CreateSignal(),
		Test = LMEngine.CreateSignal(),
		PlaceStructure = LMEngine.CreateSignal(),
	},

	---@type Plot2[]
	_plots = {},

	---@type table<Player, Plot2>
	_players = {},

	-- Signals
	StructurePlaced = Signal.new(),
	PlotAssigned = Signal.new(),
})

----- Private functions -----

local function GetPlots()
	return SETTINGS.PLOTS_LOCATION:GetChildren()
end

local function GetRandomFreePlot(plots: { Plot }): Plot?
	assert(plots, "[PlotService] GetRandomFreePlot: Free plots is nil")
	assert(#plots > 0, "[PlotService] GetRandomFreePlot: No free plots available")

	local free_plots = {}

	for _, plot in plots do
		if plot:GetPlayer() == nil then
			table.insert(free_plots, plot)
		end
	end

	if #free_plots == 0 then
		return nil
	end

	local random = free_plots[math.random(1, #free_plots)]

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

function PlotService:GetEmptyPlotDataString()
	return Base64.ToBase64(HttpService:JSONEncode({}))
end

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

			if plot == nil then
				return
			end
			--self:AssignPlot(player, plot)

			--[[local plot_data = DataService:GetPlot(player)

			if plot_data == nil then
				return
			end

			self:LoadPlotData(player, plot_data)]]
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

			if plot == nil then
				return
			end

			-- Encode the plot data
			local encoded_data = EncodePlot(plot)

			DataService:UpdatePlotData(player, plot:GetUUID(), encoded_data)

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
	assert(
		plot:GetAttribute("Occupied") ~= true,
		"[PlotService] AssignPlot: Plot is already occupied"
	)

	plot:AssignPlayer(player)

	self._players[player] = plot
	PlotService.Client.PlotAssigned:Fire(player, plot:GetModel())
	self.PlotAssigned:Fire(player, plot:GetModel())
end

function PlotService:UnassignPlot(player: Player)
	assert(player ~= nil, "[PlotService] UnassignPlot: Player is nil")
	assert(
		self._players[player] ~= nil,
		"[PlotService] UnassignPlot: Player does not have a plot assigned"
	)

	---@type Plot2
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

		local place_successful, structure = plot:PlaceStructure(structure, cframe)

		if place_successful == true then
			-- Fire the structure placed event
			self.StructurePlaced:Fire(structure)
		end

		return place_successful
	end)

	if success ~= true then
		warn("[PlotService] Failed to place structure: " .. err)
		return false
	end

	return err
end

function PlotService.Client:PlaceStructure(
	player: Player,
	structure_id: string,
	cframe: CFrame
): boolean
	-- Rate limit the function
	assert(
		PlotServiceRateLimiter:CheckRate(player) == true,
		"[PlotService] PlaceStructure: Rate limited"
	)
	assert(structure_id ~= nil, "[PlotService] PlaceStructure: Structure ID is nil")
	assert(cframe ~= nil, "[PlotService] PlaceStructure: CFrame is nil")

	return self.Server:PlaceStructure(player, structure_id, cframe) :: boolean
end

function PlotService:GetPlot(player: Player): Plot?
	return self._players[player]
end

function PlotService:LoadPlotData(player: Player, data: table, plot_uuid: string)
	local plot = self._players[player]

	if plot == nil then
		self:AssignPlot(player, GetRandomFreePlot(self._plots))
	end

	plot = self._players[player]
	assert(plot, "[PlotService] LoadPlotData: Player does not have a plot assigned")

	if data.PlotData == nil then
		data.PlotData = Base64.ToBase64(HttpService:JSONEncode({}))
	end

	local success, err = pcall(function()
		local decoded_data = Base64.FromBase64(data.PlotData)

		local plot_data = HttpService:JSONDecode(decoded_data)

		plot:Load(plot_data, plot_uuid)
	end)

	if success == false then
		warn("[PlotService] Failed to load plot data: " .. err)
	end
end

function PlotService:DeleteStructure(player: Player, structure: Model)
	assert(player, "[PlotService] DeleteStructure: Player is nil")
	assert(structure, "[PlotService] DeleteStructure: Structure is nil")

	local plot = self._players[player]
	assert(plot, "[PlotService] DeleteStructure: Player does not have a plot assigned")

	plot:DeleteStructure(structure)
end

function PlotService.Client:DeleteStructure(player: Player, structure: Model)
	assert(player, "[PlotService] DeleteStructure: Player is nil")
	assert(structure, "[PlotService] DeleteStructure: Structure is nil")

	self.Server:DeleteStructure(player, structure)
end

function PlotService:MoveStructure(player: Player, structure: Model, cframe: CFrame)
	assert(player ~= nil, "[PlotService] MoveStructure: Player is nil")
	assert(structure ~= nil, "[PlotService] MoveStructure: Structure is nil")
	assert(cframe ~= nil, "[PlotService] MoveStructure: CFrame is nil")

	local plot = self._players[player]
	assert(plot, "[PlotService] MoveStructure: Player does not have a plot assigned")

	local success, err = pcall(function()
		-- Create the structure

		local moveSuccessful = plot:MoveStructure(structure, cframe)

		return moveSuccessful
	end)

	if success ~= true then
		warn("[PlotService] Failed to move structure: " .. err)
		return false
	end

	return err
end

function PlotService.Client:MoveStructure(player: Player, structure: Model, cframe: CFrame): boolean
	-- Rate limit the function
	assert(
		PlotServiceRateLimiter:CheckRate(player) == true,
		"[PlotService] MoveStructure: Rate limited"
	)
	assert(structure ~= nil, "[PlotService] MoveStructure: Structure is nil")
	assert(cframe ~= nil, "[PlotService] MoveStructure: CFrame is nil")

	return self.Server:MoveStructure(player, structure, cframe) :: boolean
end

function PlotService:PlotHasStructure(player: Player, structureId: string): boolean
	assert(player ~= nil, "[PlotService] PlotHasStructure: Player is nil")
	assert(structureId ~= nil, "[PlotService] PlotHasStructure: StructureID is nil")

	local plot = self._players[player]
	assert(plot, "[PlotService] PlotHasStructure: Player does not have a plot assigned")

	return plot:HasStructure(structureId)
end

return PlotService
