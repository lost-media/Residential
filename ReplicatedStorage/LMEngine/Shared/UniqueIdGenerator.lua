--!strict

--[[
{Lost Media}

-[UniqueIdGenerator] Class
    A class that generates unique identifiers for objects in the game.
	This class is used to generate unique identifiers for plots in the game.

	Members:

		UniqueIdGenerator._ids [table] -- Id -> boolean
			Stores the mapping of identifiers to a boolean value

	Functions:

		UniqueIdGenerator.new  [UniqueIdGenerator] -- Constructor
			Creates a new instance of the UniqueIdGenerator class

	Methods [PlotService]:

		UniqueIdGenerator:GenerateId() -- Generates a unique identifier
			Returns a unique identifier for an object

		UniqueIdGenerator:AddExistingId(id: number) -- Adds an existing identifier
			Adds an existing identifier to the list of identifiers

		UniqueIdGenerator:LoadExistingIds(ids: { number }) -- Loads existing identifiers
			Loads a list of existing identifiers into the list of identifiers
--]]

local SETTINGS = {
	-- The minimum value for the generated identifier
	DEFAULT_MIN_ID = 0,

	-- The maximum value for the generated identifier
	DEFAULT_MAX_ID = 9999,
}
----- Types -----
type IUniqueIdGenerator = {
	__index: IUniqueIdGenerator,
	new: (min_id: number?, max_id: number?) -> UniqueIdGenerator,

	GenerateId: (self: UniqueIdGenerator) -> number,
	AddExistingId: (self: UniqueIdGenerator, id: number) -> (),
	LoadExistingIds: (self: UniqueIdGenerator, ids: { number }) -> (),
}

type UniqueIdGeneratorMembers = {
	_ids: { [number]: boolean },
	_min_id: number,
	_max_id: number,
}

export type UniqueIdGenerator = typeof(setmetatable({} :: UniqueIdGeneratorMembers, {} :: IUniqueIdGenerator))

----- Private variables -----

---@class UniqueIdGenerator
local UniqueIdGenerator: IUniqueIdGenerator = {} :: IUniqueIdGenerator
UniqueIdGenerator.__index = UniqueIdGenerator

----- Private functions -----

local function GenerateId(min_id: number, max_id: number): number
	return math.random(min_id, max_id)
end

----- Public functions -----

function UniqueIdGenerator.new(min_id: number?, max_id: number?): UniqueIdGenerator
	local self = setmetatable({}, UniqueIdGenerator)

	self._min_id = min_id or SETTINGS.DEFAULT_MIN_ID
	self._max_id = max_id or SETTINGS.DEFAULT_MAX_ID

	self._ids = {}
	return self
end

function UniqueIdGenerator:AddExistingId(id: number)
	self._ids[id] = true
end

function UniqueIdGenerator:LoadExistingIds(ids: { number })
	for _, id in ipairs(ids) do
		self._ids[id] = true
	end
end

function UniqueIdGenerator:GenerateId(): number
	local id = GenerateId(self._min_id, self._max_id)

	while self._ids[id] do
		id = GenerateId()
	end

	self._ids[id] = true

	return id
end

return UniqueIdGenerator
