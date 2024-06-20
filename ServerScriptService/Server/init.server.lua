--!strict
---@type LMEngineServer
local LMEngine = require(game:GetService("ReplicatedStorage").LMEngine)

local dir_Modules = script.Modules
local dir_Services = script.Services

LMEngine.LoadModulesFromParent(dir_Modules)
LMEngine.AddServices(dir_Services)

LMEngine.Start({
	PerServiceMiddleware = {
		{
			Service = "ReplicatedStorage",
			Middleware = {
				{
					Method = "GetChildren",
					Before = function()
						print("Before GetChildren")
					end,
					After = function()
						print("After GetChildren")
					end,
				},
			},
		},
	},
})
	:andThen(function()
		print("[LM Engine] Server started")
	end)
	:catch(function(err)
		warn("[LM Engine] Engine failed to start", err)
	end)
