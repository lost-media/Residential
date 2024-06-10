--!strict

local RS = game:GetService("ReplicatedStorage")

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local PlacementTypes = require(RS.Shared.Types.Placement)
local PlacementUtils = require(game:GetService("ReplicatedStorage").Shared.PlacementUtils)

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

	if state.isStacked == false and state.tile:GetAttribute("Occupied") == true then
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

		local snappedPointsTaken: { Attachment } = state.SnappedPointsTaken or { state.SnappedPoint }

		for _, taken in ipairs(snappedPointsTaken) do
			taken:SetAttribute("Occupied", true)
		end

		local cframe = PlacementUtils.GetSnappedAttachmentCFrame(tile, snappedPoint, placeableInfo, state)

		-- Don't rotate or level the structure
		structure:SetPrimaryPartCFrame(cframe)
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

function Plot:updateBuildingStatus()
	for _, structure in ipairs(self.placeables) do
		structure:updateStatus()
	end
end

return Plot
