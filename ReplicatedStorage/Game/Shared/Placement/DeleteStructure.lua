--[[
*{Residential} -[DeleteStructure]- v1.0.0 -----------------------------------
Handles the deletion system for structures in the game.

Author: brandon-kong (ijmod)
Last Modified: 2024-07-01

Dependencies:
    - InputController

Usage:
    local DeleteStructure = require(game.ReplicatedStorage.Modules.DeleteStructure)
    DeleteStructure.someFunction()

Functions:
    - functionName(param1: type, param2: type): returnType
      Brief description of the function
    - ...

Members [ClassName]:
    - memberName: type (brief description)
    - ...

Methods [ClassName]:
    - methodName(param1: type, param2: type): returnType
      Brief description of the method
    - ...

Changelog:
    v1.0.0 - Initial implementation
--]]

local SETTINGS = {
	SelectionBoxColor = Color3.fromRGB(255, 0, 0),
}

type IDeleteStructure = {
	__index: IDeleteStructure,

	new: () -> DeleteStructure,
	Enable: (self: DeleteStructure) -> (),
	Disable: (self: DeleteStructure) -> (),
}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LMEngine = require(ReplicatedStorage.LMEngine.Client)

local Signal = require(LMEngine.SharedDir.Signal)
local Trove = require(LMEngine.SharedDir.Trove)

export type DeleteStructure = typeof(setmetatable(
	{} :: {
		_trove: Trove.Trove,
		_mouse: Mouse,
		_plot: Model,

		OnStructureDeleted: Signal.Signal,
	},
	{} :: IDeleteStructure
))

local DeleteStructure: IDeleteStructure = {} :: IDeleteStructure
DeleteStructure.__index = DeleteStructure

----- Private functions -----

local function ModelIsPlot(model: Model)
	if model == nil then
		return false
	end

	if model:IsA("Model") == false then
		return false
	end

	local structures = model:FindFirstChild("Structures")

	if structures == nil then
		return false
	end

	if structures:IsA("Folder") == false then
		return false
	end

	local platform = model:WaitForChild("Platform")

	if platform == nil then
		return false
	end

	return true
end

----- Public functions -----

function DeleteStructure.new(plot: Model): DeleteStructure
	assert(ModelIsPlot(plot) == true, "[DeleteStructure] new: plot is not a valid plot model")

	local self = setmetatable({}, DeleteStructure)

	---@type InputController
	local InputController = LMEngine.GetController("InputController")

	local mouse = InputController:GetMouse()

	self._plot = plot
	self._trove = Trove.new()
	self._mouse = mouse

	-- Signals
	self.OnStructureDeleted = Signal.new()
	return self
end

function DeleteStructure:Enable()
	-- set up events

	-- create a selection box
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Color3 = SETTINGS.SelectionBoxColor
	selectionBox.SurfaceColor3 = SETTINGS.SelectionBoxColor
	selectionBox.LineThickness = 0.1
	selectionBox.SurfaceTransparency = 0.75
	selectionBox.Adornee = nil
	selectionBox.Parent = workspace

	self._trove:Add(selectionBox)

	self._trove:Connect(RunService.RenderStepped, function(dt)
		local target = self._mouse:GetTarget()

		if target == nil then
			selectionBox.Adornee = nil
			return
		end

		local model = target:FindFirstAncestorWhichIsA("Model")

		if model == nil then
			selectionBox.Adornee = nil
			return
		end

		if model.Parent ~= self._plot.Structures then
			selectionBox.Adornee = nil
			return
		end

		selectionBox.Adornee = model
	end)

	self._trove:Connect(UserInputService.InputBegan, function(input, gameProcessed)
		if gameProcessed == true then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		local target = self._mouse:GetTarget()

		if target == nil then
			return
		end

		local model = target:FindFirstAncestorWhichIsA("Model")

		if model == nil then
			return
		end

		if model.Parent ~= self._plot.Structures then
			return
		end

		self.OnStructureDeleted:Fire(model)
	end)
end

function DeleteStructure:Disable()
	-- disconnect events
	self._trove:Destroy()

	-- Disconnect signals
	self.OnStructureDeleted:DisconnectAll()
end

return DeleteStructure
