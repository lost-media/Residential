--!strict

--[[
{Lost Media}

-[WeldLib] Module
    A simple module that provides utility functions for creating and
    managing welds in Roblox. This module is used to create welds between
    parts in a model.
   
--]]

local SETTINGS = {}

----- Private variables -----

---@class WeldLib
local WeldLib = {}

----- Public functions -----

-- Create a new Weld
function WeldLib.NewWeld(part0: BasePart, part1: BasePart): WeldConstraint
	assert(part0, "[WeldLib] Part0 is nil")
	assert(part1, "[WeldLib] Part1 is nil")
	assert(part0:IsA("BasePart") == true, "[WeldLib] Part0 is not a BasePart")
	assert(part1:IsA("BasePart") == true, "[WeldLib] Part1 is not a BasePart")

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.Parent = part0
	return weld
end

-- Break a Weld
function WeldLib.BreakWeld(weld: WeldConstraint)
	assert(weld, "[WeldLib] Weld is nil")
	assert(weld:IsA("WeldConstraint") == true, "[WeldLib] Weld is not a WeldConstraint")

	weld:Destroy()
end

-- Update a Weld
function WeldLib.UpdateWeld(weld: WeldConstraint, part0: BasePart, part1: BasePart)
	weld.Part0 = part0 or weld.Part0
	weld.Part1 = part1 or weld.Part1
end

function WeldLib.WeldModelToPrimaryPart(model: Model)
	assert(model ~= nil, "[WeldLib] Model is nil")
	assert(model:IsA("Model") == true, "[WeldLib] Model is not a Model")
	assert(model.PrimaryPart ~= nil, "[WeldLib] Model has no PrimaryPart")

	local primary_part = model.PrimaryPart
	primary_part.Anchored = true

	-- Weld all parts to the primary part
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") == true and part ~= primary_part then
			local base_part = part :: BasePart
			local weld = WeldLib.NewWeld(primary_part, base_part)
			weld.Parent = primary_part

			base_part.Anchored = false
		end
	end
end

function WeldLib.UnweldModel(model: Model)
	assert(model, "[WeldLib] Model is nil")

	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") == true then
			for _, weld in ipairs(part:GetChildren()) do
				if weld:IsA("Weld") == true or weld:IsA("WeldConstraint") == true then
					weld:Destroy()
				end
			end
		end
	end
end

return WeldLib
