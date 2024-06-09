--!strict

local RS = game:GetService("ReplicatedStorage")

local Signal = require(RS.Packages.Signal)
local Knit = require(RS.Packages.Knit)
local PlotTypes = require(RS.Shared.Types.Plot)

local PlotController = Knit.CreateController({
	Name = "PlotController",
	Plot = nil,

	OnPlotAssigned = Signal.new(),
})

function PlotController:KnitInit()
	print("PlotController initialized")
end

function PlotController:KnitStart()
	print("PlotController started")

	local PlotService = Knit.GetService("PlotService")

	PlotService.PlotAssigned:Connect(function(plot: PlotTypes.Plot)
		print("PlotController: Plot assigned")
		self.Plot = plot

		self.OnPlotAssigned:Fire(plot)
	end)
end

function PlotController:GetPlot()
	return self.Plot
end

return PlotController
