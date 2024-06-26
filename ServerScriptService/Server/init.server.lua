--!strict
---@type LMEngineServer
local LMEngine = require(game:GetService("ReplicatedStorage").LMEngine)

local dir_Modules = script.Modules
local dir_Services = script.Services

LMEngine.LoadModulesFromParent(dir_Modules)
LMEngine.AddServices(dir_Services)

local start_time = tick()
LMEngine.Start()
	:andThen(function()
		print("[LM Engine] Server Engine started in", string.format("%.2fms", (tick() - start_time) * 100))
	end)
	:catch(function(err)
		warn("[LM Engine] Engine failed to start", err)
	end)
