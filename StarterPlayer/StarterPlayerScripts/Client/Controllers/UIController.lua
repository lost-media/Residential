--!strict

--[[
{Lost Media}

-[UIController] Controller
    A controller that listens for the PlotAssigned event from the PlotService and assigns the plot to the UIController.
	The UIController is then used to get the plot assigned to the player.
--]]

local SETTINGS = {}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)

---@type Signal
local Signal = LMEngine.GetShared("Signal")

local UiApp = require(script.Parent.Parent.UI)

---@type Promise
local Promise = require(LMEngine.SharedDir.Promise)
type Promise = typeof(Promise.new())

---@class UIController
local UIController = LMEngine.CreateController({
	Name = "UIController",
})

----- Public functions -----

function UIController:Start()
	UiApp.Initialize()
end

return UIController
