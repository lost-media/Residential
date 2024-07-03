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

        PlacementClient:GetPlatform() -- Method
            Returns the platform the client is running on

--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LMEngine = require(ReplicatedStorage.LMEngine.Client)

local Mouse = require(ReplicatedStorage.LMEngine.Client.Modules.Mouse)
local Rodux = require(ReplicatedStorage.LMEngine.Shared.Rodux)
local Signal = require(ReplicatedStorage.LMEngine.Shared.Signal)
local Trove = require(ReplicatedStorage.LMEngine.Shared.Trove)

local PlacementType = require(LMEngine.Game.Shared.Placement.Types)

local SETTINGS = {
	-- Bools
	PLACEMENT_CONFIGS = {
		AngleTilt = false, -- Toggles if you want the object to tilt when moving (based on speed)
		AudibleFeedback = true, -- Toggles sound feedback on placement
		BuildModePlacement = true, -- Toggles "build mode" placement
		CharacterCollisions = false, -- Toggles character collisions (Requires "Collisions" to be set to true)
		Collisions = true, -- Toggles collisions
		DisplayGridTexture = false, -- Toggles the grid texture to be shown when placing
		EnableFloors = true, -- Toggles if the raise and lower keys will be enabled
		GridFadeIn = true, -- If you want the grid to fade in when activating placement
		GridFadeOut = true, -- If you want the grid to fade out when ending placement
		IncludeSelectionBox = true, -- Toggles if a selection box will be shown while placing
		InstantActivation = true, -- Toggles if the model will appear at the mouse position immediately when activating placement
		Interpolation = true, -- Toggles interpolation (smoothing)
		InvertAngleTilt = false, -- Inverts the direction of the angle tilt
		MoveByGrid = true, -- Toggles grid system
		PreferSignals = true, -- Controls if you want to use signals or callbacks
		RemoveCollisionsIfIgnored = true, -- Toggles if you want to remove collisions on objects that are ignored by the mouse
		SmartDisplay = true, -- Toggles smart display for the grid. If true, it will rescale the grid texture to match your gridsize
		TransparentModel = true, -- Toggles if the model itself will be transparent
		UseHighlights = false, -- Toggles whether the selection box will be a highlight object or a selection box (TransparencyDelta must be 0)

		-- Color3
		CollisionColor3 = Color3.fromRGB(255, 75, 75), -- Color of the hitbox when colliding
		HitboxColor3 = Color3.fromRGB(75, 255, 75), -- Color of the hitbox while not colliding
		SelectionBoxCollisionColor3 = Color3.fromRGB(255, 0, 0), -- Color of the selectionBox lines when colliding (includeSelectionBox much be set to true)
		SelectionBoxColor3 = Color3.fromRGB(0, 255, 0), -- Color of the selectionBox lines (includeSelectionBox much be set to true)

		-- Integers (Will round to nearest unit)
		FloorStep = 9, -- The step (in studs) that the object will be raised or lowered
		GridTextureScale = 1, -- How large the StudsPerTileU/V is displayed (smartDisplay must be set to false)
		MaxHeight = 100, -- Max height you can place objects (in studs)
		MaxRange = 100, -- Max range for the model (in studs)
		RotationStep = 90, -- Rotation step
		TargetFPS = 60, -- The target constant FPS

		-- Numbers/Floats
		AngleTiltAmplitude = 5, -- How much the object will tilt when moving. 0 = min, 10 = max
		AudioVolume = 0.5, -- Volume of the sound feedback
		HitboxTransparency = 0.6, -- Hitbox transparency when placing
		LerpSpeed = 0.8, -- Speed of interpolation. 0 = no interpolation, 0.9 = major interpolation
		LineThickness = 0.05, -- How thick the line of the selection box is (includeSelectionBox much be set to true)
		LineTransparency = 0.5, -- How transparent the line of the selection box is (includeSelectionBox must be set to true)
		PlacementCooldown = 0.5, -- How quickly the user can place down objects (in seconds)
		TransparencyDelta = 0.6, -- Transparency of the model itself (transparentModel must equal true)

		-- Other

		GridTexture = "rbxassetid://2415319308", -- ID of the grid texture shown while placing (requires DisplayGridTexture == true)
		SoundID = "rbxassetid://9116367462", -- ID of the sound played on Placement (requires audibleFeedback == true)

		-- Cross Platform

		HapticFeedback = false, -- If you want a controller to vibrate when placing objects (only works if the user has a controller with haptic support)
		HapticVibrationAmount = 1, -- How large the vibration is when placing objects. Choose a value from 0, 1. hapticFeedback must be set to true.
	},

	CONTROLS = {
		-- PC
		RotateKey = Enum.KeyCode.R, -- Key to rotate the model
		TerminateKey = Enum.KeyCode.C, -- Key to terminate placement
		RaiseKey = Enum.KeyCode.Up, -- Key to raise the object
		LowerKey = Enum.KeyCode.Down, -- Key to lower the object

		-- Xbox
		XboxRotate = Enum.KeyCode.ButtonR1, -- Key to rotate the model
		XboxTerminate = Enum.KeyCode.ButtonX, -- Key to terminate placement
		XboxRaise = Enum.KeyCode.ButtonY, -- Key to raise the object
		XboxLower = Enum.KeyCode.ButtonB, -- Key to lower the object
	},

	DefaultGridSize = 8, -- Default grid size

	INITIAL_STATE = {
		_current_state = 4,
		_last_state = 4,
		_running = false,
		_current_model = nil,
		_is_setup = false,
		_stackable = false,
		_grid_unit = 8,
		_hitbox = nil,
		_current_rot = false,
		_floor_height = 0,

		_rotation = 0,
		_amplitude = 5,
	},

	POSSIBLE_STATES = { "Movement", "Placing", "Colliding", "Inactive", "Out-of-range" },
}

----- Types -----

type State = {
	_current_state: number,
	_running: boolean,
	_current_model: Model?,
	_last_state: number,
	_auto_placement: boolean, -- Determines if the client is auto placing

	_grid_unit: number,

	_hitbox: BasePart,
	_is_setup: boolean,
	_stackable: boolean,
	_current_rot: boolean,
	_amplitude: number,
	_floor_height: number,
	_cframe: CFrame,

	_radius_visual: Part?,
}

type IPlacementClient = {
	__index: IPlacementClient,
	new: (plot: Model, grid_unit: number?) -> PlacementClient,

	InitiatePlacement: (self: PlacementClient, model: Model, settings: ModelSettings?) -> (),
	IsPlacing: (self: PlacementClient) -> boolean,
	CancelPlacement: (self: PlacementClient) -> (),
	IsActive: (self: PlacementClient) -> boolean,
	Destroy: (self: PlacementClient) -> (),

	RaiseLevel: (self: PlacementClient) -> (),
	LowerLevel: (self: PlacementClient) -> (),

	GetPlatform: (self: PlacementClient) -> string,
	IsMobile: (self: PlacementClient) -> boolean,
	IsConsole: (self: PlacementClient) -> boolean,

	ConfirmPlacement: (self: PlacementClient) -> (),
	UpdateGridUnit: (self: PlacementClient, grid_unit: number) -> (),
}

type PlacementClientMembers = {

	_state: Rodux.Store,
	_mouse: Mouse.Mouse,
	_trove: Trove.Trove,
	_plot: Model,
	_active: boolean,
	_selection_box: SelectionBox?,
	_ignored_items: { Instance },
	_raycast_params: RaycastParams,
	_sound: Sound,

	Placed: Signal.Signal,
	Collided: Signal.Signal,
	Rotated: Signal.Signal,
	Cancelled: Signal.Signal,
	LevelChanged: Signal.Signal,
	OutOfRange: Signal.Signal,
	Initiated: Signal.Signal,
	DeleteStructure: Signal.Signal<Instance>,

	PlacementConfirmed: Signal.Signal<string, CFrame>,
}

export type PlacementClient = typeof(setmetatable(
	{} :: PlacementClientMembers,
	{} :: IPlacementClient
))

type ModelSettings = {
	can_stack: boolean,
	radius: number?,
}

----- Private variables -----

-- values used for calculations
local speed: number = 1
local range_of_ray: number = 10000
local y: number
local dir_X: number
local dir_Z: number
local initial_Y: number

local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local HapticService = game:GetService("HapticService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local PlacementUtils = require(ReplicatedStorage.Game.Shared.Placement.Utils)
local StructuresUtils = require(ReplicatedStorage.Game.Shared.Structures.Utils)

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)

local Store = Rodux.Store

---@class PlacementClient2
local PlacementClient: IPlacementClient = {} :: IPlacementClient
PlacementClient.__index = PlacementClient

----- Reducers -----

local current_state_changed = Rodux.createReducer(4, {
	["CURRENT_STATE_CHANGED"] = function(state: State, action)
		return action._current_state
	end,
})

local last_state_changed = Rodux.createReducer(4, {
	["LAST_STATE_CHANGED"] = function(state: State, action)
		return action._last_state
	end,
})

local running_changed = Rodux.createReducer(false, {
	["RUNNING_CHANGED"] = function(state: State, action)
		return action._running
	end,
})

local current_model_changed = Rodux.createReducer(nil, {
	["CURRENT_MODEL_CHANGED"] = function(state: State, action)
		return action._current_model
	end,
})

local hitbox_changed = Rodux.createReducer(nil, {
	["HITBOX_CHANGED"] = function(state: State, action)
		return action._hitbox
	end,
})

local is_setup_changed = Rodux.createReducer(false, {
	["IS_SETUP_CHANGED"] = function(state: State, action)
		return action._is_setup
	end,
})

local stackable_changed = Rodux.createReducer(false, {
	["STACKABLE_CHANGED"] = function(state: State, action)
		return action._stackable
	end,
})

local rotation_changed = Rodux.createReducer(0, {
	["ROTATION_CHANGED"] = function(state: State, action)
		return action._rotation
	end,
})

local grid_unit_changed = Rodux.createReducer(SETTINGS.DefaultGridSize, {
	["GRID_UNIT_CHANGED"] = function(state: State, action)
		return action._grid_unit
	end,
})

local current_rot_changed = Rodux.createReducer(false, {
	["CURRENT_ROT_CHANGED"] = function(state: State, action)
		return action._current_rot
	end,
})

local amplitude_changed = Rodux.createReducer(5, {
	["AMPLITUDE_CHANGED"] = function(state: State, action)
		return action._amplitude
	end,
})

local floor_height_changed = Rodux.createReducer(0, {
	["FLOOR_HEIGHT_CHANGED"] = function(state: State, action)
		return action._floor_height
	end,
})

local auto_placement_changed = Rodux.createReducer(false, {
	["AUTO_PLACEMENT_CHANGED"] = function(state: State, action)
		return action._auto_placement
	end,
})

local cframe_changed = Rodux.createReducer(CFrame.new(), {
	["CFRAME_CHANGED"] = function(state: State, action)
		return action._cframe
	end,
})

local radius_visual_changed = Rodux.createReducer(nil, {
	["RADIUS_VISUAL_CHANGED"] = function(state: State, action)
		return action._radius_visual
	end,
})

local reducers = Rodux.combineReducers({
	_current_state = current_state_changed,
	_last_state = last_state_changed,
	_running = running_changed,
	_current_model = current_model_changed,
	_hitbox = hitbox_changed,
	_is_setup = is_setup_changed,
	_stackable = stackable_changed,
	_rotation = rotation_changed,
	_grid_unit = grid_unit_changed,
	_current_rot = current_rot_changed,
	_amplitude = amplitude_changed,
	_floor_height = floor_height_changed,
	_auto_placement = auto_placement_changed,
	_cframe = cframe_changed,
	_radius_visual = radius_visual_changed,
})

----- Actions -----

local function CurrentStateChanged(current_state: number)
	return {
		type = "CURRENT_STATE_CHANGED",
		_current_state = current_state,
	}
end

local function LastStateChanged(last_state: number)
	return {
		type = "LAST_STATE_CHANGED",
		_last_state = last_state,
	}
end

local function RunningChanged(running: boolean)
	return {
		type = "RUNNING_CHANGED",
		_running = running,
	}
end

local function CurrentModelChanged(current_model: Model)
	return {
		type = "CURRENT_MODEL_CHANGED",
		_current_model = current_model,
	}
end

local function HitboxChanged(hitbox: BasePart)
	return {
		type = "HITBOX_CHANGED",
		_hitbox = hitbox,
	}
end

local function IsSetupChanged(is_setup: boolean)
	return {
		type = "IS_SETUP_CHANGED",
		_is_setup = is_setup,
	}
end

local function StackableChanged(stackable: boolean)
	return {
		type = "STACKABLE_CHANGED",
		_stackable = stackable,
	}
end

local function RotationChanged(rotation: number)
	return {
		type = "ROTATION_CHANGED",
		_rotation = rotation,
	}
end

local function GridUnitChanged(grid_unit: number)
	return {
		type = "GRID_UNIT_CHANGED",
		_grid_unit = grid_unit,
	}
end

local function CurrentRotChanged(current_rot: boolean)
	return {
		type = "CURRENT_ROT_CHANGED",
		_current_rot = current_rot,
	}
end

local function AmplitudeChanged(amplitude: number)
	return {
		type = "AMPLITUDE_CHANGED",
		_amplitude = amplitude,
	}
end

local function FloorHeightChanged(floor_height: number)
	return {
		type = "FLOOR_HEIGHT_CHANGED",
		_floor_height = floor_height,
	}
end

local function AutoPlacementChanged(auto_placement: boolean)
	return {
		type = "AUTO_PLACEMENT_CHANGED",
		_auto_placement = auto_placement,
	}
end

local function CFrameChanged(cframe: CFrame)
	return {
		type = "CFRAME_CHANGED",
		_cframe = cframe,
	}
end

local function RadiusVisualChanged(radius_visual: Part?)
	return {
		type = "RADIUS_VISUAL_CHANGED",
		_radius_visual = radius_visual,
	}
end

----- Private functions -----

local function GetRange(part: BasePart): number
	local character = LMEngine.Player.Character

	if character == nil then
		return 0
	end

	return (part.Position - character.PrimaryPart.Position).Magnitude
end

local function MakeRadiusVisual(radius: number, client: PlacementClient): Part?
	local state: State = client._state:getState()

	if state._current_model == nil then
		return
	end

	if state._radius_visual ~= nil then
		-- modify the existing one
		state._radius_visual:Destroy()
	end

	local radius_part = Instance.new("Part")
	radius_part.Shape = Enum.PartType.Cylinder
	radius_part.CastShadow = false

	-- radius is in tiles, and each tile is 8 studs
	radius = radius * 8

	radius_part.Size = Vector3.new(0.05, radius * 2 + 8, radius * 2 + 8)
	-- rotate the radius visual so that it is flat
	radius_part.CFrame = CFrame.Angles(0, 0, math.rad(90))

	radius_part.Color = Color3.fromRGB(50, 82, 100)

	--radius.Anchored = true
	radius_part.CanCollide = false
	radius_part.Transparency = 0.3
	radius_part.Parent = state._current_model

	-- weld the radius visual to the object
	local weld = Instance.new("WeldConstraint")
	weld.Parent = radius_part
	weld.Part0 = radius_part
	weld.Part1 = state._current_model.PrimaryPart

	-- set its position to the bottom of the object
	radius_part.Position = state._current_model.PrimaryPart.Position
		- Vector3.new(0, state._current_model.PrimaryPart.Size.Y / 2, 0)
		+ Vector3.new(0, 0.025, 0)

	-- Pulse the radius visual

	local pulseTween = TweenService:Create(
		radius_part,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
		{ Transparency = 0.7 }
	)
	pulseTween:Play()

	client._trove:Add(radius_part)

	client._state:dispatch(RadiusVisualChanged(radius_part))
	return radius_part
end

-- Clamps the x and z positions so they cannot leave the plot
local function Bounds(platform: BasePart, cframe: CFrame, offsetX: number, offsetZ: number): CFrame
	local pos: CFrame = platform.CFrame
	local xBound: number = (platform.Size.X * 0.5) - offsetX
	local zBound: number = (platform.Size.Z * 0.5) - offsetZ

	local newX: number = math.clamp(cframe.X, -xBound, xBound)
	local newZ: number = math.clamp(cframe.Z, -zBound, zBound)

	local newCFrame: CFrame = CFrame.new(newX, 0, newZ)

	return newCFrame
end

local function SetCurrentState(num_state: number, client: PlacementClient)
	local state: State = client._state:getState()

	local last_state = state.current_state
	client._state:dispatch(CurrentStateChanged(num_state))
	client._state:dispatch(LastStateChanged(last_state))
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

local function MakeSelectionBox(client: PlacementClient)
	local object = (client._state:getState() :: State)._current_model

	if object == nil then
		return
	end

	local selectionBox

	if SETTINGS.PLACEMENT_CONFIGS.UseHighlights == true then
		selectionBox = Instance.new("Highlight")
		selectionBox.OutlineColor = SETTINGS.PLACEMENT_CONFIGS.SelectionBoxColor3
		selectionBox.OutlineTransparency = SETTINGS.PLACEMENT_CONFIGS.LineTransparency
		selectionBox.FillTransparency = 1
		selectionBox.DepthMode = Enum.HighlightDepthMode.Occluded
		selectionBox.Adornee = object
	else
		selectionBox = Instance.new("SelectionBox")
		selectionBox.LineThickness = SETTINGS.PLACEMENT_CONFIGS.LineThickness
		selectionBox.Color3 = SETTINGS.PLACEMENT_CONFIGS.SelectionBoxColor3
		selectionBox.Transparency = SETTINGS.PLACEMENT_CONFIGS.LineTransparency
		selectionBox.Adornee = object.PrimaryPart
	end

	selectionBox.Parent = LMEngine.Player.PlayerGui
	selectionBox.Name = "[PLACEMENT] Outline"

	client._trove:Add(selectionBox)
	client._selection_box = selectionBox
end

local function ModelIsPlot(model: Model)
	if model == nil then
		return false
	end

	if model:IsA("Model") == false then
		return false
	end

	local structures = model:FindFirstChild("Structures")

	if structures == nil then
		return false
	end

	if structures:IsA("Folder") == false then
		return false
	end

	local platform = model:WaitForChild("Platform")

	if platform == nil then
		return false
	end

	return true
end

local function CheckHitbox(client: PlacementClient)
	local state: State = client._state:getState()

	local hitbox = state._hitbox
	local current_model = state._current_model
	local plot = client._plot

	if
		hitbox:IsDescendantOf(workspace) == false
		and SETTINGS.PLACEMENT_CONFIGS.Collisions == false
	then
		return
	end

	--[[if range then
		SetCurrentState(5, client);
	else
		SetCurrentState(1, client);
	end]]

	local collisionPoints: { BasePart } = workspace:GetPartsInPart(hitbox)

	local character = LMEngine.Player.Character

	if character == nil then
		return
	end

	-- Checks if there is collision on any object that is not a child of the object and is not a child of the player
	for i: number = 1, #collisionPoints, 1 do
		if collisionPoints[i].CanTouch == false then
			continue
		end
		if
			SETTINGS.PLACEMENT_CONFIGS.CharacterCollisions ~= true
			and collisionPoints[i]:IsDescendantOf(character) == true
		then
			continue
		end

		if
			collisionPoints[i]:IsDescendantOf(current_model) == true
			or collisionPoints[i] == plot
		then
			continue
		end

		SetCurrentState(3, client)
		if SETTINGS.PLACEMENT_CONFIGS.PreferSignals == true then
			client.Collided:Fire(collisionPoints[i])
		end
		break
	end

	return
end

local function EditHitboxColor(client: PlacementClient)
	local state: State = client._state:getState()

	local current_model = state._current_model

	if current_model == nil then
		return
	end

	if current_model.PrimaryPart == nil then
		return
	end

	local color = SETTINGS.PLACEMENT_CONFIGS.HitboxColor3
	local color2 = SETTINGS.PLACEMENT_CONFIGS.SelectionBoxColor3

	if state._current_state >= 3 then
		color = SETTINGS.PLACEMENT_CONFIGS.CollisionColor3
		color2 = SETTINGS.PLACEMENT_CONFIGS.SelectionBoxCollisionColor3
	end

	current_model.PrimaryPart.Color = color

	if SETTINGS.PLACEMENT_CONFIGS.IncludeSelectionBox == true then
		if SETTINGS.PLACEMENT_CONFIGS.UseHighlights then
			client._selection_box.OutlineColor = color2
		else
			client._selection_box.Color3 = color2
		end
	end
end

-- Returns a rounded cframe to the nearest grid unit
local function SnapCFrame(cframe: CFrame, client: PlacementClient): CFrame
	local state: State = client._state:getState()

	local platform = client._plot:FindFirstChild("Platform")

	local grid_unit = state._grid_unit

	local offsetX: number = (platform.Size.X % (2 * grid_unit)) * 0.5
	local offsetZ: number = (platform.Size.Z % (2 * grid_unit)) * 0.5
	local newX: number = math.round(cframe.X / grid_unit) * grid_unit - offsetX
	local newZ: number = math.round(cframe.Z / grid_unit) * grid_unit - offsetZ
	local newCFrame: CFrame = CFrame.new(newX, 0, newZ)

	return newCFrame
end

-- Calculates the Y position to be ontop of the plot (all objects) and any object (when stacking)
local function CalculateYPosition(tp: number, ts: number, o: number, normal: number): number
	if normal == 0 then
		return (tp + ts * 0.5) - o * 0.5
	end

	return (tp + ts * 0.5) + o * 0.5
end

-- Calculates the "tilt" angle
local function CalculateAngle(last: CFrame, current: CFrame, client: PlacementClient): CFrame
	if not SETTINGS.PLACEMENT_CONFIGS.AngleTilt then
		return CFrame.fromEulerAnglesXYZ(0, 0, 0)
	end

	local state: State = client._state:getState()

	local rotation = state._rotation

	local platform = client._plot:FindFirstChild("Platform")

	-- Calculates and clamps the proper angle amount
	local tiltX = (math.clamp((last.X - current.X), -10, 10) * math.pi / 180) * state._amplitude
	local tiltZ = (math.clamp((last.Z - current.Z), -10, 10) * math.pi / 180) * state._amplitude
	local preCalc = (rotation + platform.Orientation.Y) * math.pi / 180

	-- Returns the proper angle based on rotation
	return (
		CFrame.fromEulerAnglesXYZ(dir_Z * tiltZ, 0, dir_X * tiltX):Inverse()
		* CFrame.fromEulerAnglesXYZ(0, preCalc, 0)
	):Inverse() * CFrame.fromEulerAnglesXYZ(0, preCalc, 0)
end

-- Calculates the position of the object
local function CalculateItemLocation(last, final: boolean, client: PlacementClient): CFrame
	local state: State = client._state:getState()

	local current_model = state._current_model
	local primary = current_model.PrimaryPart
	local floor_height = state._floor_height

	local platform = client._plot:FindFirstChild("Platform")

	local x: number, z: number
	local sizeX: number, sizeZ: number = primary.Size.X * 0.5, primary.Size.Z * 0.5
	local offsetX: number, offsetZ: number = sizeX, sizeZ
	local finalC: CFrame

	if state._current_rot == false then
		sizeX = primary.Size.Z * 0.5
		sizeZ = primary.Size.X * 0.5
	end

	if SETTINGS.PLACEMENT_CONFIGS.MoveByGrid == true then
		offsetX = sizeX - math.floor(sizeX / state._grid_unit) * state._grid_unit
		offsetZ = sizeZ - math.floor(sizeZ / state._grid_unit) * state._grid_unit
	end

	local raycastParams = client._raycast_params
	local cam: Camera = workspace.CurrentCamera
	local ray
	local nilRay
	local target

	if client:IsMobile() == true then
		local camPos: Vector3 = cam.CFrame.Position
		ray = workspace:Raycast(camPos, cam.CFrame.LookVector * range_of_ray, raycastParams)
		nilRay = camPos
			+ cam.CFrame.LookVector
				* (SETTINGS.PLACEMENT_CONFIGS.MaxRange + platform.Size.X * 0.5 + platform.Size.Z * 0.5)
	else
		local mouse = client._mouse
		local mouse_position = mouse:GetPosition()
		local player_mouse = LMEngine.Player:GetMouse()

		local unit: Ray = cam:ScreenPointToRay(player_mouse.X, player_mouse.Y, 1)
		ray = workspace:Raycast(unit.Origin, unit.Direction * range_of_ray, raycastParams)
		nilRay = unit.Origin
			+ unit.Direction
				* (SETTINGS.PLACEMENT_CONFIGS.MaxRange + platform.Size.X * 0.5 + platform.Size.Z * 0.5)
	end

	if ray then
		x, z = ray.Position.X - offsetX, ray.Position.Z - offsetZ

		if state._stackable == true then
			target = ray.Instance
		else
			target = platform
		end
	else
		x, z = nilRay.X - offsetX, nilRay.Z - offsetZ
		target = platform
	end

	local pltCFrame: CFrame = platform.CFrame
	local positionCFrame = CFrame.new(x, 0, z) * CFrame.new(offsetX, 0, offsetZ)

	y = CalculateYPosition(platform.Position.Y, platform.Size.Y, primary.Size.Y, 1) + floor_height

	-- Changes y depending on mouse target
	if
		state._stackable
		and target
		and (target:IsDescendantOf(client._plot:FindFirstChild("Structures"))) --  or target == platform)
	then
		if ray and ray.Normal then
			local normal = CFrame.new(ray.Normal)
				:VectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Top))
				:Dot(ray.Normal)
			y = CalculateYPosition(target.Position.Y, target.Size.Y, primary.Size.Y, normal)
		end
	end

	if SETTINGS.PLACEMENT_CONFIGS.MoveByGrid == true then
		-- Calculates the correct position
		local rel: CFrame = pltCFrame:Inverse() * positionCFrame
		local snappedRel: CFrame = SnapCFrame(rel, client) * CFrame.new(offsetX, 0, offsetZ)

		--if not removePlotDependencies then
		snappedRel = Bounds(platform, snappedRel, sizeX, sizeZ)
		--end
		finalC = pltCFrame * snappedRel
	else
		finalC = pltCFrame:Inverse() * positionCFrame

		finalC = Bounds(platform, finalC, sizeX, sizeZ)

		finalC = pltCFrame * finalC
	end

	-- Clamps y to a max height above the plot position
	y = math.clamp(y, initial_Y, SETTINGS.PLACEMENT_CONFIGS.MaxHeight + initial_Y)

	-- For placement or no intepolation
	if final or SETTINGS.PLACEMENT_CONFIGS.Interpolation == false then
		return (finalC * CFrame.new(0, y - platform.Position.Y, 0))
			* CFrame.fromEulerAnglesXYZ(0, state._rotation * math.pi / 180, 0)
	end

	return (finalC * CFrame.new(0, y - platform.Position.Y, 0))
		* CFrame.fromEulerAnglesXYZ(0, state._rotation * math.pi / 180, 0)
		* CalculateAngle(last, finalC)
end

local function TranslateObject(dt: number, client: PlacementClient)
	local state: State = client._state:getState()

	local current_model = state._current_model
	local hitbox = state._hitbox

	if state._current_state == 2 or state._current_state == 4 then
		return
	end

	local primary = current_model.PrimaryPart

	if primary == nil then
		return
	end

	--range = false
	SetCurrentState(1, client)

	if GetRange(primary) > SETTINGS.PLACEMENT_CONFIGS.MaxRange then
		SetCurrentState(5, client)

		if SETTINGS.PLACEMENT_CONFIGS.PreferSignals == true then
			client.OutOfRange:Fire()
		end

		--range = true
	end

	CheckHitbox(client)
	EditHitboxColor(client)

	if SETTINGS.PLACEMENT_CONFIGS.Interpolation == true and state._is_setup == true then
		current_model:PivotTo(
			primary.CFrame:Lerp(
				CalculateItemLocation(primary.CFrame.Position, false, client),
				speed * dt * SETTINGS.PLACEMENT_CONFIGS.TargetFPS
			)
		)
		hitbox:PivotTo(CalculateItemLocation(hitbox.CFrame.Position, true, client))
	else
		current_model:PivotTo(CalculateItemLocation(primary.CFrame.Position, false, client))
		hitbox:PivotTo(CalculateItemLocation(hitbox.CFrame.Position, true, client))
	end
end

-- (Raise and Lower functions) Edits the floor based on the floor step
local function RaiseFloor(
	actionName: string,
	inputState: Enum.UserInputState,
	inputObj: InputObject?,
	client: PlacementClient
)
	local state: State = client._state:getState()

	if not (state._current_state ~= 4 and inputState == Enum.UserInputState.Begin) then
		return
	end

	if SETTINGS.PLACEMENT_CONFIGS.EnableFloors == false then --or state._stackable == true then
		return
	end

	local floor_height = state._floor_height
	floor_height += math.floor(math.abs(SETTINGS.PLACEMENT_CONFIGS.FloorStep))
	floor_height = math.clamp(floor_height, 0, SETTINGS.PLACEMENT_CONFIGS.MaxHeight)

	client._state:dispatch(FloorHeightChanged(floor_height))

	if SETTINGS.PLACEMENT_CONFIGS.PreferSignals == true then
		client.LevelChanged:Fire(true)
	end
end

local function LowerFloor(
	actionName: string,
	inputState: Enum.UserInputState,
	inputObj: InputObject?,
	client: PlacementClient
)
	local state: State = client._state:getState()

	if not (state._current_state ~= 4 and inputState == Enum.UserInputState.Begin) then
		return
	end

	if SETTINGS.PLACEMENT_CONFIGS.EnableFloors == false then --or state._stackable == true then
		return
	end

	local floor_height = state._floor_height
	floor_height -= math.floor(math.abs(SETTINGS.PLACEMENT_CONFIGS.FloorStep))
	floor_height = math.clamp(floor_height, 0, SETTINGS.PLACEMENT_CONFIGS.MaxHeight)

	client._state:dispatch(FloorHeightChanged(floor_height))

	if SETTINGS.PLACEMENT_CONFIGS.PreferSignals == true then
		client.LevelChanged:Fire(false)
	end
end

-- Verifys that the plane which the object is going to be placed upon is the correct size
local function VerifyPlane(platform: BasePart, grid_unit: number): boolean
	return platform.Size.X % grid_unit == 0 and platform.Size.Z % grid_unit == 0
end

-- Checks if there are any problems with the users setup
local function ApproveActivation(platform: BasePart, grid_unit: number)
	if VerifyPlane(platform, grid_unit) == false then
		warn("[PlacementClient2] ApproveActivation: The plot is not the correct size")
	end
	assert(
		not (grid_unit >= math.min(platform.Size.X, platform.Size.Z)),
		"[PlacementClient2] ApproveActivation: The grid unit is too large"
	)
end

-- Sets up variables for activation
local function SetupInitialization(client: PlacementClient)
	local state: State = client._state:getState()

	local current_model = state._current_model

	if current_model == nil then
		return
	end

	local hitbox = client._trove:Clone(current_model.PrimaryPart)
	client._state:dispatch(HitboxChanged(hitbox))

	--hitbox = object.PrimaryPart:Clone()
	hitbox.Transparency = 1
	hitbox.Name = "Hitbox"
	hitbox.Parent = current_model

	client._state:dispatch(RotationChanged(0))
	client._state:dispatch(
		AmplitudeChanged(math.clamp(SETTINGS.PLACEMENT_CONFIGS.AngleTiltAmplitude, 0, 10))
	)
	client._state:dispatch(CurrentRotChanged(true))

	dirX = -1
	dirZ = 1

	if SETTINGS.PLACEMENT_CONFIGS.InvertAngleTilt then
		dirX = 1
		dirZ = -1
	end

	-- Sets up interpolation speed
	speed = 1
end

-- Handles rotation of the model
local function ROTATE(
	actionName: string,
	inputState: Enum.UserInputState,
	inputObj: InputObject?,
	client: PlacementClient
)
	local state: State = client._state:getState()

	if
		state._current_state == 4
		or state._current_state == 2
		or inputState ~= Enum.UserInputState.Begin
	then
		return
	end

	--[[if smartRot then
		-- Rotates the model depending on if currentRot is true/false
		if currentRot then
			rotation += SETTINGS.PLACEMENT_CONFIGS.RotationStep
		else
			rotation -= SETTINGS.PLACEMENT_CONFIGS.RotationStep
		end
	else
		rotation += SETTINGS.PLACEMENT_CONFIGS.RotationStep
	end]]

	-- Toggles currentRot
	local rotation = state._rotation

	rotation += SETTINGS.PLACEMENT_CONFIGS.RotationStep

	local rotateAmount = math.round(rotation / 90)

	local currentRot = rotateAmount % 2 == 0 and true or false
	if rotation >= 360 then
		rotation = 0
	end

	client._state:dispatch(CurrentRotChanged(currentRot))
	client._state:dispatch(RotationChanged(rotation))

	if SETTINGS.PLACEMENT_CONFIGS.PreferSignals == true then
		client.Rotated:Fire()
	end
end

local function UnbindInputs()
	ContextActionService:UnbindAction("Rotate")
	ContextActionService:UnbindAction("Terminate")
	ContextActionService:UnbindAction("Pause")

	if SETTINGS.PLACEMENT_CONFIGS.EnableFloors == true then
		ContextActionService:UnbindAction("Raise")
		ContextActionService:UnbindAction("Lower")
	end
end

-- Resets variables on termination
local function Reset(client: PlacementClient)
	local state: State = client._state:getState()

	local hitbox = state._hitbox

	client._trove:Destroy()

	--if mobileUI ~= nil then
	--	mobileUI.Parent = script
	--end

	UnbindInputs()

	client._state:dispatch(CurrentModelChanged(nil))
	client._state:dispatch(HitboxChanged(nil))
	client._state:dispatch(IsSetupChanged(false))
	client._state:dispatch(StackableChanged(false))
	client._state:dispatch(CurrentRotChanged(false))
	client._state:dispatch(RotationChanged(0))
	client._state:dispatch(AmplitudeChanged(5))
	client._state:dispatch(FloorHeightChanged(0))

	if hitbox ~= nil then
		hitbox:Destroy()
	end

	--canActivate = true
end

-- Terminates the current placement
local function TERMINATE_PLACEMENT(client: PlacementClient)
	local state: State = client._state:getState()

	if state._current_state == 4 then
		return
	end

	local hitbox = state._hitbox

	if hitbox == nil then
		return
	end

	SetCurrentState(4, client)

	-- Unbind

	-- Removes grid texture from plot
	--if SETTINGS.DisplayGridTexture and not removePlotDependencies then
	--RemoveTexture()
	--end

	--[[
    if SETTINGS.PLACEMENT_CONFIGS.AudibleFeedback == true and placementSFX then
		task.spawn(function()
			if currentState == 2 then
				placementSFX.Ended:Wait()
			end
			placementSFX:Destroy()
		end)
	end
    ]]

	Reset(client)

	if SETTINGS.PLACEMENT_CONFIGS.PreferSignals == true then
		client.Cancelled:Fire()
	end
end

local function BindInputs(client: PlacementClient)
	local state: State = client._state:getState()

	local stackable = state._stackable

	ContextActionService:BindAction(
		"Rotate",
		function(actionName: string, inputState: Enum.UserInputState, inputObj: InputObject?)
			ROTATE(actionName, inputState, inputObj, client)
		end,
		false,
		SETTINGS.CONTROLS.RotateKey,
		SETTINGS.CONTROLS.XboxRotate
	)

	ContextActionService:BindAction(
		"Terminate",
		function(actionName: string, inputState: Enum.UserInputState, inputObj: InputObject?)
			TERMINATE_PLACEMENT(client)
		end,
		false,
		SETTINGS.CONTROLS.TerminateKey,
		SETTINGS.CONTROLS.XboxTerminate
	)

	if SETTINGS.PLACEMENT_CONFIGS.EnableFloors == true then --and stackable ~= true then
		ContextActionService:BindAction(
			"Raise",
			function(actionName: string, inputState: Enum.UserInputState, inputObj: InputObject?)
				RaiseFloor(actionName, inputState, inputObj, client)
			end,
			false,
			SETTINGS.CONTROLS.RaiseKey,
			SETTINGS.CONTROLS.XboxRaise
		)
		ContextActionService:BindAction(
			"Lower",
			function(actionName: string, inputState: Enum.UserInputState, inputObj: InputObject?)
				LowerFloor(actionName, inputState, inputObj, client)
			end,
			false,
			SETTINGS.CONTROLS.LowerKey,
			SETTINGS.CONTROLS.XboxLower
		)
	end

	client._trove:Add(
		UserInputService.InputBegan:Connect(function(input: InputObject, game_processed: boolean)
			if game_processed then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				client:ConfirmPlacement()
			end

			if input.KeyCode == Enum.KeyCode.X then
				-- Delete the current model
				client:Delete()
			end
		end)
	)
end

-- Used for sending a final CFrame to the server when using interpolation.
local function GetFinalCFrame(client: PlacementClient): CFrame
	return CalculateItemLocation(nil, true, client)
end

-- Generates vibrations on placement if the player is using a controller
local function CreateHapticFeedback()
	local isVibrationSupported = HapticService:IsVibrationSupported(Enum.UserInputType.Gamepad1)
	local largeSupported

	coroutine.resume(coroutine.create(function()
		if not isVibrationSupported then
			return
		end
		largeSupported =
			HapticService:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large)

		if largeSupported then
			HapticService:SetMotor(
				Enum.UserInputType.Gamepad1,
				Enum.VibrationMotor.Large,
				SETTINGS.PLACEMENT_CONFIGS.VibrateAmount
			)

			task.wait(0.2)

			HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, 0)
		else
			HapticService:SetMotor(
				Enum.UserInputType.Gamepad1,
				Enum.VibrationMotor.Small,
				SETTINGS.PLACEMENT_CONFIGS.VibrateAmount
			)

			task.wait(0.2)

			HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
		end
	end))
end

local function PlayAudio(client: PlacementClient)
	if SETTINGS.PLACEMENT_CONFIGS.AudibleFeedback == true and client._sound ~= nil then
		client._sound:Play()
	end
end

local function PlacementFeedback(object_id: string, callback, client: PlacementClient)
	local state: State = client._state:getState()

	local cframe = state._cframe

	if cframe == nil then
		error("CFrame is nil")
	end

	if SETTINGS.PLACEMENT_CONFIGS.PreferSignals == true then
		client.PlacementConfirmed:Fire(object_id, cframe)
	else
		xpcall(function()
			if callback then
				callback()
			end
		end, function(err)
			warn("Error in callback: " .. err)
		end)
	end
end

local function PLACEMENT(self: PlacementClient, Function: RemoteFunction, callback: () -> ()?)
	local state: State = self._state:getState()

	if
		state._current_state == 3
		or state._current_state == 4
		or state._current_state == 5
		or state._current_model == nil
	then
		return
	end

	local cf: CFrame
	local objectName = state._current_model.Name

	-- Makes sure you have waited the cooldown period before placing
	--if not coolDown(player, SETTINGS.PlacementCooldown) then
	--	return
	--end
	if state._current_state ~= 2 and state._current_state ~= 1 then
		return
	end

	cf = GetFinalCFrame(self)

	self._state:dispatch(CFrameChanged(cf))

	CheckHitbox(self)

	--print(objectName, placedObjects, self.Prefabs, Function, plot)
	--[[if not Function:InvokeServer(objectName, placedObjects, self.Prefabs, cf, plot) then
		return
	end]]

	-- get the ID
	local id = state._current_model:GetAttribute("Id")

	if id == nil then
		error("Object does not have an ID attribute")
	end

	if SETTINGS.PLACEMENT_CONFIGS.BuildModePlacement == true then
		SetCurrentState(1, self)
	else
		TERMINATE_PLACEMENT(self)
	end
	if SETTINGS.PLACEMENT_CONFIGS.HapticFeedback == true and GuiService:IsTenFootInterface() then
		CreateHapticFeedback()
	end

	PlayAudio(self)
	PlacementFeedback(id, callback, self)
end

local function DELETE(self: PlacementClient, structure: Model)
	if structure == nil then
		return
	end

	if structure:IsA("Model") == false then
		return
	end

	if structure:IsDescendantOf(self._plot:FindFirstChild("Structures")) == false then
		return
	end

	-- fire the delete signal
	self.DeleteStructure:Fire(structure)
end

local function CreateAudioFeedback()
	local audio = Instance.new("Sound")
	audio.Name = "PlacementFeedback"
	audio.Volume = SETTINGS.PLACEMENT_CONFIGS.AudioVolume
	audio.SoundId = SETTINGS.PLACEMENT_CONFIGS.SoundID
	audio.Parent = game:GetService("SoundService")

	return audio
end

----- Public functions -----

function PlacementClient.new(plot: Model, grid_unit: number?)
	assert(ModelIsPlot(plot) == true, "[PlacementClient] new: Plot must be a plot object")

	grid_unit = grid_unit or SETTINGS.DefaultGridSize

	-- Verify the plot
	ApproveActivation(plot:FindFirstChild("Platform"), grid_unit)

	local self = setmetatable({}, PlacementClient)

	self._state = Store.new(reducers, SETTINGS.INITIAL_STATE, {})

	-- Properties
	self._grid_unit = grid_unit

	self._active = true
	self._mouse = Mouse.new()
	self._trove = Trove.new()
	self._plot = plot

	self._mouse:SetFilterType(Enum.RaycastFilterType.Include)
	self._mouse:SetTargetFilter({
		plot:FindFirstChild("Tiles"),
		plot:FindFirstChild("Structures"),
	})

	self.Placed = Signal.new()
	self.Collided = Signal.new()
	self.Rotated = Signal.new()
	self.Cancelled = Signal.new()
	self.LevelChanged = Signal.new()
	self.OutOfRange = Signal.new()
	self.Initiated = Signal.new()
	self.PlacementConfirmed = Signal.new()
	self.DeleteStructure = Signal.new()

	self._ignored_items = {}

	self._raycast_params = RaycastParams.new()

	self._state:dispatch(GridUnitChanged(grid_unit))

	return self
end

function PlacementClient:InitiatePlacement(model: Model, settings: ModelSettings?)
	assert(model ~= nil, "[PlacementClient] InitiatePlacement: Model must not be nil")
	assert(model.ClassName == "Model", "[PlacementClient] InitiatePlacement: Model must be a Model")
	assert(model:IsA("Model"), "[PlacementClient] InitiatePlacement: Model must be a Model")

	local state = self._state:getState()

	if state._current_state ~= 4 then
		-- TERMINATE
		self:CancelPlacement()
	end

	if self:IsMobile() == true then
		-- add the mobile UI to the screen
	end

	local character = LMEngine.Player.Character

	self._sound = self._trove:Add(CreateAudioFeedback())
	self._trove:Add(model)

	self._state:dispatch(CurrentModelChanged(model))

	-- Sets properties of the model (CanCollide, Transparency)
	for i, inst in ipairs(model:GetDescendants()) do
		if inst:IsA("BasePart") == false then
			continue
		end
		if SETTINGS.PLACEMENT_CONFIGS.TransparentModel == true then
			inst.Transparency = inst.Transparency + SETTINGS.PLACEMENT_CONFIGS.TransparencyDelta
		end

		inst.CanCollide = false
		inst.Anchored = true
	end

	if SETTINGS.PLACEMENT_CONFIGS.RemoveCollisionsIfIgnored == true then
		for i, v: Instance in ipairs(self._ignored_items) do
			if v:IsA("BasePart") then
				v.CanTouch = false
			end
		end
	end

	model.PrimaryPart.Transparency = SETTINGS.PLACEMENT_CONFIGS.HitboxTransparency

	self._raycast_params.FilterDescendantsInstances = {
		self._plot:FindFirstChild("Structures"),
		character,
		unpack(self._ignored_items),
	}

	self._raycast_params.FilterType = Enum.RaycastFilterType.Exclude

	if settings ~= nil then
		if settings.can_stack ~= nil then
			self._state:dispatch(StackableChanged(settings.can_stack))

			if settings.can_stack == true then
				self._raycast_params.FilterDescendantsInstances = {
					model,
					character,
					unpack(self._ignored_items),
				}
			end

			if settings.radius ~= nil and settings.radius > 0 then
				MakeRadiusVisual(settings.radius, self)
			end
		end
	end

	local platform = self._plot:FindFirstChild("Platform")

	initial_Y =
		CalculateYPosition(platform.Position.Y, platform.Size.Y, model.PrimaryPart.Size.Y, 1)

	local pre_speed = 1

	-- SETUP

	if SETTINGS.PLACEMENT_CONFIGS.IncludeSelectionBox == true then
		MakeSelectionBox(self)
	end

	EditHitboxColor(self)

	local pre_speed = 1

	SetupInitialization(self)

	BindInputs(self)

	if SETTINGS.PLACEMENT_CONFIGS.Interpolation == true then
		pre_speed = math.clamp(
			math.abs(tonumber(1 - SETTINGS.PLACEMENT_CONFIGS.LerpSpeed) :: number),
			0,
			0.9
		)
		speed = pre_speed

		if SETTINGS.InstantActivation == true then
			self._state:dispatch(IsSetupChanged(true))
			speed = 1
		end
	end

	-- Parents the object to the location given

	SetCurrentState(1, self)

	if SETTINGS.PLACEMENT_CONFIGS.PreferSignals == true then
		self.Placed:Fire()
	end

	if SETTINGS.PLACEMENT_CONFIGS.InstantActivation then
		TranslateObject(1, self)
	end

	model.Parent = self._plot:FindFirstChild("Structures")

	speed = pre_speed

	if SETTINGS.PLACEMENT_CONFIGS.PreferSignals == true then
		self.Initiated:Fire()
	end

	self._state:dispatch(RunningChanged(true))
	self._state:dispatch(IsSetupChanged(true))

	self._trove:BindToRenderStep("Input", Enum.RenderPriority.Input.Value, function(dt)
		TranslateObject(dt, self)
	end)
end

function PlacementClient:IsPlacing()
	local state: State = self._state:getState()

	return state._current_state ~= 4
end

function PlacementClient:IsActive() end

function PlacementClient:CancelPlacement()
	TERMINATE_PLACEMENT(self)
end

function PlacementClient:RaiseLevel()
	RaiseFloor("Raise", Enum.UserInputState.Begin, nil, self)
end

function PlacementClient:LowerLevel()
	LowerFloor("Lower", Enum.UserInputState.Begin, nil, self)
end

function PlacementClient:ConfirmPlacement()
	local state: State = self._state:getState()

	if state._current_state == 4 then
		return
	end

	if state._auto_placement == false then
		PLACEMENT(self)
		return
	end

	self._state:dispatch(RunningChanged(true))

	repeat
		PLACEMENT(self)

		task.wait(SETTINGS.PLACEMENT_CONFIGS.PlacementCooldown)
	until (self._state:getState() :: State)._running == false
end

function PlacementClient:Delete()
	local state: State = self._state:getState()

	if state._current_state == 4 then
		return
	end

	local current_model = state._current_model

	if current_model == nil then
		return
	end

	-- get the model that the mouse is hovering over
	local mouse = self._mouse
	local target = mouse:GetTarget()

	if target == nil then
		return
	end

	local model = target:FindFirstAncestorWhichIsA("Model")

	if model == nil then
		return
	end

	-- check if the model is a structure
	if model:IsDescendantOf(self._plot:FindFirstChild("Structures")) == false then
		return
	end

	-- check if the model is the current model
	if model == current_model then
		return
	end

	DELETE(self, model)
end

function PlacementClient:Destroy()
	self._state:destruct()
	self._trove:Destroy()

	self._active = false
end

function PlacementClient:GetPlatform(): string
	local is_xbox = UserInputService.GamepadEnabled
	local is_mobile = UserInputService.TouchEnabled

	if is_mobile then
		return "Mobile"
	elseif is_xbox then
		return "Console"
	else
		return "PC"
	end
end

function PlacementClient:UpdateGridUnit(grid_unit: number)
	assert(grid_unit ~= nil, "[PlacementClient] UpdateGridUnit: Grid unit must not be nil")
	assert(grid_unit > 0, "[PlacementClient] UpdateGridUnit: Grid unit must be greater than 0")

	self._state:dispatch(GridUnitChanged(grid_unit))
end

function PlacementClient:IsMobile(): boolean
	return self:GetPlatform() == "Mobile"
end

function PlacementClient:IsConsole(): boolean
	return self:GetPlatform() == "Console"
end

return PlacementClient
