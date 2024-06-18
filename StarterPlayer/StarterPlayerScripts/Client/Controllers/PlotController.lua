--!strict
--!version: 1.0.0

--[[
{Lost Media}

-[PlotController] Controller
    A controller that listens for the PlotAssigned event from the PlotService and assigns the plot to the PlotController.
	The PlotController is then used to get the plot assigned to the player.
--]]


local SETTINGS = {

};

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine);

---@type Signal
local Signal = LMEngine.GetShared("Signal");

local PlotController = LMEngine.CreateController({
	Name = "PlotController",
	Plot = nil,

	OnPlotAssigned = Signal.new(),
})

----- Public functions -----

function PlotController:Init()
	print("[PlotController] initialized")
end

function PlotController:Start()
	print("[PlotController] started")

	local PlotService = LMEngine.GetService("PlotService");

	for i = 1, 100 do
		---@type Promise
		local test = PlotService:Test();
		test:andThen(function()
			print("[PlotController] Test signal received")
		end):catch(function(err)
			warn("[PlotController] Error: " .. err)
		end)
	end
	
	PlotService.PlotAssigned:Connect(function(plot)
		print("[PlotController] Plot assigned")
		self.Plot = plot

		self.OnPlotAssigned:Fire(plot)
	end)
end

function PlotController:GetPlot()
	return self.Plot
end

return PlotController
