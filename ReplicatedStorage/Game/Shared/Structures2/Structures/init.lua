local Types = require(script.Parent.Types)

local dirStructureCategories = script.StructureCategories

local Structures = {} :: { [string]: Types.StructureCategory }

for _, category in pairs(dirStructureCategories:GetChildren()) do
	local categoryModule: Types.StructureCategory = require(category)
	Structures[categoryModule.verboseName] = categoryModule
end

return Structures
