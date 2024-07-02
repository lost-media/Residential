-- TeleportServer.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineServer
local LMEngine = require(ReplicatedStorage.LMEngine)

local Base64 = require(LMEngine.SharedDir.Base64)

-- These arguments are guaranteed to exist and be correctly typed.
return function(context, player: Player)
	---@type DataService
	local DataService = LMEngine.GetService("DataService")

	---@type PlotService
	local PlotService = LMEngine.GetService("PlotService")

	local plot = PlotService:GetPlot(player)

	if plot ~= nil then
		-- Clear the plot
		plot:Clear()
		return "Cleared plot for " .. player.Name
	end

	return "No plot found for " .. player.Name
end
