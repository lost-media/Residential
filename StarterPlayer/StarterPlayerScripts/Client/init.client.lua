--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine)

local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

local dir_Controllers = script.Controllers
local dir_Modules = script.Modules

LMEngine.LoadModulesFromParent(dir_Modules)
LMEngine.AddControllers(dir_Controllers)

Cmdr:SetActivationKeys({
	Enum.KeyCode.F2,
})

local start_time = tick()

LMEngine.Start()
	:andThen(function()
		print("[LM Engine] Client Engine started in", string.format("%.2fms", (tick() - start_time) * 100))
	end)
	:catch(function(err)
		warn("[LM Engine] Engine failed to start", err)
	end)
