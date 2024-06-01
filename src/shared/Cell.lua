--!strict

local PlaceableType = require(game.ReplicatedStorage.Shared.Enums.PlaceableType)

local Cell = {}
Cell.__index = Cell

function Cell.new(x: number, y: number, type)
    local self = setmetatable({}, Cell)
    self.x = x
    self.y = y
    self.type = type or PlaceableType.EMPTY;
    return self
end

function Cell:isBuilding()
    return self.type.isBuilding
end

return Cell;