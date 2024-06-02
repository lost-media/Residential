Plot = {}
Plot.__index = Plot

local DEFAULT_PLOT_SIZE = 8;
local TILE_SIZE = 6;

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

function Plot:placeObject(placeable, state: table)
    
end

function Plot:updateBuildingStatus()
    for _, placeable in ipairs(self.placeables) do
        placeable:updateStatus()
    end
end

return Plot;