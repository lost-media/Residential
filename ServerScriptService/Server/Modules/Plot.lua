--!strict
--!version: 1.0.0

--[[
{Lost Media}

-[Plot] Class
    Represents a plot in the game, which is a piece
    of land that a player can build on. The plot has
    a reference to the player
    that owns it.

	Members:

		Plot._plot_model   [Instance] -- The model of the plot
        Plot._player       [Player?]  -- The player that owns the plot

    Functions:

        Plot.new(plotModel: Instance) -- Constructor
            Creates a new instance of the Plot class

	Methods:

        Plot:GetPlayer() [Player?]
            Returns the player that owns the plot

        Plot:GetModel() [Instance]
            Returns the model of the plot

        Plot:AssignPlayer(player: Player) [void]
            Assigns the plot to a player

        Plot:UnassignPlayer() [void]
            Unassigns the plot from a player

        Plot:SetAttribute(attribute: string, value: any) [void]
            Sets an attribute of the plot instance model

        Plot:GetAttribute(attribute: string) [any]
            Gets an attribute of the plot instance model
--]]

local SETTINGS = {}

----- Types -----

type IPlot = {
	__index: IPlot,
	new: (plotModel: Instance) -> IPlot,

	GetPlayer: (self: Plot) -> Player?,
	GetModel: (self: Plot) -> Instance,
	AssignPlayer: (self: Plot, player: Player) -> (),
	UnassignPlayer: (self: Plot) -> (),

	SetAttribute: (self: Plot, attribute: string, value: any) -> (),
	GetAttribute: (self: Plot, attribute: string) -> any,
}

type PlotMembers = {
	_plot_model: Instance,
	_player: Player?,
}

export type Plot = typeof(setmetatable({} :: PlotMembers, {} :: IPlot))

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineServer
local LMEngine = require(ReplicatedStorage.LMEngine)

---@type Graph
local Graph = LMEngine.GetShared("DS.Graph")

---@class Plot
local Plot: IPlot = {} :: IPlot
Plot.__index = Plot

----- Public functions -----

-- Checks if a model instance has the structure of a plot
--- @param model Instance -- The model to check
--- @returns boolean -- Whether the model is a plot
function Plot.ModelIsPlot(model: Instance): boolean
	if model == nil then
		return false
	end

	if not model:IsA("Model") then
		return false
	end

	local tiles = model:FindFirstChildOfClass("Folder")
	if tiles == nil then
		return false
	end

	local structures = model:FindFirstChildOfClass("Folder")
	if structures == nil then
		return false
	end

	return true
end

function Plot.new(plot_model: Instance): Plot
	assert(Plot.ModelIsPlot(plot_model) == true, "Model is not a plot")

	local self = setmetatable({}, Plot)
	self._plot_model = plot_model
	self._player = nil
	return self
end

function Plot:GetPlayer(): Player?
	return self._player
end

function Plot:GetModel(): Instance
	return self._plot_model
end

function Plot:AssignPlayer(player: Player)
	assert(player ~= nil, "Player cannot be nil")
	assert(self._player == nil, "Plot is already assigned to a player")
	self._player = player
end

function Plot:UnassignPlayer()
	assert(self._player ~= nil, "Plot is not assigned to a player")
	self._player = nil
end

function Plot:SetAttribute(attribute: string, value: any)
	self._plot_model:SetAttribute(attribute, value)
end

function Plot:GetAttribute(attribute: string): any
	return self._plot_model:GetAttribute(attribute)
end

function Plot.__tostring(self: Plot): string
	return "Plot " .. self._plot_id
end

return Plot
