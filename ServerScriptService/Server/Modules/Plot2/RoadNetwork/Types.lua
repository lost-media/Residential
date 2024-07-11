local LMEngine = require(game:GetService("ReplicatedStorage").LMEngine)

local Graph = require(LMEngine.SharedDir.DS.Graph)
local Signal = require(LMEngine.SharedDir.Signal)

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
	_allBuildingsConnected: boolean,
	_buildings: { Instance },
	_buildingRoadPairs: { [Instance]: Instance },

	RoadConnected: Signal.Signal,
	BuildingConnected: Signal.Signal,
	AllBuildingsConnected: Signal.Signal,
}

export type RoadNetwork = typeof(setmetatable({} :: RoadNetworkMembers, {} :: IRoadNetwork))

return RoadNetworkTypes
