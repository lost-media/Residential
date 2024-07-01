--!strict

--[[
{Lost Media}

-[PlotController] Controller
    A controller that listens for the PlotAssigned event from the PlotService and assigns the plot to the PlotController.
	The PlotController is then used to get the plot assigned to the player.
--]]

local SETTINGS = {}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)

---@type Signal
local Signal = LMEngine.GetShared("Signal")

---@class PlotController
local PlotController = LMEngine.CreateController({
	Name = "PlotController",

	_plot = nil,

	---@type Signal
	OnPlotAssigned = Signal.new(),
})

----- Public functions -----

function PlotController:Start()
	local PlotService = LMEngine.GetService("PlotService")

	local PlotAssigned: RBXScriptConnection

	PlotAssigned = PlotService.PlotAssigned:Connect(function(plot)
		print("[PlotController] Plot assigned")
		self._plot = plot

		self.OnPlotAssigned:Fire(plot)

		-- Disconnect the event
		PlotAssigned:Disconnect()
	end)
end

function PlotController:GetPlot(): Model
	return self._plot
end

function PlotController:WaitForPlot(): Model
	if self.Plot ~= nil then
		return self._plot
	end

	return self.OnPlotAssigned:Wait()
end

return PlotController
