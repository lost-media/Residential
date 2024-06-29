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

local TableUtil = require(LMEngine.SharedDir.TableUtil)

---@type Signal
local Signal = LMEngine.GetShared("Signal")

---@class PreloadController
local PreloadController = LMEngine.CreateController({
	Name = "PreloadController",

	---@type Signal
	OnPreloadComplete = Signal.new(),
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

function PreloadController:Init()
	self:PreloadAssets()
end

function PreloadController:PreloadAssets()
	-- get the mesh parts in ReplicatedStorage and Workspace
	local meshParts = GetAllMeshParts(ReplicatedStorage)
	local workspaceMeshParts = GetAllMeshParts(game.Workspace)

	-- Combine the mesh parts
	local allMeshParts = TableUtil.Extend(meshParts, workspaceMeshParts)

	-- Preload the meshes
	for _, part in ipairs(allMeshParts) do
		ContentProvider:PreloadAsync({ part })
	end

	print("[PreloadController] Preloaded meshes (1/3)")

	self.OnPreloadComplete:Fire()
end

return PreloadController
