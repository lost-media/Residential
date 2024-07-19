export type Structure = {
	name: string,
	description: string,
	id: string,
	model: Model,

	price: {
		value: number,
		currency: string,
	},
}

export type StructureCategory = {
	verboseName: string,
	verboseNamePlural: string,
	description: string,
	icon: string,

	structures: { Structure },
}

return {}
