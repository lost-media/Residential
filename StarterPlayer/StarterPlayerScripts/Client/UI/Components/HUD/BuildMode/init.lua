local SETTINGS = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local dirComponents = script.Parent.Parent

local StripeTexture = require(dirComponents.StripeTexture)

return function(props)
	local scrollingFrameRef = React.useRef(nil)
	local contentSize, setContentSize = React.useState(UDim2.new(0, 0, 0, 0))

	return e("CanvasGroup", {
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,

		Size = UDim2.new(0.55, 0, 0.55, 0),
	}, {
		e("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(0, 0, 0),
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 3,
		}),
		e("UISizeConstraint", {
			MaxSize = Vector2.new(800, 800),
			MinSize = Vector2.new(240, 240),
		}),

		e("UIAspectRatioConstraint", {
			AspectRatio = 1.3,
		}),
		e("UICorner", {
			CornerRadius = UDim.new(0, 16),
		}),
		e("UIListLayout", {
			FillDirection = props.FillDirection or Enum.FillDirection.Vertical,
			HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Center,
			VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Top,
			Padding = props.ListPadding or UDim.new(0, 0),
		}),
	})
end
