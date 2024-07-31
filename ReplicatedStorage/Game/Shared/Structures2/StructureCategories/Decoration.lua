local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LMEngine = require(ReplicatedStorage.LMEngine)

local Currency = require(LMEngine.Game.Currency)

local dirStructures = ReplicatedStorage.Structures.Decoration

local structureTypes = require(script.Parent.Parent.Types)

export type DecorationStructure = structureTypes.Structure & {}

export type Decoration = structureTypes.StructureCategory & {
	structures: { DecorationStructure },
}

local Decoration: Decoration = {
	layoutOrder = 4,
	verboseName = "Decoration",
	verboseNamePlural = "Decorations",
	description = "Decorations are structures that are necessary to progress in the game. They are the backbone of your city and provide the necessary services to keep your city running.",
	icon = "rbxassetid://18312572742",
	structures = {},

	folder = dirStructures,
}

Decoration.structures = {
	{
		id = "decoration/street_lamp",
		name = "Street Lamp",
		description = "Light up the streets with this Street Lamp",
		model = dirStructures["StreetLamp"],
		viewportZoomScale = 0.75,
		price = {
			value = 0,
			currency = Currency.kloins,
		},
	},
} :: { DecorationStructure }

return Decoration
