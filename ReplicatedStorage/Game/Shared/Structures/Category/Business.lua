----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dir_Structures = ReplicatedStorage.Game.Shared.Structures
local dir_Utils = dir_Structures.Utils

local TableUtil = require(dir_Utils.TableUtil)

local StructureTypes = require(script.Parent.Parent.Types)

local StructureFolder: Folder = ReplicatedStorage.Structures
local BusinessesFolder: Folder = StructureFolder.Business

local SharedProperties = {
	Category = "Business",
	BuildTime = 0,
	IsABuilding = true,
	Stacking = {
		Allowed = false,
	},
	Price = 100,
	GridUnit = 4,
	AerialViewAngle = 0,
}

local Businesses: StructureTypes.IndustrialCollection = {
	TableUtil.Reconcile({
		Name = "Grocery Store",
		UID = 0,
		Id = "Business/Grocery Store",
		Description = "A normal grocery store",
		Model = BusinessesFolder["Grocery Store"],
	}, SharedProperties),
}

return Businesses
