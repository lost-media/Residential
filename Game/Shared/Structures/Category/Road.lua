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
		Allowed = true,
	},
	Price = 100,
}

local Roads: StructureTypes.RoadCollection = {
	["Normal Road"] = TableUtil.Reconcile({
		Name = "Normal Road",
		Id = "Road/Normal Road",
		Description = "A normal road",
		Model = RoadFolder["Normal Road"],

		Stacking = {
			Allowed = true,
			AllowedModels = {
				["Road/Streetlight"] = StackingUtils.CreateStackingData(
					false,
					{ "Top1", "Top2" },
					{ ["Top1"] = "Top1", ["Top2"] = "Top2" }
				),
				["Road/Elevated Normal Road"] = StackingUtils.CreateStackingData(
					false,
					{ "Top1", "Top2" },
					{ ["Top1"] = "Center", ["Top2"] = "Center", ["Center"] = "Center" },

					{
						Strict = true,
						SnapPointsToMatch = {
							{
								["Top1"] = "Bottom1",
								["Top2"] = "Bottom2",
							},
							{
								["Top1"] = "Bottom2",
								["Top2"] = "Bottom1",
							},
						},
					}
				),
			},
		},
	}, SharedProperties),

	["Curved Road"] = TableUtil.Reconcile({
		Name = "Curved Road",
		Id = "Road/Curved Road",
		Description = "A curved road",
		Model = RoadFolder["Curved Road"],

		Stacking = {
			Allowed = true,

			AllowedModels = {
				["Road/Streetlight"] = StackingUtils.CreateStackingData(
					false,
					{ "Top1", "Top2", "Top3" },
					{ ["Top1"] = "Top1", ["Top2"] = "Top2", ["Top3"] = "Top3" }
				),
			},
		},
	}, SharedProperties),

	["Intersection Road"] = TableUtil.Reconcile({
		Name = "Intersection Road",
		Id = "Road/Intersection Road",
		Description = "A curved road",
		Model = RoadFolder["Intersection Road"],

		Stacking = {
			Allowed = true,

			AllowedModels = {
				["Road/Streetlight"] = StackingUtils.CreateStackingData(
					false,
					{ "Top1", "Top2", "Top3", "Top4" },
					{ ["Top1"] = "Top1", ["Top2"] = "Top2", ["Top3"] = "Top3", ["Top4"] = "Top4" }
				),
			},
		},
	}, SharedProperties),

	["Highway Road"] = TableUtil.Reconcile({
		Name = "Highway Road",
		Id = "Road/Highway Road",
		Description = "A curved road",
		Model = RoadFolder["Highway Road"],

		Stacking = {
			Allowed = true,

			AllowedModels = {
				["Road/Streetlight"] = StackingUtils.CreateStackingData(
					false,
					{ "Top1", "Top2", "Top3" },
					{ ["Top1"] = "Top1", ["Top2"] = "Top2", ["Top3"] = "Top3" }
				),
			},
		},
	}, SharedProperties),

	["Ramp Road"] = TableUtil.Reconcile({
		Name = "Ramp Road",
		Id = "Road/Ramp Road",
		Description = "A ramp road",
		Model = RoadFolder["Ramp Road"],

		Stacking = {
			Allowed = false,
		},
	}, SharedProperties),

	["Dead-End Road"] = TableUtil.Reconcile({
		Name = "Elevated Normal Road",
		Id = "Road/Dead-End Road",
		Description = "A curved road",
		Model = RoadFolder["Dead End Road"],

		Stacking = {
			Allowed = true,

			AllowedModels = {
				["Road/Streetlight"] = StackingUtils.CreateStackingData(
					false,
					{ "Top1", "Top2", "Top3" },
					{ ["Top1"] = "Top1", ["Top2"] = "Top2", ["Top3"] = "Top3" }
				),

				["Road/Elevated Normal Road"] = StackingUtils.CreateStackingData(
					false,
					{ "Top1", "Top2" },
					{ ["Top1"] = "Center", ["Top2"] = "Center", ["Center"] = "Center" },

					{
						Strict = true,
						SnapPointsToMatch = {
							{
								["Top1"] = "Bottom1",
								["Top2"] = "Bottom2",
							},
							{
								["Top1"] = "Bottom2",
								["Top2"] = "Bottom1",
							},
						},
					}
				),
			},
		},
	}, SharedProperties),

	["Streetlight"] = TableUtil.Reconcile({
		Name = "Streetlight",
		Id = "Road/Streetlight",
		Description = "A normal streetlight",
		Price = 500,
		Model = RoadFolder["Streetlight"],
		FullArea = false,

		Stacking = {
			Allowed = false,
		},
	}, SharedProperties),
}

return Roads
