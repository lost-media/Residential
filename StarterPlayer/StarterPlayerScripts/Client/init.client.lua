--!strict
---@type LMEngineClient
local LMEngine = require(game:GetService("ReplicatedStorage").LMEngine)

local dir_Controllers = script.Controllers
local dir_Modules = script.Modules

LMEngine.LoadModulesFromParent(dir_Modules)
LMEngine.AddControllers(dir_Controllers)

LMEngine.Start()
	:andThen(function()
		print("[LM Engine] Client started")
	end)
	:catch(function(err)
		warn("[LM Engine] Engine failed to start", err)
	end)
