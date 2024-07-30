local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LMEngine = require(ReplicatedStorage.LMEngine)

local Currency = require(LMEngine.Game.Currency)
type Currency = Currency.Currency

export type Structure = {
	name: string,
	description: string,
	id: string,
	model: Model,
	viewportZoomScale: number?,

	price: {
		value: number,
		currency: Currency,
	},
}

export type StructureCategory = {
	layoutOrder: number,
	verboseName: string,
	verboseNamePlural: string,
	description: string,
	icon: string,

	structures: { Structure },

	folder: Folder,
}

return {}
