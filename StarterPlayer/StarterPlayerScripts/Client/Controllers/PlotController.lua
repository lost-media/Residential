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

---@type Promise
local Promise = require(LMEngine.SharedDir.Promise)
type Promise = typeof(Promise.new())

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

	local plotAssigned: RBXScriptConnection

	plotAssigned = PlotService.PlotAssigned:Connect(function(plot)
		print("[PlotController] Plot assigned")
		self._plot = plot

		self.OnPlotAssigned:Fire(plot)

		-- Disconnect the event
		plotAssigned:Disconnect()
	end)
end

function PlotController:GetPlotAsync(): Promise
	return Promise.new(function(resolve)
		if self._plot ~= nil then
			resolve(self._plot)
		else
			self.OnPlotAssigned:Connect(function(plot)
				resolve(plot)
			end)
		end
	end)
end

return PlotController
