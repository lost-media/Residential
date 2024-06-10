local RS = game:GetService("ReplicatedStorage")

local StackingUtils = require(RS.Shared.Structures.Utils.Stacking)
local StructureTypes = require(script.Parent.Parent.Types)
local TableUtil = require(RS.Packages.TableUtil)

local StructureFolder = RS.Structures
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
	["Normal Road"] = TableUtil.Reconcile(SharedProperties, {
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
	}),

	["Curved Road"] = TableUtil.Reconcile(SharedProperties, {
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
	}),

	["Intersection Road"] = TableUtil.Reconcile(SharedProperties, {
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
	}),

	["Elevated Normal Road"] = TableUtil.Reconcile(SharedProperties, {
		Name = "Elevated Normal Road",
		Id = "Road/Elevated Normal Road",
		Description = "A curved road",
		Model = RoadFolder["Elevated Normal Road"],

		Stacking = {
			Allowed = true,

			AllowedModels = {
				["Road/Elevated Normal Road"] = StackingUtils.CreateStackingData(
					true,
					{ "Top1", "Top2" },
					{ ["Top1"] = "Center", ["Top2"] = "Center" },
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

				["Road/Streetlight"] = StackingUtils.CreateStackingData(
					false,
					{ "Top1", "Top2", "Top3", "Top4" },
					{ ["Top1"] = "Top1", ["Top2"] = "Top2" }
				),
			},
		},
	}),

	["Streetlight"] = {
		Category = "Road",
		Name = "Streetlight",
		Id = "Road/Streetlight",
		Description = "A normal streetlight",
		Price = 100,
		Model = RoadFolder["Streetlight"],
		BuildTime = 1,
		FullArea = false,

		Stacking = {
			Allowed = false,
		},
	},

	["Test"] = {
		Name = "Test",
		Id = "Road/Test",
		Description = "A normal test",
		Price = 100,
		Model = RoadFolder["Test"],
		BuildTime = 1,
		FullArea = false,

		Stacking = {
			Allowed = false,
		},
	},
}

return Roads
