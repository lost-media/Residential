local StructureFactory = {}

local StructureUtils = require(script.Parent.Utils)
local Structures = require(script.Parent)

function StructureFactory.MakeStructure(structure_id: string)
	assert(structure_id ~= nil, "StructureFactory.MakeStructure: structure_id is nil")

	local new_structure = StructureUtils.GetStructureModelFromId(structure_id)
	assert(new_structure ~= nil, "StructureFactory.MakeStructure: structure_id is invalid")

	-- Clone the structure model
	local structure = new_structure:Clone()
	return structure
end

return StructureFactory
