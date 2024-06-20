--!strict

--[[
{Lost Media}

-[InputController] Controller
    Provides
--]]

local SETTINGS = {}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)

---@type Mouse
local Mouse = LMEngine.GetModule("Mouse")

---@class InputController
local InputController = LMEngine.CreateController({
	Name = "InputController",

	InputBeganCallbacks = {},
	InputEndedCallbacks = {},

	_mouse = Mouse.new(),
})

----- Public functions -----

function InputController:Init()
	print("[InputController] initialized")

	UserInputService.InputBegan:Connect(function(input, game_processed)
		for _, callback in self.InputBeganCallbacks do
			callback(input, game_processed)
		end
	end)

	UserInputService.InputEnded:Connect(function(input, game_processed)
		for _, callback in self.InputEndedCallbacks do
			callback(input, game_processed)
		end
	end)
end

function InputController:Start()
	print("[InputController] started")
end

function InputController:RegisterInputBegan(callback: (input: InputObject, game_processed: boolean?) -> ()): number
	table.insert(self.InputBeganCallbacks, callback)

	-- Return the index of the callback
	return #self.InputBeganCallbacks
end

function InputController:RegisterInputEnded(callback: (input: InputObject, game_processed: boolean?) -> ()): number
	table.insert(self.InputEndedCallbacks, callback)

	-- Return the index of the callback
	return #self.InputEndedCallbacks
end

function InputController:UnregisterInputBegan(index: number)
	assert(index <= #self.InputBeganCallbacks, "[InputController] UnregisterInputBegan: Index out of range")
	table.remove(self.InputBeganCallbacks, index)
end

function InputController:UnregisterInputEnded(index: number)
	assert(index <= #self.InputEndedCallbacks, "[InputController] UnregisterInputBegan: Index out of range")
	table.remove(self.InputEndedCallbacks, index)
end

function InputController:GetMouse(): Mouse
	return self._mouse
end

return InputController
