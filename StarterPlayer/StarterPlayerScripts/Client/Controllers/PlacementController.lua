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

local DeleteStructure = require(LMEngine.Game.Shared.Placement.DeleteStructure)
local PlacementClient = require(LMEngine.Game.Shared.Placement.PlacementClient2)
---@type PlacementClient
--local PlacementClient = LMEngine.GetModule("PlacementClient")

---@type Signal
local Signal = LMEngine.GetShared("Signal")

---@type Trove
local Trove = LMEngine.GetShared("Trove")

local TroveObject = Trove.new()

local StructuresUtils = require(ReplicatedStorage.Game.Shared.Structures.Utils)

---@class PlacementController
local PlacementController = LMEngine.CreateController({
	Name = "PlacementController",

	_placement_client = nil,
	_delete_structure_client = nil,
	_structures_index = 1,

	_state = nil,

	-- Signals
	OnStructureDeleteDisabled = Signal.new(),
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
		self._delete_structure_client = DeleteStructure.new(plot)

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
	if self._state == "placing" then
		return
	end

	-- check if the player is in delete mode, if so, disable it
	if self._state == "deleting" then
		self:DisableDeleteMode()
	end

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

	self._state = "placing"

	self._placement_client:UpdateGridUnit(grid_unit)
	self._placement_client:InitiatePlacement(clone, settings)
end

function PlacementController:StopPlacement()
	if self._state ~= "placing" then
		return
	end
	if self._placement_client ~= nil then
		self._state = nil
		self._placement_client:CancelPlacement()
	end
end

function PlacementController:EnableDeleteMode()
	if self._placement_client ~= nil then
		if self._placement_client:IsPlacing() == true then
			self:StopPlacement()
		end
	end

	self._state = "deleting"

	self._delete_structure_client:Enable()

	local PlotService = LMEngine.GetService("PlotService")

	-- Listen for structure deletion
	self._delete_structure_client.OnStructureDeleted:Connect(function(structure)
		PlotService:DeleteStructure(structure)
		-- show toast message
	end)
end

function PlacementController:DisableDeleteMode()
	if self._state ~= "deleting" then
		return
	end

	self._state = nil

	self._delete_structure_client:Disable()

	self.OnStructureDeleteDisabled:Fire()
end

return PlacementController
