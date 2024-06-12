local PlotTypes = {}

export type Plot = Model & {
	Tiles: Folder,
	Structures: Folder,
	Debris: Folder,
	Center: BasePart,
}

export type Tile = BasePart

function PlotTypes.isPlotValid(plot: Plot): boolean
	if plot == nil then
		return false
	end

	if plot:FindFirstChild("Tiles") == nil then
		return false
	end

	if plot:FindFirstChild("Structures") == nil then
		return false
	end

	if plot:FindFirstChild("Debris") == nil then
		return false
	end

	local center = plot:WaitForChild("Center")

	if center == nil then
		return false
	end

	return true
end

return PlotTypes
