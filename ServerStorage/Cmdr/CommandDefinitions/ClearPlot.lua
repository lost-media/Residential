-- ClearPlot.lua

return {
	Name = "clearplot",
	Aliases = { "cp" },
	Description = "Clears the plot of the specified player",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The players whose plot you want to clear",
		},
	},
}
