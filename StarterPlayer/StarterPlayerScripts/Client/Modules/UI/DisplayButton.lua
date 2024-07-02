--!strict

--[[
{Lost Media}

-[Display Button] UI Module
    Represents a button that is on the main HUD of the game.

	Members:

        DisplayButton.Button1Down [Signal] -- Signal
            Fired when the button is pressed

        DisplayButton.Button1Up [Signal] -- Signal
            Fired when the button is released

        DisplayButton.Clicked [Signal] -- Signal

    Functions:

        DisplayButton.new  [DisplayButton] -- Constructor
            Creates a new instance of the DisplayButton class

	Methods:

        DisplayButton:Disconnect() -- Disconnects all signals
            Disconnects all signals

--]]

local SETTINGS = {}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)

local UIElement = require(script.Parent.UIElement)

---@type Trove
local Trove = require(LMEngine.SharedDir.Trove)

---@type Signal
local Signal = require(LMEngine.SharedDir.Signal)

local DisplayButton = {}
DisplayButton.__index = DisplayButton

-- Inherits from UIElement
setmetatable(DisplayButton, UIElement)

----- Private functions -----

-- Checks if the instance is a display button
local function InstanceIsDisplayButton(instance: Instance): boolean
	return instance:IsA("ImageButton") and instance:FindFirstChild("TextButton") == nil
end

----- Public functions -----

function DisplayButton.new(instance: Instance)
	assert(
		InstanceIsDisplayButton(instance) == true,
		"[DisplayButton]: Instance is not a display button"
	)
	local self = setmetatable(UIElement.new(instance), DisplayButton)

	self.Button1Down = Signal.new()
	self.Button1Up = Signal.new()
	self.Clicked = Signal.new()

	return self
end

function DisplayButton:Connect()
	self._trove:Add(self._instance.MouseButton1Down:Connect(function()
		self.Button1Down:Fire()
	end))

	self._trove:Add(self._instance.MouseButton1Up:Connect(function()
		self.Button1Up:Fire()
	end))
end

return DisplayButton
