local SETTINGS = {
	CircleAssetId = "rbxassetid://18416727845",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

type CircleProps = {
	Position: UDim2?,
	AnchorPoint: Vector2?,
	Size: UDim2?,
	ImageColor3: Color3?,
	imageTransparency: number?,

	onClick: () -> (),
	onMouseEnter: () -> (),
	onMouseLeave: () -> (),
}

return function(props: CircleProps)
	return e("ImageButton", {
		BackgroundTransparency = 1,
		Image = SETTINGS.CircleAssetId,
		Size = props.Size or UDim2.new(1, 0, 1, 0),
		ImageColor3 = props.ImageColor3 or Color3.fromRGB(255, 255, 255),
		Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		ImageTransparency = props.imageTransparency or 0,

		[React.Event.Activated] = props.onClick,
		[React.Event.MouseEnter] = props.onMouseEnter,
		[React.Event.MouseLeave] = props.onMouseLeave,
	}, {
		e("UIAspectRatioConstraint", {
			AspectRatio = 1,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width,
		}),

		unpack(props.children or {}),
	})
end
