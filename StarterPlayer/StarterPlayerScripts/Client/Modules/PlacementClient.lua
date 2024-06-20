--!strict

--[[
{Lost Media}

-[PlacementClient] Module
    Provides a class for managing the placement of objects in a 3D space
    and snapping them to a grid. This module is used to manage the placement
    of objects in the game.

	Members:

        Graph._nodes   [table] -- Node -> Node
            Stores the mapping of nodes to nodes

    Functions:

        PlacementClient.new  [PlacementClient] -- Constructor
            Creates a new instance of the PlacementClient class

	Methods:

        Graph:AddNode(node: Node) [void]
            Adds a node to the graph

        Graph:RemoveNode(node: Node) [void]
            Removes a node from the graph

        Graph:AddEdge(node1: Node, node2: Node) [void]
            Adds an edge between two nodes

        Graph:RemoveEdge(node1: Node, node2: Node) [void]
            Removes an edge between two nodes

        Graph:GetNeighbors(node: Node) {Node[]}?
            Returns the neighbors of a node

        Graph:GetNodes() {Node[]}
            Returns the nodes in the graph

        Graph:HasNode(node: Node) boolean
            Returns true if the graph contains the node

        Graph:HasEdge(node1: Node, node2: Node) boolean
            Returns true if the graph contains an edge between the two nodes

        Graph:Clear() [void]
            Clears the graph

        Graph:Size() number
            Returns the number of nodes in the graph

--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mouse = require(ReplicatedStorage.LMEngine.Client.Modules.Mouse)
local Rodux = require(ReplicatedStorage.LMEngine.Shared.Rodux)
local Trove = require(ReplicatedStorage.LMEngine.Shared.Trove)

local SETTINGS = {
	INITIAL_STATE = {
		_placement_type = "None",
		_tile = nil,
		_ghost_structure = nil,
	} :: State,
}

----- Types -----

type IPlacementClient = {
	__index: IPlacementClient,
	new: () -> PlacementClient,

	Destroy: (self: PlacementClient) -> (),
	InitiatePlacement: (self: PlacementClient, model: Model) -> (),
}

type PlacementClientMembers = {
	_state: Rodux.Store,
	_mouse: Mouse.Mouse,
	_trove: Trove.Trove,
	_plot: Model,
}

type PlacementType = "Place" | "Move" | "Remove" | "None"

type State = {
	_tile: BasePart?,
	_placement_type: PlacementType,
}

export type PlacementClient = typeof(setmetatable({} :: PlacementClientMembers, {} :: IPlacementClient))

----- Private variables -----

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)

local Store = Rodux.Store

---@class PlacementClient;
local PlacementClient: IPlacementClient = {} :: IPlacementClient
PlacementClient.__index = PlacementClient

----- Reducers -----

local tile_reducers = Rodux.createReducer(nil, {
	["TILE_CHANGED"] = function(state: State, action)
		return action._tile
	end,
})

local placement_type_reducers = Rodux.createReducer("None", {
	["PLACEMENT_TYPE_CHANGED"] = function(state: State, action)
		return action._placement_type
	end,
})

local ghost_structure_reducers = Rodux.createReducer(nil, {
	["GHOST_STRUCTURE_UPDATED"] = function(state: State, action)
		return action._ghost_structure
	end,
})

local reducer = Rodux.combineReducers({
	_tile = tile_reducers,
	_placement_type = placement_type_reducers,
	_ghost_structure = ghost_structure_reducers,
})

----- Private functions -----

local function ModelIsPlot(model: Model)
	if model == nil then
		return false
	end

	if model:IsA("Model") == false then
		return false
	end

	local tiles = model:FindFirstChild("Tiles")

	if tiles == nil then
		return false
	end

	if tiles:IsA("Folder") == false then
		return false
	end

	local structures = model:FindFirstChild("Structures")

	if structures == nil then
		return false
	end

	if structures:IsA("Folder") == false then
		return false
	end

	return true
end

local function PartIsTile(part: BasePart, plot: Model?)
	if plot == nil then
		return false
	end

	if ModelIsPlot(plot) == false then
		return false
	end

	local tiles = plot:FindFirstChild("Tiles")

	return part:FindFirstAncestorWhichIsA("Folder") == tiles
end

-- Determines if the client is moving/placing/removing an object
local function PlacementTypeIsNone(state: State)
	return state._placement_type == "None"
end

local function TileChanged(tile: BasePart)
	return {
		type = "TILE_CHANGED",
		_tile = tile,
	}
end

local function PlacementTypeChanged(placement_type: PlacementType)
	return {
		type = "PLACEMENT_TYPE_CHANGED",
		_placement_type = placement_type,
	}
end

local function UpdateGhostStructure(structure: Model)
	return {
		type = "GHOST_STRUCTURE_UPDATED",
		_ghost_structure = structure,
	}
end

local function AttemptToSnapToTile(client: PlacementClient, tile: BasePart)
	local state: State = client._state:getState()

	local currentTile = state._tile
	if currentTile == nil or currentTile ~= tile then
		client._state:dispatch(TileChanged(tile))
	end

	--self:UpdateCanConfirmPlacement(true)
end

local function RenderSteppedUpdate(client: PlacementClient, dt: number)
	local state: State = client._state:getState()

	-- The client is not in a placement state
	if PlacementTypeIsNone(state) == true then
		return
	end

	local plot = client._plot
	local mouse = client._mouse

	local target = mouse:GetTarget()

	--[[
    -- Get the closest base part to the hit position
	local closestInstance = mouse:GetTarget() --mouse:GetClosestInstanceToMouseFromParent(self.plot)

	-- The radius visual should follow the ghost structure
	if self.state.radiusVisual then
		self.state.radiusVisual.CFrame = CFrame.new(self.state.ghostStructure.PrimaryPart.Position)
		self.state.radiusVisual.CFrame = self.state.radiusVisual.CFrame * CFrame.Angles(0, math.rad(90), math.rad(90))
	end

	if closestInstance == nil then
		if self.state.tile == nil then
			return
		end
		closestInstance = self.state.tile
	end

	-- Check if its a tile
	if self:PartIsTile(closestInstance) == true then
		self:AttemptToSnapToTile(closestInstance)
	else
		self:AttemptToSnapToAttachment(closestInstance)
	end

	self:UpdateLevelVisibility()

	self:UpdatePosition()
	--self:UpdateSelectionBox()
    ]]
	--

	if target == nil then
		if state._tile == nil then
			return
		end
		target = state._tile
	end

	if PartIsTile(target, plot) == true then
		-- Attempt to snap to the tile
		AttemptToSnapToTile(client, target)
	else
		-- Attempt to snap to the attachment
	end
end

----- Public functions -----

function PlacementClient.new(plot: Model)
	assert(ModelIsPlot(plot) == true, "[PlacementClient] new: Plot must be a Model")

	local self = setmetatable({}, PlacementClient)

	self._state = Store.new(reducer, SETTINGS.INITIAL_STATE, {})

	self._mouse = Mouse.new()
	self._trove = Trove.new()
	self._plot = plot

	return self
end

function PlacementClient:InitiatePlacement(model: Model)
	assert(model:IsA("Model"), "[PlacementClient] InitiatePlacement: Model must be a Model")

	local state = self._state:getState()

	if PlacementTypeIsNone(state) == false then
		return
	end

	self._state:dispatch(PlacementTypeChanged("Place"))
	self._state:dispatch(UpdateGhostStructure(model))

	self._trove:BindToRenderStep("PlacementClient", 2, function(dt: number)
		RenderSteppedUpdate(self, dt)
	end)
end

function PlacementClient:Destroy()
	self._state:destruct()
	self._trove:Destroy()
end

return PlacementClient
