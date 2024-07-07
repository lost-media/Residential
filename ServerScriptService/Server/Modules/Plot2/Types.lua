local LMEngine = require(game:GetService("ReplicatedStorage").LMEngine)

local RoadNetworkTypes = require(script.Parent.RoadNetwork.Types)
local Trove = require(LMEngine.SharedDir.Trove)

local PlotTypes = {}

export type PlotModel = Model & {
	Tiles: Folder,
	Structures: Folder,
}

export type IPlot = {
	__index: IPlot,
	__tostring: (self: Plot) -> string,

	ModelIsPlot: (model: Instance) -> boolean,
	new: (plotModel: Instance) -> Plot,

	GetUUID: (self: Plot) -> string,
	GetPlayer: (self: Plot) -> Player?,
	GetModel: (self: Plot) -> Instance,
	AssignPlayer: (self: Plot, player: Player) -> (),
	UnassignPlayer: (self: Plot) -> (),
	Clear: (self: Plot) -> (),

	SetAttribute: (self: Plot, attribute: string, value: any) -> (),
	GetAttribute: (self: Plot, attribute: string) -> any,

	GetBuildings: (self: Plot) -> { [number]: Model },
	GetRoads: (self: Plot) -> { [number]: Model },

	PlaceStructure: (self: Plot, structure: Model, cframe: CFrame) -> boolean,
	MoveStructure: (self: Plot, structure: Model, cframe: CFrame) -> boolean,

	GetPlaceable: (self: Plot, model: Model) -> Model?,
	Serialize: (self: Plot) -> { [number]: SerializedStructure },

	DeleteStructure: (self: Plot, structure: Model) -> (),
}

type PlotMembers = {
	_plot_model: Instance,
	_player: Player?,
	_trove: Trove.Trove,
	_road_network: RoadNetworkTypes.RoadNetwork,
	_plot_uuid: string?,
}

export type Plot = typeof(setmetatable({} :: PlotMembers, {} :: IPlot))

export type SerializedStructure = {
	CFrame: { number },
}

return PlotTypes
