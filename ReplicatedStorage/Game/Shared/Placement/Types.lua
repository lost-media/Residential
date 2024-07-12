export type ClientPlacementType = "Place" | "Move" | "Destroy"

export type ClientState = {
	_tile: BasePart?,
	_placement_type: ClientPlacementType,
	_ghost_structure: Model?,
	_can_confirm_placement: boolean,
	_rotation: number,
	_is_stacked: boolean,
	_level: number,
	_attachments: { Attachment },
	_structure_id: string,

	_is_orientation_strict: boolean,
	_mounted_attachment: Attachment?,
	_stacked_structure: Model?,
}

export type ServerState = {
	_tile: BasePart?,
	_structure_id: string,
	_level: number,
	_rotation: number,

	_is_orientation_strict: boolean,
	_is_stacked: boolean,
	_attachments: { Attachment },
	_mounted_attachment: Attachment?,
	_stacked_structure: Model?,
}

return {}
