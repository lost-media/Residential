--!strict
--!version: 1.0.0

--[[
{Lost Media}

-[PlotService] Service
    Handles the player added event and player removal event, decoupling the
    PlayerService from the rest of the game with one-way function callbacks.


	Members:

		PlotService.PlayerAddedCallbacks   [table<Scope, function[]>] -- Callbacks to run when a player is added
			Stores the mapping of players to plots

		PlotService.PlayerRemovedCallbacks   [table<Scope, function[]>] -- Callbacks to run when a player is removed
			Stores the mapping of players to plots

	Methods [PlotService]:

		PlotService:RegisterPlayerAdded(callback: (player: Player) -> (), scope: Scope?) -- Registers a callback to run when a player is added
			callback [function]
			scope [Scope] -- The scope of the callback

		PlotService:RegisterPlayerRemoved(callback: (player: Player) -> (), scope: Scope?) -- Registers a callback to run when a player is removed
			callback [function]
			scope [Scope] -- The scope of the callback

	The scope of a callback determines when it is run. The scopes are as follows:

		- "URGENT" -- Goes first, good for tasks that need to be resolved immediately
		- "NORMAL" -- Good for tasks that don't have any arbitrary priority
		- "LOW" -- Goes last, good for data that needs to resolve itself after all other tasks are finished

--]]

local SETTINGS = {
	Scopes = {
		["LOW"] = true, -- Goes last, good for data that needs to resolve itself after all other tasks are finished
		["URGENT"] = true,
		["NORMAL"] = true,
	},

	ScopeOrder = {
		"URGENT",
		"NORMAL",
		"LOW",
	},

	ScopeDefault = "NORMAL",
}

type Scope = "LOW" | "URGENT" | "NORMAL"

-----  Private variables -----

local LMEngine = require(game:GetService("ReplicatedStorage").LMEngine)

---@class PlayerService
local PlayerService = LMEngine.CreateService({
	Name = "PlayerService",

	-- RBX signal that fires when a player is added
	---@type RBXScriptSignal | nil
	PlayerAdded = nil,

	---@type RBXScriptSignal | nil
	PlayerRemoved = nil,

	---@type function[]
	PlayerAddedCallbacks = {},
	---@type function[]
	PlayerRemovedCallbacks = {},
})

----- Public functions -----

function PlayerService:Init()
	self.PlayerAdded = game.Players.PlayerAdded:Connect(function(player)
		for _, scope in SETTINGS.ScopeOrder do
			if self.PlayerAddedCallbacks[scope] == nil then
				continue
			end
			for _, callback in self.PlayerAddedCallbacks[scope] do
				callback(player)
			end
		end
	end)

	self.PlayerRemoved = game.Players.PlayerRemoving:Connect(function(player)
		for _, scope in SETTINGS.ScopeOrder do
			if self.PlayerRemovedCallbacks[scope] == nil then
				continue
			end
			for _, callback in self.PlayerRemovedCallbacks[scope] do
				callback(player)
			end
		end
	end)

	-- In case a player is already in the game before the service is initialized
	for _, player in ipairs(game.Players:GetPlayers()) do
		for _, scope in SETTINGS.ScopeOrder do
			for _, callback in self.PlayerAddedCallbacks[scope] do
				callback(player)
			end
		end
	end
end

function PlayerService:RegisterPlayerAdded(callback: (player: Player) -> (), scope: Scope?)
	scope = scope or SETTINGS.ScopeDefault
	if not SETTINGS.Scopes[scope] then
		warn("[PlayerService] Invalid scope: " .. scope)
		return
	end

	if self.PlayerAddedCallbacks[scope] == nil then
		self.PlayerAddedCallbacks[scope] = {}
	end

	table.insert(self.PlayerAddedCallbacks[scope], callback)
end

function PlayerService:RegisterPlayerRemoved(callback: (player: Player) -> (), scope: Scope?)
	scope = scope or SETTINGS.ScopeDefault
	if not SETTINGS.Scopes[scope] then
		warn("[PlayerService] Invalid scope: " .. scope)
		return
	end

	if self.PlayerRemovedCallbacks[scope] == nil then
		self.PlayerRemovedCallbacks[scope] = {}
	end

	table.insert(self.PlayerRemovedCallbacks[scope], callback)
end

return PlayerService
