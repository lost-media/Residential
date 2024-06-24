local StructureTypes = {}

export type StructureCollection = {
	Road: RoadCollection,
	Industrial: IndustrialCollection,
	Residence: ResidenceCollection,
	Commercial: CommercialCollection,
}

export type RoadCollection = {
	[string]: Road,
}

export type IndustrialCollection = {
	[string]: Industrial,
}

export type ResidenceCollection = {
	[string]: Residence,
}

export type CommercialCollection = {
	[string]: Commercial,
}

export type Structure = {
	Category: "Road" | "Industrial" | "Residence" | "Commercial",
	Name: string,
	Id: string,
	Description: string,
	Price: number,
	Model: Model,
	BuildTime: number,
	FullArea: boolean, -- If the structure occupies the whole area of the tile

	Stacking: Stacked?,
	GridUnit: number,

	Properties: {
		[string]: any,
	},
}

export type Stacked = {
	Allowed: true,
	SnapPoints: {
		[string]: { string },
	},
	AllowedModels: {
		[string]: {
			IncreaseLevel: boolean?,
			MaxStack: number,
			Orientation: Orientation,
			RequiredSnapPoints: { string }, -- Snap points required to stack
			OccupiedSnapPoints: { string }, -- Snap points occupied by the structure, this also
			-- determines the snap point to snap to when stacking
			WhitelistedSnapPoints: { string }?, -- Snap points that can be used to stack
		},
	},
} | {
	Allowed: false,
} | nil

export type Orientation = {
	Strict: false,
} | {
	Strict: true,
	SnapPointsToMatch: { { [string]: string } }, -- Keys are snap points of the base model, values are snap points of the model to stack
}

export type Road = Structure & {
	Properties: {
		Speed: number,
		Capacity: number,
	},
}

export type Industrial = Structure & {
	Properties: {
		ProductionRate: number,
		ProductionCapacity: number,
		ProductionCost: number,
		ProductionTime: number,
	},
}

export type Residence = Structure & {
	Properties: {
		MaxResidents: number,
		Population: number,
		PopulationCapacity: number,
		PopulationGrowthRate: number,
		PopulationGrowthTime: number,
	},
}

export type Commercial = Structure & {}

return StructureTypes
