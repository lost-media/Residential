local PlacementState = {}

export type PlacementState = {
	isPlacing: boolean,
	canConfirmPlacement: boolean,

	structureId: string?,
	ghostStructure: Model?,
	tile: BasePart?,

	rotation: number,
	level: number,

	-- Stacked properties
	isStacked: boolean,
}

return PlacementState
