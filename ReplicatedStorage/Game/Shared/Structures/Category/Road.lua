----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dir_Structures = ReplicatedStorage.Game.Shared.Structures
local dir_Utils = dir_Structures.Utils

local TableUtil = require(dir_Utils.TableUtil)

local StructureTypes = require(script.Parent.Parent.Types)

local StructureFolder: Folder = ReplicatedStorage.Structures
local RoadFolder: Folder = StructureFolder.Road

local SharedProperties = {
	Category = "Road",
	BuildTime = 0,
	FullArea = true,
	IsABuilding = false,
	Stacking = {
		Allowed = false,
	},
	Price = 100,
	GridUnit = 4,
	AerialViewAngle = 45,
}

local Roads: StructureTypes.RoadCollection = {
	TableUtil.Reconcile({
		Name = "Normal",
		UID = 0,
		Id = "Road/Normal",
		Description = "A normal road",
		Model = RoadFolder["Normal"],
	}, SharedProperties),

	TableUtil.Reconcile({
		Name = "Curved",
		UID = 1,
		Id = "Road/Curved",
		Description = "A curved road",
		Model = RoadFolder["Curved"],
	}, SharedProperties),

	TableUtil.Reconcile({
		Name = "Intersection",
		UID = 2,
		Id = "Road/Intersection",
		Description = "A curved",
		Model = RoadFolder["Intersection"],
	}, SharedProperties),

	TableUtil.Reconcile({
		Name = "T-Intersection",
		UID = 3,
		Id = "Road/T-Intersection",
		Description = "A T-Intersection road",
		Model = RoadFolder["T-Intersection"],
	}, SharedProperties),

	TableUtil.Reconcile({
		Name = "Ramp",
		UID = 4,
		Id = "Road/Ramp",
		Description = "A ramp road",
		Model = RoadFolder["Ramp"],
	}, SharedProperties),

	TableUtil.Reconcile({
		Name = "Dead End",
		UID = 5,
		Id = "Road/Dead End",
		Description = "A curved road",
		Model = RoadFolder["Dead End"],
	}, SharedProperties),
}

return Roads
