return {
	Id = "Tutorial",
	Name = "Welcome to Your New City!",
	Quests = {
		[1] = {
			Narrative = {
				'Welcome, <font color="rgb(50, 150, 150)"><b>Mayor</b></font>! Let\'s start building your city. First, we need to establish a central hub.',
				'The <font color="rgb(191, 124, 49)"><b>City Hall</b></font> is the central hub of your city. It provides a foundation for your city\'s growth.',
				"You can access the City Hall's menu by clicking the 'hammer' icon on the bottom of the screen.",
			},
			Objective = "Build a City Hall",
			Hint = "Select the Town Hall from the building menu and place it on your plot.",
			CanSkip = false,
			Action = {
				Type = "BuildStructure",
				StructureId = "City Hall",
				Amount = 1,

				Accumulative = true, -- If the quest should check if they already did the action before
				-- e.g. if they already built a city hall before
			},

			Rewards = {
				{
					Structures = {},
					Credits = 50,
					Roadbucks = 5,
				},
			},
		},

		[2] = {
			Narrative = {
				"Great job! Now let's connect our city with roads.",
			},
			Objective = "Build a road connected to the City Hall.",
			Hint = "Select the road tool from the menu and drag a road from the Town Hall to create a connected path.",
			CanSkip = false,
			Action = {
				Type = "BuildStructure",
				StructureId = "Road/Normal",
				Amount = 1,

				Accumulative = false, -- If the quest should check if they already did the action before
				-- e.g. if they already built a city hall before
			},

			AdditionalComments = {
				--	"Roads connect buildings and allow residents to travel.",
				--	"Make sure to connect all buildings to the City Hall to ensure your buildings are accessible.",
				--	"Buildings that are not connected to the City Hall will not be powered.",
			},

			Rewards = {
				{
					Structures = {},
					Credits = 50,
					Roadbucks = 5,
				},
			},
		},

		[3] = {
			Narrative = { "Time to bring in residents! Let's build some houses." },
			Objective = "Construct a house along the road.",
			Hint = "Select a house from the residential buildings menu and place it adjacent to the road's sidewalk.",
			CanSkip = false,
			Action = {
				Type = "BuildStructure",
				StructureId = "Residence/Victorian House 2",
				Amount = 1,

				Accumulative = false, -- If the quest should check if they already did the action before
				-- e.g. if they already built a city hall before
			},

			AdditionalComments = {
				--	"Residential buildings provide housing for your residents.",
				--	"They require power to function, so make sure they are connected to the City Hall.",
				--	"Residential buildings generate taxes based on the number of residents living in them.",
			},

			Rewards = {
				{
					Structures = {},
					Credits = 50,
					Roadbucks = 5,
				},
			},
		},

		[4] = {
			Narrative = { "Residents need basic utilities. Let's provide them with water." },
			Objective = "Build a water tower.",
			Hint = "Select the water tower from the utility services menu and place it within range of your house.",
			CanSkip = false,
			Action = {
				Type = "BuildStructure",
				StructureId = "Utilities/Water Tower",
				Amount = 1,

				Accumulative = false, -- If the quest should check if they already did the action before
				-- e.g. if they already built a city hall before
			},

			Rewards = {
				{
					Structures = {},
					Credits = 50,
					Roadbucks = 5,
				},
			},
		},

		[5] = {
			Narrative = {
				"<b>YOUCH!</b> I just stubbed my toe! We need a service to help with that.",
			},
			Objective = "Place a hospital.",
			Hint = "Select a hospital from the services menu and place it on your plot.",
			CanSkip = false,
			Action = {
				Type = "BuildStructure",
				StructureId = "Services/Hospital",
				Amount = 1,

				Accumulative = false, -- If the quest should check if they already did the action before
				-- e.g. if they already built a city hall before
			},

			AdditionalComments = {
				--	"Services like hospitals provide happiness to your residents.",
				--	"Without them, residents may become unhappy and leave your city.",
				--	"Make sure to place services near residential areas for maximum effect.",
			},

			Rewards = {
				{
					Structures = {},
					Credits = 50,
					Roadbucks = 5,
				},
			},
		},

		[6] = {
			Narrative = {
				"We spent a lot of credits! Let's earn some back by building businesses.",
			},
			Objective = "Place a grocery store.",
			Hint = "Select a business from the businesses menu and place it on your plot.",
			CanSkip = false,
			Action = {
				Type = "BuildStructure",
				StructureId = "Business/Grocery Store",
				Amount = 1,

				Accumulative = false, -- If the quest should check if they already did the action before
				-- e.g. if they already built a city hall before
			},

			Rewards = {
				{
					Structures = {},
					Credits = 50,
					Roadbucks = 5,
				},
			},
		},

		[7] = {
			Type = "Quest",
			Narrative = { "Great job! Now let's connect our city with roads." },
			Objective = "Connect all buildings with roads.",
			Hint = "Each building should be connected to the road network that leads to the City Hall.",
			CanSkip = false,
			Action = {
				Type = "ConnectAllBuildings",
				Amount = 1, -- Amount of times the signal should fire in order to complete the quest
				Accumulative = true,
			},

			Rewards = {
				{
					Structures = {},
					Credits = 50,
					Roadbucks = 5,
				},
			},
		},
	},

	EndingDialog = {
		"Congratulations on completing the tutorial! You're now ready to build your dream city.",
		"Remember, the success of your city depends on the happiness of your residents. Keep them happy and your city will thrive.",
		"Good luck, Mayor!",
	},

	Rewards = {
		Credits = 100,
		Roadbucks = 10,
	},
}
