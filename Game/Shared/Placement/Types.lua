export type ClientPlacementType = "Place" | "Move" | "Destroy"

export type ClientState = {
	_tile: BasePart?,
	_placement_type: ClientPlacementType,
	_ghost_structure: Model?,
	_can_confirm_placement: boolean,
	_rotation: number,
	_is_stacked: boolean,
	_level: number,
}

export type ServerState = {
	_tile: BasePart?,
	_structure_id: string,
	_level: number,
	_rotation: number,
	_is_stacked: boolean,
}

return {}
