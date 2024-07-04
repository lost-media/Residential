----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dir_Structures = ReplicatedStorage.Game.Shared.Structures
local dir_Utils = dir_Structures.Utils

local TableUtil = require(dir_Utils.TableUtil)

local StructureTypes = require(script.Parent.Parent.Types)

local StructureFolder: Folder = ReplicatedStorage.Structures
local IndustrialFolder: Folder = StructureFolder.Industrial

local SharedProperties = {
	Category = "Industrial",
	BuildTime = 0,
	FullArea = true,
	IsABuilding = true,
	Stacking = {
		Allowed = false,
	},
	Price = 100,
	GridUnit = 4,
	AerialViewAngle = 0,

	Properties = {
		Radius = 2, -- Tiles
	},
}

local Industrials: StructureTypes.IndustrialCollection = {
	TableUtil.Reconcile({
		Name = "Water Tower",
		UID = 0,
		Id = "Industrial/Water Tower",
		Description = "A normal road",
		Model = IndustrialFolder["Water Tower"],
	}, SharedProperties),
}

return Industrials
