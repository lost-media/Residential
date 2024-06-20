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

---@type PlacementClient
local PlacementClient = LMEngine.GetModule("PlacementClient")

---@type Signal
local Signal = LMEngine.GetShared("Signal")

local PlacementController = LMEngine.CreateController({
	Name = "PlacementController",

	_placement_client = nil,
})

----- Public functions -----

function PlacementController:Init()
	print("[PlacementController] initialized")
end

function PlacementController:Start()
	print("[PlacementController] started")

	---@type PlotController
	local PlotController = LMEngine.GetController("PlotController")

	local plot = PlotController:WaitForPlot()

	self._placement_client = PlacementClient.new(plot)

	---@type InputController
	local InputController = LMEngine.GetController("InputController")

	InputController:RegisterInputBegan("PlacementController", function(input)
		if input.KeyCode == Enum.KeyCode.E then
			if self._placement_client:IsPlacing() == true then
				self._placement_client:CancelPlacement()
				return
			end

			self:StartPlacement("Old Watertower")
		end
	end)
end

function PlacementController:StartPlacement(structureId: string)
	-- fetch the structure from the structures list
	if self._placement_client == nil then
		self._placement_client = PlacementClient.new()
	end

	if self._placement_client:IsActive() == false then
		self._placement_client = PlacementClient.new()
	end

	-- for now, clone the structure from the workspace
	local structure = workspace:WaitForChild(structureId):Clone()
	structure.Parent = workspace

	self._placement_client:InitiatePlacement(structure)
end

return PlacementController
