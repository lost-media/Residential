local LMEngine = require(game:GetService("ReplicatedStorage").LMEngine)

local Graph = require(LMEngine.SharedDir.DS.Graph)

local PlotTypes = script.Parent.Parent.Types
type Plot = PlotTypes.Plot

local RoadNetworkTypes = {}

export type IRoadNetwork = {
	__index: IRoadNetwork,
	new: (plot: Plot) -> RoadNetwork,

	GetPlot: (self: RoadNetwork) -> Plot,
	AddRoad: (self: RoadNetwork, road: Instance) -> nil,
	GetRoads: (self: RoadNetwork) -> { Instance },
}

export type RoadNetworkMembers = {
	_plot: Plot,
	_graph: Graph.Graph,
}

export type RoadNetwork = typeof(setmetatable({} :: RoadNetworkMembers, {} :: IRoadNetwork))

return RoadNetworkTypes
