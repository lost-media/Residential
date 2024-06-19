--!strict
--!version: 1.0.0

--[[
{Lost Media}

-[PlotService] Service
    Handles the player added event and player removal event, decoupling the
    PlayerService from the rest of the game with one-way function callbacks.
--]]

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
	print("[PlayerService] initialized")

	self.PlayerAdded = game.Players.PlayerAdded:Connect(function(player)
		for _, callback in self.PlayerAddedCallbacks do
			callback(player)
		end
	end)

	self.PlayerRemoved = game.Players.PlayerRemoving:Connect(function(player)
		for _, callback in self.PlayerRemovedCallbacks do
			callback(player)
		end
	end)
end

function PlayerService:Start()
	print("[PlayerService] started")
end

function PlayerService:RegisterPlayerAdded(callback: (player: Player) -> ())
	table.insert(self.PlayerAddedCallbacks, callback)
end

function PlayerService:RegisterPlayerRemoved(callback: (player: Player) -> ())
	table.insert(self.PlayerRemovedCallbacks, callback)
end

return PlayerService
