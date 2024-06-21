--!strict

--[[
{Lost Media}

-[StructureService] Service
    Central service that manages the plots in the game.
	This service is responsible for assigning plots to players
	and serializing the plot data to the client.

	Members:

		StructureService._plots   [table] -- Player -> Plot
			Stores the mapping of players to plots

	Methods [StructureService]:

		StructureService:AssignPlot(player: Player, plot: Instance) -- Assigns a plot to a player
			player [Player]
			plot   [Instance]
--]]

local SETTINGS = {
	STRUCTURES = game:GetService("ReplicatedStorage").Structures :: Folder,
	MAX_RETRIES = 5,
}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dir_Structures = ReplicatedStorage.Game.Shared.Structures

local StructuresCollection = require(dir_Structures)

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine)

---@type WeldLib
local WeldLib = LMEngine.GetShared("Weld")

---@type RetryAsync
local RetryAsync = LMEngine.GetShared("RetryAsync")

---@class StructureService
local StructureService = LMEngine.CreateService({
	Name = "StructureService",
})

----- Private functions -----

----- Public functions -----

function StructureService:Init()
	print("[StructureService] initialized")

	for _, structures in StructuresCollection do
		for _, structure in pairs(structures) do
			WeldLib.WeldModelToPrimaryPart(structure.Model)
			structure.Model:SetAttribute("Id", structure.Id)
		end
	end
end

function StructureService:Start()
	print("[StructureService] started")
end

return StructureService
