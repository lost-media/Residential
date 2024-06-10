local PlacementState = {}

export type PlacementState = {
	isPlacing: boolean,
	canConfirmPlacement: boolean,

	structureId: string?,
	ghostStructure: Model?,
	tile: BasePart?,

	rotation: number,
	level: number,

	mountedAttachment: Attachment,
	attachments: { Attachment },
	stackedStructure: Model,

	isStacked: boolean,
}

return PlacementState
