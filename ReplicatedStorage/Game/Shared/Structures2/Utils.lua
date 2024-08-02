local Structures = require(script.Parent.Structures)
local Types = require(script.Parent.Types)

type Structure = Types.Structure

local Structures2Utils = {}

function Structures2Utils.getStructure(structureId: string): Structure
	for _, category in pairs(Structures) do
		for _, structure in pairs(category.structures) do
			if structure.id == structureId then
				return structure
			end
		end
	end

	warn("Structure not found with id: " .. structureId)
	return nil
end

function Structures2Utils.getStructuresInCategory(categoryName: string): { Structure }
	for _, category in pairs(Structures) do
		if category.verboseName == categoryName then
			return category.structures
		end
	end

	return {}
end

function Structures2Utils.getCategory(categoryName: string): Types.StructureCategory
	for _, category in pairs(Structures) do
		if category.verboseName == categoryName then
			return category
		end
	end

	return nil
end

function Structures2Utils.getCategories(): { Types.StructureCategory }
	local categories = {}

	for _, category in pairs(Structures) do
		table.insert(categories, category)
	end

	return categories
end

return Structures2Utils
