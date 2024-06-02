Plot = {}
Plot.__index = Plot

local DEFAULT_PLOT_SIZE = 8;
local TILE_SIZE = 6;
local LEVEL_HEIGHT = 6;

--[[

    The Plot Instance model has the following structure:

    Model
    ├── Placeables
    ├── Tiles

    The Placeables folder contains all the models that were placed on the plot.

    The Tiles folder contains the cells that make up the plot. In a standard plot, there are 64 cells (8x8).
    Each cell is a BasePart that is 6x6 studs in size. Their name is a number which may not have any correlation to their position in the plot.

]]--

function Plot.new(model: Model, id: number)

    -- Validate the model before creating the Plot instance

    if (model == nil) then
        error("Model is nil")
    end

    if (model:FindFirstChild("Tiles") == nil) then
        error("Model does not have a Tiles folder")
    end

    if (model:FindFirstChild("Placeables") == nil) then
        error("Model does not have a Placeables folder")
    end

    if (id == nil) then
        error("Plot cannot be created without an ID")
    end

    local self = setmetatable({}, Plot)

    self.player = nil
    self.placeables = {}
    self.tiles = {}

    self.id = id
    self.model = model
    self.size = DEFAULT_PLOT_SIZE

    self.model.Name = id

    for i, v: BasePart in ipairs(model.Tiles:GetChildren()) do
        self.tiles[i] = v
    end

    return self
end

function Plot:getInstance()
    return self.model
end

function Plot:getPlayer() : Player?
    return self.player
end

function Plot:assignPlayer(player: Player)
    if (self.player ~= nil) then
        error("Plot already has a player assigned")
    end

    if (player == nil) then
        error("Player is nil")
    end

    player:SetAttribute("Plot", self.id)
    self.player = player
end

function Plot:removePlayer()
    self.player = nil
end

function Plot:getTile(tile: BasePart) : BasePart?
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
        local tileX = math.floor((tilePos.X + TILE_SIZE/2) / TILE_SIZE)
        local tileY = math.floor((tilePos.Z + TILE_SIZE/2) / TILE_SIZE)

        if tileX == x and tileY == y then
            return tile
        end
    end
    return nil
end

-- type
function Plot:isAdjacentTo(tile1: BasePart, tile2: BasePart) : boolean
    local tile1Pos = tile1.Position
    local tile2Pos = tile2.Position

    local tile1X = math.floor((tile1Pos.X + TILE_SIZE/2) / TILE_SIZE)
    local tile1Y = math.floor((tile1Pos.Z + TILE_SIZE/2) / TILE_SIZE)

    local tile2X = math.floor((tile2Pos.X + TILE_SIZE/2) / TILE_SIZE)
    local tile2Y = math.floor((tile2Pos.Z + TILE_SIZE/2) / TILE_SIZE)

    if (math.abs(tile1X - tile2X) <= 1 and math.abs(tile1Y - tile2Y) <= 1) then
        return true
    end

    return false
end

function Plot:isOccupied(tile: BasePart) : boolean
    for _, placeable in ipairs(self.placeables) do
        if placeable:isOccupying(tile) then
            return true
        end
    end
    return false
end

function Plot:placeObject(placeable: Model, state: table)
    if (placeable == nil) then
        error("Placeable is nil")
    end

    if (state == nil) then
        error("State is nil")
    end

    local placeableType = placeable.Name

    if (self.placeables[placeableType] == nil) then
        self.placeables[placeableType] = {}
    end

    table.insert(self.placeables[placeableType], placeable)

    placeable:SetAttribute("Plot", self.id)
    placeable:SetAttribute("Level", state.Level)
    placeable:SetAttribute("Rotation", state.Rotation)
    placeable:SetAttribute("Tile", state.Tile.Name)
    placeable:SetAttribute("Stacked", state.Stacked or false)


    placeable.Parent = self.model.Placeables

    local tile = self:getTile(state.Tile)

    if (tile == nil) then
        error("Tile is nil")
    end

    local tileHeight = tile.Size.Y
    local _, placeableSize = placeable:GetBoundingBox()

    local objectPosition = tile.Position + Vector3.new(0, (placeableSize.Y / 2) + (tileHeight / 2), 0)
    objectPosition = objectPosition + Vector3.new(0, state.Level * LEVEL_HEIGHT, 0)

    placeable.PrimaryPart.CFrame = CFrame.new(objectPosition) * CFrame.Angles(0, math.rad(state.Rotation), 0)

    if (state.Stacked) then
        local stackedOn: Model? = state.StackedOn
        if (stackedOn == nil) then
            error("Stacked object is nil")
        end

        local stackedOnPlaceable = self:getPlaceable(stackedOn)

        if (stackedOnPlaceable == nil) then
            error("Stacked object is not on the plot")
        end

        -- Get snapped point
        local snappedPoint = state.SnappedPoint;
        if (snappedPoint == nil) then
            error("Snapped point is nil")
        end

        local snappedPointPosition = snappedPoint.Position
        
        local stackedOnPosition = stackedOn.PrimaryPart.Position
        local stackedOnSize = stackedOn.PrimaryPart.Size

        local stackedOnHeight = stackedOnSize.Y

        local stackedObjectPosition = stackedOnPosition + Vector3.new(0, (placeableSize.Y / 2), 0)
        stackedObjectPosition = stackedObjectPosition + snappedPointPosition

        placeable.PrimaryPart.CFrame = CFrame.new(stackedObjectPosition) * CFrame.Angles(0, math.rad(state.Rotation), 0)
        

    end
end

function Plot:getPlaceable(placeable: Model) : Model?
    for _, placeableType in pairs(self.placeables) do
        for _, v in ipairs(placeableType) do
            if v == placeable then
                return v
            end
        end
    end
    return nil
end

function Plot:updateBuildingStatus()
    for _, placeable in ipairs(self.placeables) do
        placeable:updateStatus()
    end
end

return Plot;