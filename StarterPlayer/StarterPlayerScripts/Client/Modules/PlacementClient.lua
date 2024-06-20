--!strict

--[[
{Lost Media}

-[PlacementClient] Module
    Provides a class for managing the placement of objects in a 3D space
    and snapping them to a grid. This module is used to manage the placement
    of objects in the game.

	Members:

        PlacementClient._state [Rodux.Store] -- The state of the placement client
            The state of the placement client

        PlacementClient._mouse [Mouse] -- The mouse object
            The mouse object

        PlacementClient._trove [Trove] -- The trove object
            The trove object

        PlacementClient._plot [Model] -- The plot model
            The plot model

    Functions:

        PlacementClient.new  [PlacementClient] -- Constructor
            Creates a new instance of the PlacementClient class

	Methods:

        PlacementClient:Destroy() -- Destructor
            Destroys the placement client

        PlacementClient:InitiatePlacement(model: Model) -- Method
            Initiates the placement of a model

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
		_can_confirm_placement = false,
		_rotation = 0,
		_is_stacked = false,
		_level = 1,
	} :: State,

	ROTATION_INCREMENT = 90,
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
	_ghost_structure: Model?,
	_can_confirm_placement: boolean,
	_rotation: number,
	_is_stacked: boolean,
	_level: number,
}

export type PlacementClient = typeof(setmetatable({} :: PlacementClientMembers, {} :: IPlacementClient))

----- Private variables -----

local UserInputService = game:GetService("UserInputService")

local PlacementUtils = require(ReplicatedStorage.Game.Shared.PlacementUtils)

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

local can_confirm_placement_reducers = Rodux.createReducer(false, {
	["CAN_CONFIRM_PLACEMENT_CHANGED"] = function(state: State, action)
		return action._can_confirm_placement
	end,
})

local rotation_reducers = Rodux.createReducer(0, {
	["ROTATION_CHANGED"] = function(state: State, action)
		return action._rotation
	end,
})

local is_stacked_reducers = Rodux.createReducer(false, {
	["IS_STACKED_CHANGED"] = function(state: State, action)
		return action._is_stacked
	end,
})

local level_reducers = Rodux.createReducer(1, {
	["LEVEL_CHANGED"] = function(state: State, action)
		return action._level
	end,
})

local reducer = Rodux.combineReducers({
	_tile = tile_reducers,
	_placement_type = placement_type_reducers,
	_ghost_structure = ghost_structure_reducers,
	_can_confirm_placement = can_confirm_placement_reducers,
	_rotation = rotation_reducers,
	_is_stacked = is_stacked_reducers,
	_level = level_reducers,
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

local function RotationChanged(rotation: number)
	return {
		type = "ROTATION_CHANGED",
		_rotation = rotation,
	}
end

local function CanConfirmPlacementChanged(can_confirm_placement: boolean)
	return {
		type = "CAN_CONFIRM_PLACEMENT_CHANGED",
		_can_confirm_placement = can_confirm_placement,
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

local function SnapToTileWithLevel(client: PlacementClient, tile: BasePart)
	local state: State = client._state:getState()

	local ghost_structure = state._ghost_structure

	if ghost_structure == nil then
		return
	end

	if tile == nil then
		return
	end

	local newCFrame = PlacementUtils.GetSnappedTileCFrame(tile, state)
	print(newCFrame)
	--self:MoveModelToCF(ghost_structure, newCFrame, false);
end

local function UpdatePosition(client: PlacementClient)
	-- Completely state dependent
	local state: State = client._state:getState()

	if state._is_stacked == true then
		--self:SnapToAttachment(self.state.mountedAttachment, self.state.tile)
	else
		SnapToTileWithLevel(client, state._tile)
	end
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

	UpdatePosition(client)
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

	local state: State = self._state:getState()

	if PlacementTypeIsNone(state) == false then
		return
	end

	self._trove:Add(model)

	self._state:dispatch(PlacementTypeChanged("Place"))
	self._state:dispatch(UpdateGhostStructure(model))

	self._trove:BindToRenderStep("PlacementClient", 2, function(dt: number)
		RenderSteppedUpdate(self, dt)
	end)

	self._trove:Add(UserInputService.InputBegan:Connect(function(input: InputObject)
		if input.KeyCode == Enum.KeyCode.R then
			state = self._state:getState()
			local rotation = state._rotation + SETTINGS.ROTATION_INCREMENT
			if rotation >= 360 then
				rotation = 0
			end
			self._state:dispatch(RotationChanged(rotation))
		end
	end))
end

function PlacementClient:Destroy()
	self._state:destruct()
	self._trove:Destroy()
end

return PlacementClient
