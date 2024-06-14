local RS = game:GetService("ReplicatedStorage")

local StackingUtils = require(RS.Shared.Structures.Utils.Stacking)
local StructureTypes = require(script.Parent.Parent.Types)
local TableUtil = require(RS.Packages.TableUtil)

local StructureFolder = RS.Structures
local IndustrialFolder: Folder = StructureFolder.Industrial

local SharedProperties = {
	Category = "Industrial",
	BuildTime = 0,
	FullArea = true,
	Stacking = {
		Allowed = false,
	},
	Price = 100,
	IsBuilding = true,

	Properties = {
		Radius = 1, -- Tiles
	},
}

local Industrials: StructureTypes.IndustrialCollection = {
	["Water Tower"] = TableUtil.Reconcile({
		Name = "Water Tower",
		Id = "Industrial/Water Tower",
		Description = "A normal road",
		Model = IndustrialFolder["Water Tower"],
	}, SharedProperties),
}

return Industrials
