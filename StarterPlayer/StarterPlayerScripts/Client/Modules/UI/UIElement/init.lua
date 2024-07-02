--!strict

--[[
{Lost Media}

-[UIElement] UI Module
    Represents an abstract UI element which contains common properties and methods for all UI elements.

	Members:

        UIElement._instance [Instance] -- The instance of the UI element
            The instance of the UI element

    Functions:

        UIElement.new  [UIElement] -- Constructor
            Creates a new instance of the UIElement class

	Methods:

        UIElement:Connect() -- Connects all signals
            Connects all signals

        UIElement:Disconnect() -- Disconnects all signals
            Disconnects all signals

--]]

local SETTINGS = {}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)

local UIElementTypes = require(script.Types)
type IUIElement = UIElementTypes.IUIElement
type UIElement = UIElementTypes.UIElement

local Trove = require(LMEngine.SharedDir.Trove)

local UIElement = {}
UIElement.__index = UIElement

----- Public functions -----

function UIElement.new(instance: Instance)
	local self = setmetatable({}, UIElement)

	self._instance = instance
	self._trove = Trove.new()

	return self
end

function UIElement:Disconnect()
	-- Disconnect all signals
	self._trove:Destroy()
end

return UIElement
