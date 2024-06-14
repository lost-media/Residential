--!strict

local RS = game:GetService("ReplicatedStorage")
local VFX: Folder = RS.VFX

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local PlacementTypes = require(RS.Shared.Types.Placement)
local PlacementUtils = require(game:GetService("ReplicatedStorage").Shared.PlacementUtils)
local Signal = require(game:GetService("ReplicatedStorage").Packages.Signal)

export type IPlot = {
	__index: IPlot,
	new: (model: Model, id: number) -> Plot,
	getInstance: (self: Plot) -> Model,
	getPlayer: (self: Plot) -> Player?,
	assignPlayer: (self: Plot, player: Player) -> (),
	removePlayer: (self: Plot) -> (),
	getTile: (self: Plot, tile: BasePart) -> BasePart?,
	getTileAt: (self: Plot, x: number, y: number) -> BasePart?,
	isOccupied: (self: Plot, tile: BasePart) -> boolean,
	placeObject: (self: Plot, placeableId: string, state: PlacementTypes.PlacementState) -> (),
	getPlaceable: (self: Plot, structure: Model) -> Model?,
	updateBuildingStatus: (self: Plot) -> (),
}

type Plot = typeof(setmetatable(
	{} :: {
		player: Player?,
		placeables: { Model },
		tiles: { BasePart },

		id: number,
		model: Model,
		size: number,

		signals: {
			PlotAssigned: Signal.Signal,
			PlacedStructure: Signal.Signal,
		},
	},
	{} :: IPlot
))

local Plot: IPlot = {} :: IPlot
Plot.__index = Plot

local DEFAULT_PLOT_SIZE = 8
local TILE_SIZE = 8

--[[

    The Plot Instance model has the following structure:

    Model
    ├── Placeables
    ├── Tiles

    The Placeables folder contains all the models that were placed on the plot.

    The Tiles folder contains the cells that make up the plot. In a standard plot, there are 64 cells (8x8).
    Each cell is a BasePart that is 6x6 studs in size. Their name is a number which may not have any correlation to their position in the plot.

]]
--

function Plot.new(model, id)
	-- Validate the model before creating the Plot instance

	if model == nil then
		error("Model is nil")
	end

	if model:FindFirstChild("Tiles") == nil then
		error("Model does not have a Tiles folder")
	end

	if model:FindFirstChild("Structures") == nil then
		error("Model does not have a Structures folder")
	end

	if id == nil then
		error("Plot cannot be created without an ID")
	end

	local self = setmetatable({}, Plot)

	self.player = nil
	self.placeables = {}
	self.tiles = {}
	self.signals = {
		PlotAssigned = Signal.new(),
		PlacedStructure = Signal.new(),
	}

	self.id = id
	self.model = model
	self.size = DEFAULT_PLOT_SIZE

	self.model.Name = tostring(id)

	local tiles: Folder = model:FindFirstChild("Tiles") :: Folder

	for i, v: BasePart in ipairs(tiles:GetChildren()) do
		self.tiles[i] = v
		v:SetAttribute("Occupied", false)
	end

	return self
end

function Plot:getInstance()
	return self.model
end

function Plot:getPlayer()
	return self.player
end

function Plot:assignPlayer(player)
	if self.player ~= nil then
		error("Plot already has a player assigned")
	end

	if player == nil then
		error("Player is nil")
	end

	player:SetAttribute("Plot", self.id)
	self.player = player
end

function Plot:removePlayer()
	self.player = nil
end

function Plot:getTile(tile: BasePart): BasePart?
	for i, v: BasePart in ipairs(self.tiles) do
		if v == tile then
			return v
		end
	end
	return nil
end

function Plot:getTileAt(x, y)
	for _, tile in ipairs(self.tiles) do
		local tilePos = tile.Position
		local tileX = math.floor((tilePos.X + TILE_SIZE / 2) / TILE_SIZE)
		local tileY = math.floor((tilePos.Z + TILE_SIZE / 2) / TILE_SIZE)

		if tileX == x and tileY == y then
			return tile
		end
	end
	return nil
end

function Plot:isOccupied(tile: BasePart): boolean
	for _, structure in ipairs(self.placeables) do
		if structure:isOccupying(tile) then
			return true
		end
	end
	return false
end

function Plot:placeObject(structureId: string, state: PlacementTypes.PlacementState)
	if structureId == nil then
		error("Structure ID is nil")
	end

	local StructureService = Knit.GetService("StructureService")

	if StructureService == nil then
		error("StructureService is nil")
	end

	if state == nil then
		error("State is nil")
	end

	if state.tile == nil then
		error("Tile is nil")
	end

	if state.level == nil then
		error("Level is nil")
	end

	if state.isStacked == false and self:getPlaceablesOnTileWithLevel(state.tile, state.level) then
		error("Tile is already occupied")
	end

	local tile = self:getTile(state.tile)

	if tile == nil then
		error("Tile is nil")
	end

	-- Snap point

	if state.isStacked then
		local snappedPoint = state.mountedAttachment
		if snappedPoint == nil then
			error("Snapped point is nil")
		end

		if snappedPoint:GetAttribute("Occupied") == true then
			error("Snapped point is already occupied")
		end
	end

	local structure = StructureService:CreateStructureFromIdentifier(structureId)

	if structure == nil then
		error("Placeable is nil")
	end

	local placeableInfo = StructureService:GetStructureEntry(structureId)

	if placeableInfo == nil then
		error("Placeable info is nil")
	end

	local placeableType = structure.Name

	if self.placeables[placeableType] == nil then
		self.placeables[placeableType] = {}
	end

	table.insert(self.placeables[placeableType], structure)

	-- Add all server-side attributes to the structure
	structure:SetAttribute("Id", structureId)
	structure:SetAttribute("Plot", self.id)
	structure:SetAttribute("Level", state.level)
	structure:SetAttribute("Rotation", state.rotation)
	structure:SetAttribute("Tile", state.tile.Name)
	structure:SetAttribute("Stacked", state.isStacked or false)
	structure:SetAttribute("Category", placeableInfo.Category)

	tile:SetAttribute("Occupied", true)

	structure.Parent = self.model.Structures

	local newCFrame = PlacementUtils.GetSnappedTileCFrame(tile, state)

	structure:PivotTo(newCFrame)

	tile:SetAttribute("Occupied", true)

	if state.isStacked then
		local stackedOn: Model? = state.stackedStructure
		if stackedOn == nil then
			error("Stacked object is nil")
		end

		local stackedOnPlaceable = self:getPlaceable(stackedOn)

		if stackedOnPlaceable == nil then
			error("Stacked object is not on the plot")
		end

		-- Get snapped point
		local snappedPoint: Attachment? = state.mountedAttachment
		if snappedPoint == nil then
			error("Snapped point is nil")
		end

		local snappedPointsTaken: { Attachment } = state.SnappedPointsTaken or { snappedPoint }

		-- Set all snapped points as occupied
		for _, taken in ipairs(snappedPointsTaken) do
			taken:SetAttribute("Occupied", true)
		end

		local cframe = PlacementUtils.GetSnappedAttachmentCFrame(tile, snappedPoint, placeableInfo, state)

		-- Don't rotate or level the structure
		structure:SetPrimaryPartCFrame(cframe)
	end

	self.signals.PlacedStructure:Fire(structure)

	-- add VFX for placing the structure
	local PlacedDownVFX = VFX.PlacedDown:Clone()
	PlacedDownVFX.Parent = structure.PrimaryPart

	-- set the VFX to the correct position
	PlacedDownVFX.CFrame = structure.PrimaryPart.CFrame * CFrame.new(0, 0.5, 0)

	-- set the VFX to be visible
	for _, v in ipairs(PlacedDownVFX:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = true
		end
	end

	-- after x seconds, remove the VFX
	coroutine.wrap(function()
		task.wait(0.75)
		for _, v in ipairs(PlacedDownVFX:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
		task.wait(1)
		PlacedDownVFX:Destroy()
	end)()

	local type = placeableInfo.Category

	if type == "Road" then
		local allRoadConnections = self:getRoadConnectionAttachments()
		local currentRoadConnections = self:getStructureRoadAttachments(structure)

		for _, connection: Attachment in ipairs(currentRoadConnections) do
			for _, roadConnection: Attachment in ipairs(allRoadConnections) do
				if
					roadConnection ~= connection
					and (roadConnection.WorldCFrame.Position - connection.WorldCFrame.Position).Magnitude < 0.1
				then
					print("adjacent road connection found")
				end
			end
		end
	end
end

function Plot:getPlaceable(structure: Model): Model?
	for _, placeableType in pairs(self.placeables) do
		for _, v in ipairs(placeableType) do
			if v == structure then
				return v
			end
		end
	end
	return nil
end

function Plot:getPlaceablesOnTile(tile: BasePart)
	local structures = {}
	for _, structure in ipairs(self.placeables) do
		if structure:GetAttribute("Tile") == tile.Name then
			table.insert(structures, structure)
		end
	end
	return structures
end

function Plot:getPlaceablesOnTileWithLevel(tile: BasePart, level: number)
	for _, structure in ipairs(self.placeables) do
		if structure:GetAttribute("Tile") == tile.Name then
			if structure:GetAttribute("Level") == level then
				return structure
			end
		end
	end
	return nil
end

function Plot:getStructureRoadAttachments(structure: Model): { Attachment }
	if structure == nil then
		error("Structure is nil")
	end

	if structure.PrimaryPart == nil then
		error("Structure does not have a PrimaryPart")
	end

	if structure:GetAttribute("Category") ~= "Road" then
		return {}
	end

	local roadConnectionsReturn = {}

	local roadConnections = structure.PrimaryPart:GetChildren()

	for _, connection in ipairs(roadConnections) do
		if connection:IsA("Attachment") and connection.Name == "RoadConnection" then
			table.insert(roadConnectionsReturn, connection)
		end
	end

	return roadConnectionsReturn
end

function Plot:getRoadConnectionAttachments(): { Attachment }
	local roadConnectionsReturn = {}

	for _, structure in ipairs(self.model.Structures:GetChildren()) do
		local roadConnections = self:getStructureRoadAttachments(structure)

		for _, connection in ipairs(roadConnections) do
			table.insert(roadConnectionsReturn, connection)
		end
	end

	return roadConnectionsReturn
end

function Plot:getStructureFromRoadConnectionAttachment(attachment: Attachment): Model?
	if attachment == nil then
		error("Attachment is nil")
	end

	local model = attachment:FindFirstAncestorWhichIsA("Model")

	if model == nil then
		error("Attachment does not have a model ancestor")
	end

	if model:IsDescendantOf(self.model) == false then
		error("Model is not a descendant of the plot")
	end

	return model
end

function Plot:updateBuildingStatus()
	for _, structure in ipairs(self.placeables) do
		structure:updateStatus()
	end
end

return Plot
