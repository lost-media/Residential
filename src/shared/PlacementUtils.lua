local RS = game:GetService("ReplicatedStorage")
local PlotConfigs = require(RS.Shared.Configs.Plot)
local Structure = require(RS.Shared.Structures)
local StructureTypes = require(RS.Shared.Structures.Types)

local PlacementUtils = {}

function PlacementUtils.GetSnappedTileCFrame(tile: BasePart, state: { level: number, rotation: number })
	local tileHeight = tile.Size.Y

	local pos = tile.Position + Vector3.new(0, tileHeight / 2 + 0.5, 0)
	local newCFrame = CFrame.new(pos)
	newCFrame = newCFrame * CFrame.Angles(0, math.rad(state.rotation), 0)
	newCFrame = newCFrame * CFrame.new(0, state.level * PlotConfigs.PLOT_LEVEL_HEIGHT, 0)

	return newCFrame
end

function PlacementUtils.GetSnappedAttachmentCFrame(
	tile: BasePart,
	snappedPoint: Attachment,
	structureInfo: StructureTypes.Structure,
	state: { level: number, rotation: number }
)
	if tile == nil then
		error("Tile is nil")
	end

	if snappedPoint == nil then
		error("Snapped point is nil")
	end

	if structureInfo == nil then
		error("Structure info is nil")
	end

	if state == nil then
		error("State is nil")
	end

	local tileHeight = tile.Size.Y

	if structureInfo.FullArea == false then
		tileHeight = tileHeight / 2
	end

	local pos = snappedPoint.WorldPosition
	local yVal = (tile.Position + Vector3.new(0, tileHeight, 0)).Y

	if structureInfo.FullArea == false then
		yVal = pos.Y + tileHeight
	end

	pos = Vector3.new(pos.X, yVal, pos.Z)

	local newCFrame = CFrame.new(pos)

	newCFrame = newCFrame * CFrame.Angles(0, math.rad(state.rotation), 0)

	if structureInfo.FullArea == true then
		newCFrame = newCFrame * CFrame.new(0, state.level * PlotConfigs.PLOT_LEVEL_HEIGHT, 0)
	end

	return newCFrame
end

return PlacementUtils
