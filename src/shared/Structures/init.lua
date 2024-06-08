--!strict

--[[

    For now, there are 4 types of Structures:
    - Industrial
    - Residence
    - Commercial
    - Road
    
    Each type of Structure has a different set of properties, such as:
    - Industrial: Production rate, production capacity, production cost, production time
    - Residence: Population, population capacity, population growth rate, population growth time
    - Commercial: Revenue, revenue capacity, revenue growth rate, revenue growth time
    - Road: Cost, speed, capacity

    BuildTime is in minutes

    ["Starter House"] = {
                Name = "Starter House",
                Id = "Residence/House/Starter House",
                Description = "A small house for beginners",
                Price = 1000,
                Model = Residence["Starter House"],
                BuildTime = 5,

                Properties = {
                    MaxResidents = 2,
                },

                Stacking = {
                    Allowed = true,
                    SnapPoints = {
                        Top = {"TopSnap1"},
                        Bottom = {"BottomSnap1"},
                    },
                    AllowedModels = {
                        ["Residence/House/Starter House"] = {
                            MaxStack = 3,
                            OrientationStrict = false,
                        }
                    }
                }
            }
--]]

local RS = game:GetService("ReplicatedStorage")

local StructuresFolder = RS.Structures
local Road: Folder = StructuresFolder.Road
local Industrial: Folder = StructuresFolder.Industrial
local Residence: Folder = StructuresFolder.Residence
local Commercial: Folder = StructuresFolder.Commercial

export type StructuresCollection = {
	Road: {
		[string]: Road,
	},
	Industrial: {
		[string]: Industrial,
	},
	Residence: {
		[string]: Residence,
	},
	Commercial: {
		[string]: Commercial,
	},
}

export type Structure = {
	Name: string,
	Id: string,
	Description: string,
	Price: number,
	Model: Model,
	BuildTime: number,
	FullArea: boolean, -- If the structure occupies the whole area of the tile

	Stacking: Stacked?,

	Properties: {
		[string]: any,
	},
}

export type Stacked = {
	Allowed: true,
	SnapPoints: {
		[string]: { string },
	},
	AllowedModels: {
		[string]: {
			MaxStack: number,
			Orientation: Orientation,
			RequiredSnapPoints: { string }, -- Snap points required to stack
			OccupiedSnapPoints: { string }, -- Snap points occupied by the structure, this also
			-- determines the snap point to snap to when stacking
			WhitelistedSnapPoints: { string }?, -- Snap points that can be used to stack
		},
	},
} | {
	Allowed: false,
} | nil

export type Orientation = {
	Strict: false,
} | {
	Strict: true,
	SnapPointsToMatch: { { [string]: string } }, -- Keys are snap points of the base model, values are snap points of the model to stack
}

export type Road = Structure & {
	Properties: {
		Speed: number,
		Capacity: number,
	},
}

export type Industrial = Structure & {
	Properties: {
		ProductionRate: number,
		ProductionCapacity: number,
		ProductionCost: number,
		ProductionTime: number,
	},
}

export type Residence = Structure & {
	Properties: {
		MaxResidents: number,
		Population: number,
		PopulationCapacity: number,
		PopulationGrowthRate: number,
		PopulationGrowthTime: number,
	},
}

export type Commercial = Structure & {}

local Structures: StructuresCollection = {
	Road = {
		["Normal Road"] = {
			Name = "Normal Road",
			Id = "Road/Normal Road",
			Description = "A normal road",
			Price = 100,
			Model = Road["Normal Road"],
			BuildTime = 1,
			FullArea = true,

			Properties = {
				Speed = 1,
				Capacity = 1,
			},

			Stacking = {
				Allowed = true,
				AllowedModels = {

					["Road/Test"] = {
						Orientation = {
							Strict = true,
							SnapPointsToMatch = {
								{
									["Center"] = "Bottom1",
									["Top1"] = "Bottom2",
								},
								{
									["Center"] = "Bottom1",
									["Top2"] = "Bottom2",
								},
							},
						},

						WhitelistedSnapPoints = {
							"Top1",
							"Top2",
						},

						RequiredSnapPoints = {
							"Top1",
							"Top2",
						},

						OccupiedSnapPoints = {
							["Top1"] = "Top1", -- If mouse is near Top1, snap to Center
							["Top2"] = "Top2", -- If mouse is near Top2, snap to Center
						},
					},

					["Road/Streetlight"] = {
						Orientation = {
							Strict = false,
						},

						WhitelistedSnapPoints = {
							"Top1",
							"Top2",
						},

						RequiredSnapPoints = {
							"Top1",
							"Top2",
						},

						OccupiedSnapPoints = {
							["Top1"] = "Top1", -- If mouse is near Top1, snap to Center
							["Top2"] = "Top2", -- If mouse is near Top2, snap to Center
						},
					},

					["Road/Elevated Normal Road"] = {
						Orientation = {
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
						},

						WhitelistedSnapPoints = {
							"Top1",
							"Top2",
						},

						RequiredSnapPoints = {
							"Top1",
							"Top2",
						},
						OccupiedSnapPoints = {
							["Top1"] = "Center", -- If mouse is near Top1, snap to Center
							["Top2"] = "Center", -- If mouse is near Top2, snap to Center
							["Center"] = "Center",
						},
					},
				},
			},
		},

		["Elevated Normal Road"] = {
			Name = "Elevated Normal Road",
			Id = "Road/Elevated Normal Road",
			Description = "A normal elevated road",
			Price = 100,
			Model = Road["Elevated Normal Road"],
			BuildTime = 1,
			FullArea = true,

			Properties = {
				Speed = 1,
				Capacity = 1,
			},

			Stacking = {
				Allowed = true,
				AllowedModels = {

					["Road/Streetlight"] = {
						Orientation = {
							Strict = false,
						},

						WhitelistedSnapPoints = {
							"Top1",
							"Top2",
						},

						RequiredSnapPoints = {
							"Top1",
							"Top2",
						},
						OccupiedSnapPoints = {
							["Top1"] = "Top1", -- If mouse is near Top1, snap to Center
							["Top2"] = "Top2", -- If mouse is near Top2, snap to Center
						},
					},

					["Road/Test"] = {
						Orientation = {
							Strict = true,
							SnapPointsToMatch = {
								{
									["Center"] = "Bottom1",
									["Top1"] = "Bottom2",
								},
								{
									["Center"] = "Bottom1",
									["Top2"] = "Bottom2",
								},
							},
						},

						WhitelistedSnapPoints = {
							"Top1",
							"Top2",
						},

						RequiredSnapPoints = {
							"Top1",
							"Top2",
						},

						OccupiedSnapPoints = {
							["Top1"] = "Top1", -- If mouse is near Top1, snap to Center
							["Top2"] = "Top2", -- If mouse is near Top2, snap to Center
						},
					},
				},
			},
		},

		["Streetlight"] = {
			Name = "Streetlight",
			Id = "Road/Streetlight",
			Description = "A normal streetlight",
			Price = 100,
			Model = Road["Streetlight"],
			BuildTime = 1,
			FullArea = false,

			Properties = {
				Speed = 1,
				Capacity = 1,
			},

			Stacking = {
				Allowed = false,
			},
		},

		["Test"] = {
			Name = "Test",
			Id = "Road/Test",
			Description = "A normal test",
			Price = 100,
			Model = Road["Test"],
			BuildTime = 1,
			FullArea = false,

			Properties = {
				Speed = 1,
				Capacity = 1,
			},

			Stacking = {
				Allowed = false,
			},
		},
	},
} :: StructuresCollection

return Structures
