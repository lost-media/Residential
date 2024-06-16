--!strict

local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Mouse = require(script.Parent.Parent.Utils.Mouse)
local PlacementUtils = require(RS.Shared.PlacementUtils)
local Signal = require(RS.Packages.Signal)
local StructuresUtils = require(RS.Shared.Structures.Utils)

-- Types
local PlacementTypes = require(RS.Shared.Types.Placement)
local Plot = require(RS.Shared.Types.Plot)

-- Constants
local MIN_LEVEL = 0
local ROTATION_STEP = 90
local TRANSPARENCY_DIM_FACTOR = 4
local TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

type IPlacementClient = {
	__index: IPlacementClient,
	new: (plot: Plot.Plot) -> PlacementClient,

	GetMouse: (self: PlacementClient) -> Mouse.Mouse,
	Update: (self: PlacementClient, deltaTime: number) -> (),
	Destroy: (self: PlacementClient) -> (),
	StartPlacement: (self: PlacementClient, structureId: string) -> (),
	StopPlacement: (self: PlacementClient) -> (),
	GenerateGhostStructureFromId: (self: PlacementClient, structureId: string) -> Model,
	PartIsTile: (self: PlacementClient, part: BasePart) -> boolean,
	PartIsFromStructure: (self: PlacementClient, part: BasePart) -> boolean,
	GetTileFromName: (self: PlacementClient, name: string) -> BasePart?,
	GetStructureFromPart: (self: PlacementClient, part: BasePart) -> Model?,
	SnapToTile: (self: PlacementClient, tile: BasePart) -> (),
	SnapToAttachment: (self: PlacementClient, attachment: Attachment) -> (),
	MoveModelToCF: (self: PlacementClient, model: Model, cframe: CFrame, instant: boolean) -> (),
	Rotate: (self: PlacementClient) -> (),
	GetAttachmentsFromStructure: (self: PlacementClient, model: Model) -> { Attachment },
	GetAllAttachmentsFromPlot: (self: PlacementClient, tile: BasePart) -> { Attachment },
}

export type PlacementClient = typeof(setmetatable(
	{} :: {
		mouse: Mouse.Mouse,
		plot: Plot.Plot,
		state: PlacementTypes.PlacementState,
		connections: { [string]: RBXScriptConnection },
		signals: {
			OnPlacementConfirmed: Signal.Signal,
			OnPlacementStarted: Signal.Signal,
			OnPlacementEnded: Signal.Signal,
			OnTileChanged: Signal.Signal,
			OnRotate: Signal.Signal,
			OnStructureHover: Signal.Signal,
			OnStacked: Signal.Signal,
			OnStackedAttachmentChanged: Signal.Signal,
			OnUnstacked: Signal.Signal,
			OnLevelChanged: Signal.Signal,
			OnCanConfirmPlacementChanged: Signal.Signal,
			OnDelete: Signal.Signal,
		},
		structureCollectionEntry: table,
	},
	{} :: IPlacementClient
))

local function dimModel(model: Model)
	-- If the model is already dimmed, no need to dim it again
	if model:GetAttribute("Dimmed") == true then
		return
	end

	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("BasePart") then
			instance:SetAttribute("OriginalTransparency", instance.Transparency)
			instance.Transparency = 1 - (1 - instance.Transparency) / TRANSPARENCY_DIM_FACTOR
		end
	end

	model:SetAttribute("Dimmed", true)
end

function unDimModel(model: Model)
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

local function uncollideModel(model: Model)
	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("BasePart") then
			instance.CanCollide = false
		end
	end
end

local PlacementClient = {}
PlacementClient.__index = PlacementClient

function PlacementClient.new(plot: Plot.Plot)
	-- Validate the plot before creating the PlacementClient instance
	if Plot.isPlotValid(plot) == false then
		error("Plot is invalid")
	end

	local self = setmetatable({}, PlacementClient)

	self.mouse = Mouse.new()
	self.mouse:SetFilterType(Enum.RaycastFilterType.Include)
	self.mouse:SetTargetFilter({})

	self.plot = plot

	self.state = {
		isPlacing = false,
		canConfirmPlacement = false,

		structureId = nil,
		ghostStructure = nil,
		tile = nil,

		rotation = 0,
		level = 0,

		isStacked = false,
	}

	self.connections = {}

	-- Signals
	self.signals = {
		OnPlacementConfirmed = Signal.new(),
		OnPlacementStarted = Signal.new(),
		OnPlacementEnded = Signal.new(),
		OnTileChanged = Signal.new(),
		OnRotate = Signal.new(),
		OnStructureHover = Signal.new(),
		OnStacked = Signal.new(),
		OnStackedAttachmentChanged = Signal.new(),
		OnUnstacked = Signal.new(),
		OnLevelChanged = Signal.new(),
		OnCanConfirmPlacementChanged = Signal.new(),
		OnDelete = Signal.new(),
	}

	return self
end

function PlacementClient:GenerateGhostStructureFromId(structureId: string)
	local structure = StructuresUtils.GetStructureModelFromId(structureId)

	if structure == nil then
		warn("Structure not found")
		return
	end

	local ghostStructure = structure:Clone()
	ghostStructure.Parent = workspace

	-- SETTING: only including the plot makes the ghost
	-- structure snap to the

	self.mouse:SetFilterType(Enum.RaycastFilterType.Include)

	--self.highlightInstance = self:MakeHighlight(ghostStructure)
	self.selectionBox = self:MakeSelectionBox(ghostStructure)

	self.state.ghostStructure = ghostStructure
	uncollideModel(ghostStructure)

	return ghostStructure
end

function PlacementClient:StartPlacement(structureId: string)
	self.state.isPlacing = true
	self.state.structureId = structureId

	self.structureCollectionEntry = StructuresUtils.GetStructureFromId(structureId)

	if self.structureCollectionEntry == nil then
		warn("Structure not found")
		return
	end

	self.mouse:SetTargetFilter({
		--ghostStructure,
		--game.Players.LocalPlayer.Character,
		self.plot.Structures,
		self.plot.Tiles,
	})

	self.state.ghostStructure = self:GenerateGhostStructureFromId(structureId)

	-- check if the entry has properties and if it has a radius
	if self.structureCollectionEntry.Properties ~= nil and self.structureCollectionEntry.Properties.Radius ~= nil then
		self.state.radius = self.structureCollectionEntry.Properties.Radius
		self.state.radiusVisual = self:CreateRadiusVisual(self.state.radius)
	end

	-- Set up render stepped
	self.connections.onRenderStep = RunService.RenderStepped:Connect(function(dt: number)
		self:Update(dt)
	end)

	self.connections.onInputBegan = UIS.InputBegan:Connect(function(input: InputObject)
		if input.KeyCode == Enum.KeyCode.R then
			self:Rotate()
		elseif input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.C then
			self:StopPlacement()
		elseif input.KeyCode == Enum.KeyCode.Up then
			self:RaiseLevel()
		elseif input.KeyCode == Enum.KeyCode.Down then
			self:LowerLevel()
		elseif input.KeyCode == Enum.KeyCode.X then
			local mouse = self:GetMouse()
			local closestInstance = mouse:GetTarget()

			if closestInstance == nil then
				return
			end

			if self:PartIsFromStructure(closestInstance) then
				self:Delete(self:GetStructureFromPart(closestInstance))
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:ConfirmPlacement()
		end
	end)

	self.signals.OnPlacementStarted:Fire()
end

function PlacementClient:ConfirmPlacement()
	if self:CanPlaceStructure(self.state.ghostStructure) == false then
		return
	end

	self.signals.OnPlacementConfirmed:Fire(self.state.structureId, self.state)
end

function PlacementClient:Delete(model: Model)
	-- delete the model that the player is hovering over
	if model == nil then
		return
	end

	self.signals.OnDelete:Fire(model)
end

function PlacementClient:MakeHighlight(instance: Instance)
	local highlight = Instance.new("Highlight")
	highlight.Parent = instance
	highlight.FillColor = Color3.fromRGB(0, 255, 0)
	highlight.FillTransparency = 0.5
	highlight.Adornee = instance

	return highlight
end

function PlacementClient:MakeSelectionBox(instance: Instance)
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Parent = instance
	selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
	selectionBox.LineThickness = 0.05
	selectionBox.Adornee = instance

	selectionBox.SurfaceTransparency = 0.5
	selectionBox.SurfaceColor3 = Color3.fromRGB(0, 255, 0)

	return selectionBox
end

function PlacementClient:StopPlacement()
	self.state.isPlacing = false

	self:Disconnect()

	if self.state.ghostStructure ~= nil then
		self.state.ghostStructure:Destroy()
	end

	if self.hoverPart then
		self.hoverPart:Destroy()
	end

	if self.state.radiusVisual then
		self.state.radiusVisual:Destroy()
	end

	for _, structures in ipairs(self.plot.Structures:GetChildren()) do
		unDimModel(structures)
	end

	self.signals.OnPlacementEnded:Fire()
end

function PlacementClient:GetMouse()
	return self.mouse
end

function PlacementClient:PartIsTile(part: BasePart)
	if part == nil then
		return false
	end
	return part:IsA("Part") and part:IsDescendantOf(self.plot.Tiles)
end

function PlacementClient:PartIsFromStructure(part: BasePart)
	if part == nil then
		return false
	end

	if part:IsA("BasePart") == false then
		return false
	end

	if part:IsDescendantOf(self.plot.Structures) == false then
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

	if self:GetTileFromName(structure:GetAttribute("Tile")) == nil then
		return false
	end

	return true
end

function PlacementClient:GetTileFromName(name: string)
	return self.plot.Tiles:FindFirstChild(name)
end

function PlacementClient:GetStructureFromPart(part: BasePart)
	if self:PartIsFromStructure(part) == false then
		return nil
	end

	local structure: Model? = part:FindFirstAncestorWhichIsA("Model")
	return structure
end

function PlacementClient:Update(deltaTime: number)
	-- If the player is not placing a structure, return
	if not self.state.isPlacing then
		return
	end

	local mouse: Mouse.Mouse = self.mouse

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
end

function PlacementClient:AttemptToSnapToTile(closestInstance: BasePart)
	local currentTile = self.state.tile
	if currentTile == nil or currentTile ~= closestInstance then
		self.state.tile = closestInstance
		self.signals.OnTileChanged:Fire(closestInstance)
	end

	self:RemoveStacked()

	-- Snap the ghost structure to the tile
	self:UpdateCanConfirmPlacement(true)
end

function PlacementClient:AttemptToSnapToAttachment(closestInstance: BasePart)
	local mouse: Mouse.Mouse = self.mouse

	local succesfullySnapped = true

	-- Check if the part is from a structure
	if self:PartIsFromStructure(closestInstance) == true then
		local structure: Model = self:GetStructureFromPart(closestInstance)
		if structure == nil then
			self.signals.OnStructureHover:Fire(nil)
			self:RemoveStacked()

			return
		end

		local structureId = structure:GetAttribute("Id")
		local structureTile = self:GetTileFromName(structure:GetAttribute("Tile"))

		self.signals.OnStructureHover:Fire(structure)

		-- check if the structure is on the same level
		if structureTile == nil then
			self:RemoveStacked()
			return
		end

		if structure:GetAttribute("Level") ~= self.state.level then
			self:AttemptToSnapToTile(structureTile)
			return
		end

		-- Determine if the structure is stackable
		local isStackable = StructuresUtils.CanStackStructureWith(structureId, self.state.structureId)

		if isStackable == false then
			-- If the structure is not stackable, then just snap to the structures tile
			--self:RemoveStacked()
			-- get the structure the player is hovering over
			if structureTile:GetAttribute("Occupied") == true then
				self.state.tile = structureTile
				self:AttemptToSnapToTile(structureTile)
				--succesfullySnapped = false
			else
				self.state.tile = structureTile
				self:AttemptToSnapToTile(structureTile)

				succesfullySnapped = false
			end
		else
			self.state.stackedStructure = structure

			-- get the attachments of the structure
			local whitelistedSnapPoints =
				StructuresUtils.GetStackingWhitelistedSnapPointsWith(structureId, self.state.structureId)

			if whitelistedSnapPoints ~= nil then
				local attachmentInstances = self:GetAttachmentsFromStringList(whitelistedSnapPoints)
				whitelistedSnapPoints = attachmentInstances
			else
				whitelistedSnapPoints = {}
			end

			local attachments = (#whitelistedSnapPoints > 0) and whitelistedSnapPoints
				or self:GetAttachmentsFromStructure(structure)

			-- Get the closest attachment to the mouse
			local closestAttachment = mouse:GetClosestAttachmentToMouse(attachments)

			if closestAttachment == nil then
				self:RemoveStacked()
				return
			end

			-- check if the attachment is occupied

			if closestAttachment:GetAttribute("Occupied") == true then
				--self:RemoveStacked()
				--self.state.canConfirmPlacement = false
				succesfullySnapped = false
				--return
			end

			if self.state.isStacked == false then
				self.signals.OnStacked:Fire(structure, closestAttachment)
			end

			self.state.isStacked = true

			local attachmentPointToSnapTo = StructuresUtils.GetMountedAttachmentPointFromStructures(
				structure,
				self.state.structureId,
				closestAttachment
			)

			if attachmentPointToSnapTo == nil then
				--self:RemoveStacked()
				succesfullySnapped = false
				--return
			end

			if self.state.mountedAttachment == nil or self.state.mountedAttachment ~= attachmentPointToSnapTo then
				self.signals.OnStackedAttachmentChanged:Fire(attachmentPointToSnapTo, self.state.mountedAttachment)
			end

			if attachmentPointToSnapTo:GetAttribute("Occupied") == true then
				--self.state.canConfirmPlacement = false
				succesfullySnapped = false
			end

			self.state.attachments = attachments
			self.state.mountedAttachment = attachmentPointToSnapTo

			local orientationStrict = StructuresUtils.IsOrientationStrict(structureId, self.state.structureId)

			self.state.orientationStrict = orientationStrict

			if self.state.orientationStrict == true then
				self:AttemptToSnapRotationOnStrictOrientation()
			end

			-- change tile to the structure tile

			if structureTile == nil then
				self:RemoveStacked()
				succesfullySnapped = false
			end

			if self.state.tile == nil or self.state.tile ~= structureTile then
				self.signals.OnTileChanged:Fire(structureTile)
			end

			self.state.tile = structureTile

			if StructuresUtils.IsIncreasingLevel(structureId, self.state.structureId) then
				self:UpdateLevel(structure:GetAttribute("Level") + 1 or 0)
			else
				self:UpdateLevel(structure:GetAttribute("Level") or 0)
			end
		end
	else
		self.signals.OnStructureHover:Fire(nil)
		self:RemoveStacked()
		--self.state.canConfirmPlacement = false
		succesfullySnapped = false
	end

	self:UpdateCanConfirmPlacement(succesfullySnapped)
end

function PlacementClient:GetAttachmentsFromStringList(attachments: { string }?): { Attachment }
	if attachments == nil then
		return {}
	end

	if self.state.stackedStructure == nil then
		return {}
	end

	local attachmentInstances = {}

	for _, attachmentName in ipairs(attachments) do
		local attachment = self.state.stackedStructure.PrimaryPart:FindFirstChild(attachmentName)
		if attachment ~= nil then
			table.insert(attachmentInstances, attachment)
		end
	end

	return attachmentInstances
end

function PlacementClient:RemoveStacked()
	self.state.isStacked = false
	self.state.mountedAttachment = nil
	self.state.attachments = {}
	self.state.stackedStructure = nil
end

function PlacementClient:UpdatePosition()
	-- Completely state dependent
	if self.state.isStacked then
		self:SnapToAttachment(self.state.mountedAttachment, self.state.tile)
	else
		self:SnapToTileWithLevel(self.state.tile)
	end
end

function PlacementClient:UpdateSelectionBox()
	if self.state.ghostStructure == nil then
		return
	end

	if self.selectionBox == nil then
		return
	end

	if self.state.canConfirmPlacement == true then
		self.selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
		self.selectionBox.SurfaceColor3 = Color3.fromRGB(0, 255, 0)
	else
		self.selectionBox.Color3 = Color3.fromRGB(255, 0, 0)
		self.selectionBox.SurfaceColor3 = Color3.fromRGB(255, 0, 0)
	end
end

function PlacementClient:SnapToTile(tile: BasePart)
	local ghostStructure = self.state.ghostStructure

	if ghostStructure == nil then
		return
	end

	if tile == nil then
		return
	end

	if tile:GetAttribute("Occupied") == true then
		self:UpdateCanConfirmPlacement(false)
	end

	local newCFrame = PlacementUtils.GetSnappedTileCFrame(tile, self.state)

	self:MoveModelToCF(ghostStructure, newCFrame, false)
end

function PlacementClient:SnapToTileWithLevel(tile: BasePart)
	local ghostStructure = self.state.ghostStructure

	if ghostStructure == nil then
		return
	end

	if tile == nil then
		return
	end

	local level = self.state.level

	if tile:GetAttribute("Occupied") == true then
		-- find all the structures on the tile
		local structures = self:GetStructuresOnTile(tile)
		-- check if the level is occupied

		for _, structure in ipairs(structures) do
			if structure:GetAttribute("Level") == level then
				self:UpdateCanConfirmPlacement(false)
			end
		end
	end

	local newCFrame = PlacementUtils.GetSnappedTileCFrame(tile, self.state)

	self:MoveModelToCF(ghostStructure, newCFrame, false)
end

function PlacementClient:GetSimulatedStackCFrame(tile: BasePart, attachment: Attachment)
	local ghostStructure = self.state.ghostStructure

	if ghostStructure == nil then
		return
	end

	if self.structureCollectionEntry == nil then
		return
	end

	if tile == nil or attachment == nil then
		return
	end

	return PlacementUtils.GetSnappedAttachmentCFrame(tile, attachment, self.structureCollectionEntry, self.state)
end

function PlacementClient:SnapToAttachment(attachment: Attachment, tile: BasePart)
	local ghostStructure = self.state.ghostStructure
	local simulatedCFrame = self:GetSimulatedStackCFrame(tile, attachment)

	if simulatedCFrame == nil then
		return
	end

	self:MoveModelToCF(ghostStructure, simulatedCFrame, false)
end

function PlacementClient:MoveModelToCF(model: Model, cframe: CFrame, instant: boolean)
	if instant then
		model:PivotTo(cframe)
	else
		local tween = TweenService:Create(model.PrimaryPart, TWEEN_INFO, { CFrame = cframe })
		tween:Play()
	end
end

function PlacementClient:Rotate()
	self.state.rotation = self.state.rotation + ROTATION_STEP
	if self.state.rotation >= 360 then
		self.state.rotation = 0
	end

	if self.state.isStacked and self.state.orientationStrict then
		local validRotations = self:GetValidRotationsWithStrictOrientation()
		if #validRotations == 0 or table.find(validRotations, self.state.rotation) == nil then
			self:UpdateCanConfirmPlacement(false)
			return
		end
	end

	self.signals.OnRotate:Fire(self.state.rotation)
end

function PlacementClient:GetAttachmentsFromStructure(model: Model)
	local attachments = {}

	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("Attachment") then
			table.insert(attachments, instance)
		end
	end

	return attachments
end

function PlacementClient:GetAllAttachmentsFromPlot(tile: BasePart)
	local attachments = {}

	for _, structure in ipairs(self.plot.Structures:GetChildren()) do
		if structure:IsA("Model") then
			if structure:GetAttribute("Tile") == tile.Name then
				for _, attachment in ipairs(self:GetAttachmentsFromStructure(structure)) do
					table.insert(attachments, attachment)
				end
			end
		end
	end

	return attachments
end

function PlacementClient:GetValidRotationsWithStrictOrientation()
	-- Clone the ghost structure and test the rotation
	local clone = self.state.ghostStructure:Clone()

	local rotations = {}

	for i = 0, 360, ROTATION_STEP do
		local newCFrame = self:GetSimulatedStackCFrame(self.state.tile, self.state.mountedAttachment)

		if newCFrame == nil then
			return rotations
		end

		newCFrame = CFrame.new(newCFrame.Position) * CFrame.Angles(0, math.rad(i), 0)
		--newCFrame = newCFrame * CFrame.new(0, self.state.level * LEVEL_HEIGHT, 0)

		clone:PivotTo(newCFrame)

		-- Check if the attachment points match
		local stackedStructureId = self.state.stackedStructure:GetAttribute("Id")
		if stackedStructureId == nil then
			return
		end

		local attachmentPointsThatMatch = StructuresUtils.GetAttachmentsThatMatchSnapPoints(
			stackedStructureId,
			self.state.structureId,
			self.state.stackedStructure,
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

function PlacementClient:AttemptToSnapRotationOnStrictOrientation()
	if self.state.stackedStructure == nil then
		return
	end

	-- get the entry from the structure collection
	local structureId = self.state.stackedStructure:GetAttribute("Id")
	local structureEntry = StructuresUtils.GetStructureFromId(structureId)

	if structureEntry == nil then
		return
	end

	if StructuresUtils.IsOrientationStrict(structureId, self.state.structureId) == false then
		return
	end

	local ghostStructure = self.state.ghostStructure

	if ghostStructure == nil then
		return
	end

	local rotations = self:GetValidRotationsWithStrictOrientation()

	if rotations == nil then
		self:UpdateCanConfirmPlacement(false)
		return
	end

	if #rotations == 0 then
		self:UpdateCanConfirmPlacement(false)
		return
	end

	if table.find(rotations, self.state.rotation) == nil then
		self.state.rotation = rotations[1]
		self.signals.OnRotate:Fire(self.state.rotation)
	end
end

function PlacementClient:CanPlaceStructure(model: Model)
	local ghostStructure = model

	if ghostStructure == nil then
		return false
	end

	if self.state.canConfirmPlacement == false then
		return false
	end

	return true
end

function PlacementClient:UpdateLevelVisibility()
	for _, structure in ipairs(self.plot.Structures:GetChildren()) do
		if structure:IsA("Model") then
			local level = structure:GetAttribute("Level")
			if level == nil then
				level = 0
			end

			-- SETTING: make this a setting so that the player can toggle it
			local structureLevel = level

			if structureLevel == self.state.level then
				unDimModel(structure)
			else
				dimModel(structure)
			end
		end
	end
end

function PlacementClient:Destroy()
	self:StopPlacement()
	self:Disconnect()

	if self.state.ghostStructure then
		self.state.ghostStructure:Destroy()
	end

	if self.state.radiusVisual then
		self.state.radiusVisual:Destroy()
	end

	if self.hoverPart then
		self.hoverPart:Destroy()
	end

	if self.selectionBox then
		self.selectionBox:Destroy()
	end
end

function PlacementClient:Disconnect()
	for _, connection in pairs(self.connections) do
		connection:Disconnect()
	end
end

function PlacementClient:CreateRadiusVisual(radius: number)
	if self.state.ghostStructure == nil then
		return
	end

	if self.radiusVisual then
		self.radiusVisual:Destroy()
	end

	self.radiusVisual = Instance.new("Part")
	self.radiusVisual.Shape = Enum.PartType.Cylinder
	self.radiusVisual.CastShadow = false

	-- radius is in tiles, and each tile is 8 studs
	radius = radius * 8

	self.radiusVisual.Size = Vector3.new(0.05, radius * 2 + 8, radius * 2 + 8)
	-- rotate the radius visual so that it is flat
	self.radiusVisual.Color = Color3.fromRGB(50, 82, 100)

	--self.radiusVisual.Anchored = true
	self.radiusVisual.CanCollide = false
	self.radiusVisual.Transparency = 0.3
	self.radiusVisual.Parent = workspace

	-- Pulse the radius visual

	local part = self.radiusVisual -- replace this with the actual part you want to pulse

	local pulseTween = TweenService:Create(
		part,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
		{ Transparency = 0.7 }
	)
	pulseTween:Play()

	return self.radiusVisual
end

function PlacementClient:UpdateLevel(level: number)
	if level < MIN_LEVEL then
		level = MIN_LEVEL
	end

	self.state.level = level
	self.signals.OnLevelChanged:Fire(level)
end

function PlacementClient:RaiseLevel()
	self:UpdateLevel(self.state.level + 1)
end

function PlacementClient:LowerLevel()
	self:UpdateLevel(math.max(self.state.level - 1, MIN_LEVEL))
end

function PlacementClient:GetStructuresOnTile(tile: BasePart)
	if tile == nil then
		return
	end

	local structures = {}

	for _, structure in ipairs(self.plot.Structures:GetChildren()) do
		if structure:IsA("Model") then
			if structure:GetAttribute("Tile") == tile.Name then
				table.insert(structures, structure)
			end
		end
	end

	return structures
end

function PlacementClient:UpdateCanConfirmPlacement(canConfirm: boolean)
	if self.state.canConfirmPlacement ~= canConfirm then
		self.state.canConfirmPlacement = canConfirm
		self.signals.OnCanConfirmPlacementChanged:Fire(canConfirm)
		self:UpdateSelectionBox()
	end
end

return PlacementClient
