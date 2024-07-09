----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dir_Structures = ReplicatedStorage.Game.Shared.Structures
local dir_Utils = dir_Structures.Utils

local TableUtil = require(dir_Utils.TableUtil)

local StructureTypes = require(script.Parent.Parent.Types)

local StructureFolder: Folder = ReplicatedStorage.Structures
local CityHallFolder: Folder = StructureFolder["City Hall"]

local SharedProperties = {
	Category = "City Hall",
	BuildTime = 30,
	FullArea = true,
	IsABuilding = true,
	Stacking = {
		Allowed = false,
	},
	Price = 100,
	GridUnit = 4,
	AerialViewAngle = 45,

	FrontSurface = Enum.NormalId.Front, -- The "doors" of the house. there can be multiple doors
}

local CityHalls: StructureTypes.CityHallCollection = {
	TableUtil.Reconcile({
		Name = "City Hall",
		UID = 0,
		Id = "City Hall",
		Description = "A city hall",
		Model = CityHallFolder["City Hall"],
	}, SharedProperties),
}

return CityHalls
