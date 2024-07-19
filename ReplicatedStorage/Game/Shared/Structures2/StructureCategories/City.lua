local ReplicatedStorage = game:GetService("ReplicatedStorage")
local dirStructures = ReplicatedStorage.Structures.City

local structureTypes = require(script.Parent.Parent.Types)

export type CityStructure = structureTypes.Structure & {}

export type City = structureTypes.StructureCategory & {
	structures: { CityStructure },
}

local City: City = {
	verboseName = "City",
	verboseNamePlural = "Cities",
	description = "City buildings are structures that are necessary to progress in the game. They are the backbone of your city and provide the necessary services to keep your city running.",
	icon = "rbxassetid://18539171639",
	structures = {},
}

City.structures = {
	{
		id = "city_hall",
		name = "City Hall",
		description = "The City Hall is the central building of your city. It is where you can manage your city and its services.",
		model = dirStructures["CityHall"],
		price = {
			value = 100,
			currency = "kloins",
		},
	},
}

return City
