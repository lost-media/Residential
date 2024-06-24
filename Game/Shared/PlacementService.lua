--!nonstrict

--[[

Thank you for using Placement Service!

Current Version - V1.6.2
Written by zblox164. Initial release (V1.0.0) on 2020-05-22

]]
--

local SETTINGS = {
	-- Bools
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
}
-- IT IS RECOMMENDED NOT TO EDIT PAST THIS POINT

local PlacementInfo = { __type = "PlacementInfo" }
PlacementInfo.__index = PlacementInfo

-- SETTINGS (DO NOT EDIT SETTINGS IN THE SCRIPT. USE THE ATTRIBUTES INSTEAD)

-- Bools

--[[
local angleTilt: boolean = script:GetAttribute("AngleTilt") -- Toggles if you want the object to tilt when moving (based on speed)
local audibleFeedback: boolean = script:GetAttribute("AudibleFeedback") -- Toggles sound feedback on placement
local buildModePlacement: boolean = script:GetAttribute("BuildModePlacement") -- Toggles "build mode" placement
local charCollisions: BoolValue = script:GetAttribute("CharacterCollisions") -- Toggles character collisions (Requires "Collisions" to be set to true)
local collisions: boolean = script:GetAttribute("Collisions") -- Toggles collisions
local DisplayGridTexture: boolean = script:GetAttribute("DisplayGridTexture") -- Toggles the grid texture to be shown when placing
local enableFloors: boolean = script:GetAttribute("EnableFloors") -- Toggles if the raise and lower keys will be enabled
local gridFadeIn: boolean = script:GetAttribute("GridFadeIn") -- If you want the grid to fade in when activating placement
local gridFadeOut: boolean = script:GetAttribute("GridFadeOut") -- If you want the grid to fade out when ending placement
local includeSelectionBox: boolean = script:GetAttribute("IncludeSelectionBox") -- Toggles if a selection box will be shown while placing
local instantActivation: boolean = script:GetAttribute("InstantActivation") -- Toggles if the model will appear at the mouse position immediately when activating placement
local interpolation: boolean = script:GetAttribute("Interpolation") -- Toggles interpolation (smoothing)
local invertAngleTilt: boolean = script:GetAttribute("InvertAngleTilt") -- Inverts the direction of the angle tilt
local moveByGrid: boolean = script:GetAttribute("MoveByGrid") -- Toggles grid system
local preferSignals: boolean = script:GetAttribute("PreferSignals") -- Controls if you want to use signals or callbacks
local removeCollisionsIfIgnored: boolean = script:GetAttribute("RemoveCollisionsIfIgnored") -- Toggles if you want to remove collisions on objects that are ignored by the mouse
local smartDisplay: boolean = script:GetAttribute("SmartDisplay") -- Toggles smart display for the grid. If true, it will rescale the grid texture to match your gridsize
local transparentModel: boolean = script:GetAttribute("TransparentModel") -- Toggles if the model itself will be transparent
local useHighlights: boolean = script:GetAttribute("UseHighlights") -- Toggles whether the selection box will be a highlight object or a selection box (TransparencyDelta must be 0)

-- Color3
local collisionColor: Color3 = script:GetAttribute("CollisionColor3") -- Color of the hitbox when colliding
local hitboxColor: Color3 = script:GetAttribute("HitboxColor3") -- Color of the hitbox while not colliding
local selectionCollisionColor: Color3 = script:GetAttribute("SelectionBoxCollisionColor3") -- Color of the selectionBox lines when colliding (includeSelectionBox much be set to true)
local selectionColor: Color3 = script:GetAttribute("SelectionBoxColor3") -- Color of the selectionBox lines (includeSelectionBox much be set to true)

-- Integers (Will round to nearest unit if given float)
local floorStep: number = script:GetAttribute("FloorStep") -- The step (in studs) that the object will be raised or lowered
local gridTextureScale: number = script:GetAttribute("GridTextureScale") -- How large the StudsPerTileU/V is displayed (smartDisplay must be set to false)
local maxHeight: number = script:GetAttribute("MaxHeight") -- Max height you can place objects (in studs)
local maxRange: number = script:GetAttribute("MaxRange") -- Max range for the model (in studs)
local rotationStep: number = script:GetAttribute("RotationStep") -- Rotation step

-- Numbers/Floats
local angleTiltAmplitude: number = script:GetAttribute("AngleTiltAmplitude") -- How much the object will tilt when moving. 0 = min, 10 = max
local audioVolume: number = script:GetAttribute("AudioVolume") -- Volume of the sound feedback
local hitboxTransparency: number = script:GetAttribute("HitboxTransparency") -- Hitbox transparency when placing
local lerpSpeed: number = script:GetAttribute("LerpSpeed") -- Speed of interpolation. 0 = no interpolation, 0.9 = major interpolation
local lineThickness: number = script:GetAttribute("LineThickness") -- How thick the line of the selection box is (includeSelectionBox much be set to true)
local lineTransparency: number = script:GetAttribute("LineTransparency") -- How transparent the line of the selection box is (includeSelectionBox must be set to true)
local placementCooldown: number = script:GetAttribute("PlacementCooldown") -- How quickly the user can place down objects (in seconds)
local targetFPS: number = script:GetAttribute("TargetFPS") -- The target constant FPS
local transparencyDelta: number = script:GetAttribute("TransparencyDelta") -- Transparency of the model itself (transparentModel must equal true)

-- Other
local gridTexture: string = script:GetAttribute("GridTextureID") -- ID of the grid texture shown while placing (requires DisplayGridTexture == true)
local soundID: string = script:GetAttribute("SoundID") -- ID of the sound played on Placement (requires audibleFeedback == true)

-- Cross Platform
local hapticFeedback: boolean = script:GetAttribute("HapticFeedback") -- If you want a controller to vibrate when placing objects (only works if the user has a controller with haptic support)
local vibrateAmount: number = script:GetAttribute("HapticVibrationAmount") -- How large the vibration is when placing objects. Choose a value from 0, 1. hapticFeedback must be set to true.
--]]

-- Essentials
local contextActionService: ContextActionService = game:GetService("ContextActionService")
local guiService: GuiService = game:GetService("GuiService")
local hapticService: HapticService = game:GetService("HapticService")
local runService: RunService = game:GetService("RunService")
local tweenService: TweenService = game:GetService("TweenService")
local userInputService: UserInputService = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera: Camera = workspace.CurrentCamera
local mouse: Mouse = player:GetMouse()

-- math/cframe functions
local clamp: (number, number, number) -> number = math.clamp
local floor: (number) -> number = math.floor
local abs: (number) -> number = math.abs
local min: (number, ...number) -> number = math.min
local pi: number = math.pi
local round: (number) -> number = math.round
local cframe = CFrame.new
local anglesXYZ: (number, number, number) -> CFrame = CFrame.fromEulerAnglesXYZ
local fromOrientation: (number, number, number) -> CFrame = CFrame.fromOrientation

-- states
local states: {} = { "movement", "placing", "colliding", "inactive", "out-of-range" }

local currentState: number = 4
local lastState: number = 4

-- Constructor variables
local GRID_UNIT: number
local rotateKey: Enum.KeyCode
local terminateKey: Enum.KeyCode
local raiseKey: Enum.KeyCode
local lowerKey: Enum.KeyCode
local xboxRotate: Enum.KeyCode
local xboxTerminate: Enum.KeyCode
local xboxRaise: Enum.KeyCode
local xboxLower: Enum.KeyCode
local mobileUI: ScreenGui = script:FindFirstChildOfClass("ScreenGui")

-- signals
--[[
local placed: BindableEvent
local collided: BindableEvent
local outOfRange: BindableEvent
local rotated: BindableEvent
local terminated: BindableEvent
local changeFloors: BindableEvent
local activated: BindableEvent
-]]

-- bools
local autoPlace: boolean?
local canActivate: boolean? = true
local isMobile: boolean? = false
local isXbox: boolean? = false
local currentRot: boolean? = false
local removePlotDependencies: boolean?
local setup: boolean? = false

local running: boolean? = false
local canPlace: boolean?
local stackable: boolean? = false
local smartRot: boolean?
local range: boolean?

-- values used for calculations
local speed: number = 1
local rangeOfRay: number = 10000
local y: number
local dirX: number
local dirZ: number
local initialY: number
local floorHeight: number = 0

-- Placement Variables
local hitbox
local object
local primary
local selection
local plot
local target
local placementSFX
local rotation
local mobileUI
local placedObjects
local amplitude

-- other
local lastPlacement: {} = {}
local humanoid: Humanoid = character:WaitForChild("Humanoid")
local raycastParams: RaycastParams = RaycastParams.new()
local messages: {} = {
	["101"] = "[Placement Service] Your trying to activate placement too fast! Please slow down.",
	["201"] = "[Placement Service] Error code 201: The object that the model is moving on is not scaled correctly. Consider changing it.",
	["301"] = "[Placement Service] Error code 301: You have improperly setup your callback function. Please input a valid callback.",
	["401"] = "[Placement Service] Error code 401: Grid size is too close to the plot size. To fix this, try lowering the grid size.",
	["501"] = "[Placement Service] Error code 501: Cannot find a surface to place on. Please make sure one is available.",
}

-- Tween Info
local fade: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

-- Sets the current state depending on input of function
local function SetCurrentState(state: number)
	currentState = clamp(state, 1, 5)
	lastState = currentState
end

-- Changes the color of the hitbox depending on the current state
local function EditHitboxColor()
	if not primary then
		return
	end
	local color = SETTINGS.HitboxColor3
	local color2 = SETTINGS.SelectionBoxColor3

	if currentState >= 3 then
		color = SETTINGS.CollisionColor3
		color2 = SETTINGS.SelectionBoxCollisionColor3
	end

	primary.Color = color

	if SETTINGS.IncludeSelectionBox == true then
		if SETTINGS.UseHighlights then
			selection.OutlineColor = color2
		else
			selection.Color3 = color2
		end
	end
end

-- Checks for collisions on the hitbox
local function CheckHitbox()
	if not (hitbox:IsDescendantOf(workspace) and SETTINGS.Collisions) then
		return
	end
	if range then
		SetCurrentState(5)
	else
		SetCurrentState(1)
	end
	character = player.Character

	local collisionPoints: { BasePart } = workspace:GetPartsInPart(hitbox)

	-- Checks if there is collision on any object that is not a child of the object and is not a child of the player
	for i: number = 1, #collisionPoints, 1 do
		if not collisionPoints[i].CanTouch then
			continue
		end
		if (SETTINGS.CharacterCollisions ~= true) and collisionPoints[i]:IsDescendantOf(character) then
			continue
		end
		if not ((not collisionPoints[i]:IsDescendantOf(object)) and collisionPoints[i] ~= plot) then
			continue
		end

		SetCurrentState(3)
		if SETTINGS.PreferSignals == true then
			collided:Fire(collisionPoints[i])
		end
		break
	end

	return
end

-- (Raise and Lower functions) Edits the floor based on the floor step
local function RaiseFloor(actionName: string, inputState: Enum.UserInputState, inputObj: InputObject?)
	if not (currentState ~= 4 and inputState == Enum.UserInputState.Begin) then
		return
	end
	if not (SETTINGS.EnableFloors and not stackable) then
		return
	end
	floorHeight += floor(abs(SETTINGS.FloorStep))
	floorHeight = math.clamp(floorHeight, 0, SETTINGS.MaxHeight)

	if SETTINGS.PreferSignals == true then
		changeFloors:Fire(true)
	end
end

local function LowerFloor(actionName: string, inputState: Enum.UserInputState, inputObj: InputObject?)
	if not (currentState ~= 4 and inputState == Enum.UserInputState.Begin) then
		return
	end
	if not (SETTINGS.EnableFloors and not stackable) then
		return
	end
	floorHeight -= floor(abs(SETTINGS.FloorStep))
	floorHeight = math.clamp(floorHeight, 0, SETTINGS.MaxHeight)

	if SETTINGS.PreferSignals == true then
		changeFloors:Fire(false)
	end
end

-- Handles scaling of the grid texture on placement activation
local function DisplayGrid(grid_unit: number)
	local gridTex: Texture = Instance.new("Texture")
	gridTex.Name = "GridTexture"
	gridTex.Texture = SETTINGS.GridTexture
	gridTex.Face = Enum.NormalId.Top
	gridTex.Transparency = 1
	gridTex.StudsPerTileU = SETTINGS.GridTextureScale
	gridTex.StudsPerTileV = SETTINGS.GridTextureScale

	if SETTINGS.SmartDisplay == true then
		gridTex.StudsPerTileU = grid_unit
		gridTex.StudsPerTileV = grid_unit
	end

	if SETTINGS.GridFadeIn == true then
		local tween: Tween = tweenService:Create(gridTex, fade, { Transparency = 0 })
		tween:Play()
	else
		gridTex.Transparency = 0
	end

	gridTex.Parent = plot
end

local function DisplaySelectionBox()
	local selectionBox

	if SETTINGS.UseHighlights == true then
		selectionBox = Instance.new("Highlight")
		selectionBox.OutlineColor = SETTINGS.SelectionBoxColor3
		selectionBox.OutlineTransparency = SETTINGS.LineTransparency
		selectionBox.FillTransparency = 1
		selectionBox.DepthMode = Enum.HighlightDepthMode.Occluded
		selectionBox.Adornee = object
	else
		selectionBox = Instance.new("SelectionBox")
		selectionBox.LineThickness = SETTINGS.LineThickness
		selectionBox.Color3 = SETTINGS.SelectionBoxColor3
		selectionBox.Transparency = SETTINGS.LineTransparency
		selectionBox.Adornee = primary
	end

	selectionBox.Parent = player.PlayerGui
	selectionBox.Name = "outline"
	selection = selectionBox
end

-- Removes any textures/grids
local function RemoveTexture()
	for i, texture: Instance in ipairs(plot:GetChildren()) do
		if not (texture.Name == "GridTexture" and texture:IsA("Texture")) then
			continue
		end
		if not SETTINGS.GridFadeOut then
			texture:Destroy()
			break
		end

		local tween = tweenService:Create(texture, fade, { Transparency = 1 })
		tween:Play()

		local connection = tween.Completed:Connect(function()
			texture:Destroy()
		end)
		connection:Disconnect()
	end
end

local function CreateAudioFeedback()
	local audio = Instance.new("Sound")
	audio.Name = "PlacementFeedback"
	audio.Volume = SETTINGS.AudioVolume
	audio.SoundId = SETTINGS.SoundID
	audio.Parent = player.PlayerGui
	placementSFX = audio
end

local function PlayAudio()
	if SETTINGS.AudibleFeedback == true and placementSFX then
		placementSFX:Play()
	end
end

-- Checks to see if the model is in range of the maxRange
local function GetRange(): number
	character = player.Character
	return (primary.Position - character.PrimaryPart.Position).Magnitude
end

-- Handles rotation of the model
local function ROTATE(actionName: string, inputState: Enum.UserInputState, inputObj: InputObject?)
	if not (currentState ~= 4 and currentState ~= 2 and inputState == Enum.UserInputState.Begin) then
		return
	end
	if smartRot then
		-- Rotates the model depending on if currentRot is true/false
		if currentRot then
			rotation += SETTINGS.RotationStep
		else
			rotation -= SETTINGS.RotationStep
		end
	else
		rotation += SETTINGS.RotationStep
	end

	-- Toggles currentRot
	local rotateAmount = round(rotation / 90)
	currentRot = rotateAmount % 2 == 0 and true or false
	if rotation >= 360 then
		rotation = 0
	end
	if SETTINGS.PreferSignals == true then
		rotated:Fire()
	end
end

-- Calculates the Y position to be ontop of the plot (all objects) and any object (when stacking)
local function CalculateYPosition(tp: number, ts: number, o: number, normal: number): number
	if normal == 0 then
		return (tp + ts * 0.5) - o * 0.5
	end

	return (tp + ts * 0.5) + o * 0.5
end

-- Clamps the x and z positions so they cannot leave the plot
local function Bounds(c: CFrame, offsetX: number, offsetZ: number): CFrame
	local pos: CFrame = plot.CFrame
	local xBound: number = (plot.Size.X * 0.5) - offsetX
	local zBound: number = (plot.Size.Z * 0.5) - offsetZ

	local newX: number = clamp(c.X, -xBound, xBound)
	local newZ: number = clamp(c.Z, -zBound, zBound)

	local newCFrame: CFrame = cframe(newX, 0, newZ)

	return newCFrame
end

-- Returns a rounded cframe to the nearest grid unit
local function SnapCFrame(c: CFrame, grid_unit: number): CFrame
	local offsetX: number = (plot.Size.X % (2 * grid_unit)) * 0.5
	local offsetZ: number = (plot.Size.Z % (2 * grid_unit)) * 0.5
	local newX: number = round(c.X / grid_unit) * grid_unit - offsetX
	local newZ: number = round(c.Z / grid_unit) * grid_unit - offsetZ
	local newCFrame: CFrame = cframe(newX, 0, newZ)

	return newCFrame
end

-- Calculates the "tilt" angle
local function CalculateAngle(last: CFrame, current: CFrame): CFrame
	if not SETTINGS.AngleTilt then
		return anglesXYZ(0, 0, 0)
	end

	-- Calculates and clamps the proper angle amount
	local tiltX = (clamp((last.X - current.X), -10, 10) * pi / 180) * amplitude
	local tiltZ = (clamp((last.Z - current.Z), -10, 10) * pi / 180) * amplitude
	local preCalc = (rotation + plot.Orientation.Y) * pi / 180

	-- Returns the proper angle based on rotation
	return (anglesXYZ(dirZ * tiltZ, 0, dirX * tiltX):Inverse() * anglesXYZ(0, preCalc, 0)):Inverse()
		* anglesXYZ(0, preCalc, 0)
end

-- Calculates the position of the object
local function CalculateItemLocation(last, final: boolean, placement_service): CFrame
	local x: number, z: number
	local sizeX: number, sizeZ: number = primary.Size.X * 0.5, primary.Size.Z * 0.5
	local offsetX: number, offsetZ: number = sizeX, sizeZ
	local finalC: CFrame

	if not currentRot then
		sizeX = primary.Size.Z * 0.5
		sizeZ = primary.Size.X * 0.5
	end

	if SETTINGS.MoveByGrid == true then
		offsetX = sizeX - floor(sizeX / placement_service._grid_unit) * placement_service._grid_unit
		offsetZ = sizeZ - floor(sizeZ / placement_service._grid_unit) * placement_service._grid_unit
	end

	local cam: Camera = workspace.CurrentCamera
	local ray
	local nilRay
	local target

	if isMobile then
		local camPos: Vector3 = cam.CFrame.Position
		ray = workspace:Raycast(camPos, cam.CFrame.LookVector * rangeOfRay, raycastParams)
		nilRay = camPos + cam.CFrame.LookVector * (SETTINGS.MaxRange + plot.Size.X * 0.5 + plot.Size.Z * 0.5)
	else
		local unit: Ray = cam:ScreenPointToRay(mouse.X, mouse.Y, 1)
		ray = workspace:Raycast(unit.Origin, unit.Direction * rangeOfRay, raycastParams)
		nilRay = unit.Origin + unit.Direction * (SETTINGS.MaxRange + plot.Size.X * 0.5 + plot.Size.Z * 0.5)
	end

	if ray then
		x, z = ray.Position.X - offsetX, ray.Position.Z - offsetZ

		if stackable then
			target = ray.Instance
		else
			target = plot
		end
	else
		x, z = nilRay.X - offsetX, nilRay.Z - offsetZ
		target = plot
	end

	target = target

	local pltCFrame: CFrame = plot.CFrame
	local positionCFrame = cframe(x, 0, z) * cframe(offsetX, 0, offsetZ)

	y = CalculateYPosition(plot.Position.Y, plot.Size.Y, primary.Size.Y, 1) + floorHeight

	-- Changes y depending on mouse target
	if stackable and target and (target:IsDescendantOf(placedObjects) or target == plot) then
		if ray and ray.Normal then
			local normal =
				cframe(ray.Normal):VectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Top)):Dot(ray.Normal)
			y = CalculateYPosition(target.Position.Y, target.Size.Y, primary.Size.Y, normal)
		end
	end

	if SETTINGS.MoveByGrid == true then
		-- Calculates the correct position
		local rel: CFrame = pltCFrame:Inverse() * positionCFrame
		local snappedRel: CFrame = SnapCFrame(rel, placement_service._grid_unit) * cframe(offsetX, 0, offsetZ)

		if not removePlotDependencies then
			snappedRel = Bounds(snappedRel, sizeX, sizeZ)
		end
		finalC = pltCFrame * snappedRel
	else
		finalC = pltCFrame:Inverse() * positionCFrame

		if not removePlotDependencies then
			finalC = Bounds(finalC, sizeX, sizeZ)
		end
		finalC = pltCFrame * finalC
	end

	-- Clamps y to a max height above the plot position
	y = clamp(y, initialY, SETTINGS.MaxHeight + initialY)

	-- For placement or no intepolation
	if final or not SETTINGS.Interpolation then
		return (finalC * cframe(0, y - plot.Position.Y, 0)) * anglesXYZ(0, rotation * pi / 180, 0)
	end

	return (finalC * cframe(0, y - plot.Position.Y, 0))
		* anglesXYZ(0, rotation * pi / 180, 0)
		* CalculateAngle(last, finalC)
end

-- Used for sending a final CFrame to the server when using interpolation.
local function GetFinalCFrame(placement_service): CFrame
	return CalculateItemLocation(nil, true, placement_service)
end

-- Finds a surface for non plot dependant placements
local function FindPlot(): BasePart
	local cam: Camera = workspace.CurrentCamera
	local ray
	local nilRay

	if isMobile then
		local camPos: Vector3 = cam.CFrame.Position
		ray = workspace:Raycast(camPos, cam.CFrame.LookVector * SETTINGS.MaxRange, raycastParams)
		nilRay = camPos + cam.CFrame.LookVector * SETTINGS.MaxRange
	else
		local unit: Ray = cam:ScreenPointToRay(mouse.X, mouse.Y, 1)
		ray = workspace:Raycast(unit.Origin, unit.Direction * SETTINGS.MaxRange, raycastParams)
		nilRay = unit.Origin + unit.Direction * SETTINGS.MaxRange
	end

	if ray then
		target = ray.Instance
	end

	return target
end

-- Sets the position of the object
local function TranslateObject(dt, placement_service)
	if not (currentState ~= 2 and currentState ~= 4) then
		return
	end

	range = false
	SetCurrentState(1)

	if GetRange() > SETTINGS.MaxRange then
		SetCurrentState(5)

		if SETTINGS.PreferSignals == true then
			outOfRange:Fire()
		end

		range = true
	end

	CheckHitbox()
	EditHitboxColor()

	if removePlotDependencies then
		plot = FindPlot() or plot
	end

	if SETTINGS.Interpolation == true and not setup then
		object:PivotTo(
			primary.CFrame:Lerp(
				CalculateItemLocation(primary.CFrame.Position, false, placement_service),
				speed * dt * SETTINGS.TargetFPS
			)
		)
		hitbox:PivotTo(CalculateItemLocation(hitbox.CFrame.Position, true, placement_service))
	else
		object:PivotTo(CalculateItemLocation(primary.CFrame.Position, false, placement_service))
		hitbox:PivotTo(CalculateItemLocation(hitbox.CFrame.Position, placement_service, true))
	end
end

-- Unbinds all inputs
local function UnbindInputs()
	contextActionService:UnbindAction("Rotate")
	contextActionService:UnbindAction("Terminate")
	contextActionService:UnbindAction("Pause")

	if SETTINGS.EnableFloors == true then
		contextActionService:UnbindAction("Raise")
		contextActionService:UnbindAction("Lower")
	end
end

-- Resets variables on termination
local function Reset()
	if selection then
		selection:Destroy()
	end

	if mobileUI ~= nil then
		mobileUI.Parent = script
	end

	stackable = nil
	canPlace = nil
	smartRot = nil
	hitbox:Destroy()

	if object ~= nil then
		object:Destroy()
		object = nil
	end

	--canActivate = true
end

-- Sets up variables for activation
local function set()
	hitbox = object.PrimaryPart:Clone()
	hitbox.Transparency = 1
	hitbox.Name = "Hitbox"
	hitbox.Parent = object
	rotation = 0
	dirX = -1
	dirZ = 1
	amplitude = clamp(SETTINGS.AngleTiltAmplitude, 0, 10)
	currentRot = true

	if SETTINGS.InvertAngleTilt then
		dirX = 1
		dirZ = -1
	end

	-- Sets up interpolation speed
	speed = 1
end

-- Terminates the current placement
local function TERMINATE_PLACEMENT()
	if not hitbox then
		return
	end
	SetCurrentState(4)

	-- Removes grid texture from plot
	if SETTINGS.DisplayGridTexture and not removePlotDependencies then
		RemoveTexture()
	end

	if SETTINGS.AudibleFeedback == true and placementSFX then
		task.spawn(function()
			if currentState == 2 then
				placementSFX.Ended:Wait()
			end
			placementSFX:Destroy()
		end)
	end

	Reset()
	UnbindInputs()
	if SETTINGS.PreferSignals == true then
		terminated:Fire()
	end
end

-- Binds all inputs for PC and Xbox
local function BindInputs()
	contextActionService:BindAction("Rotate", ROTATE, false, SETTINGS.CONTROLS.RotateKey, SETTINGS.CONTROLS.XboxRotate)
	contextActionService:BindAction(
		"Terminate",
		TERMINATE_PLACEMENT,
		false,
		SETTINGS.CONTROLS.TerminateKey,
		SETTINGS.CONTROLS.XboxTerminate
	)

	if SETTINGS.EnableFloors == true and not stackable then
		contextActionService:BindAction(
			"Raise",
			RaiseFloor,
			false,
			SETTINGS.CONTROLS.RaiseKey,
			SETTINGS.CONTROLS.XboxRaise
		)
		contextActionService:BindAction(
			"Lower",
			LowerFloor,
			false,
			SETTINGS.CONTROLS.LowerKey,
			SETTINGS.CONTROLS.XboxLower
		)
	end
end

-- Makes sure that you cannot place objects too fast.
local function coolDown(plr: Player, cd: number): boolean
	if lastPlacement[plr.UserId] == nil then
		lastPlacement[plr.UserId] = tick()

		return true
	elseif tick() - lastPlacement[plr.UserId] >= cd then
		lastPlacement[plr.UserId] = tick()

		return true
	else
		return false
	end
end

-- Generates vibrations on placement if the player is using a controller
local function CreateHapticFeedback()
	local isVibrationSupported = hapticService:IsVibrationSupported(Enum.UserInputType.Gamepad1)
	local largeSupported

	coroutine.resume(coroutine.create(function()
		if not isVibrationSupported then
			return
		end
		largeSupported = hapticService:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large)

		if largeSupported then
			hapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, SETTINGS.VibrateAmount)

			task.wait(0.2)

			hapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, 0)
		else
			hapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, SETTINGS.VibrateAmount)

			task.wait(0.2)

			hapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
		end
	end))
end

-- Rounds all integer attributes to the nearest whole number (int)
local function RoundInts()
	SETTINGS.MaxHeight = round(SETTINGS.MaxHeight)
	SETTINGS.FloorStep = round(SETTINGS.FloorStep)
	SETTINGS.RotationStep = round(SETTINGS.RotationStep)
	SETTINGS.GridTextureScale = round(SETTINGS.GridTextureScale)
	SETTINGS.MaxRange = round(SETTINGS.MaxRange)

	--script:SetAttribute("MaxHeight", round(script:GetAttribute("MaxHeight")))
	--script:SetAttribute("FloorStep", round(script:GetAttribute("FloorStep")))
	--script:SetAttribute("RotationStep", round(script:GetAttribute("RotationStep")))
	--script:SetAttribute("GridTextureScale", round(script:GetAttribute("GridTextureScale")))
	--script:SetAttribute("MaxRange", round(script:GetAttribute("MaxRange")))

	--updateAttributes()
end

local function PlacementFeedback(objectName, callback)
	if SETTINGS.PreferSignals == true then
		placed:Fire(objectName)
	else
		xpcall(function()
			if callback then
				callback()
			end
		end, function(err)
			warn(messages["301"] .. "\n\n" .. err)
		end)
	end
end

local function PLACEMENT(self, Function: RemoteFunction, callback: () -> ()?)
	if not (currentState ~= 3 and currentState ~= 4 and currentState ~= 5 and object) then
		return
	end

	local cf: CFrame
	local objectName = tostring(object)

	-- Makes sure you have waited the cooldown period before placing
	if not coolDown(player, SETTINGS.PlacementCooldown) then
		return
	end
	if not (currentState == 2 or currentState == 1) then
		return
	end

	cf = GetFinalCFrame(self)
	CheckHitbox()

	--print(objectName, placedObjects, self.Prefabs, Function, plot)
	if not Function:InvokeServer(objectName, placedObjects, self.Prefabs, cf, plot) then
		return
	end
	if SETTINGS.BuildModePlacement == true then
		SetCurrentState(1)
	else
		TERMINATE_PLACEMENT()
	end
	if SETTINGS.HapticFeedback == true and guiService:IsTenFootInterface() then
		CreateHapticFeedback()
	end

	PlayAudio()
	PlacementFeedback(objectName, callback)
end

-- Returns the current platform
local function GET_PLATFORM(): string
	isXbox = userInputService.GamepadEnabled
	isMobile = userInputService.TouchEnabled

	if isMobile then
		return "Mobile"
	elseif isXbox then
		return "Console"
	else
		return "PC"
	end
end

-- Verifys that the plane which the object is going to be placed upon is the correct size
local function VerifyPlane(grid_unit: number): boolean
	return plot.Size.X % grid_unit == 0 and plot.Size.Z % grid_unit == 0
end

-- Checks if there are any problems with the users setup
local function ApproveActivation(grid_unit: number)
	if not VerifyPlane(grid_unit) then
		warn(messages["201"])
	end
	assert(not (grid_unit >= min(plot.Size.X, plot.Size.Z)), messages["401"])
end

-- Methods

-- Constructor function
function PlacementInfo.new(GridUnit: number, Prefabs: Instance, ...: Instance?)
	local self = setmetatable({}, PlacementInfo)

	-- Sets variables needed
	GRID_UNIT = abs(round(GridUnit))

	self.GridUnit = GRID_UNIT
	self._grid_unit = GridUnit

	self.Items = Prefabs
	self.ROTATE_KEY = SETTINGS.CONTROLS.RotateKey
	self.CANCEL_KEY = SETTINGS.CONTROLS.CancelKey
	self.RAISE_KEY = SETTINGS.CONTROLS.RaiseKey
	self.LOWER_KEY = SETTINGS.CONTROLS.LowerKey
	self.XBOX_ROTATE = SETTINGS.CONTROLS.XboxRotate
	self.XBOX_TERMINATE = SETTINGS.CONTROLS.XboxTerminate
	self.XBOX_RAISE = SETTINGS.CONTROLS.XboxRaise
	self.Version = "1.6.2"
	self.Creator = "zblox164"
	self.MobileUI = script:FindFirstChildOfClass("ScreenGui")
	self.IgnoredItems = { ... }
	self.Prefabs = Prefabs
	mobileUI = script:FindFirstChildOfClass("ScreenGui")

	if not mobileUI then
		warn("[Placement Service]: Failed to locate a ScreenGui for mobile compatibility.")
	end

	placed = Instance.new("BindableEvent")
	collided = Instance.new("BindableEvent")
	outOfRange = Instance.new("BindableEvent")
	rotated = Instance.new("BindableEvent")
	terminated = Instance.new("BindableEvent")
	changeFloors = Instance.new("BindableEvent")
	activated = Instance.new("BindableEvent")

	self.Placed = placed.Event
	self.Collided = collided.Event
	self.OutOfRange = outOfRange.Event
	self.Rotated = rotated.Event
	self.Terminated = terminated.Event
	self.ChangedFloors = changeFloors.Event
	self.Activated = activated.Event

	runService:BindToRenderStep("Input", Enum.RenderPriority.Input.Value, function(dt)
		TranslateObject(dt, self)
	end)

	return self
end

function PlacementInfo:getPlatform(): string
	return GET_PLATFORM()
end

-- returns the current state when called
function PlacementInfo:getCurrentState(): string
	return states[currentState]
end

-- Pauses the current state
function PlacementInfo:pauseCurrentState()
	lastState = currentState

	if object then
		currentState = 4
	end
end

-- Resumes the current state if paused
function PlacementInfo:Resume()
	if object then
		SetCurrentState(lastState)
	end
end

function PlacementInfo:Raise()
	RaiseFloor("Raise", Enum.UserInputState.Begin)
end

function PlacementInfo:Lower()
	LowerFloor("Lower", Enum.UserInputState.Begin)
end

function PlacementInfo:Rotate()
	ROTATE("Rotate", Enum.UserInputState.Begin)
end

function PlacementInfo:Terminate()
	TERMINATE_PLACEMENT()
end

function PlacementInfo:HaltPlacement()
	if not autoPlace then
		return
	end
	if running then
		running = false
	end
end

function PlacementInfo:EditAttribute(attribute: string, input: any)
	if script:GetAttribute(attribute) ~= nil then
		script:SetAttribute(attribute, input)
		RoundInts()
		--updateAttributes()

		return
	end

	warn("Attribute " .. attribute .. "does not exist.")
end

-- Requests to place down the object
function PlacementInfo:RequestPlacement(func: RemoteFunction, callback: (...any?) -> ())
	if not autoPlace then
		PLACEMENT(self, func, callback)
		return
	end
	running = true

	repeat
		PLACEMENT(self, func, callback)

		task.wait(SETTINGS.PlacementCooldown)
	until not running
end

-- Activates placement
function PlacementInfo:Activate(
	ID: string,
	PlacedObjects: Instance,
	Plot: BasePart,
	Stackable: boolean,
	SmartRotation: boolean,
	AutoPlace: boolean
)
	if currentState ~= 4 then
		TERMINATE_PLACEMENT()
	end
	if GET_PLATFORM() == "Mobile" then
		mobileUI.Parent = player.PlayerGui
	end

	-- Sets necessary variables for placement
	character = player.Character or player.CharacterAdded:Wait()
	plot = Plot
	object = self.Prefabs:FindFirstChild(tostring(ID)):Clone()
	placedObjects = PlacedObjects
	primary = object.PrimaryPart

	ApproveActivation(self._grid_unit)

	if SETTINGS.DisplayGridTexture then
		DisplayGrid(self._grid_unit)
	end
	if SETTINGS.IncludeSelectionBox then
		DisplaySelectionBox()
	end
	if SETTINGS.AudibleFeedback then
		CreateAudioFeedback()
	end

	-- Sets properties of the model (CanCollide, Transparency)
	for i, inst in ipairs(object:GetDescendants()) do
		if not inst:IsA("BasePart") then
			continue
		end
		if SETTINGS.TransparentModel == true then
			inst.Transparency = inst.Transparency + SETTINGS.TransparencyDelta
		end

		inst.CanCollide = false
		inst.Anchored = true
	end

	if SETTINGS.RemoveCollisionsIfIgnored == true then
		for i, v: Instance in ipairs(self.IgnoredItems) do
			if v:IsA("BasePart") then
				v.CanTouch = false
			end
		end
	end

	object.PrimaryPart.Transparency = SETTINGS.HitboxTransparency
	stackable = Stackable
	smartRot = SmartRotation

	-- Allows stackable objects depending on stk variable given by the user
	raycastParams.FilterDescendantsInstances = { placedObjects, character, unpack(self.IgnoredItems) }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	if Stackable then
		raycastParams.FilterDescendantsInstances = { object, character, unpack(self.IgnoredItems) }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	end

	-- Toggles buildmode placement (infinite placement) depending on if set true by the user
	--[[canActivate = false
	if SETTINGS.BuildModePlacement == true then
		canActivate = true
	end]]

	-- Gets the initial y pos and gives it to y
	initialY = CalculateYPosition(Plot.Position.Y, Plot.Size.Y, object.PrimaryPart.Size.Y, 1)
	y = initialY
	removePlotDependencies = false
	autoPlace = AutoPlace
	local preSpeed = 1

	set()
	EditHitboxColor()
	RoundInts()
	BindInputs()

	if SETTINGS.Interpolation == true then
		preSpeed = clamp(abs(tonumber(1 - SETTINGS.LerpSpeed) :: number), 0, 0.9)
		speed = preSpeed

		if SETTINGS.InstantActivation == true then
			setup = true
			speed = 1
		end
	end

	-- Parents the object to the location given
	if not object then
		TERMINATE_PLACEMENT()
		warn(messages["101"])
	end
	SetCurrentState(1)

	if SETTINGS.InstantActivation == true then
		TranslateObject(self)
	end
	object.Parent = PlacedObjects

	task.wait()

	speed = preSpeed
	if SETTINGS.PreferSignals == true then
		activated:Fire()
	end

	setup = false
end

function PlacementInfo:ChangeGridSize(newGridSize: number)
	self.GridUnit = abs(round(newGridSize))
	self._grid_unit = newGridSize
end

-- REMOVE THIS FUNCTION IF YOU ARE NOT GOING TO USE IT
function PlacementInfo:noPlotActivate(ID: string, PlacedObjects: Instance, SmartRotation: boolean, AutoPlace: boolean)
	if currentState ~= 4 then
		TERMINATE_PLACEMENT()
	end
	if GET_PLATFORM() == "Mobile" then
		mobileUI.Parent = player.PlayerGui
	end

	-- Sets necessary variables for placement
	character = player.Character or player.CharacterAdded:Wait()
	plot = FindPlot()
	object = self.Prefabs:FindFirstChild(tostring(ID)):Clone()
	placedObjects = PlacedObjects
	primary = object.PrimaryPart

	if not plot then
		error(messages["501"])
	end

	-- Sets properties of the model (CanCollide, Transparency)
	for i, inst in ipairs(object:GetDescendants()) do
		if not inst:IsA("BasePart") then
			continue
		end
		if SETTINGS.TransparentModel == true then
			inst.Transparency = inst.Transparency + SETTINGS.TransparencyDelta
		end

		inst.CanCollide = false
		inst.Anchored = true
	end

	if SETTINGS.RemoveCollisionsIfIgnored == true then
		for i, v: Instance in ipairs(self.IgnoredItems) do
			if v:IsA("BasePart") then
				v.CanTouch = false
			end
		end
	end

	if SETTINGS.IncludeSelectionBox == true then
		DisplaySelectionBox()
	end
	if SETTINGS.AudibleFeedback == true then
		CreateAudioFeedback()
	end

	object.PrimaryPart.Transparency = SETTINGS.HitboxTransparency
	stackable = true
	smartRot = SmartRotation
	removePlotDependencies = true
	mouse.TargetFilter = object
	raycastParams.FilterDescendantsInstances = { object, character, unpack(self.IgnoredItems) }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	-- Toggles buildmode placement (infinite placement) depending on if set true by the user
	canActivate = false
	if SETTINGS.BuildModePlacement == true then
		canActivate = true
	end

	-- Gets the initial y pos and gives it to y
	initialY = 0
	y = initialY
	autoPlace = AutoPlace
	local preSpeed = 1

	set()
	EditHitboxColor()
	RoundInts()
	BindInputs()

	if SETTINGS.Interpolation == true then
		preSpeed = clamp(abs(tonumber(1 - SETTINGS.LerpSpeed) :: number), 0, 0.9)
		speed = preSpeed

		if SETTINGS.InstantActivation == true then
			setup = true
			speed = 1
		end
	end

	-- Parents the object to the location given
	if not object then
		TERMINATE_PLACEMENT()
		warn(messages["101"])
	end
	SetCurrentState(1)

	if SETTINGS.InstantActivation == true then
		TranslateObject(nil, self)
	end
	object.Parent = PlacedObjects

	task.wait()

	speed = preSpeed
	if SETTINGS.PreferSignals == true then
		activated:Fire()
	end
	setup = false
end

return PlacementInfo

-- Created and written by zblox164 (2020-2022)
