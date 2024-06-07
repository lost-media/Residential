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
};

export type Stacked = {
    Allowed: true,
    SnapPoints: {
        [string]: {string},
    },
    AllowedModels: {
        [string]: {
            MaxStack: number,
            OrientationStrict: boolean,
            RequiredSnapPoints: {string}, -- Snap points required to stack
            OccupiedSnapPoints: {string}, -- Snap points occupied by the structure
        },
    },
} | {
    Allowed: false,
} | nil

export type Road = Structure & {
    Properties: {
        Speed: number,
        Capacity: number,
    }
}

export type Industrial = Structure & {
    Properties : {
        ProductionRate: number,
        ProductionCapacity: number,
        ProductionCost: number,
        ProductionTime: number,
    }
}

export type Residence = Structure & {
    Properties: {
        MaxResidents: number,
        Population: number,
        PopulationCapacity: number,
        PopulationGrowthRate: number,
        PopulationGrowthTime: number,
    }
}

export type Commercial = Structure & {

}

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
                    ["Road/Normal Road"] = {
                        MaxStack = 3,
                        OrientationStrict = false,
                        RequiredSnapPoints = {
                            "Top1",
                            "Top2"
                        },
                        OccupiedSnapPoints = {
                            "Top1",
                            "Top2"
                        }
                    }
                }
            }
        }
    }
} :: StructuresCollection

return Structures