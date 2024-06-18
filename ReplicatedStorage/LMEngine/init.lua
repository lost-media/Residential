--[[
{Lost Media}

-[LMEngine.init] Module
    This script is used to initialize the engine core, completely
    agnostic of the client or server side. It will delegate the
    loading of the core, extension, and game-specific packages to
    the client and server modules.

    Execution order:
    1. Check if the environment is a test environment; if so, load
        the testing framework
--]]

local SETTINGS = {}

----- Private variables -----

local LMEngine

local RunService: RunService = game:GetService("RunService")

local ServerInit: string = "LMEngineServerInit"

local IsServer: boolean = RunService:IsServer()
local IsRunning: boolean = RunService:IsRunning()
local IsTesting: boolean = RunService:IsStudio()

local Client
local Server
----- Initialize the engine core -----

-- Load the testing framework if the environment is a test environment

if IsTesting == true then
	require(script.Test.LMEngineTestInit)
end

if IsServer == true then
	return require(script.Server.LMEngineServerInit)
else
	local loaded_server = script:FindFirstChild("Server")
	if loaded_server ~= nil and IsRunning == true then
		loaded_server:Destroy()
	end

	if Client ~= nil then
		return Client
	end

	Client = require(script.Client.LMEngineClientInit)
	return Client
end

return LMEngine
