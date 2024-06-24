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

		PlacementClient._active [boolean] -- Determines if the client is active
			Determines if the client is active

		PlacementClient._selection_box [SelectionBox] -- The selection box
			The selection box

		PlacementClient.PlacementConfirmed [Signal] -- Signal


    Functions:

        PlacementClient.new  [PlacementClient] -- Constructor
            Creates a new instance of the PlacementClient class

	Methods:

        PlacementClient:Destroy() -- Destructor
            Destroys the placement client
			THIS CAN ONLY BE CALLED ONCE. 
			This will destroy the state of the client and remove all connections.

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

local LMEngine = require(ReplicatedStorage.LMEngine.Client)

local Mouse = require(ReplicatedStorage.LMEngine.Client.Modules.Mouse)
local Rodux = require(ReplicatedStorage.LMEngine.Shared.Rodux)
local Signal = require(ReplicatedStorage.LMEngine.Shared.Signal)
local Trove = require(ReplicatedStorage.LMEngine.Shared.Trove)

local PlacementType = require(LMEngine.Game.Shared.Placement.Types)

local SETTINGS = {
	INITIAL_STATE = {
		_placement_type = "None",
		_tile = nil,
		_ghost_structure = nil,
		_can_confirm_placement = true,
		_rotation = 0,
		_level = 1,
		_attachments = {},
		_structure_id = nil,

		-- stacking states
		_is_stacked = false,
		_mounted_attachment = nil,
		_stacked_structure = nil,
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
	_selection_box: SelectionBox?,

	PlacementConfirmed: Signal.Signal<PlacementType.ServerState>,
}

type PlacementType = "Place" | "Move" | "Remove" | "None"

type State = PlacementType.ClientState

export type PlacementClient = typeof(setmetatable({} :: PlacementClientMembers, {} :: IPlacementClient))

----- Private variables -----

local UserInputService = game:GetService("UserInputService")

local PlacementUtils = require(ReplicatedStorage.Game.Shared.Placement.Utils)

local StructuresUtils = require(ReplicatedStorage.Game.Shared.Structures.Utils)

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

local _mounted_attachment_reducers = Rodux.createReducer(nil, {
	["MOUNTED_ATTACHMENT_CHANGED"] = function(state: State, action)
		return action._mounted_attachment
	end,
})

local _stacked_structure_reducers = Rodux.createReducer(nil, {
	["STACKED_STRUCTURE_CHANGED"] = function(state: State, action)
		return action._stacked_structure
	end,
})

local _attachments_reducers = Rodux.createReducer({}, {
	["ATTACHMENTS_CHANGED"] = function(state: State, action)
		return action._attachments
	end,
})

local _is_orientation_strict_reducers = Rodux.createReducer(false, {
	["ORIENTATION_STRICT_CHANGED"] = function(state: State, action)
		return action._is_orientation_strict
	end,
})

local structure_id_reducers = Rodux.createReducer(nil, {
	["STRUCTURE_ID_CHANGED"] = function(state: State, action)
		return action._structure_id
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

	_attachments = _attachments_reducers,
	_structure_id = structure_id_reducers,
	_is_orientation_strict = _is_orientation_strict_reducers,
	_mounted_attachment = _mounted_attachment_reducers,
	_stacked_structure = _stacked_structure_reducers,
})

----- Private functions -----

local function MakeSelectionBox()
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
	selectionBox.LineThickness = 0.05

	selectionBox.SurfaceTransparency = 0.5
	selectionBox.SurfaceColor3 = Color3.fromRGB(0, 255, 0)

	return selectionBox
end

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

local function GetTileFromName(client: PlacementClient, name: string)
	return client._plot.Tiles:FindFirstChild(name)
end

local function PartIsFromStructure(part: BasePart, client: PlacementClient)
	if part == nil then
		return false
	end

	if part:IsA("BasePart") == false then
		return false
	end

	if part:IsDescendantOf(client._plot.Structures) == false then
		return false
	end

	local structure: Model? = part:FindFirstAncestorWhichIsA("Model")
	if structure == nil then
		return false
	end

	if structure:GetAttribute("Id") == nil then
		return false
	end

	if structure:GetAttribute("Tile") == nil then
		return false
	end

	if GetTileFromName(client, structure:GetAttribute("Tile")) == nil then
		return false
	end

	return true
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

local function StackedChanged(is_stacked: boolean)
	return {
		type = "IS_STACKED_CHANGED",
		_is_stacked = is_stacked,
	}
end

local function StructureIdChanged(structure_id: string)
	return {
		type = "STRUCTURE_ID_CHANGED",
		_structure_id = structure_id,
	}
end

local function CanConfirmPlacementChanged(can_confirm_placement: boolean)
	return {
		type = "CAN_CONFIRM_PLACEMENT_CHANGED",
		_can_confirm_placement = can_confirm_placement,
	}
end

local function GetStructureFromPart(part: BasePart, client: PlacementClient)
	local structure: Model? = part:FindFirstAncestorWhichIsA("Model")
	if structure == nil then
		return nil
	end

	if structure:GetAttribute("Id") == nil then
		return nil
	end

	if structure:GetAttribute("Tile") == nil then
		return nil
	end

	if GetTileFromName(client, structure:GetAttribute("Tile")) == nil then
		return nil
	end

	return structure
end

local function UpdateTileState(client: PlacementClient, tile: BasePart)
	local state: State = client._state:getState()

	local currentTile = state._tile
	if currentTile == nil or currentTile ~= tile then
		client._state:dispatch(TileChanged(tile))
	end

	client._state:dispatch(StackedChanged(false))
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

local function SnapToAttachment(attachment: Attachment, tile: BasePart, client: PlacementClient)
	local state: State = client._state:getState()

	local ghostStructure = state._ghost_structure
	local simulatedCFrame = GetSimulatedStackCFrame(client, tile, attachment)

	if simulatedCFrame == nil then
		return
	end

	PlacementUtils.MoveModelToCFrame(ghostStructure, simulatedCFrame, false)
end
local function UpdatePosition(client: PlacementClient)
	-- Completely state dependent
	local state: State = client._state:getState()

	if state._is_stacked == true then
		SnapToAttachment(state._mounted_attachment, state._tile, client)
	else
		SnapToTileWithLevel(client, state._tile)
	end
end

function GetAttachmentsFromStringList(client: PlacementClient, attachments: { string }?): { Attachment }
	if attachments == nil then
		return {}
	end

	local state: PlacementType.ClientState = client._state:getState()

	if state._stacked_structure == nil then
		return {}
	end

	local attachmentInstances = {}

	for _, attachmentName in ipairs(attachments) do
		local attachment = state._stacked_structure.PrimaryPart:FindFirstChild(attachmentName)
		if attachment ~= nil then
			table.insert(attachmentInstances, attachment)
		end
	end

	return attachmentInstances
end

function GetAttachmentsFromStructure(model: Model)
	local attachments = {}

	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("Attachment") then
			table.insert(attachments, instance)
		end
	end

	return attachments
end

function GetSimulatedStackCFrame(client: PlacementClient, tile: BasePart, attachment: Attachment)
	local state: State = client._state:getState()

	local ghostStructure = state._ghost_structure

	if ghostStructure == nil then
		return
	end

	local structureEntry = StructuresUtils.GetStructureFromId(ghostStructure:GetAttribute("Id"))

	if structureEntry == nil then
		return
	end

	if tile == nil or attachment == nil then
		return
	end

	return PlacementUtils.GetSnappedAttachmentCFrame(tile, attachment, structureEntry, state)
end

function GetValidRotationsWithStrictOrientation(client: PlacementClient)
	-- Clone the ghost structure and test the rotation
	local state: State = client._state:getState()

	local clone = state._ghost_structure:Clone()

	local client_structure_id: string = state._ghost_structure:GetAttribute("Id")

	local rotations = {}

	for i = 0, 360, SETTINGS.ROTATION_INCREMENT do
		local newCFrame = GetSimulatedStackCFrame(state._tile, state._mounted_attachment)

		if newCFrame == nil then
			return rotations
		end

		newCFrame = CFrame.new(newCFrame.Position) * CFrame.Angles(0, math.rad(i), 0)
		--newCFrame = newCFrame * CFrame.new(0, self.state.level * LEVEL_HEIGHT, 0)

		clone:PivotTo(newCFrame)

		-- Check if the attachment points match
		local stackedStructureId = state._stacked_structure:GetAttribute("Id")
		if stackedStructureId == nil then
			return
		end

		local attachmentPointsThatMatch = StructuresUtils.GetAttachmentsThatMatchSnapPoints(
			stackedStructureId,
			client_structure_id,
			state._stacked_structure,
			clone
		)

		if attachmentPointsThatMatch == nil then
			clone:Destroy()
			return
		end

		local allMatch = false

		for _, dict in ipairs(attachmentPointsThatMatch) do
			local match = true
			for key, value in pairs(dict) do
				local distance = (key.WorldCFrame.Position - value.WorldCFrame.Position).Magnitude

				if distance > 0.1 then
					match = false
					break
				end
			end
			if match then
				allMatch = true
				break
			end
		end

		if allMatch then
			table.insert(rotations, i)
		end
	end

	clone:Destroy()
	return rotations
end

local function AttemptToSnapRotationOnStrictOrientation(client: PlacementClient)
	local state: State = client._state:getState()
	if state._stacked_structure == nil then
		return
	end

	local client_structure_id: string = state._ghost_structure:GetAttribute("Id")

	-- get the entry from the structure collection
	local structureId = state._stacked_structure:GetAttribute("Id")
	local structureEntry = StructuresUtils.GetStructureFromId(structureId)

	if structureEntry == nil then
		return
	end

	if StructuresUtils.IsOrientationStrict(structureId, client_structure_id) == false then
		return
	end

	local ghostStructure = state._ghost_structure

	if ghostStructure == nil then
		return
	end

	local rotations = GetValidRotationsWithStrictOrientation(client)

	if rotations == nil then
		--self:UpdateCanConfirmPlacement(false)
		return
	end

	if #rotations == 0 then
		--self:UpdateCanConfirmPlacement(false)
		return
	end

	if table.find(rotations, state._rotation) == nil then
		client._state:dispatch(RotationChanged(rotations[1]))
	end
end

local function UpdateSelectionBox(selection_box: SelectionBox, can_place: boolean)
	if can_place == true then
		selection_box.Color3 = Color3.fromRGB(0, 255, 0)
		selection_box.SurfaceColor3 = Color3.fromRGB(0, 255, 0)
	else
		selection_box.Color3 = Color3.fromRGB(255, 0, 0)
		selection_box.SurfaceColor3 = Color3.fromRGB(255, 0, 0)
	end
end

function AttemptToSnapToAttachment(client: PlacementClient, closestInstance: BasePart)
	local mouse = client._mouse
	local state: State = client._state:getState()

	local client_structure_id: string = state._ghost_structure:GetAttribute("Id")

	local succesfullySnapped = true

	-- Check if the part is from a structure
	if PartIsFromStructure(closestInstance, client) == true then
		local structure: Model = GetStructureFromPart(closestInstance, client)
		if structure == nil then
			return
		end

		local structureId = structure:GetAttribute("Id")
		local structureTile = GetTileFromName(client, structure:GetAttribute("Tile"))

		-- check if the structure is on the same level
		if structureTile == nil then
			return
		end

		if structure:GetAttribute("Level") ~= state._level then
			UpdateTileState(client, structureTile)
			return
		end

		-- Determine if the structure is stackable
		local isStackable = StructuresUtils.CanStackStructureWith(structureId, client_structure_id)

		if isStackable == false then
			-- If the structure is not stackable, then just snap to the structures tile
			--self:RemoveStacked()
			-- get the structure the player is hovering over
			if structureTile:GetAttribute("Occupied") == false then
				succesfullySnapped = false
			end

			UpdateTileState(client, structureTile)
			client._state:dispatch(TileChanged(structureTile))
		else
			client._state:dispatch({
				type = "STACKED_STRUCTURE_CHANGED",
				_stacked_structure = structure,
			})

			-- get the attachments of the structure
			local whitelistedSnapPoints =
				StructuresUtils.GetStackingWhitelistedSnapPointsWith(structureId, client_structure_id)

			if whitelistedSnapPoints ~= nil then
				local attachmentInstances = GetAttachmentsFromStringList(client, whitelistedSnapPoints)
				whitelistedSnapPoints = attachmentInstances
			else
				whitelistedSnapPoints = {}
			end

			local attachments = (#whitelistedSnapPoints > 0) and whitelistedSnapPoints
				or GetAttachmentsFromStructure(structure)

			-- Get the closest attachment to the mouse
			local closestAttachment = mouse:GetClosestAttachmentToMouse(attachments)

			if closestAttachment == nil then
				return
			end

			-- check if the attachment is occupied

			if closestAttachment:GetAttribute("Occupied") == true then
				--self:RemoveStacked()
				--self.state.canConfirmPlacement = false
				succesfullySnapped = false
				--return
			end

			client._state:dispatch({
				type = "ATTACHMENTS_CHANGED",
				_attachments = attachments,
			})

			client._state:dispatch(StackedChanged(true))

			local attachmentPointToSnapTo = StructuresUtils.GetMountedAttachmentPointFromStructures(
				structure,
				client_structure_id,
				closestAttachment
			)

			if attachmentPointToSnapTo == nil then
				succesfullySnapped = false
				return
			end

			if state._mounted_attachment == nil or state._mounted_attachment ~= attachmentPointToSnapTo then
				--self.signals.OnStackedAttachmentChanged:Fire(attachmentPointToSnapTo, self.state.mountedAttachment)
			end

			if attachmentPointToSnapTo:GetAttribute("Occupied") == true then
				--self.state.canConfirmPlacement = false
				succesfullySnapped = false
			end

			client._state:dispatch({
				type = "MOUNTED_ATTACHMENT_CHANGED",
				_mounted_attachment = attachmentPointToSnapTo,
			})

			client._state:dispatch({
				type = "ATTACHMENTS_CHANGED",
				_attachments = attachments,
			})

			local orientationStrict = StructuresUtils.IsOrientationStrict(structureId, client_structure_id)

			client._state:dispatch({
				type = "ORIENTATION_STRICT_CHANGED",
				_is_orientation_strict = orientationStrict,
			})

			if orientationStrict == true then
				AttemptToSnapRotationOnStrictOrientation(client)
			end

			-- change tile to the structure tile

			if structureTile == nil then
				succesfullySnapped = false
			end

			if state._tile == nil or state._tile ~= structureTile then
				client._state:dispatch(TileChanged(structureTile))
			end

			--self.state.tile = structureTile

			if StructuresUtils.IsIncreasingLevel(structureId, client_structure_id) then
				client:RaiseLevel()
			else
				client._state:dispatch({
					type = "LEVEL_CHANGED",
					_level = structure:GetAttribute("Level"),
				})
			end
		end
	else
		--self.signals.OnStructureHover:Fire(nil)
		--self:RemoveStacked()
		--self.state.canConfirmPlacement = false
		succesfullySnapped = false
	end

	--UpdateCanConfirmPlacement(succesfullySnapped)
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
		AttemptToSnapToAttachment(client, target)
	end

	UpdatePosition(client)

	-- get the updated state

	state = client._state:getState()

	local can_place = PlacementUtils.CanPlaceStructure(plot, state)
	client._state:dispatch(CanConfirmPlacementChanged(can_place))

	-- Update the selection box
	if client._selection_box then
		UpdateSelectionBox(client._selection_box, can_place)
	end
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

	local structure_id = model:GetAttribute("Id")

	if structure_id == nil then
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

	self._selection_box = selection_box

	self._state:dispatch(PlacementTypeChanged("Place"))
	self._state:dispatch(UpdateGhostStructure(model))
	self._state:dispatch(StructureIdChanged(structure_id))

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
