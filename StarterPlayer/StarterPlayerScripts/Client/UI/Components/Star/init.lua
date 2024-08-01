local SETTINGS = {
	StarAssetId = "rbxassetid://18744383356",
	SmallerStarAssetId = "rbxassetid://18744630014",
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

	starValue: number?,
	value: number?,
}

return function(props: CircleProps)
	local starValue = props.starValue or 1
	local value = props.value or 0
	local calculatedValue = 0

	if math.floor(value) >= starValue then
		calculatedValue = 1
	else
		local decimalValue = starValue - value
		if decimalValue > 1 then
			calculatedValue = 0
		else
			calculatedValue = value - math.floor(value)
		end
	end

	print(calculatedValue, 1 / calculatedValue)

	return e("ImageButton", {
		BackgroundTransparency = 1,
		Image = SETTINGS.StarAssetId,
		Size = props.Size or UDim2.new(1, 0, 1, 0),
		ImageColor3 = props.ImageColor3 or Color3.fromRGB(0, 0, 0),
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

		e("UIPadding", {
			PaddingTop = UDim.new(0, 3),
			PaddingBottom = UDim.new(0, 3),
			PaddingLeft = UDim.new(0, 3),
			PaddingRight = UDim.new(0, 3),
		}),

		e("ImageButton", {
			BackgroundTransparency = 1,
			Image = SETTINGS.SmallerStarAssetId,
			Size = UDim2.new(1, 0, 1, 0),
			ImageColor3 = props.ImageColor3 or Color3.fromRGB(255, 255, 255),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ImageTransparency = props.imageTransparency or 0,

			[React.Event.Activated] = props.onClick,
			[React.Event.MouseEnter] = props.onMouseEnter,
			[React.Event.MouseLeave] = props.onMouseLeave,
		}, {
			e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(calculatedValue, 0, 1, 0),
				ClipsDescendants = true,
			}, {
				e("ImageButton", {
					BackgroundTransparency = 1,
					Image = SETTINGS.SmallerStarAssetId,
					Size = UDim2.new(1 / calculatedValue, 0, 1, 0),
					ImageColor3 = Color3.fromRGB(255, 210, 85),
					ImageTransparency = props.imageTransparency or 0,

					[React.Event.Activated] = props.onClick,
					[React.Event.MouseEnter] = props.onMouseEnter,
					[React.Event.MouseLeave] = props.onMouseLeave,
				}),
			}),
		}),
	})
end
