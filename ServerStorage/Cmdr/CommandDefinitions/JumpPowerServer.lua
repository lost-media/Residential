-- JumpPowerServer.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineServer
local LMEngine = require(ReplicatedStorage.LMEngine)

-- These arguments are guaranteed to exist and be correctly typed.
return function(context, player: Player, jumpPower: number)
	if player.Character ~= nil then
		player.Character.Humanoid.UseJumpPower = true
		player.Character.Humanoid.JumpPower = jumpPower

		return "Changed jump power for " .. player.Name
	end
end
