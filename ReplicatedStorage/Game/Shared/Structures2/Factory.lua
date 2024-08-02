local Utils = require(script.Parent.Utils)

local Structures2Factory = {}

function Structures2Factory.makeStructure(structureId: string)
	local structure = Utils.getStructure(structureId)

	if structure == nil then
		return nil
	end

	return structure.model:Clone()
end

return Structures2Factory
