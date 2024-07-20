local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LMEngine = require(ReplicatedStorage.LMEngine)

local Currency = require(LMEngine.Game.Currency)

local dirStructures = ReplicatedStorage.Structures.Business

local structureTypes = require(script.Parent.Parent.Types)

export type BusinessStructure = structureTypes.Structure & {}

export type Industrial = structureTypes.StructureCategory & {
	structures: { BusinessStructure },
}

local Business: Industrial = {
	layoutOrder = 4,
	verboseName = "Business",
	verboseNamePlural = "Businesses",
	description = "Business buildings are structures that are necessary to progress in the game. They are the backbone of your city and provide the necessary services to keep your city running.",
	icon = "rbxassetid://18539219318",
	structures = {},

	folder = dirStructures,
}

Business.structures = {
	{
		id = "business/grocery_store",
		name = "Grocery Store",
		description = "A basic Grocery Store",
		model = dirStructures["GroceryStore"],
		viewportZoomScale = 0.75,

		price = {
			value = 0,
			currency = Currency.kloins,
		},
	},
} :: { BusinessStructure }

return Business
