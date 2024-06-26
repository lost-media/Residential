local LMEngine = require(game:GetService("ReplicatedStorage").LMEngine)

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

	GetPlayer: (self: Plot) -> Player?,
	GetModel: (self: Plot) -> Instance,
	AssignPlayer: (self: Plot, player: Player) -> (),
	UnassignPlayer: (self: Plot) -> (),

	SetAttribute: (self: Plot, attribute: string, value: any) -> (),
	GetAttribute: (self: Plot, attribute: string) -> any,

	PlaceStructure: (self: Plot, structure: Model, cframe: CFrame) -> boolean,
	GetPlaceable: (self: Plot, model: Model) -> Model?,
	Serialize: (self: Plot) -> { [number]: SerializedStructure },
}

type PlotMembers = {
	_plot_model: Instance,
	_player: Player?,
	_trove: Trove.Trove,
}

export type Plot = typeof(setmetatable({} :: PlotMembers, {} :: IPlot))

export type SerializedStructure = {
	CFrame: { number },
}

return PlotTypes
