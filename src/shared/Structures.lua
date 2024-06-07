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

export type StructuresCollection = {
    Road: {
        [string]: Road,
    },
    
}

export type Structure = {
    Name: string,
    Id: string,
    Description: string,
    Price: number,
    Model: Model,
    BuildTime: number,

    Stacking: Stacked?,

    Properties: {
        [string]: any,
    },
};

export type Stacked = {
    Allowed: boolean,
    SnapPoints: {
        [string]: {string},
    },
    AllowedModels: {
        [string]: {
            MaxStack: number,
            OrientationStrict: boolean,
        },
    },
}

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
        
    }
} :: StructuresCollection

return Structures