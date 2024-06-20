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

function InputController:RegisterInputBegan(key: string, callback: (input: InputObject, game_processed: boolean?) -> ())
	assert(self.InputBeganCallbacks[key] == nil, "[InputController] RegisterInputBegan: Key already exists")
	assert(callback ~= nil, "[InputController] RegisterInputBegan: Callback is nil")
	self.InputBeganCallbacks[key] = callback

	-- Return the index of the callback
end

function InputController:RegisterInputEnded(key: string, callback: (input: InputObject, game_processed: boolean?) -> ())
	assert(self.InputEndedCallbacks[key] == nil, "[InputController] RegisterInputEnded: Key already exists")
	assert(callback ~= nil, "[InputController] RegisterInputEnded: Callback is nil")

	self.InputEndedCallbacks[key] = callback

	-- Return the index of the callback
	return #self.InputEndedCallbacks
end

function InputController:UnregisterInputBegan(key: string)
	assert(self.InputBeganCallbacks[key] ~= nil, "[InputController] UnregisterInputBegan: Key does not exist")
	self.InputBeganCallbacks[key] = nil
end

function InputController:UnregisterInputEnded(key: string)
	assert(self.InputEndedCallbacks[key] ~= nil, "[InputController] UnregisterInputEnded: Key does not exist")
	self.InputEndedCallbacks[key] = nil
end

function InputController:GetMouse(): Mouse
	return self._mouse
end

return InputController
