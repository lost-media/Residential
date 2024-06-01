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

function Plot.new(model: Model)
    local self = setmetatable({}, Plot)

    self.placeables = {}
    self.tiles = {}
    self.model = model

    self.size = DEFAULT_PLOT_SIZE

    for i, v: BasePart in ipairs(model.Tiles:GetChildren()) do
        self.tiles[i] = v
    end

    return self
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
function Plot:isAdjacentTo(tile: BasePart, type: string) : boolean
    -- TODO: Implement this
end

function Plot:placeObject(x: number, y: number, placeable)
    placeable:place(self, x, y)
end

function Plot:updateBuildingStatus()
    for _, placeable in ipairs(self.placeables) do
        placeable:updateStatus()
    end
end

return Plot;