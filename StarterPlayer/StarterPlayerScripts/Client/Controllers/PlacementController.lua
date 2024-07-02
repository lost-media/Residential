--!strict

--[[
{Lost Media}

-[PlacementController] Controller
    A controller that listens for the PlotAssigned event from the PlotService and assigns the plot to the PlacementController.
	The PlotController is then used to get the plot assigned to the player.
--]]

local SETTINGS = {}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)

local PlacementClient = require(LMEngine.Game.Shared.Placement.PlacementClient2)
---@type PlacementClient
--local PlacementClient = LMEngine.GetModule("PlacementClient")

---@type Signal
local Signal = LMEngine.GetShared("Signal")

---@type Trove
local Trove = LMEngine.GetShared("Trove")

local TroveObject = Trove.new()

local StructuresUtils = require(ReplicatedStorage.Game.Shared.Structures.Utils)

local PlacementController = LMEngine.CreateController({
	Name = "PlacementController",

	_placement_client = nil,
	_structures_index = 1,
})

local StructuresList = {
	"Road/Ramp",
	"City Hall",
	"Residence/Medieval House",
	"Industrial/Water Tower",
	"Road/Streetlight",
	"Road/T-Intersection",
	"Road/Dead End",
	"Road/Curved",
	"Road/Normal",
	"Road/Intersection",
}

----- Public functions -----

function PlacementController:Start()
	local PlotService = LMEngine.GetService("PlotService")

	---@type PlotController
	local PlotController = LMEngine.GetController("PlotController")
	---@type InputController
	local InputController = LMEngine.GetController("InputController")

	local plotPromise = PlotController:GetPlotAsync()

	plotPromise:andThen(function(plot)
		self._placement_client = PlacementClient.new(plot)

		self._placement_client.PlacementConfirmed:Connect(function(structure_id, cframe)
			---@type Promise
			local placement_promise = PlotService:PlaceStructure(structure_id, cframe)

			placement_promise
				:andThen(function(successful: boolean)
					if successful == false then
						-- Show toast message
						print("[PlacementController] Structure placement failed")
					end
				end)
				:catch(function(err)
					warn("[PlacementController] Failed to place structure: " .. err)
					-- TODO: Handle error, show toast message
				end)
		end)

		self._placement_client.DeleteStructure:Connect(function(structure: Model)
			PlotService:DeleteStructure(structure)
		end)
	end)

	InputController:RegisterInputBegan("PlacementController", function(input, gameProcessed)
		if gameProcessed == true then
			return
		end

		if self._placement_client == nil then
			return
		end

		if input.KeyCode == Enum.KeyCode.E then
			self._structures_index = self._structures_index + 1
			if self._structures_index > #StructuresList then
				self._structures_index = 1
			end
			self:StopPlacement()
			self:StartPlacement(StructuresList[self._structures_index])
		elseif input.KeyCode == Enum.KeyCode.Q then
			self._structures_index = self._structures_index - 1
			if self._structures_index < 1 then
				self._structures_index = #StructuresList
			end
			self:StopPlacement()
			self:StartPlacement(StructuresList[self._structures_index])
		end
	end)
end

function PlacementController:StartPlacement(structureId: string)
	local structure = StructuresUtils.GetStructureFromId(structureId)
	assert(structure ~= nil, "[PlacementController] StartPlacement: Structure not found")

	-- fetch the structure from the structures list
	if self._placement_client == nil then
		local PlotController = LMEngine.GetController("PlotController")
		local plot = PlotController:WaitForPlot()

		self._placement_client = PlacementClient.new(plot)
	end

	if self._placement_client:IsActive() == false then
		local PlotController = LMEngine.GetController("PlotController")
		local plot = PlotController:WaitForPlot()

		self._placement_client = PlacementClient.new(plot)
	end

	local clone = structure.Model:Clone()
	clone.Parent = workspace

	TroveObject:Add(clone)

	-- Get the GridUnit of the structure

	local settings = {}

	local grid_unit = structure.GridUnit

	-- get the stacking info of the structure
	local stacking = structure.Stacking.Allowed

	settings.can_stack = stacking

	local properties = structure.Properties

	if properties ~= nil and properties.Radius ~= nil then
		settings.radius = properties.Radius
	end

	self._placement_client:UpdateGridUnit(grid_unit)
	self._placement_client:InitiatePlacement(clone, settings)
end

function PlacementController:StopPlacement()
	if self._placement_client ~= nil then
		self._placement_client:CancelPlacement()
	end
end

return PlacementController
