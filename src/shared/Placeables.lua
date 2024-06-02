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

Placeables.Index = {
    Residence = {
        House = {
            ["Starter House"] = {
                Name = "Starter House",
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
        },
        Apartment = {
            ["Starter Apartment"] = {
                Name = "Starter Apartment",
                Description = "A small apartment for beginners",
                Price = 2000,
                Model = Residence["Starter Apartment"],
                BuildTime = 10,

                Properties = {
                    MaxResidents = 4,
                }
            }
        }
    },

    Road = {
        ["Normal Road"] = {
            Name = "Normal Road",
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
            Description = "A curved road",
            Price = 100,
            Model = Roads["Curved Road"],
            BuildTime = 0,

            Properties = {
                Speed = 1,
                Capacity = 1,
            }
        },
    },

    Commercial = {
        Store = {
            ["Starter Store"] = {
                Name = "Starter Store",
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