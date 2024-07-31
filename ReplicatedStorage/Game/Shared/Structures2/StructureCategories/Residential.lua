local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LMEngine = require(ReplicatedStorage.LMEngine)

local Currency = require(LMEngine.Game.Currency)

local dirStructures = ReplicatedStorage.Structures.Residential

local structureTypes = require(script.Parent.Parent.Types)

export type ResidentialStructure = structureTypes.Structure & {}

export type Residential = structureTypes.StructureCategory & {
	structures: { ResidentialStructure },
}

local Residential: Residential = {
	layoutOrder = 1,
	verboseName = "Residential",
	verboseNamePlural = "Residentials",
	description = "Residential buildings are structures that are necessary to progress in the game. They are the backbone of your city and provide the necessary services to keep your city running.",
	icon = "rbxassetid://18312606125",
	structures = {},

	folder = dirStructures,
}

Residential.structures = {
	{
		id = "residential/medieval_house1",
		name = "Medieval House 1",
		description = "A small medieval house.",
		model = dirStructures["Medieval House 1"],
		price = {
			value = 100,
			currency = Currency.kloins,
		},
	},

	{
		id = "residential/medieval_house2",
		name = "Medieval House 2",
		description = "A small medieval house.",
		model = dirStructures["Medieval House 2"],
		price = {
			value = 100,
			currency = Currency.kloins,
		},
	},

	{
		id = "residential/victorian_house1",
		name = "Victorian House 1",
		description = "A small victorian house.",
		model = dirStructures["Victorian House 1"],
		price = {
			value = 100,
			currency = Currency.kloins,
		},
	},

	{
		id = "residential/victorian_house2",
		name = "Victorian House 2",
		description = "A small victorian house.",
		model = dirStructures["Victorian House 2"],
		price = {
			value = 100,
			currency = Currency.kloins,
		},
	},
} :: { ResidentialStructure }

return Residential
