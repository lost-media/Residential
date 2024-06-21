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

		PlacementClient:IsPlacing() -- Method
			Determines if the client is placing an object

		PlacementClient:IsActive() -- Method
			Determines if the client is active

		PlacementClient:CancelPlacement() -- Method
			Cancels the placement of an object

		PlacementClient:RaiseLevel() -- Method
			Raises the level of the object

		PlacementClient:LowerLevel() -- Method
			Lowers the level of the object

--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mouse = require(ReplicatedStorage.LMEngine.Client.Modules.Mouse)
local Rodux = require(ReplicatedStorage.LMEngine.Shared.Rodux)
local Signal = require(ReplicatedStorage.LMEngine.Shared.Signal)
local Trove = require(ReplicatedStorage.LMEngine.Shared.Trove)

local PlacementType = require(ReplicatedStorage.Game.Shared.Placement.Types)

local SETTINGS = {
	INITIAL_STATE = {
		_placement_type = "None",
		_tile = nil,
		_ghost_structure = nil,
		_can_confirm_placement = true,
		_rotation = 0,
		_is_stacked = false,
		_level = 1,
	} :: State,

	ROTATION_INCREMENT = 90,
	TRANSPARENCY_DIM_FACTOR = 1.5,
	MAX_LEVEL = 9,
}

----- Types -----

type IPlacementClient = {
	__index: IPlacementClient,
	new: () -> PlacementClient,

	InitiatePlacement: (self: PlacementClient, model: Model) -> (),
	IsPlacing: (self: PlacementClient) -> boolean,
	CancelPlacement: (self: PlacementClient) -> (),
	IsActive: (self: PlacementClient) -> boolean,
	Destroy: (self: PlacementClient) -> (),

	RaiseLevel: (self: PlacementClient) -> (),
	LowerLevel: (self: PlacementClient) -> (),
}

type PlacementClientMembers = {
	_state: Rodux.Store,
	_mouse: Mouse.Mouse,
	_trove: Trove.Trove,
	_plot: Model,
	_active: boolean,

	PlacementConfirmed: Signal.Signal<PlacementType.ServerState>,
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

local PlacementUtils = require(ReplicatedStorage.Game.Shared.Placement.Utils)

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

local can_confirm_placement_reducers = Rodux.createReducer(true, {
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

local function DimModel(model: Model)
	-- If the model is already dimmed, no need to dim it again
	if model:GetAttribute("Dimmed") == true then
		return
	end

	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("BasePart") then
			instance:SetAttribute("OriginalTransparency", instance.Transparency)
			instance.Transparency = 1 - (1 - instance.Transparency) / SETTINGS.TRANSPARENCY_DIM_FACTOR
		end
	end

	model:SetAttribute("Dimmed", true)
end

function UndimModel(model: Model)
	if model:GetAttribute("Dimmed") == false then
		return
	end

	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("BasePart") then
			local originalTransparency = instance:GetAttribute("OriginalTransparency")
			if originalTransparency ~= nil then
				instance.Transparency = originalTransparency
			end
		end
	end

	model:SetAttribute("Dimmed", nil)
end

local function UncollideModel(model: Model)
	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("BasePart") then
			instance.CanCollide = false
		end
	end
end

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

local function UpdateTileState(client: PlacementClient, tile: BasePart)
	local state: State = client._state:getState()

	local currentTile = state._tile
	if currentTile == nil or currentTile ~= tile then
		client._state:dispatch(TileChanged(tile))
	end
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
	PlacementUtils.MoveModelToCFrame(ghost_structure, newCFrame, false)
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
		-- Update the tile state and determine if the tile has changed
		UpdateTileState(client, target)
	else
		-- Attempt to snap to the attachment
		--AttemptToSnapToAttachment(closestInstance)
	end

	UpdatePosition(client)
end

local function MakeSelectionBox()
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
	selectionBox.LineThickness = 0.05

	selectionBox.SurfaceTransparency = 0.5
	selectionBox.SurfaceColor3 = Color3.fromRGB(0, 255, 0)

	return selectionBox
end

----- Public functions -----

function PlacementClient.new(plot: Model)
	assert(ModelIsPlot(plot) == true, "[PlacementClient] new: Plot must be a Model")

	local self = setmetatable({}, PlacementClient)

	self._state = Store.new(reducer, SETTINGS.INITIAL_STATE, {})

	self._active = true
	self._mouse = Mouse.new()
	self._trove = Trove.new()
	self._plot = plot

	self._mouse:SetFilterType(Enum.RaycastFilterType.Include)
	self._mouse:SetTargetFilter({
		plot:FindFirstChild("Tiles"),
		plot:FindFirstChild("Structures"),
	})

	self.PlacementConfirmed = Signal.new()

	return self
end

function PlacementClient:InitiatePlacement(model: Model)
	assert(model ~= nil, "[PlacementClient] InitiatePlacement: Model must not be nil")
	assert(model.ClassName == "Model", "[PlacementClient] InitiatePlacement: Model must be a Model")
	assert(model:IsA("Model"), "[PlacementClient] InitiatePlacement: Model must be a Model")

	local state: State = self._state:getState()

	if PlacementTypeIsNone(state) == false then
		return
	end

	-- Set up the ghost structure
	DimModel(model)
	UncollideModel(model)

	self._trove:Add(model)

	-- Create the selection box
	local selection_box = MakeSelectionBox()
	selection_box.Parent = model
	selection_box.Adornee = model

	self._trove:Add(selection_box)

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
		elseif input.KeyCode == Enum.KeyCode.Up then
			self:RaiseLevel()
		elseif input.KeyCode == Enum.KeyCode.Down then
			self:LowerLevel()
		elseif input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.Escape then
			self:CancelPlacement()
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			state = self._state:getState()
			if PlacementTypeIsNone(state) == true then
				return
			end

			self:ConfirmPlacement()
		end
	end))
end

function PlacementClient:IsPlacing()
	local state: State = self._state:getState()

	return PlacementTypeIsNone(state) == false
end

function PlacementClient:IsActive()
	return self._active
end

function PlacementClient:CancelPlacement()
	local state: State = self._state:getState()

	if PlacementTypeIsNone(state) == true then
		return
	end

	self._state:dispatch(PlacementTypeChanged("None"))
	self._state:dispatch(UpdateGhostStructure(nil))

	self._trove:Destroy()
end

function PlacementClient:RaiseLevel()
	local state: State = self._state:getState()

	if state._level >= SETTINGS.MAX_LEVEL then
		return
	end

	self._state:dispatch({
		type = "LEVEL_CHANGED",
		_level = state._level + 1,
	})
end

function PlacementClient:LowerLevel()
	local state: State = self._state:getState()

	if state._level <= 1 then
		return
	end

	self._state:dispatch({
		type = "LEVEL_CHANGED",
		_level = state._level - 1,
	})
end

function PlacementClient:ConfirmPlacement()
	local state: State = self._state:getState()

	if PlacementTypeIsNone(state) == true then
		return
	end

	if state._can_confirm_placement == false then
		return
	end

	-- Strip the state to only the necessary information
	state = PlacementUtils.StripClientState(state)

	-- Confirm the placement
	self.PlacementConfirmed:Fire(state)

	--self._state:dispatch(PlacementTypeChanged("None"))
	--self._state:dispatch(UpdateGhostStructure(nil))

	--self._trove:Destroy()
end

function PlacementClient:Destroy()
	self._state:destruct()
	self._trove:Destroy()

	self._active = false
end

return PlacementClient
