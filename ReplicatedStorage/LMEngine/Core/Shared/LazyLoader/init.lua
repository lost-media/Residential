--!strict

--[[
{Lost Media}

-[LazyLoader] Module
    Loads a module or a table of modules lazily, only when they are
    needed. This is useful for loading modules that are not needed
   
--]]

type ModuleType = typeof(table) | () -> any

local SETTINGS = {
	_VERSION = "1.0.0",
	_RESERVED_NAMES = {
		"new",
		"AddModule",
		"GetModule",
		"LoadModulesFromParent",
	},
	DEFAULT_DEEP = false,
}

----- Private variables -----

---@class LazyLoader
local LazyLoader = {}
LazyLoader.__index = LazyLoader

type LazyLoaderMembers = {
	_modules: { [string]: ModuleType },
}
export type LazyLoader = typeof(setmetatable({} :: LazyLoaderMembers, LazyLoader))

----- Private functions -----

local function ModuleIsSelf(module: ModuleScript): boolean
	return module == script
end

local function ModuleIsReserved(module_name: string): boolean
	for _, reserved_name in ipairs(SETTINGS._RESERVED_NAMES) do
		if module_name == reserved_name then
			return true
		end
	end

	return false
end

local function ModuleIsReservedOrSelf(module: ModuleScript): boolean
	return ModuleIsSelf(module) or ModuleIsReserved(module.Name)
end

-- Turns an Instance's children into a key-value table such as
--[[
GetKeyChildStructure(Instance) ->
{
	["Instance.Module1"] = Instance,
	["Instance.Module2"] = Instance,
}

There is a dot between the parent's name and the child's name.
--]]

local function GetKeyChildStructure(script: Instance, key: string?): { [string]: Instance }
	local new_key: string = key or ""

	local children = script:GetChildren()
	local key_child_structure = {}

	for _, child in ipairs(children) do
		local child_key = #new_key > 0 and new_key .. "." .. child.Name or child.Name

		if child:IsA("ModuleScript") then
			-- don't load .spec files
			if string.match(child.Name, ".spec") then
				continue
			end

			key_child_structure[child_key] = child
		elseif #child:GetChildren() > 0 then
			local child_structure = GetKeyChildStructure(child, child_key)
			for nested_key, value in pairs(child_structure) do
				key_child_structure[nested_key] = value :: ModuleScript
			end
		end
	end

	return key_child_structure :: { [string]: any }
end

-- Public functions --

function LazyLoader.new(): LazyLoader
	local self = {}

	self._modules = {}

	return setmetatable(self, LazyLoader)
end

function LazyLoader:AddModule(key: string, module: ModuleScript)
	assert(module ~= nil, "Module is nil")
	assert(typeof(module) == "Instance", "Module is not an instance")
	assert(module:IsA("ModuleScript"), "Module is not a ModuleScript")
	assert(key ~= nil, "Key is nil")

	if ModuleIsReservedOrSelf(module) == true then
		return
	end

	self._modules[key] = module :: any
end

function LazyLoader:GetModule(module_name: string): ModuleType
	assert(module_name ~= nil, "Module name is nil")
	assert(typeof(module_name) == "string", "Module name is not a string")
	assert(self._modules[module_name] ~= nil, "Module does not exist")

	local module = self._modules[module_name]

	-- Check if it is an Instance or a table or a function
	if typeof(module) == "Instance" then
		-- require the module
		self._modules[module_name] = require(module) :: ModuleType
	end

	return self._modules[module_name]
end

function LazyLoader:LoadModulesFromParent(parent: Instance, deep: boolean?)
	assert(parent ~= nil, "Parent is nil")
	assert(typeof(parent) == "Instance", "Parent is not an instance")

	deep = deep or SETTINGS.DEFAULT_DEEP

	local map = {}
	for _, module in ipairs(parent:GetChildren()) do
		if module:IsA("ModuleScript") then
			map[module.Name] = module
		end
	end

	if deep == true then
		map = GetKeyChildStructure(parent) :: { [string]: any }
	end

	for key, module in map do
		if module:IsA("ModuleScript") then
			self:AddModule(key, module)
		end
	end
end

return setmetatable(LazyLoader, LazyLoader)
