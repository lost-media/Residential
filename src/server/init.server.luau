local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

Knit.AddServices(script.Services)

Knit.Start()
	:andThen(function()
		print("Server started")

		local PlotService = Knit.GetService("PlotService")
		-- Set up onPlayerAdded and onPlayerRemoving events

		game.Players.PlayerAdded:Connect(function(player)
			PlotService:AssignPlot(player)
		end)

		game.Players.PlayerRemoving:Connect(function(player)
			local plot = player:GetAttribute("Plot")
			if plot then
				PlotService:RemovePlayerFromPlot(player)
			end
		end)
	end)
	:catch(function(err)
		warn("Server failed to start:", err)
	end)
