----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dir_Structures = ReplicatedStorage.Game.Shared.Structures
local dir_Utils = dir_Structures.Utils

local StackingUtils = require(dir_Utils.Stacking)
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
	["Normal Road"] = TableUtil.Reconcile({
		Name = "Normal Road",
		Id = "Road/Normal Road",
		Description = "A normal road",
		Model = RoadFolder["Normal Road"],
	}, SharedProperties),

	["Curved Road"] = TableUtil.Reconcile({
		Name = "Curved Road",
		Id = "Road/Curved Road",
		Description = "A curved road",
		Model = RoadFolder["Curved Road"],
	}, SharedProperties),

	["Intersection Road"] = TableUtil.Reconcile({
		Name = "Intersection Road",
		Id = "Road/Intersection Road",
		Description = "A curved road",
		Model = RoadFolder["Intersection Road"],
	}, SharedProperties),

	["Highway Road"] = TableUtil.Reconcile({
		Name = "Highway Road",
		Id = "Road/Highway Road",
		Description = "A curved road",
		Model = RoadFolder["Highway Road"],
	}, SharedProperties),

	["Ramp Road"] = TableUtil.Reconcile({
		Name = "Ramp Road",
		Id = "Road/Ramp Road",
		Description = "A ramp road",
		Model = RoadFolder["Ramp Road"],
	}, SharedProperties),

	["Dead-End Road"] = TableUtil.Reconcile({
		Name = "Elevated Normal Road",
		Id = "Road/Dead-End Road",
		Description = "A curved road",
		Model = RoadFolder["Dead End Road"],
	}, SharedProperties),

	["Streetlight"] = TableUtil.Reconcile({
		Name = "Streetlight",
		Id = "Road/Streetlight",
		Description = "A normal streetlight",
		Price = 500,
		Model = RoadFolder["Streetlight"],
		FullArea = false,
		GridUnit = 0.25,

		Stacking = {
			Allowed = true,
		},
	}, SharedProperties),
}

return Roads
