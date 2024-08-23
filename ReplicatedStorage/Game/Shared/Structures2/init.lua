local Factory = require(script.Factory)
local Structures = require(script.Structures)
local Utils = require(script.Utils)

local Types = require(script.Types)
export type Structure = Types.Structure
export type StructureCategory = Types.StructureCategory

local Structures2 = {
	Factory = Factory,
	Structures = Structures,
	Utils = Utils,
	Types = Types,
}

return Structures2
