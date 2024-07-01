-- ClearPlot.lua

return {
	Name = "jumppower",
	Aliases = { "jp" },
	Description = "Sets the jump power of the specified player",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player whose jump power you want to set",
		},
		{
			Type = "number",
			Name = "power",
			Description = "The power of the jump",
		},
	},
}
