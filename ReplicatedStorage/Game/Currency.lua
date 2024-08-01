export type Currency = {
	verboseName: string,
	verboseNamePlural: string,
	icon: string,
}

local Currency = {}

Currency.kloins = {
	verboseName = "Kloins",
	verboseNamePlural = "Kloins",

	icon = "rbxassetid://18521714111",
} :: Currency

Currency.roadbucks = {
	verboseName = "Roadbucks",
	verboseNamePlural = "Roadbucks",

	icon = "rbxassetid://18491523583",
} :: Currency

return Currency
