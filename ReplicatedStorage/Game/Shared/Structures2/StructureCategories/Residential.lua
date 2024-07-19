local ReplicatedStorage = game:GetService("ReplicatedStorage")
local dirStructures = ReplicatedStorage.Structures.City

local structureTypes = require(script.Parent.Parent.Types)

export type ResidentialStructure = structureTypes.Structure & {}

export type Residential = structureTypes.StructureCategory & {
	structures: { ResidentialStructure },
}

local Residential: Residential = {
	verboseName = "Residential",
	verboseNamePlural = "Residentials",
	description = "Residential buildings are structures that are necessary to progress in the game. They are the backbone of your city and provide the necessary services to keep your city running.",
	icon = "rbxassetid://18312606125",
	structures = {},
}

Residential.structures = {
	{
		id = "city_hall",
		name = "Futuristic",
		description = "The City Hall is the central building of your city. It is where you can manage your city and its services.",
		model = dirStructures["CityHall"],
		price = {
			value = 100,
			currency = "kloins",
		},
	},
} :: { ResidentialStructure }

return Residential
