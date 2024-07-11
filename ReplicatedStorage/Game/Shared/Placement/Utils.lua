local SETTINGS = {
	TWEEN_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PlotConfigs = require(ReplicatedStorage.Game.Shared.Configs.Plot)

local PlacementType = require(script.Parent.Types)

local PlacementUtils = {}

----- Private functions -----

local function ModelIsPlot(model: Model)
	if model == nil then
		return false
	end

	if model:IsA("Model") == false then
		return false
	end

	local tiles = model:FindFirstChild("Tiles")

	if tiles == nil then
		return false
	end

	if tiles:IsA("Folder") == false then
		return false
	end

	local structures = model:FindFirstChild("Structures")

	if structures == nil then
		return false
	end

	if structures:IsA("Folder") == false then
		return false
	end

	return true
end

local function TileExists(tile: string, plot: Model)
	assert(ModelIsPlot(plot), "[PlacementUtils] TileExists : Model is not a plot")
	assert(tile ~= nil, "[PlacementUtils] TileExists : Tile is nil")

	local tiles = plot:FindFirstChild("Tiles")

	if tiles == nil then
		return false
	end

	return tiles:FindFirstChild(tile) ~= nil
end

----- Public functions -----

function PlacementUtils.GetSnappedTileCFrame(
	tile: BasePart,
	state: { _level: number, _rotation: number }
)
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
	state: PlacementType.ClientState
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

	newCFrame = newCFrame * CFrame.Angles(0, math.rad(state._rotation), 0)

	if structureInfo.FullArea == true then
		newCFrame = newCFrame * CFrame.new(0, state._level * PlotConfigs.PLOT_LEVEL_HEIGHT, 0)
	end

	return newCFrame
end

function PlacementUtils.MoveModelToCFrame(model: Model, cframe: CFrame, instant: boolean)
	assert(model, "[PlacementUtils] MoveModelToCFrame : Model is nil")
	assert(cframe, "[PlacementUtils] MoveModelToCFrame : CFrame is nil")
	assert(
		model.PrimaryPart ~= nil,
		"[PlacementUtils] MoveModelToCFrame : Model.PrimaryPart is nil"
	)

	if instant then
		model:PivotTo(cframe)
	else
		local tween =
			TweenService:Create(model.PrimaryPart, SETTINGS.TWEEN_INFO, { CFrame = cframe })
		tween:Play()
	end
end

function PlacementUtils.StripClientState(
	state: PlacementType.ClientState
): PlacementType.ServerState
	return {
		_tile = state._tile,
		_structure_id = state._ghost_structure:GetAttribute("Id"),
		_rotation = state._rotation,
		_is_stacked = state._is_stacked,
		_level = state._level,

		-- Stacked structure
		_attachments = state._attachments,
		_stacked_structure = state._stacked_structure,
		_mounted_attachment = state._mounted_attachment,
	}
end

function PlacementUtils.CanPlaceStructure(plot: Model, state: PlacementType.ServerState): boolean
	if plot == nil then
		error("Plot is nil")
	end

	if ModelIsPlot(plot) == false then
		error("Model is not a plot")
	end

	if state == nil then
		error("State is nil")
	end

	if state._tile == nil then
		return false
	end

	if state._structure_id == nil then
		return false
	end

	if state._rotation == nil then
		return false
	end

	if state._is_stacked == nil then
		return false
	end

	if state._level == nil then
		return false
	end

	if state._is_stacked == true then
		if state._stacked_structure == nil then
			return false
		end

		if state._mounted_attachment == nil then
			return false
		end

		if state._mounted_attachment:GetAttribute("Occupied") == true then
			return false
		end
	else
		-- Check if the tile is occupied

		local is_tile_occupied = state._tile:GetAttribute("Occupied")

		if is_tile_occupied == true then
			-- Check if there are any structures on the same level
			for _, structure in plot.Structures:GetChildren() do
				if structure:IsA("Model") then
					local structure_level = structure:GetAttribute("Level")

					local tile = structure:GetAttribute("Tile")

					local tile_part = plot.Tiles:FindFirstChild(tostring(tile))

					if structure_level == state._level and state._tile == tile_part then
						return false
					end
				end
			end
		end
	end

	return true
end

return PlacementUtils
