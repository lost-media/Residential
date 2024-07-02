local StackingUtils = {}

type Orientation = {
	Strict: boolean,
	SnapPointsToMatch: { { [string]: string } }?,
}

function StackingUtils.CreateStackingData(
	IncreaseLevel: boolean?,
	snapPoints: { string },
	occupiedSnapPoints: { [string]: string },
	Orientation: Orientation?
)
	return {
		IncreaseLevel = IncreaseLevel or false,
		Orientation = Orientation or { Strict = false },
		WhitelistedSnapPoints = snapPoints or {},
		RequiredSnapPoints = snapPoints or {},
		OccupiedSnapPoints = occupiedSnapPoints or {},
	}
end

return StackingUtils
