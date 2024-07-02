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
	Stacking = {
		Allowed = false,
	},
	Price = 100,
	GridUnit = 4,
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

	["Streetlight"] = TableUtil.Reconcile({
		Name = "Streetlight",
		UID = 6,
		Id = "Road/Streetlight",
		Description = "A normal streetlight",
		Model = RoadFolder["Streetlight"],
		GridUnit = 0.25,

		Stacking = {
			Allowed = true,
		},
	}, SharedProperties),
}

return Roads
