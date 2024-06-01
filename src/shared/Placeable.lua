--!strict

local Placeable = {
    ClassName = "Placeable";
}

Placeable.__index = Placeable

function Placeable.new()
    local self = setmetatable({}, Placeable)

    return self
end

function Placeable:place(plot, tile: BasePart)
    error("Placeable:place must be overridden")
end

function Placeable:isOccupying(tile: BasePart) : boolean
    error("Placeable:isOccupying must be overridden")
end

function Placeable:updateStatus()
    error("Placeable:updateStatus must be overridden")
end

function Placeable:getOccupiedTile() : BasePart?
    error("Placeable:getOccupiedTile must be overridden")
end

function Placeable:isAdjacentTo(plot, type: string) : boolean
    local tile = self:getOccupiedTile()
    if tile == nil then
        return false
    end
    return plot:isAdjacentTo(tile, type)
end

return Placeable