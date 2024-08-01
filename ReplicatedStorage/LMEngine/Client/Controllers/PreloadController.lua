--!strict

--[[
{Lost Media}

-[PreloadController] Controller
    A controller that preloads assets 
--]]

local SETTINGS = {
	Assets = {
		"rbxassetid://9046515361",
		"rbxassetid://1839690393",
		"rbxassetid://1836160504",
	},
}

----- Private variables -----

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)

local Promise = require(LMEngine.SharedDir.Promise)
local Signal = require(LMEngine.SharedDir.Signal)
local TableUtil = require(LMEngine.SharedDir.TableUtil)

---@class PreloadController
local PreloadController = LMEngine.CreateController({
	Name = "PreloadController",

	---@type Signal
	OnPreloadComplete = Signal.new(),

	_preloadComplete = false,
})

----- Private functions -----

local function GetMeshParts(model: Model): { BasePart }
	local meshParts = {}

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("MeshPart") then
			table.insert(meshParts, part)
		end
	end

	return meshParts
end

local function GetAllMeshParts(parent: Instance): { BasePart }
	local meshParts = {}

	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("Model") then
			local parts = GetMeshParts(child)

			for _, part in ipairs(parts) do
				table.insert(meshParts, part)
			end
		end
	end

	return meshParts
end

----- Public functions -----

function PreloadController:PreloadAssets()
	if self:IsPreloadComplete() then
		return
	end

	-- get the mesh parts in ReplicatedStorage and Workspace
	local meshParts = GetAllMeshParts(ReplicatedStorage)
	local workspaceMeshParts = GetAllMeshParts(game.Workspace)

	-- Combine the mesh parts
	local allMeshParts = TableUtil.Extend(meshParts, workspaceMeshParts)

	-- Preload the meshes
	for _, part in ipairs(allMeshParts) do
		ContentProvider:PreloadAsync({ part })
	end

	print("[PreloadController] Preloaded meshes (1/2)")

	-- Preload the assets
	for _, asset in ipairs(SETTINGS.Assets) do
		ContentProvider:PreloadAsync({ asset })
	end

	print("[PreloadController] Preloaded assets (2/2)")

	self._preloadComplete = true
	self.OnPreloadComplete:Fire()
end

function PreloadController:IsPreloadComplete()
	return self._preloadComplete
end

function PreloadController:WaitForPreloadCompleteAsync()
	if self:IsPreloadComplete() then
		return Promise.resolve()
	end

	return Promise.new(function(resolve)
		local connection
		connection = self.OnPreloadComplete:Connect(function()
			connection:Disconnect()
			resolve()
			print("[PreloadController] Preload complete")
		end)
	end)
end

return PreloadController
