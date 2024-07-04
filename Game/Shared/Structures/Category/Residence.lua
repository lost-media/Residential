----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dir_Structures = ReplicatedStorage.Game.Shared.Structures
local dir_Utils = dir_Structures.Utils

local TableUtil = require(dir_Utils.TableUtil)

local StructureTypes = require(script.Parent.Parent.Types)

local StructureFolder: Folder = ReplicatedStorage.Structures
local ResidenceFolder: Folder = StructureFolder.Residence

local SharedProperties = {
	Category = "Residence",
	BuildTime = 30,
	FullArea = true,
	IsABuilding = true,
	Stacking = {
		Allowed = false,
	},
	Price = 100,
	GridUnit = 4,
	AerialViewAngle = 45,

	Properties = {
		Radius = 2, -- Tiles
	},
}

local Residences: StructureTypes.CityHallCollection = {
	TableUtil.Reconcile({
		Name = "Medieval House",
		UID = 0,
		Id = "Residence/Medieval House",
		Description = "A medieval house",
		Model = ResidenceFolder["Medieval House"],
	}, SharedProperties),
}

return Residences
