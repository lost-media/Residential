--!strict

--[[
{Lost Media}

-[MigrationManager] Module
    Central service that manages the migrations of player and plot profiles.

	Methods:
    
        MigrationManager.MigratePlayerProfile(player: Player, profile: Profile) -> Profile
            player  [Player]
            profile [Profile]
            Returns the migrated profile

        MigrationManager.MigratePlotProfile(player: Player, profile: Profile) -> Profile
            player  [Player]
            profile [Profile]
            Returns the migrated profile
		
--]]

local SETTINGS = {
	PlayerProfileMigrations = {
		[1] = require(script.Migrations.PlayerProfile.Migration_001),
	},

	PlotProfileMigrations = {
		[1] = require(script.Migrations.PlotProfile.Migration_001),
	},
}

----- Private variables -----

local MigrationManager = {}

----- Public functions -----

function MigrationManager.MigratePlayerProfile(player: Player, profile)
	local currentVersion = profile.Data.Version or 0
	for version, migration in SETTINGS.PlayerProfileMigrations do
		if version > currentVersion then
			profile.Data = migration.Migrate(player, profile.Data)
			profile.Data.Version = version

			print(
				"[MigrationManager]: Migrated player profile for player: " .. player.Name .. " to version: " .. version
			)
		end
	end

	return profile
end

function MigrationManager.MigratePlotProfile(player: Player, profile)
	local currentVersion = profile.Data.Version or 0
	for version, migration in SETTINGS.PlotProfileMigrations do
		if version > currentVersion then
			profile.Data = migration.Migrate(player, profile.Data)
			profile.Data.Version = version
		end
	end

	return profile
end

return MigrationManager
