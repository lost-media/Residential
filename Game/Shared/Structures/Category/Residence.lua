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
	AerialViewAngle = 0,

	FrontSurface = Enum.NormalId.Front, -- The "doors" of the house. there can be multiple doors
}

local Residences: StructureTypes.CityHallCollection = {
	TableUtil.Reconcile({
		Name = "Medieval House 1",
		UID = 0,
		Id = "Residence/Medieval House 1",
		Description = "A medieval house",
		Model = ResidenceFolder["Medieval House 1"],

		Price = 15000,

		FrontSurface = {
			Enum.NormalId.Left,
			Enum.NormalId.Front,
		},
	}, SharedProperties),

	TableUtil.Reconcile({
		Name = "Medieval House 2",
		UID = 1,
		Id = "Residence/Medieval House 2",
		Description = "A medieval house",
		Model = ResidenceFolder["Medieval House 2"],
		Price = 9500,
	}, SharedProperties),

	TableUtil.Reconcile({
		Name = "Victorian House 1",
		UID = 2,
		Id = "Residence/Victorian House 1",
		Description = "A Victorian house",
		Model = ResidenceFolder["Victorian House 1"],
		Price = 2500,
	}, SharedProperties),

	TableUtil.Reconcile({
		Name = "Victorian House 2",
		UID = 3,
		Id = "Residence/Victorian House 2",
		Description = "A Victorian house",
		Model = ResidenceFolder["Victorian House 2"],
		Price = 1000,
	}, SharedProperties),
}

return Residences
