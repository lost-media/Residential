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

local function CheckHitbox(character, object, plot)
	if not object then
		return false
	end
	local collisionPoints = workspace:GetPartsInPart(object.PrimaryPart)

	-- Checks if there is collision on any object that is not a child of the object and is not a child of the player
	for i = 1, #collisionPoints, 1 do
		if collisionPoints[i].CanTouch ~= true then
			continue
		end

		if
			collisionPoints[i]:IsDescendantOf(object) == true
			or collisionPoints[i]:IsDescendantOf(character) == true
			or collisionPoints[i] == plot
		then
			-- Skip this iteration if any of the conditions are true
			continue
		end

		return true
	end

	return false
end

-- Checks if the object exceeds the boundries given by the plot
local function CheckBoundaries(plot: BasePart, primary: BasePart): boolean
	local pos: CFrame = plot.CFrame
	local size: Vector3 = CFrame.fromOrientation(0, primary.Orientation.Y * math.pi / 180, 0) * primary.Size
	local currentPos: CFrame = pos:Inverse() * primary.CFrame

	local xBound: number = (plot.Size.X - size.X)
	local zBound: number = (plot.Size.Z - size.Z)

	return currentPos.X > xBound or currentPos.X < -xBound or currentPos.Z > zBound or currentPos.Z < -zBound
end

local function HandleCollisions(character: Model, item, collisions: boolean, plot): boolean
	if not collisions then
		item.PrimaryPart.Transparency = 1
		return true
	end

	local collision = CheckHitbox(character, item, plot)
	if collision ~= nil then
		item:Destroy()
		return false
	end

	item.PrimaryPart.Transparency = 1
	return true
end

local function GetCollisions(name: string): boolean
	return true
end

local function place(player, name: string, location: Instance, prefabs: Instance, cframe: CFrame, plot: BasePart)
	local collisions = GetCollisions(name)
	local item = prefabs:FindFirstChild(name):Clone()
	item.PrimaryPart.CanCollide = false
	item:PivotTo(cframe)

	if plot then
		if CheckBoundaries(plot, item.PrimaryPart) == true then
			return
		end

		item.Parent = location

		return HandleCollisions(player.Character, item, collisions, plot)
	end

	return HandleCollisions(player.Character, item, collisions, plot)
end

-- Edit if you want to have a server check if collisions are enabled or disabled
local function getCollisions(name: string): boolean
	return true
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
	assert(structure ~= nil, "[PlotService] PlaceStructure: Structure is nil")

	local structure_id = structure:GetAttribute("Id")

	if structure_id == nil then
		structure_id = self._uid_generator:GenerateId()
		structure:SetAttribute("Id", structure_id)
	end

	local collisions = GetCollisions(structure)

	local item = prefabs:FindFirstChild(name):Clone()
	item.PrimaryPart.CanCollide = false
	item:PivotTo(cframe)

	if plot then
		if CheckBoundaries(plot, item.PrimaryPart) == true then
			return
		end

		item.Parent = location

		return HandleCollisions(player.Character, item, collisions, plot)
	end

	return HandleCollisions(player.Character, item, collisions, plot)
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
