-- Changes the currency name from "Gems" to "Roadbucks"

local SETTINGS = {
	Schema = {
		UserId = -1,
		PlotData = nil,
		Coins = 0,
		Roadbucks = 0,
		Inventory = {},
	},

	FieldsToAdd = {},

	FieldsToRemove = {},

	FieldsToMove = {
		["Gems"] = "Roadbucks",
	},
}
----- Private variables -----

local Migration = {}

type Schema = {
	Plots: { [string]: string },
}

----- Public functions -----

function Migration.Migrate(player: Player, profile_data: table)
	if profile_data == nil then
		profile_data = SETTINGS.Schema
	end

	-- Add a new field with a default value
	for key, field in SETTINGS.FieldsToAdd do
		if profile_data[key] == nil then
			profile_data[key] = SETTINGS.FieldsToAdd[key]
		end
	end

	-- Remove any unused fields
	for _, field in SETTINGS.FieldsToRemove do
		profile_data[field] = nil
	end

	-- Move fields to a new location
	for key, newKey in SETTINGS.FieldsToMove do
		profile_data[newKey] = profile_data[key] or SETTINGS.Schema[newKey]
		profile_data[key] = nil
	end

	print(profile_data)

	return profile_data
end

return Migration
