local LMEngine = require(game:GetService("ReplicatedStorage").LMEngine)

local PlotTypes = script.Parent.Parent.Types
type Plot = PlotTypes.Plot

local RoadNetworkTypes = {}

export type IRoadNetwork = {
	__index: IRoadNetwork,
	new: (plot: Plot) -> RoadNetwork,

	GetPlot: (self: RoadNetwork) -> Plot,
}

export type RoadNetworkMembers = {
	_plot: Plot,
}

export type RoadNetwork = typeof(setmetatable({} :: RoadNetworkMembers, {} :: IRoadNetwork))

return RoadNetworkTypes
