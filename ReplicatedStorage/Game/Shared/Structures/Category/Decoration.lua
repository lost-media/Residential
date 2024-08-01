----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dir_Structures = ReplicatedStorage.Game.Shared.Structures
local dir_Utils = dir_Structures.Utils

local TableUtil = require(dir_Utils.TableUtil)

local StructureTypes = require(script.Parent.Parent.Types)

local StructureFolder: Folder = ReplicatedStorage.Structures
local DecorationsFolder: Folder = StructureFolder.Decorations

local SharedProperties = {
	Category = "Decoration",
	BuildTime = 0,
	IsABuilding = false,
	Stacking = {
		Allowed = false,
	},
	Price = 100,
	GridUnit = 4,
	AerialViewAngle = 0,
}

local Industrials: StructureTypes.IndustrialCollection = {
	TableUtil.Reconcile({
		Name = "Streetlamp",
		UID = 0,
		Id = "Decoration/Streetlamp",
		Description = "A normal streetlamp",
		Model = DecorationsFolder["Streetlamp"],

		GridUnit = 1,
		Stacking = {
			Allowed = true,
		},
	}, SharedProperties),
}

return Industrials
