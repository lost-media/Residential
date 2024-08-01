local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LMEngine = require(ReplicatedStorage.LMEngine)

local Currency = require(LMEngine.Game.Currency)

local dirStructures = ReplicatedStorage.Structures.Road

local structureTypes = require(script.Parent.Parent.Types)

export type RoadStructure = structureTypes.Structure & {}

export type Road = structureTypes.StructureCategory & {
	structures: { RoadStructure },
}

local Road: Road = {
	layoutOrder = 2,
	verboseName = "Road",
	verboseNamePlural = "Roads",
	description = "City buildings are structures that are necessary to progress in the game. They are the backbone of your city and provide the necessary services to keep your city running.",
	icon = "rbxassetid://18312539919",
	structures = {},

	folder = dirStructures,
}

Road.structures = {
	{
		id = "road/normal",
		name = "Normal Road",
		description = "The City Hall is the central building of your city. It is where you can manage your city and its services.",
		model = dirStructures["Normal"],
		viewportZoomScale = 0.75,
		price = {
			value = 50,
			currency = Currency.kloins,
		},
	},

	{
		id = "road/curved",
		name = "Curved Road",
		description = "The City Hall is the central building of your city. It is where you can manage your city and its services.",
		model = dirStructures["Curved"],
		viewportZoomScale = 0.75,
		price = {
			value = 50,
			currency = Currency.kloins,
		},
	},

	{
		id = "road/int",
		name = "Intersection Road",
		description = "The City Hall is the central building of your city. It is where you can manage your city and its services.",
		model = dirStructures["Intersection"],
		viewportZoomScale = 0.75,
		price = {
			value = 50,
			currency = Currency.kloins,
		},
	},

	{
		id = "road/t-int",
		name = "T-Intersection Road",
		description = "The City Hall is the central building of your city. It is where you can manage your city and its services.",
		model = dirStructures["T-Intersection"],
		viewportZoomScale = 0.75,
		price = {
			value = 50,
			currency = Currency.kloins,
		},
	},
	{
		id = "road/deadend",
		name = "Dead-End Road",
		description = "The City Hall is the central building of your city. It is where you can manage your city and its services.",
		model = dirStructures["DeadEnd"],
		viewportZoomScale = 0.75,
		price = {
			value = 50,
			currency = Currency.kloins,
		},
	},
	{
		id = "road/ramp",
		name = "Ramp",
		description = "The City Hall is the central building of your city. It is where you can manage your city and its services.",
		model = dirStructures["Ramp"],
		viewportZoomScale = 0.75,
		price = {
			value = 50,
			currency = Currency.kloins,
		},
	},
}

return Road
