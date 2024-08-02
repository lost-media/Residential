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
local MoveStructure = require(LMEngine.Game.Shared.Placement.MoveStructure)
local PlacementClient = require(LMEngine.Game.Shared.Placement.PlacementClient2)

---@type Signal
local Signal = LMEngine.GetShared("Signal")

---@type Trove
local Trove = LMEngine.GetShared("Trove")

local TroveObject = Trove.new()

local Structures2 = require(ReplicatedStorage.Game.Shared.Structures2)

---@class PlacementController
local PlacementController = LMEngine.CreateController({
	Name = "PlacementController",

	_placement_client = nil,
	_delete_structure_client = nil,
	_move_structure_client = nil,

	_state = nil,
	_isMoving = false,

	-- Signals
	PlacementBegan = Signal.new(),
	OnStructureDeleteEnabled = Signal.new(),
	OnStructureDeleteDisabled = Signal.new(),

	OnStructureMoveEnabled = Signal.new(),
	OnStructureMoveDisabled = Signal.new(),
})

----- Private functions -----

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
		self._move_structure_client = MoveStructure.new(plot)

		self._placement_client.PlacementConfirmed:Connect(function(structure_id, cframe)
			---@type Promise
			local placement_promise

			if self._isMoving == true then
				if self._movingStructure == nil then
					return
				end
				placement_promise = PlotService:MoveStructure(self._movingStructure, cframe)
			else
				placement_promise = PlotService:PlaceStructure(structure_id, cframe)
			end

			placement_promise
				:andThen(function(successful: boolean)
					if successful == false then
						-- Show toast message
						--print("[PlacementController] Structure placement failed")
					end

					if successful == true then
						if self._isMoving == true then
							-- set the moving structure's parent back to the plot
							self._movingStructure.Parent = plot.Structures
							self._movingStructure:PivotTo(cframe)

							self._movingStructure = nil
							self._movingStructureOriginalCFrame = nil

							self:StopPlacement()

							if self._openPlacementFrame == true then
								---@type FrameController
								local FrameController = LMEngine.GetController("FrameController")
								FrameController:OpenFrame("SelectionFrame")
							end
						end
					end
				end)
				:catch(function(err)
					warn("[PlacementController] Failed to place structure: " .. err)
					-- TODO: Handle error, show toast message
				end)
		end)

		self._placement_client.Cancelled:Connect(function()
			if self._openPlacementFrame == true and self._state ~= nil then
				---@type FrameController
				local FrameController = LMEngine.GetController("FrameController")

				FrameController:OpenFrame("SelectionFrame")
			end

			if
				self._isMoving == true
				and self._movingStructure ~= nil
				and self._movingStructureOriginalCFrame ~= nil
			then
				self._movingStructure.Parent = plot.Structures
				self._movingStructure:PivotTo(self._movingStructureOriginalCFrame)
				self._movingStructure = nil
				self._movingStructureOriginalCFrame = nil
			end

			self._state = nil
		end)
	end)

	---@type FrameController
	local FrameController = LMEngine.GetController("FrameController")

	FrameController.FrameOpened:Connect(function(name: string)
		if name == "SelectionFrame" then
			print("SelectionFrame opened")
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

	local structure = Structures2.Utils.getStructure(structureId)
	assert(structure ~= nil, "[PlacementController] StartPlacement: Structure not found")

	-- fetch the structure from the structures list
	if self._placement_client == nil then
		---@type PlotController
		local PlotController = LMEngine.GetController("PlotController")
		PlotController:GetPlotAsync():andThen(function(plot)
			self._placement_client = PlacementClient.new(plot)
		end)
	end

	if self._placement_client == nil then
		return
	end

	if self._placement_client:IsActive() == false then
		local PlotController = LMEngine.GetController("PlotController")
		local plot = PlotController:WaitForPlot()

		self._placement_client = PlacementClient.new(plot)
	end

	local clone = structure.model:Clone()

	self._isMoving = false

	self:StartMovement(clone)
end

function PlacementController:StartMovement(clone: Model)
	local structureId = clone:GetAttribute("Id")

	if structureId == nil then
		return
	end

	-- disable delete mode and move mode
	if self._state == "deleting" then
		self:DisableDeleteMode()
	end

	self:DisableMoveMode()

	local structure = Structures2.Utils.getStructure(structureId)

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

	if structure.IsABuilding == true then
		settings.frontSurface = structure.FrontSurface
	end

	self._state = "placing"

	self._placement_client:UpdateGridUnit(grid_unit)
	self._placement_client:InitiatePlacement(clone, settings)

	---@type FrameController
	local FrameController = LMEngine.GetController("FrameController")

	-- get the "SelectionFrame" UI open status
	local selectionFrameOpen = FrameController:IsFrameOpen("BuildModeFrame")

	if selectionFrameOpen == true then
		self._openPlacementFrame = true
	else
		self._openPlacementFrame = false
	end

	self.PlacementBegan:Fire()
end

function PlacementController:StopPlacement()
	if self._state ~= "placing" then
		return
	end
	if self._placement_client ~= nil then
		self._state = nil
		self._placement_client:CancelPlacement()
		self._isMoving = false
		self._movingStructure = nil
		self._movingStructureOriginalCFrame = nil
	end
end

function PlacementController:EnableDeleteMode()
	if self._placement_client ~= nil then
		if self._placement_client:IsPlacing() == true then
			self:StopPlacement()
		end
	end

	if self._delete_structure_client == nil then
		return
	end

	self._state = "deleting"

	self._delete_structure_client:Enable()

	self.OnStructureDeleteEnabled:Fire()

	local PlotService = LMEngine.GetService("PlotService")

	-- Listen for structure deletion
	self._delete_structure_client.OnStructureDeleted:Connect(function(structure)
		PlotService:DeleteStructure(structure)
		-- show toast message
	end)
end

function PlacementController:DisableDeleteMode()
	if self._delete_structure_client == nil then
		return
	end

	self._state = nil

	self._delete_structure_client:Disable()

	self.OnStructureDeleteDisabled:Fire()
end

function PlacementController:EnableMoveMode()
	if self._placement_client ~= nil then
		if self._placement_client:IsPlacing() == true then
			self:StopPlacement()
		end
	end

	if self._move_structure_client == nil then
		return
	end

	self._state = "moving"

	self._move_structure_client:Enable()

	self.OnStructureMoveEnabled:Fire()

	local PlotService = LMEngine.GetService("PlotService")

	-- Listen for structure deletion
	self._move_structure_client.OnStructureMoving:Connect(
		function(structure: Model, originalCFrame: CFrame)
			-- create a cloen of the model
			local clone = structure:Clone()

			-- set the original model's parent to nil to prevent it from being deleted
			structure.Parent = nil

			-- add the clone to the workspace
			clone.Parent = workspace

			-- get the structure's id
			local structure_id = structure:GetAttribute("Id")

			if structure_id == nil then
				return
			end

			self._isMoving = true

			self._movingStructure = structure
			self._movingStructureOriginalCFrame = originalCFrame

			self:StartMovement(clone)
		end
	)
end

function PlacementController:DisableMoveMode()
	if self._move_structure_client == nil then
		return
	end

	self._state = nil

	self._move_structure_client:Disable()

	self.OnStructureMoveDisabled:Fire()

	--self._isMoving = false
end

return PlacementController
