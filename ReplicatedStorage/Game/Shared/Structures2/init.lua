local types = require(script.Types)
export type Structure = types.Structure
export type StructureCategory = types.StructureCategory

local dirStructureCategories = script.StructureCategories

type Structures = { [string]: StructureCategory }

local Structures = {}

Structures.Structures = {} :: Structures

function Structures.getStructure(structureId: string): Structure
	for _, category in pairs(Structures.Structures) do
		for _, structure in pairs(category.structures) do
			if structure.id == structureId then
				return structure
			end
		end
	end

	warn("Structure not found with id: " .. structureId)
	return nil
end

function Structures.getStructuresInCategory(categoryName: string): { Structure }
	for _, category in pairs(Structures.Structures) do
		if category.verboseName == categoryName then
			return category.structures
		end
	end

	return {}
end

function Structures.getCategories(): { StructureCategory }
	local categories = {}

	for _, category in pairs(Structures.Structures) do
		table.insert(categories, category)
	end

	return categories
end

function Structures.getCategory(categoryName: string): StructureCategory
	for _, category in pairs(Structures.Structures) do
		if category.verboseName == categoryName then
			return category
		end
	end

	return nil
end

----- Initialize -----

for _, category in pairs(dirStructureCategories:GetChildren()) do
	local categoryModule: StructureCategory = require(category)
	Structures.Structures[categoryModule.verboseName] = categoryModule
end

return Structures
