--!strict

--[[

    For now, there are 4 types of Placeables:
    - Industrial
    - Residence
    - Commercial
    - Road
    
    Each type of Placeable has a different set of properties, such as:
    - Industrial: Production rate, production capacity, production cost, production time
    - Residence: Population, population capacity, population growth rate, population growth time
    - Commercial: Revenue, revenue capacity, revenue growth rate, revenue growth time
    - Road: Cost, speed, capacity

    BuildTime is in minutes
--]]

local Placeables = {}

local RS = game:GetService("ReplicatedStorage");
local PlaceablesFolder: Folder = RS.Placeables;

local Roads = PlaceablesFolder.Road;
local Residence = PlaceablesFolder.Residence;
local Commercial = PlaceablesFolder.Commercial;
local Industrial = PlaceablesFolder.Industrial;

function Placeables.GetPlaceableFromId(id: string)
    -- Valid ID is "Residence/House/Starter House" or "Road/Normal Road" etc.

    -- Split the ID into parts
    local parts = string.split(id, "/");

    local placeable = Placeables.Index;

    for i, part in ipairs(parts) do
        placeable = placeable[part];

        if (placeable == nil) then
            warn("Invalid placeable ID: " .. id);
            return nil;
        end
    end

    return placeable;
end

function Placeables.GetPlaceableFromInstance(instance: Instance) : any
    -- recursively search for the instance in the Index

    local function searchForInstance(index: any, instance: Instance)
        for key, value in pairs(index) do
            if (value.Model == instance) then
                return value;
            end

            if (type(value) == "table") then
                local result = searchForInstance(value, instance);
                if (result) then
                    return result;
                end
            end
        end

        return nil;
    end

    return searchForInstance(Placeables.Index, instance);
end

Placeables.Index = {
    Residence = {
        House = {
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
        }
    },

    Road = {
        ["Normal Road"] = {
            Name = "Normal Road",
            Id = "Road/Normal Road",
            Description = "A normal road",
            Price = 100,
            Model = Roads["Normal Road"],
            BuildTime = 0,

            Properties = {
                Speed = 1,
                Capacity = 1,
            }
        },

        ["Curved Road"] = {
            Name = "Curved Road",
            Id = "Road/Curved Road",
            Description = "A curved road",
            Price = 100,
            Model = Roads["Curved Road"],
            BuildTime = 0,

            Properties = {
                Speed = 1,
                Capacity = 1,
            }
        },
        ["Elevated Road"] = {
            Name = "Elevated Road",
            Id = "Road/Elevated Road",
            Description = "An elevated road",
            Price = 100,
            Model = Roads["Elevated Road"],
            BuildTime = 0,

            Properties = {
                Speed = 1,
                Capacity = 1,
            },

            Stacking = {
                Allowed = true,
                AllowedModels = {
                    ["Road/Elevated Road"] = {
                        MaxStack = 3,
                        OrientationStrict = false,
                        SnapPoints = {
                            "TopSnap1",
                            "TopSnap2",
                        },
                        SnapPointsTaken = {
                            "TopSnap1",
                            "TopSnap2",
                        },
                        MountingPoint = "CentralSnapPoint"
                    },
                    ["Road/Streetlight"] = {
                        MaxStack = 3,
                        OrientationStrict = false,
                        SnapPoints = {
                            "TopSnap1",
                            "TopSnap2",
                        },
                    }
                }
            }
        },

        ["Streetlight"] = {
            Name = "Streetlight",
            Id = "Road/Streetlight",
            Description = "A streetlight",
            Price = 100,
            Model = Roads["Streetlight"],
            BuildTime = 0,

            Properties = {
                Speed = 1,
                Capacity = 1,
            },

            Stacking = {
                Allowed = true,
                AllowedModels = {
                    ["Road/Elevated Road"] = {
                        MaxStack = 3,
                        OrientationStrict = false,
                        SnapPoints = {
                            "CentralSnapPoint"
                        }
                    }
                }
            }
        },
    },

    Commercial = {
        Store = {
            ["Starter Store"] = {
                Name = "Starter Store",
                Id = "Commercial/Store/Starter Store",
                Description = "A small store for beginners",
                Price = 1000,
                Model = Commercial["Starter Store"],
                BuildTime = 5,

                Properties = {
                    MaxCustomers = 5,
                    RevenuePerCustomer = 1,
                }
            }
        }
    },

    Industrial = {
        Factory = {
            ["Starter Factory"] = {
                Name = "Starter Factory",
                Id = "Industrial/Factory/Starter Factory",
                Description = "A small factory for beginners",
                Price = 1000,
                Model = Industrial["Starter Factory"],
                BuildTime = 5,

                Properties = {
                    MaxWorkers = 5,
                    ProductionRate = 1,
                    ProductionCapacity = 10,
                    OutputPerMinute = 1,
                }
            }
        }
    },
    

}

return Placeables;