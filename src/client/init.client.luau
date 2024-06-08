local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

Knit.AddControllers(script.Controllers)

Knit.Start()
	:andThen(function()
		print("Client started")
	end)
	:catch(function(err)
		warn("Client failed to start:", err)
	end)
