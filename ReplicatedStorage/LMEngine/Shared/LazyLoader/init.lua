--!strict
--!version: 1.0.0

--[[
{Lost Media}

-[LazyLoader] Module
    Loads a module or a table of modules lazily, only when they are
    needed. This is useful for loading modules that are not needed
   
--]]

type ModuleType = table | () -> any

export type ILazyLoader = {
	__index: ILazyLoader,
	new: () -> LazyLoader,
	AddModule: (self: LazyLoader, module: ModuleScript) -> nil,
	GetModule: (self: LazyLoader, module_name: string) -> ModuleType,
	LoadModulesFromParent: (self: LazyLoader, parent: Instance, deep: boolean?) -> table,
}

export type LazyLoaderMembers = {
	_modules: { [string]: ModuleType },
}

export type LazyLoader = typeof(setmetatable({} :: LazyLoaderMembers, {} :: ILazyLoader))

local SETTINGS = {
	_VERSION = "1.0.0",
	_RESERVED_NAMES = {
		"new",
		"AddModule",
		"GetModule",
		"LoadModulesFromParent",
	},
}

----- Private variables -----

---@class LazyLoader
local LazyLoader: ILazyLoader = {}
LazyLoader.__index = LazyLoader

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

-- Public functions --

function LazyLoader.new(): LazyLoader
	local self = {}

	self._modules = {}

	return setmetatable(self, LazyLoader)
end

function LazyLoader:AddModule(module: ModuleScript): nil
	assert(module ~= nil, "Module is nil")
	assert(typeof(module) == "Instance", "Module is not an instance")
	assert(module:IsA("ModuleScript"), "Module is not a ModuleScript")

	if ModuleIsReservedOrSelf(module) == true then
		return
	end

	self._modules[module.Name] = module
end

function LazyLoader:GetModule(module_name: string): ModuleType
	assert(module_name ~= nil, "Module name is nil")
	assert(typeof(module_name) == "string", "Module name is not a string")
	assert(self._modules[module_name] ~= nil, "Module does not exist")

	local module = self._modules[module_name]

	-- Check if it is an Instance or a table or a function
	if typeof(module) == "Instance" then
		-- require the module
		self._modules[module_name] = require(module)
	end

	return self._modules[module_name]
end

function LazyLoader:LoadModulesFromParent(parent: Instance, deep: boolean?): nil
	assert(parent ~= nil, "Parent is nil")
	assert(typeof(parent) == "Instance", "Parent is not an instance")

	deep = deep or false

	local children = parent:GetChildren()

	if deep == true then
		children = parent:GetDescendants()
	end

	for _, module in ipairs(children) do
		if module:IsA("ModuleScript") then
			self:AddModule(module)
		end
	end
end

----- Initialize the lazy loader -----

return setmetatable(LazyLoader, LazyLoader)

--[[

Use the LazyLoader module to load modules lazily. For example:

local LazyLoader = require(script:FindFirstChild("LazyLoader"));

local MyModule = LazyLoader.MyModule;

--]]
