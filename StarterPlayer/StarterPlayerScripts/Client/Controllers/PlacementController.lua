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

	local ghost_structure = workspace:WaitForChild("Old Watertower"):Clone()
	ghost_structure.Parent = workspace

	self._placement_client:InitiatePlacement(ghost_structure)
end

return PlacementController
