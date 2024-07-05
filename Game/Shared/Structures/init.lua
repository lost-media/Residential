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

local StructureTypes = require(script.Types)

local StructureCategoryFolder = script.Category

local StructuresFolder = RS.Structures
local Road: Folder = StructuresFolder.Road
local Industrial: Folder = StructuresFolder.Industrial
local Residence: Folder = StructuresFolder.Residence
local Commercial: Folder = StructuresFolder.Commercial

local CityHallCategory = require(StructureCategoryFolder.CityHall)
local DecorationsCategory = require(StructureCategoryFolder.Decorations)
local IndustrialCategory = require(StructureCategoryFolder.Industrial)
local ResidenceCategory = require(StructureCategoryFolder.Residence)
local RoadCategory = require(StructureCategoryFolder.Road)

local Structures: StructureTypes.StructureCollection = {
	["Residence"] = ResidenceCategory,
	["Roads"] = RoadCategory,
	["Utility"] = IndustrialCategory,
	["City Hall"] = CityHallCategory,
	["Decorations"] = DecorationsCategory,
} :: StructureTypes.StructureCollection

return Structures
