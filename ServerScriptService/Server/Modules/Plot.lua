--!strict

--[[
{Lost Media}

-[Plot] Class
    Represents a plot in the game, which is a piece
    of land that a player can build on. The plot has
    a reference to the player
    that owns it.

    Tiles are parts in a folder called "Tiles" in the plot model.
    They can be represented as a graph data structure in order to
    find paths between them and neighbors/adjacent tiles.

	Members:

		Plot._plot_model   [Instance] -- The model of the plot
        Plot._player       [Player?]  -- The player that owns the plot

    Functions:

        Plot.new(plotModel: Instance) -- Constructor
            Creates a new instance of the Plot class

        Plot.ModelIsPlot(model: Instance) boolean
            Checks if a model instance has the structure of a plot

	Methods:

        Plot:GetPlayer() [Player?]
            Returns the player that owns the plot

        Plot:GetModel() [Instance]
            Returns the model of the plot

        Plot:AssignPlayer(player: Player) [void]
            Assigns the plot to a player

        Plot:UnassignPlayer() [void]
            Unassigns the plot from a player

        Plot:SetAttribute(attribute: string, value: any) [void]
            Sets an attribute of the plot instance model

        Plot:GetAttribute(attribute: string) [any]
            Gets an attribute of the plot instance model
--]]

local SETTINGS = {
	-- The size of a tile in studs in X and Z dimensions
	TILE_SIZE = 8,
}

local PlacementType = require(game:GetService("ReplicatedStorage").Game.Shared.Placement.Types)

----- Types -----

---@class PlotModel
export type PlotModel = Model & {
	Tiles: Folder,
	Structures: Folder,
}

type IPlot = {
	__index: IPlot,
	__tostring: (self: Plot) -> string,

	ModelIsPlot: (model: Instance) -> boolean,
	new: (plotModel: Instance) -> Plot,

	GetPlayer: (self: Plot) -> Player?,
	GetModel: (self: Plot) -> Instance,
	AssignPlayer: (self: Plot, player: Player) -> (),
	UnassignPlayer: (self: Plot) -> (),

	SetAttribute: (self: Plot, attribute: string, value: any) -> (),
	GetAttribute: (self: Plot, attribute: string) -> any,

	PlaceStructure: (self: Plot, state: PlacementType.ServerState) -> (),
}

export type Plot = typeof(setmetatable({} :: PlotMembers, {} :: IPlot))

----- Private variables -----

local NEIGHBORS = {
	Vector3.new(0, 0, SETTINGS.TILE_SIZE),
	Vector3.new(0, 0, -SETTINGS.TILE_SIZE),
	Vector3.new(SETTINGS.TILE_SIZE, 0, 0),
	Vector3.new(-SETTINGS.TILE_SIZE, 0, 0),
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineServer
local LMEngine = require(ReplicatedStorage.LMEngine)

---@type Graph
local Graph = require(ReplicatedStorage.LMEngine.Shared.DS.Graph)
type Graph = Graph.Graph

type PlotMembers = {
	_plot_model: Instance,
	_player: Player?,
	_tiles: Graph,
}

---@class Plot
local Plot: IPlot = {} :: IPlot
Plot.__index = Plot

----- Private functions -----

local function InitializePlotTiles(tiles: { Instance }): Graph
	local graph = Graph.new() :: Graph

	local positions = {} :: { [Vector3]: Graph.Node }

	for i, tile in tiles do
		if not tile:IsA("Part") then
			warn("Tile is not a part:", tile)
			continue
		end

		tile.Name = tostring(i)

		local node = Graph.Node(i, tile)
		graph:AddNode(node)

		positions[tile.Position] = node
	end

	-- Add edges between adjacent tiles

	for _, tile in tiles do
		if not tile:IsA("Part") then
			continue
		end

		tile = tile :: Part
		for _, offset in NEIGHBORS do
			local neighbor_position = tile.Position + offset
			local neighbor = positions[neighbor_position]
			if neighbor then
				graph:AddEdge(positions[tile.Position], neighbor)
			end
		end
	end

	return graph
end

----- Public functions -----

-- Checks if a model instance has the structure of a plot
--- @param model Instance -- The model to check
--- @returns boolean -- Whether the model is a plot
function Plot.ModelIsPlot(model: Instance): boolean
	if model == nil then
		return false
	end

	if not model:IsA("Model") then
		return false
	end

	local tiles = model:FindFirstChildOfClass("Folder")
	if tiles == nil then
		return false
	end

	local structures = model:FindFirstChildOfClass("Folder")
	if structures == nil then
		return false
	end

	return true
end

function Plot.new(plot_model: Instance)
	assert(Plot.ModelIsPlot(plot_model) == true, "Model is not a plot")

	local self = setmetatable({}, Plot)
	self._plot_model = plot_model
	self._player = nil :: Player?

	self._tiles = InitializePlotTiles(plot_model:FindFirstChild("Tiles"):GetChildren())

	return self
end

function Plot:GetPlayer(): Player?
	return self._player
end

function Plot:GetModel(): Instance
	return self._plot_model
end

function Plot:AssignPlayer(player: Player)
	assert(player ~= nil, "Player cannot be nil")
	assert(self._player == nil, "Plot is already assigned to a player")
	self._player = player
end

function Plot:UnassignPlayer()
	assert(self._player ~= nil, "Plot is not assigned to a player")
	self._player = nil
end

function Plot:SetAttribute(attribute: string, value: any)
	self._plot_model:SetAttribute(attribute, value)
end

function Plot:GetAttribute(attribute: string): any
	return self._plot_model:GetAttribute(attribute)
end

function Plot.__tostring(self: Plot): string
	return "Plot " .. self._plot_model.Name
end

return Plot
