local StructuresUtils = {}

local StructuresCollection = require(script.Parent)

function StructuresUtils.ParseStructureId(structureId: string)
	local split = string.split(structureId, "/")

	if #split < 2 then
		warn("Invalid structureId")
		return
	end

	return split[1], split[2]
end

function StructuresUtils.GetStructureFromId(structureId: string)
	local structureType, structureName = StructuresUtils.ParseStructureId(structureId)
	local structure = StructuresCollection[structureType][structureName]

	if structure == nil then
		warn("Structure not found")
		return
	end

	return structure
end

function StructuresUtils.GetStructureModelFromId(structureId: string): Model?
	local structureType, structureName = StructuresUtils.ParseStructureId(structureId)

	if structureType == nil or structureName == nil then
		return
	end

	return StructuresCollection[structureType][structureName].Model
end

function StructuresUtils.GetIdFromStructure(structure: Model): string?
	for structureType, structureCollection in pairs(StructuresCollection) do
		for structureName, structureData in pairs(structureCollection) do
			if structureData.Model == structure then
				return structureData.Id
			end
		end
	end

	return nil
end

function StructuresUtils.IsStructureStackable(structureId: string): boolean
	local structure = StructuresUtils.GetStructureFromId(structureId)

	if structure == nil then
		return false
	end

	return structure.Stacking ~= nil
end

function StructuresUtils.CanStackStructureWith(structureId: string, otherStructureId: string): boolean
	local structure = StructuresUtils.GetStructureFromId(structureId)

	if structure == nil then
		return false
	end

	if structure.Stacking == nil then
		return false
	end

	if structure.Stacking.Allowed == false then
		return false
	end

	if structure.Stacking.AllowedModels == nil then
		return false
	end

	return structure.Stacking.AllowedModels[otherStructureId] ~= nil
end

function StructuresUtils.GetStackingRequiredSnapPointsWith(structureId: string, otherStructureId: string): { string }?
	local canStack = StructuresUtils.CanStackStructureWith(structureId, otherStructureId)

	if canStack == false then
		return
	end

	local structure = StructuresUtils.GetStructureFromId(structureId)
	local stackingData = structure.Stacking.AllowedModels[otherStructureId]

	return stackingData.RequiredSnapPoints
end

function StructuresUtils.GetStackingWhitelistedSnapPointsWith(
	structureId: string,
	otherStructureId: string
): { string }?
	local canStack = StructuresUtils.CanStackStructureWith(structureId, otherStructureId)

	if canStack == false then
		return
	end

	local structure = StructuresUtils.GetStructureFromId(structureId)
	local stackingData = structure.Stacking.AllowedModels[otherStructureId]

	return stackingData.WhitelistedSnapPoints
end

function StructuresUtils.GetStackingOccupiedSnapPointsWith(structureId: string, otherStructureId: string): { string }?
	local canStack = StructuresUtils.CanStackStructureWith(structureId, otherStructureId)

	if canStack == false then
		return
	end

	local structure = StructuresUtils.GetStructureFromId(structureId)
	local stackingData = structure.Stacking.AllowedModels[otherStructureId]

	return stackingData.OccupiedSnapPoints
end

function StructuresUtils.GetMountedAttachmentPointFromStructures(
	model: Model?,
	otherStructureId: string,
	attachment: Attachment
): Attachment?
	if model == nil then
		return
	end

	local structureId: string? = model:GetAttribute("Id")
	if structureId == nil then
		return
	end

	local canStack = StructuresUtils.CanStackStructureWith(structureId, otherStructureId)

	if canStack == false then
		return
	end

	local occupiedSnapPoints = StructuresUtils.GetStackingOccupiedSnapPointsWith(structureId, otherStructureId)

	if occupiedSnapPoints == nil then
		return
	end

	if occupiedSnapPoints[attachment.Name] == nil then
		return
	end

	return model.PrimaryPart:FindFirstChild(occupiedSnapPoints[attachment.Name])
end

function StructuresUtils.IsOrientationStrict(structureId1: string, structureId2: string)
	local structure1 = StructuresUtils.GetStructureFromId(structureId1)
	local structure2 = StructuresUtils.GetStructureFromId(structureId2)

	if structure1 == nil or structure2 == nil then
		return false
	end

	if structure1.Stacking == nil then
		return false
	end

	if structure1.Stacking.Allowed == false then
		return false
	end

	if structure1.Stacking.AllowedModels == nil then
		return false
	end

	if structure1.Stacking.AllowedModels[structureId2] == nil then
		return false
	end

	return structure1.Stacking.AllowedModels[structureId2].Orientation.Strict
end

function StructuresUtils.SnapPointsToMatchWith(structureId1: string, structureId2: string)
	if StructuresUtils.IsOrientationStrict(structureId1, structureId2) == false then
		return
	end

	local structure1 = StructuresUtils.GetStructureFromId(structureId1)

	return structure1.Stacking.AllowedModels[structureId2].Orientation.SnapPointsToMatch
end

function StructuresUtils.GetAttachmentsThatMatchSnapPoints(
	structureId1: string,
	structureId2: string,
	structure1: Model,
	structure2: Model
): { { [Attachment]: Attachment } }?
	if structure1 == nil or structure2 == nil then
		return
	end

	if StructuresUtils.IsOrientationStrict(structureId1, structureId2) == false then
		return
	end

	local snapPointsToMatch = StructuresUtils.SnapPointsToMatchWith(structureId1, structureId2)

	if snapPointsToMatch == nil then
		return
	end

	local attachmentsThatMatch: { { [Attachment]: Attachment } } = {}

	for _, snapPoint2 in pairs(snapPointsToMatch) do
		local a = {}

		for attachment1, attachment2 in pairs(snapPoint2) do
			if attachment1 == nil or attachment2 == nil then
				warn("Attachment1 or Attachment2 not found")
				return
			end

			local xAttachment1 = structure1.PrimaryPart:FindFirstChild(attachment1)
			local xAttachment2 = structure2.PrimaryPart:FindFirstChild(attachment2)

			if xAttachment1 ~= nil and xAttachment2 ~= nil then
				a[xAttachment1] = xAttachment2
			end

			if xAttachment1 == nil then
				warn("Attachment1 not found")
			end

			if xAttachment2 == nil then
				warn("Attachment2 not found")
			end
		end

		if a ~= {} then
			table.insert(attachmentsThatMatch, a)
		end
	end

	return attachmentsThatMatch
end

function StructuresUtils.IsIncreasingLevel(structureId1: string, structureId2: string): boolean
	local structure1 = StructuresUtils.GetStructureFromId(structureId1)
	local structure2 = StructuresUtils.GetStructureFromId(structureId2)

	if structure1 == nil or structure2 == nil then
		return false
	end

	if structure1.Stacking == nil then
		return false
	end

	if structure1.Stacking.Allowed == false then
		return false
	end

	if structure1.Stacking.AllowedModels == nil then
		return false
	end

	if structure1.Stacking.AllowedModels[structureId2] == nil then
		return false
	end

	return structure1.Stacking.AllowedModels[structureId2].IncreaseLevel
end

return StructuresUtils
