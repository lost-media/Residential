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

---@type LMEngineServer
local LMEngine = require(ReplicatedStorage.LMEngine)

local dir_Structures = ReplicatedStorage.Game.Shared.Structures

local Structures2 = require(LMEngine.Game.Shared.Structures2)

local PlotConfigs = require(LMEngine.Game.Shared.Configs.Plot)

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
	for _, structures in Structures2.Structures do
		for _, structure in structures.structures do
			local model = structure.model

			WeldLib.WeldModelToPrimaryPart(model)
			model:SetAttribute(PlotConfigs.STRUCTURE_ID_ATTRIBUTE_KEY, structure.Id)

			-- the hitboxes don't need to collide with the player
			if model.PrimaryPart ~= nil then
				model.PrimaryPart.CanCollide = false
			end
		end
	end
end

return StructureService
