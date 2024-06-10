local RS = game:GetService("ReplicatedStorage")
local ServerUtil: Folder = script.Parent.Parent.Utils
local Structures: Folder = RS.Structures

local Knit = require(RS.Packages.Knit)
local PlaceableType = require(RS.Shared.Enums.PlaceableType)
local StructuresModule = require(RS.Shared.Structures)
local StructuresUtils = require(RS.Shared.Structures.Utils)
local Weld = require(RS.Shared.Weld)

local StructureService = Knit.CreateService({
	Name = "StructureService",
	Client = {},

	Placeables = {},
})

function StructureService:KnitInit()
	print("StructureService initialized")

	-- Weld all models in each subfolder of Placeables

	for _, folder in ipairs(Structures:GetChildren()) do
		for _, model in ipairs(folder:GetChildren()) do
			Weld.WeldPartsToPrimaryPart(model)
		end
	end

	print("StructureService: Welded all models in Structures")

	-- Store all models in Placeables in StructureService.Placeables

	for _, folder in ipairs(Structures:GetChildren()) do
		if self:PlaceableTypeIsValid(folder.Name) == false then
			warn("Invalid placeable type: " .. folder.Name)
			continue
		end

		if StructureService.Placeables[folder.Name] == nil then
			StructureService.Placeables[folder.Name] = {}
		end

		for _, model in ipairs(folder:GetChildren()) do
			local id = StructuresUtils.GetIdFromStructure(model)
			if id == nil then
				warn("StructureService: Invalid ID for model: " .. model.Name)
				continue
			end

			model:SetAttribute("Id", id)
			table.insert(StructureService.Placeables[folder.Name], model)
		end
	end
end

function StructureService:KnitStart()
	print("StructureService started")
end

function StructureService:PlaceableTypeIsValid(placeableType: string): boolean
	for _, enum in pairs(PlaceableType) do
		if enum.name == placeableType then
			return true
		end
	end

	return false
end

function StructureService:GetStructureEntry(id: string)
	return StructuresUtils.GetStructureFromId(id)
end

function StructureService:CreateStructureFromIdentifier(identifier: string): Model?
	local model = StructuresUtils.GetStructureModelFromId(identifier)

	if model == nil then
		warn("StructureService: Invalid identifier: " .. identifier)
		return nil
	end

	return model:Clone()
end

return StructureService
