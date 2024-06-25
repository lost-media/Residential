--!strict

--[[
{Lost Media}

-[Plot2] Class
    Represents a plot in the game, which is a piece
    of land that a player can build on. The plot has
    a reference to the player
    that owns it.

	A plot contains a platform that represents the ground
	and a folder that contains the structures that are placed

	Each structure that is placed on the plot will generate a unique ID
	that is used to identify the structure. This can be used to serialize
	the structure data to the DataStore.

	Members:

		Plot._plot_model   [Instance] -- The model of the plot
        Plot._player       [Player?]  -- The player that owns the plot

    Functions:

        Plot.new(plotModel: Instance) -- Constructor
            Creates a new instance of the Plot class

        Plot.ModelIsPlot(model: Instance) boolean
            Checks if a model instance has the structure of a plot

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

		Plot:PlaceStructure(structure: Model, cframe: CFrame) boolean
			Places a structure on the plot

		Plot:Serialize() { [number]: SerializedStructure }
			Serializes all the structures on the plot

		Plot:GetPlaceable(model: Model) Model?
			Returns the model that can be placed on the plot
--]]

local SETTINGS = {
	-- The size of a tile in studs in X and Z dimensions
	TILE_SIZE = 8,
}
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local VFX: Folder = ReplicatedStorage.VFX;
local PlacementType = require(ReplicatedStorage.Game.Shared.Placement.Types)

---@type Trove
local Trove = require(ReplicatedStorage.LMEngine.Shared.Trove)

---@type UniqueIdGenerator
local UniqueIdGenerator = require(ReplicatedStorage.LMEngine.Shared.UniqueIdGenerator)
----- Types -----

export type PlotModel = Model & {
	Tiles: Folder,
	Structures: Folder,
}

type IPlot = {
	__index: IPlot,
	__tostring: (self: Plot) -> string,

	ModelIsPlot: (model: Instance) -> boolean,
	new: (plotModel: Instance) -> Plot,

	GetPlayer: (self: Plot) -> Player?,
	GetModel: (self: Plot) -> Instance,
	AssignPlayer: (self: Plot, player: Player) -> (),
	UnassignPlayer: (self: Plot) -> (),

	SetAttribute: (self: Plot, attribute: string, value: any) -> (),
	GetAttribute: (self: Plot, attribute: string) -> any,

	PlaceStructure: (self: Plot, structure: Model, cframe: CFrame) -> boolean,
	GetPlaceable: (self: Plot, model: Model) -> Model?,
	Serialize: (self: Plot) -> { [number]: SerializedStructure },
}

type PlotMembers = {
	_plot_model: Instance,
	_player: Player?,
	_trove: Trove.Trove,
}

export type Plot = typeof(setmetatable({} :: PlotMembers, {} :: IPlot))

type SerializedStructure = {
	PlotId: number,
	CFrame: { number },
}

----- Private variables -----

local NEIGHBORS = {
	Vector3.new(0, 0, SETTINGS.TILE_SIZE),
	Vector3.new(0, 0, -SETTINGS.TILE_SIZE),
	Vector3.new(SETTINGS.TILE_SIZE, 0, 0),
	Vector3.new(-SETTINGS.TILE_SIZE, 0, 0),
}

---@type LMEngineServer
local LMEngine = require(ReplicatedStorage.LMEngine)

local StructureFactory = require(LMEngine.Game.Shared.Structures.StructureFactory)

---@class Plot2
local Plot: IPlot = {} :: IPlot
Plot.__index = Plot

----- Private functions -----

local function CheckHitbox(character: Model, object: Model, plot: Plot)
	if object == nil then
		return false
	end

	if object.PrimaryPart == nil then
		return false
	end

	local collisionPoints = workspace:GetPartsInPart(object.PrimaryPart)

	-- Checks if there is collision on any object that is not a child of the object and is not a child of the player
	for i = 1, #collisionPoints, 1 do
		if collisionPoints[i].CanTouch ~= true then
			continue
		end

		if
			collisionPoints[i]:IsDescendantOf(object) == true
			or collisionPoints[i]:IsDescendantOf(character) == true
			or collisionPoints[i] == plot:GetModel():FindFirstChild("Platform")
		then
			-- Skip this iteration if any of the conditions are true
			continue
		end

		return true
	end

	return false
end

-- Checks if the object exceeds the boundries given by the plot
local function CheckBoundaries(plot: BasePart, primary: BasePart): boolean
	local pos: CFrame = plot.CFrame
	local size: Vector3 = CFrame.fromOrientation(0, primary.Orientation.Y * math.pi / 180, 0) * primary.Size
	local currentPos: CFrame = pos:Inverse() * primary.CFrame

	local xBound: number = (plot.Size.X - size.X)
	local zBound: number = (plot.Size.Z - size.Z)

	return currentPos.X > xBound or currentPos.X < -xBound or currentPos.Z > zBound or currentPos.Z < -zBound
end

local function HandleCollisions(character: Model, structure: Model, collisions: boolean, plot: Plot): boolean
	if collisions ~= true then
		structure.PrimaryPart.Transparency = 1
		return true
	end

	local collision = CheckHitbox(character, structure, plot)

	if collision == true then
		structure:Destroy()
		return false
	end

	structure.PrimaryPart.Transparency = 1
	return true
end

local function GetCollisions(name: string): boolean
	return true
end

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

	local structures = model:FindFirstChildOfClass("Folder")
	if structures == nil then
		return false
	end

	local platform = model:FindFirstChildOfClass("Part")
	if platform == nil then
		return false
	end

	return true
end

function Plot.new(plot_model: Instance)
	assert(Plot.ModelIsPlot(plot_model) == true, "Model is not a plot")

	local self = setmetatable({}, Plot)
	self._plot_model = plot_model
	self._player = nil :: Player?
	self._trove = Trove.new()

	return self
end

function Plot:Load(data: { [string]: { [number]: SerializedStructure } })

	local platform: Part = self._plot_model:FindFirstChild("Platform")

	for structure_id, v in data do
		for _, structure_data in v do
			--local id: number = structure_data.PlotId
			--table.insert(ids, id)

			local structure: Model = StructureFactory.MakeStructure(structure_id)

			if structure == nil then
				warn("[Plot] Failed to load structure with ID: " .. structure_id)
				continue
			end

			local relative_cframe = CFrame.new(unpack(structure_data.CFrame))

			local absolute_cframe = platform.CFrame * relative_cframe

			structure:PivotTo(absolute_cframe)
			structure.Parent = self._plot_model.Structures
		end
	end

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

function Plot:PlaceStructure(structure: Model, cframe: CFrame): boolean
	assert(structure ~= nil, "[PlotService] PlaceStructure: Structure is nil")

	local structure_id: string? = structure:GetAttribute("Id")

	assert(structure_id ~= nil, "[PlotService] PlaceStructure: Structure ID is nil")

	local collisions = GetCollisions(structure_id)

	structure.PrimaryPart.CanCollide = false
	structure:PivotTo(cframe)

	local platform = self._plot_model:FindFirstChild("Platform")

	if CheckBoundaries(platform, structure.PrimaryPart) == true then
		return false
	end

	structure.Parent = self._plot_model.Structures

	local can_place =  HandleCollisions(self._player.Character, structure, collisions, self)

	if (can_place == false) then
		return false;
	end

	
	-- add VFX for placing the structure
	local PlacedDownVFX = VFX.PlacedDown:Clone()
	PlacedDownVFX.Parent = structure.PrimaryPart;

	-- set the VFX to the correct position
	PlacedDownVFX.CFrame = structure.PrimaryPart.CFrame * CFrame.new(0, 0.5, 0)

	PlacedDownVFX.Smoke:Clear()
	PlacedDownVFX.Smoke:Emit(100)

	-- after x seconds, remove the VFX
	coroutine.wrap(function()
		task.wait(0.75)
		for _, v in ipairs(PlacedDownVFX:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end

		task.wait(1)

		PlacedDownVFX:Destroy()
	end)()
end

function Plot:GetPlaceable(model: Model)
	local parent = model.Parent

	while parent ~= nil do
		if parent == self._plot_model then
			return model
		end

		parent = parent.Parent
	end

	return nil
end
--- Serializes all the structures on the plot
---@return table
function Plot:Serialize(): { [number]: SerializedStructure }
	local data = {}

	local structures = self._plot_model.Structures:GetChildren()

	for i = 1, #structures do
		local structure: Model = structures[i]

		local structure_id = structure:GetAttribute("Id")

		if structure.PrimaryPart == nil then
			warn("[Plot] Structure does not have a primary part")
			continue
		end

		local cframe: CFrame = structure.PrimaryPart.CFrame

		if structure_id == nil then
			warn("[Plot] Structure does not have an ID")
			continue
		end

		-- get the relative CFrame of the structure to the platform

		local platform: Part = self._plot_model:FindFirstChild("Platform")

		if platform == nil then
			warn("[Plot] Plot does not have a platform")
			continue
		end

		local relative_cframe: CFrame = platform.CFrame:Inverse() * cframe

		local serialized_cframe = { relative_cframe:GetComponents() }

		if data[structure_id] == nil then
			data[structure_id] = {}
		end

		table.insert(data[structure_id], {
			CFrame = serialized_cframe,
		});
	end

	return data
end

function Plot.__tostring(self: Plot): string
	return "Plot " .. self._plot_model.Name
end

return Plot
