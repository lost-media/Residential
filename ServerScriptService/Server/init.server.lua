--!strict

local ServerStorage = game:GetService("ServerStorage")

---@type LMEngineServer
local LMEngine = require(game:GetService("ReplicatedStorage").LMEngine)

local Cmdr = require(LMEngine.SharedDir.Cmdr)

local dir_Modules = script.Modules
local dir_Services = script.Services

LMEngine.LoadModulesFromParent(dir_Modules)
LMEngine.AddServices(dir_Services)

Cmdr:RegisterDefaultCommands()
Cmdr:RegisterCommandsIn(ServerStorage.Cmdr.CommandDefinitions)
Cmdr:RegisterHooksIn(ServerStorage.Cmdr.Hooks)

local start_time = os.clock()

LMEngine.Start()
	:andThen(function()
		print("[LM Engine] Server Engine started in", string.format("%.2fms", (os.clock() - start_time) * 100))
	end)
	:catch(function(err)
		warn("[LM Engine] Engine failed to start", err)
	end)
