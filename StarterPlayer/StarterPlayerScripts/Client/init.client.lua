--!strict
---@type LMEngineClient
local LMEngine = require(game:GetService("ReplicatedStorage").LMEngine)

local dir_Controllers = script.Controllers
local dir_Modules = script.Modules

LMEngine.LoadModulesFromParent(dir_Modules)

LMEngine.AddControllers(dir_Controllers)

local start_time = tick()
LMEngine.Start()
	:andThen(function()
		print("[LM Engine] Client Engine started in", string.format("%.2fms", (tick() - start_time) * 100))
	end)
	:catch(function(err)
		warn("[LM Engine] Engine failed to start", err)
	end)
