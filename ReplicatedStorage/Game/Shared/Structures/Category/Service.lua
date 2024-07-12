----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dir_Structures = ReplicatedStorage.Game.Shared.Structures
local dir_Utils = dir_Structures.Utils

local TableUtil = require(dir_Utils.TableUtil)

local StructureTypes = require(script.Parent.Parent.Types)

local StructureFolder: Folder = ReplicatedStorage.Structures
local ServicesFolder: Folder = StructureFolder.Services

local SharedProperties = {
	Category = "Service",
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
		Name = "Hospital",
		UID = 0,
		Id = "Services/Hospital",
		Description = "A normal hospital",
		Model = ServicesFolder["Hospital"],
	}, SharedProperties),
}

return Industrials
