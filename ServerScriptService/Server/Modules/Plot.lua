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

	Each structure that is placed on the plot will generate a unique ID
	that is used to identify the structure. This can be used to serialize
	the structure data to the DataStore.

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

	PlaceStructure: (self: Plot, structure: Model, state: PlacementType.ServerState) -> boolean,
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

---@type Trove
local Trove = require(ReplicatedStorage.LMEngine.Shared.Trove)

local PlacementUtils = require(ReplicatedStorage.Game.Shared.Placement.Utils)
local StructureUtils = require(ReplicatedStorage.Game.Shared.Structures.Utils)

---@type UniqueIdGenerator
local UniqueIdGenerator = LMEngine.GetShared("UniqueIdGenerator")

---@type Graph
local Graph = require(ReplicatedStorage.LMEngine.Shared.DS.Graph)
type Graph = Graph.Graph

type PlotMembers = {
	_plot_model: Instance,
	_player: Player?,
	_tiles: Graph,
	_trove: Trove.Trove,
	_uid_generator: UniqueIdGenerator.UniqueIdGenerator,
}

---@class Plot
local Plot: IPlot = {} :: IPlot
Plot.__index = Plot

----- Private functions -----

local function ThrowIfStateInvalid(state: PlacementType.ServerState)
	assert(state, "[PlotService] PlaceStructure: State is nil")
	assert(state._tile, "[PlotService] PlaceStructure: State._tile is nil")
	assert(state._structure_id, "[PlotService] PlaceStructure: State._structure_id is nil")
	assert(state._level, "[PlotService] PlaceStructure: State._level is nil")
	assert(state._rotation, "[PlotService] PlaceStructure: State._rotation is nil")
	--assert(state._is_stacked, "[PlotService] PlaceStructure: State._is_stacked is nil")
end

local function InitializePlotTiles(tiles: { Instance }): Graph
	local graph = Graph.new() :: Graph

	local positions = {} :: { [Vector3]: Graph.Node }

	for i, tile in tiles do
		if not tile:IsA("Part") then
			warn("Tile is not a part:", tile)
			continue
		end

		tile.Name = tostring(i)

		local node = Graph.Node(tile, tile)
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
	self._trove = Trove.new()
	self._uid_generator = UniqueIdGenerator.new()

	self._tiles = InitializePlotTiles(plot_model:FindFirstChild("Tiles"):GetChildren())

	return self
end

function Plot:Load(data) -- loading existing plot data
	-- Load existing IDs into the UniqueIdGenerator
	local ids: { number } = {}

	self._uid_generator:LoadExistingIds(ids)
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

function Plot:PlaceStructure(structure: Model, state: PlacementType.ServerState): boolean
	assert(structure ~= nil, "Structure cannot be nil")
	assert(state ~= nil, "State cannot be nil")

	ThrowIfStateInvalid(state)

	-- Check if the structure can be placed on the plot
	local tile = self._tiles:GetNode(state._tile)

	if tile == nil then
		warn("Tile not found in plot")
		return false
	end

	-- Create the structure
	local structure_instance = self._trove:Clone(structure)

	-- Calculate the position of the structure

	tile = tile:GetValue() :: Part

	if state._is_stacked == false then
		if tile:GetAttribute("Occupied") == true then
			-- See if there is already a structure on the same level and tile
			local structures = self:GetStructuresOnTile(tile)

			for _, structure in structures do
				if structure:GetAttribute("Level") == state._level then
					-- Cannot place structure on an occupied tile
					return false
				end
			end

			-- Otherwise, it is good!
		end

		local new_cframe = PlacementUtils.GetSnappedTileCFrame(tile, state)

		-- Set the structure's position to the tile's position
		PlacementUtils.MoveModelToCFrame(structure_instance, new_cframe, true)
	else
		local stackedOn: Model? = state._stacked_structure

		if stackedOn == nil then
			error("Stacked object is nil")
		end

		local stackedOnPlaceable = self:GetPlaceable(stackedOn)

		if stackedOnPlaceable == nil then
			error("Stacked object is not on the plot")
		end

		-- Get snapped point
		local snappedPoint: Attachment? = state._mounted_attachment

		if snappedPoint == nil then
			error("Snapped point is nil")
		end

		if snappedPoint:GetAttribute("Occupied") == true then
			-- Cannot place structure on an occupied snapped point
			return false
		end

		local placeableInfo = StructureUtils.GetStructureFromId(state._structure_id)

		local snappedPointsTaken: { Attachment } = { snappedPoint } -- state._attachments or { snappedPoint }

		-- Set all snapped points as occupied
		for _, taken in ipairs(snappedPointsTaken) do
			taken:SetAttribute("Occupied", true)
		end

		local cframe = PlacementUtils.GetSnappedAttachmentCFrame(tile, snappedPoint, placeableInfo, state)

		-- Don't rotate or level the structure
		PlacementUtils.MoveModelToCFrame(structure_instance, cframe, true)
	end

	tile:SetAttribute("Occupied", true)

	-- Set the structure's parent to the plot model
	structure_instance.Parent = self._plot_model.Structures

	-- Set the structure's attributes

	print(state._level)

	structure_instance:SetAttribute("PlotId", self._uid_generator:GenerateId())
	structure_instance:SetAttribute("Tile", tile.Name)
	structure_instance:SetAttribute("Level", state._level)
	structure_instance:SetAttribute("Rotation", state._rotation)
	structure_instance:SetAttribute("IsStacked", state._is_stacked)

	if state._is_stacked == true then
		structure_instance:SetAttribute("StackedOn", state._stacked_structure:GetAttribute("PlotId"))
	end

	return true
end

function Plot:GetPlaceable(model: Model)
	local parent = model.Parent

	while parent ~= nil do
		if parent == self._plot_model then
			return model
		end

		parent = parent.Parent
	end

	return nil
end

function Plot:GetStructuresOnTile(tile: Graph.Node): { Model }
	local structures = {} :: { Model }

	for _, structure in pairs(self._plot_model.Structures:GetChildren()) do
		if structure:GetAttribute("Tile") == tile.Name then
			table.insert(structures, structure)
		end
	end

	return structures
end

function Plot.__tostring(self: Plot): string
	return "Plot " .. self._plot_model.Name
end

return Plot
