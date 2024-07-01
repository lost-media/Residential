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

	DataService:UpdatePlot(player, "")

	PlotService:LoadPlotData(player, Base64.ToBase64("{}"))

	return "Cleared plot for " .. player.Name
end
