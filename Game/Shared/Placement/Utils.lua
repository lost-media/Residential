local SETTINGS = {
	TWEEN_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PlotConfigs = require(ReplicatedStorage.Game.Shared.Configs.Plot)

local PlacementType = require(script.Parent.Types)

local PlacementUtils = {}

----- Public functions -----

function PlacementUtils.GetSnappedTileCFrame(tile: BasePart, state: { _level: number, _rotation: number })
	local tileHeight = tile.Size.Y

	local pos = tile.Position + Vector3.new(0, tileHeight / 2 + 0.5, 0)
	local newCFrame = CFrame.new(pos)
	newCFrame = newCFrame * CFrame.Angles(0, math.rad(state._rotation), 0)
	newCFrame = newCFrame * CFrame.new(0, (state._level - 1) * PlotConfigs.PLOT_LEVEL_HEIGHT, 0)

	return newCFrame
end

function PlacementUtils.GetSnappedAttachmentCFrame(
	tile: BasePart,
	snappedPoint: Attachment,
	structureInfo,
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

function PlacementUtils.MoveModelToCFrame(model: Model, cframe: CFrame, instant: boolean)
	assert(model, "[PlacementUtils] MoveModelToCFrame : Model is nil")
	assert(cframe, "[PlacementUtils] MoveModelToCFrame : CFrame is nil")
	assert(model.PrimaryPart ~= nil, "[PlacementUtils] MoveModelToCFrame : Model.PrimaryPart is nil")

	if instant then
		model:PivotTo(cframe)
	else
		local tween = TweenService:Create(model.PrimaryPart, SETTINGS.TWEEN_INFO, { CFrame = cframe })
		tween:Play()
	end
end

function PlacementUtils.StripClientState(state: PlacementType.ClientState): PlacementType.ServerState
	return {
		_tile = state._tile,
		_structure_id = state._ghost_structure:GetAttribute("Id"),
		_rotation = state._rotation,
		_is_stacked = state._is_stacked,
		_level = state._level,
	}
end

return PlacementUtils
