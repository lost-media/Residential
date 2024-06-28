-- Migrations/Migration_001.lua

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineServer
local LMEngine = require(ReplicatedStorage.LMEngine)

local HttpService = game:GetService("HttpService")

local Migration = {}

type Schema = {
	Plots: { [string]: string },
}

local Schema = {
	Plots = {},
	UserId = -1,
	Name = "Default",
	Storage = {},
	CompletedTutorial = false,
}

----- Public functions -----

function Migration.Migrate(player: Player, profileData)
	-- Perform migration logic here
	-- For example, adding a new field with a default value
	if profileData == nil then
		profileData = Schema
	end

	-- Remove any unused fields
	profileData.NewField = nil
	profileData.Money = nil
	profileData.Name = nil
	profileData.Storage = nil
	profileData.UserId = nil

	if profileData.Plot ~= nil then
		-- profileData.Plot holds the actual plot data, we want to remove this
		-- and move it to a new Profile key with a UUID

		local plot_name = player.Name .. "'s Plot"
		local plot_data = {
			PlotData = profileData.Plot,
			Name = plot_name,
			UserId = player.UserId,
			Storage = {},
			Version = 1,
		}

		-- Generate a UUID for the plot
		local plot_id = HttpService:GenerateGUID(false)
		profileData.Plots = {
			[plot_id] = plot_name,
		}

		profileData.Plot = nil

		---@type DataService
		local DataService = LMEngine.GetService("DataService")

		-- create a new plot profile
		DataService:CreatePlotProfile(player, plot_id, plot_data)
	end

	return profileData
end

return Migration
