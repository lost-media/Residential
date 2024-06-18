--!strict
--!version: 1.0.0

--[[
{Lost Media}

-[WeldLib] Module
    A simple module that provides utility functions for creating and
    managing welds in Roblox. This module is used to create welds between
    parts in a model.
   
--]]

local SETTINGS = {}

----- Private variables -----

local WeldLib = {}

----- Public functions -----

-- Create a new Weld
function WeldLib.NewWeld(part0: BasePart, part1: BasePart, c0: CFrame, c1: CFrame): Weld
	assert(part0, "[WeldLib] Part0 is nil")
	assert(part1, "[WeldLib] Part1 is nil")
	assert(part0:IsA("BasePart") == true, "[WeldLib] Part0 is not a BasePart")
	assert(part1:IsA("BasePart") == true, "[WeldLib] Part1 is not a BasePart")

	local weld = Instance.new("Weld")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.C0 = c0 or CFrame.new()
	weld.C1 = c1 or CFrame.new()
	weld.Parent = part0
	return weld
end

-- Break a Weld
function WeldLib.BreakWeld(weld: Weld)
	assert(weld, "[WeldLib] Weld is nil")
	assert(weld:IsA("Weld") == true, "[WeldLib] Weld is not a Weld")

	weld:Destroy()
end

-- Update a Weld
function WeldLib.UpdateWeld(weld: Weld, part0: BasePart, part1: BasePart, c0: CFrame, c1: CFrame)
	weld.Part0 = part0 or weld.Part0
	weld.Part1 = part1 or weld.Part1
	weld.C0 = c0 or weld.C0
	weld.C1 = c1 or weld.C1
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
			local weld = WeldLib.NewWeld(primary_part, part)
			weld.Parent = primary_part

			part.Anchored = false
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
