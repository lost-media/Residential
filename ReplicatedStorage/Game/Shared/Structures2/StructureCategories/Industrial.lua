local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LMEngine = require(ReplicatedStorage.LMEngine)

local Currency = require(LMEngine.Game.Currency)

local dirStructures = ReplicatedStorage.Structures.Industrial

local structureTypes = require(script.Parent.Parent.Types)

export type IndustrialStructure = structureTypes.Structure & {}

export type Industrial = structureTypes.StructureCategory & {
	structures: { IndustrialStructure },
}

local Industrial: Industrial = {
	layoutOrder = 3,
	verboseName = "Industrial",
	verboseNamePlural = "Industrials",
	description = "City buildings are structures that are necessary to progress in the game. They are the backbone of your city and provide the necessary services to keep your city running.",
	icon = "rbxassetid://18313003018",
	structures = {},

	folder = dirStructures,
}

Industrial.structures = {
	{
		id = "industrial/water_tower",
		name = "Water Tower",
		description = "A basic Water Tower",
		model = dirStructures["WaterTower"],
		viewportZoomScale = 0.75,

		price = {
			value = 1,
			currency = Currency.kloins,
		},
	},
} :: { IndustrialStructure }

return Industrial
