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
        InstantActivation = false, -- Toggles if the model will appear at the mouse position immediately when activating placement
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
        FloorStep = 8, -- The step (in studs) that the object will be raised or lowered
        GridTextureScale = 1, -- How large the StudsPerTileU/V is displayed (smartDisplay must be set to false)
        MaxHeight = 100, -- Max height you can place objects (in studs)
        MaxRange = 100, -- Max range for the model (in studs)
        RotationStep = 90, -- Rotation step
        TargetFPS = 60, -- The target constant FPS

        -- Numbers/Floats
        AngleTiltAmplitude = 5, -- How much the object will tilt when moving. 0 = min, 10 = max
        AudioVolume = 0.5, -- Volume of the sound feedback
        HitboxTransparency = 0.5, -- Hitbox transparency when placing
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
		TerminateKey = Enum.KeyCode.X, -- Key to terminate placement
		RaiseKey = Enum.KeyCode.E, -- Key to raise the object
		LowerKey = Enum.KeyCode.Q, -- Key to lower the object

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

        _rotation = 0,
        _amplitude = 5,
    },

    POSSIBLE_STATES = { "Movement", "Placing", "Colliding", "Inactive", "Out-of-range" };
}

----- Types -----

type State = {
    _current_state: number,
    _running: boolean,
    _current_model: Model?,
    _last_state: number,

    _grid_unit: number,

    _hitbox: BasePart,
    _is_setup: boolean,
    _stackable: boolean,
    _current_rot: boolean,
    _amplitude: number,
}

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

    GetPlatform: (self: PlacementClient) -> string,
    IsMobile: (self: PlacementClient) -> boolean,
    IsConsole: (self: PlacementClient) -> boolean,
}

type PlacementClientMembers = {

	_state: Rodux.Store,
	_mouse: Mouse.Mouse,
	_trove: Trove.Trove,
	_plot: Model,
	_active: boolean,
	_selection_box: SelectionBox?,

    Placed: Signal.Signal<PlacementType.ServerState>,
    Collided: Signal.Signal<PlacementType.ServerState>,
    Rotated: Signal.Signal<PlacementType.ServerState>,
    Cancelled: Signal.Signal<PlacementType.ServerState>,
    LevelChanged: Signal.Signal<PlacementType.ServerState>,
    OutOfRange: Signal.Signal<PlacementType.ServerState>,

	PlacementConfirmed: Signal.Signal<PlacementType.ServerState>,
}

export type PlacementClient = typeof(setmetatable({} :: PlacementClientMembers, {} :: IPlacementClient))

----- Private variables -----

-- values used for calculations
local speed: number = 1
local range_of_ray: number = 10000
local y: number
local dir_X: number
local dir_Z: number
local initial_Y: number
local floor_height: number = 0

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
		return action._current_state;
	end,
});

local last_state_changed = Rodux.createReducer(4, {
    ["LAST_STATE_CHANGED"] = function(state: State, action)
        return action._last_state;
    end,
});

local running_changed = Rodux.createReducer(false, {
    ["RUNNING_CHANGED"] = function(state: State, action)
        return action._running;
    end,
});

local current_model_changed = Rodux.createReducer(nil, {
    ["CURRENT_MODEL_CHANGED"] = function(state: State, action)
        return action._current_model;
    end,
});

local hitbox_changed = Rodux.createReducer(nil, {
    ["HITBOX_CHANGED"] = function(state: State, action)
        return action._hitbox;
    end,
});

local is_setup_changed = Rodux.createReducer(false, {
    ["IS_SETUP_CHANGED"] = function(state: State, action)
        return action._is_setup;
    end,
});

local stackable_changed = Rodux.createReducer(false, {
    ["STACKABLE_CHANGED"] = function(state: State, action)
        return action._stackable;
    end,
});

local rotation_changed = Rodux.createReducer(0, {
    ["ROTATION_CHANGED"] = function(state: State, action)
        return action._rotation;
    end,
});

local grid_unit_changed = Rodux.createReducer(SETTINGS.DefaultGridSize, {
    ["GRID_UNIT_CHANGED"] = function(state: State, action)
        return action._grid_unit;
    end,
});

local current_rot_changed = Rodux.createReducer(false, {
    ["CURRENT_ROT_CHANGED"] = function(state: State, action)
        return action._current_rot;
    end,
});

local amplitude_changed = Rodux.createReducer(5, {
    ["AMPLITUDE_CHANGED"] = function(state: State, action)
        return action._amplitude;
    end,
});

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
});

----- Actions -----

local function CurrentStateChanged(current_state: number)
    return {
        type = "CURRENT_STATE_CHANGED",
        _current_state = current_state,
    };
end

local function LastStateChanged(last_state: number)
    return {
        type = "LAST_STATE_CHANGED",
        _last_state = last_state,
    };
end

local function RunningChanged(running: boolean)
    return {
        type = "RUNNING_CHANGED",
        _running = running,
    };
end

local function CurrentModelChanged(current_model: Model)
    return {
        type = "CURRENT_MODEL_CHANGED",
        _current_model = current_model,
    };
end

local function HitboxChanged(hitbox: BasePart)
    return {
        type = "HITBOX_CHANGED",
        _hitbox = hitbox,
    };
end

local function IsSetupChanged(is_setup: boolean)
    return {
        type = "IS_SETUP_CHANGED",
        _is_setup = is_setup,
    };
end

local function StackableChanged(stackable: boolean)
    return {
        type = "STACKABLE_CHANGED",
        _stackable = stackable,
    };
end

local function RotationChanged(rotation: number)
    return {
        type = "ROTATION_CHANGED",
        _rotation = rotation,
    };
end

local function GridUnitChanged(grid_unit: number)
    return {
        type = "GRID_UNIT_CHANGED",
        _grid_unit = grid_unit,
    };
end

local function CurrentRotChanged(current_rot: boolean)
    return {
        type = "CURRENT_ROT_CHANGED",
        _current_rot = current_rot,
    };
end

local function AmplitudeChanged(amplitude: number)
    return {
        type = "AMPLITUDE_CHANGED",
        _amplitude = amplitude,
    };
end



----- Private functions -----

local function GetRange(part: BasePart): number
	local character = LMEngine.Player.Character;

    if (character == nil) then
        return 0;
    end

	return (part.Position - character.PrimaryPart.Position).Magnitude;
end

-- Clamps the x and z positions so they cannot leave the plot
local function Bounds(platform: BasePart, cframe: CFrame, offsetX: number, offsetZ: number): CFrame
	local pos: CFrame = platform.CFrame
	local xBound: number = (platform.Size.X * 0.5) - offsetX;
	local zBound: number = (platform.Size.Z * 0.5) - offsetZ;

	local newX: number = math.clamp(cframe.X, -xBound, xBound);
	local newZ: number = math.clamp(cframe.Z, -zBound, zBound);

	local newCFrame: CFrame = CFrame.new(newX, 0, newZ);

	return newCFrame;
end

local function SetCurrentState(state: number, client: PlacementClient)
    local state: State = client._state:getState();

    local last_state = state.current_state;
    client._state:dispatch(CurrentStateChanged(state));
    client._state:dispatch(LastStateChanged(last_state));
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

	local structures = model:FindFirstChild("Structures")

	if structures == nil then
		return false
	end

	if structures:IsA("Folder") == false then
		return false
	end

    local platform = model:FindFirstChild("Platform");

    if platform == nil then
        return false;
    end

    if (platform:IsA("Part") == false) then
        return false;
    end

	return true
end

local function CheckHitbox(client: PlacementClient)
    local state: State = client._state:getState();

    local hitbox = state._hitbox;
    local current_model = state._current_model;
    local plot = client._plot;

	if (hitbox:IsDescendantOf(workspace) == false and SETTINGS.PLACEMENT_CONFIGS.Collisions == false) then
		return
	end

	--[[if range then
		SetCurrentState(5, client);
	else
		SetCurrentState(1, client);
	end]]

	local collisionPoints: { BasePart } = workspace:GetPartsInPart(hitbox);

    local character = LMEngine.Player.Character;

    if (character == nil) then
        return;
    end

	-- Checks if there is collision on any object that is not a child of the object and is not a child of the player
	for i: number = 1, #collisionPoints, 1 do
		if (collisionPoints[i].CanTouch == false) then
			continue
		end
		if (SETTINGS.PLACEMENT_CONFIGS.CharacterCollisions ~= true and collisionPoints[i]:IsDescendantOf(character) == true) then
			continue
		end

		if (collisionPoints[i]:IsDescendantOf(current_model) == true or collisionPoints[i] == plot) then
			continue;
		end

		SetCurrentState(3, client);
		if SETTINGS.PLACEMENT_CONFIGS.PreferSignals == true then
			client.Collided:Fire(collisionPoints[i]);
		end
		break
	end

	return
end

local function EditHitboxColor(client: PlacementClient)
    local state: State = client._state:getState();

    local current_model = state._current_model;

    if current_model == nil then
        return;
    end

    if current_model.PrimaryPart == nil then
        return;
    end

	local color = SETTINGS.PLACEMENT_CONFIGS.HitboxColor3;
	local color2 = SETTINGS.PLACEMENT_CONFIGS.SelectionBoxColor3;

	if (state._current_state) >= 3 then
		color = SETTINGS.CollisionColor3;
		color2 = SETTINGS.SelectionBoxCollisionColor3;
	end

	current_model.PrimaryPart.Color = color

	if (SETTINGS.PLACEMENT_CONFIGS.IncludeSelectionBox == true) then
		if SETTINGS.PLACEMENT_CONFIGS.UseHighlights then
			client._selection_box.OutlineColor = color2
		else
			client._selection_box.Color3 = color2
		end
	end
end


-- Returns a rounded cframe to the nearest grid unit
local function SnapCFrame(platform: BasePart, cframe: CFrame, client: PlacementClient): CFrame

    local state: State = client._state:getState();

    local grid_unit = state._grid_unit;

	local offsetX: number = (platform.Size.X % (2 * grid_unit)) * 0.5
	local offsetZ: number = (platform.Size.Z % (2 * grid_unit)) * 0.5
	local newX: number = math.round(cframe.X / grid_unit) * grid_unit - offsetX
	local newZ: number = math.round(cframe.Z / grid_unit) * grid_unit - offsetZ
	local newCFrame: CFrame = cframe(newX, 0, newZ)

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

    local state: State = client._state:getState();

    local rotation = state._rotation;

    local platform = client._plot:FindFirstChild("Platform");

	-- Calculates and clamps the proper angle amount
	local tiltX = (math.clamp((last.X - current.X), -10, 10) * math.pi / 180) * state._amplitude
	local tiltZ = (math.clamp((last.Z - current.Z), -10, 10) * math.pi / 180) * state._amplitude
	local preCalc = (rotation + platform.Orientation.Y) * math.pi / 180

	-- Returns the proper angle based on rotation
	return (CFrame.fromEulerAnglesXYZ(dir_Z * tiltZ, 0, dir_X * tiltX):Inverse() * CFrame.fromEulerAnglesXYZ(0, preCalc, 0)):Inverse()
		* CFrame.fromEulerAnglesXYZ(0, preCalc, 0)
end

-- Calculates the position of the object
local function CalculateItemLocation(last, final: boolean, client: PlacementClient): CFrame
	
    local state: State = client._state:getState();

    local current_model = state._current_model;
    local primary = current_model.PrimaryPart;

    local platform = client._plot:FindFirstChild("Platform");

    local x: number, z: number
	local sizeX: number, sizeZ: number = primary.Size.X * 0.5, primary.Size.Z * 0.5
	local offsetX: number, offsetZ: number = sizeX, sizeZ
	local finalC: CFrame

	if (state._current_rot == false) then
		sizeX = primary.Size.Z * 0.5;
		sizeZ = primary.Size.X * 0.5;
	end

	if SETTINGS.PLACEMENT_CONFIGS.MoveByGrid == true then
		offsetX = sizeX - math.floor(sizeX / state._grid_unit) * state._grid_unit
		offsetZ = sizeZ - math.floor(sizeZ / state._grid_unit) * state._grid_unit
	end

    local raycastParams = RaycastParams.new()
	local cam: Camera = workspace.CurrentCamera
	local ray
	local nilRay
	local target

	if (client:IsMobile() == true) then
		local camPos: Vector3 = cam.CFrame.Position
		ray = workspace:Raycast(camPos, cam.CFrame.LookVector * range_of_ray, raycastParams)
		nilRay = camPos + cam.CFrame.LookVector * (SETTINGS.PLACEMENT_CONFIGS.MaxRange + platform.Size.X * 0.5 + platform.Size.Z * 0.5)
	else

        local mouse = client._mouse;
        local mouse_position = mouse:GetPosition();
		local unit: Ray = cam:ScreenPointToRay(mouse_position.X, mouse_position.Y, 1)
		ray = workspace:Raycast(unit.Origin, unit.Direction * range_of_ray, raycastParams)
		nilRay = unit.Origin + unit.Direction * (SETTINGS.PLACEMENT_CONFIGS.MaxRange + platform.Size.X * 0.5 + platform.Size.Z * 0.5)
	end

	if ray then
		x, z = ray.Position.X - offsetX, ray.Position.Z - offsetZ

		--[[
        if stackable then
			target = ray.Instance
		else
			target = plot
		end
        --]]
        target = platform;
	else
		x, z = nilRay.X - offsetX, nilRay.Z - offsetZ
		target = platform;
	end

	target = target

	local pltCFrame: CFrame = platform.CFrame
	local positionCFrame = CFrame.new(x, 0, z) * CFrame.new(offsetX, 0, offsetZ)

	y = CalculateYPosition(platform.Position.Y, platform.Size.Y, primary.Size.Y, 1) + floor_height;

	-- Changes y depending on mouse target
	if state._stackable and target and (target:IsDescendantOf(client._plot:FindFirstChild("Structures")) or target == platform) then
		if ray and ray.Normal then
			local normal =
				CFrame.new(ray.Normal):VectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Top)):Dot(ray.Normal)
			y = CalculateYPosition(target.Position.Y, target.Size.Y, primary.Size.Y, normal)
		end
	end

	if SETTINGS.PLACEMENT_CONFIGS.MoveByGrid == true then
		-- Calculates the correct position
		local rel: CFrame = pltCFrame:Inverse() * positionCFrame
		local snappedRel: CFrame = SnapCFrame(rel, state._grid_unit) * CFrame.new(offsetX, 0, offsetZ)

		--if not removePlotDependencies then
			--snappedRel = Bounds(snappedRel, sizeX, sizeZ)
		--end
		finalC = pltCFrame * snappedRel
	else
		finalC = pltCFrame:Inverse() * positionCFrame

		finalC = Bounds(finalC, sizeX, sizeZ)

		finalC = pltCFrame * finalC
	end

	-- Clamps y to a max height above the plot position
	y = math.clamp(y, initial_Y, SETTINGS.PLACEMENT_CONFIGS.MaxHeight + initial_Y)

	-- For placement or no intepolation
	if final or not SETTINGS.PLACEMENT_CONFIGS.Interpolation then
		return (finalC * CFrame.new(0, y - platform.Position.Y, 0)) * CFrame.fromEulerAnglesXYZ(0, state._rotation * math.pi / 180, 0)
	end

	return (finalC * CFrame.new(0, y - platform.Position.Y, 0))
		* CFrame.fromEulerAnglesXYZ(0, state._rotation * math.pi / 180, 0)
		* CalculateAngle(last, finalC)
end

local function TranslateObject(dt: number, client: PlacementClient)
    local state: State = client._state:getState();

    local current_model = state._current_model;
    local primary = current_model.PrimaryPart;
    local hitbox = state._hitbox;

	if (state._current_state == 2 or state._current_state == 4) then
		return
	end

	--range = false
	SetCurrentState(1, client);

	if GetRange(primary) > SETTINGS.PLACEMENT_CONFIGS.MaxRange then
		SetCurrentState(5, client);

		if SETTINGS.PLACEMENT_CONFIGS.PreferSignals == true then
			client.OutOfRange:Fire()
		end

		--range = true
	end

	CheckHitbox();
	EditHitboxColor();

	if (SETTINGS.PLACEMENT_CONFIGS.Interpolation == true and state._is_setup == false) then
		current_model:PivotTo(
			primary.CFrame:Lerp(CalculateItemLocation(primary.CFrame.Position, false, client), speed * dt * SETTINGS.PLACEMENT_CONFIGS.TargetFPS)
		)
		hitbox:PivotTo(CalculateItemLocation(hitbox.CFrame.Position, true, client))
	else
		current_model:PivotTo(CalculateItemLocation(primary.CFrame.Position, false, client))
		hitbox:PivotTo(CalculateItemLocation(hitbox.CFrame.Position, true, client))
	end
end

----- Public functions -----

function PlacementClient.new(plot: Model, grid_unit: number?)
	assert(ModelIsPlot(plot) == true, "[PlacementClient] new: Plot must be a plot object");

	local self = setmetatable({}, PlacementClient);

	self._state = Store.new(reducers, SETTINGS.INITIAL_STATE, {});

    -- Properties
    self._grid_unit = grid_unit or SETTINGS.DefaultGridSize;

	self._active = true;
	self._mouse = Mouse.new();
	self._trove = Trove.new();
	self._plot = plot;

	self._mouse:SetFilterType(Enum.RaycastFilterType.Include);
	self._mouse:SetTargetFilter({
		plot:FindFirstChild("Tiles"),
		plot:FindFirstChild("Structures"),
	});

	self.Placed = Signal.new();
    self.Collided = Signal.new();
    self.Rotated = Signal.new();
    self.Cancelled = Signal.new();
    self.LevelChanged = Signal.new();
    self.OutOfRange = Signal.new();

    self._trove:BindToRenderStep("Input", Enum.RenderPriority.Input.Value, function(dt)
        
    end)
	return self;
end

function PlacementClient:InitiatePlacement(model: Model)
	assert(model ~= nil, "[PlacementClient] InitiatePlacement: Model must not be nil")
	assert(model.ClassName == "Model", "[PlacementClient] InitiatePlacement: Model must be a Model")
	assert(model:IsA("Model"), "[PlacementClient] InitiatePlacement: Model must be a Model")

end

function PlacementClient:IsPlacing()
	
end

function PlacementClient:IsActive()
	
end

function PlacementClient:CancelPlacement()
end

function PlacementClient:RaiseLevel()
	
end

function PlacementClient:LowerLevel()
	
end

function PlacementClient:ConfirmPlacement()
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

function PlacementClient:IsMobile(): boolean
    return self:GetPlatform() == "Mobile"
end

function PlacementClient:IsConsole(): boolean
    return self:GetPlatform() == "Console"
end

return PlacementClient
