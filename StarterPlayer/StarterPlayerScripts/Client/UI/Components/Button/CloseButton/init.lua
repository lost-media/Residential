local SETTINGS = {
	CircleAssetId = "rbxassetid://18416727845",
	CloseAssetId = "rbxassetid://18312760469",

	ScaleFactor = 1.1,

	ClickSoundId = "rbxassetid://8755541422",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local dirComponents = script.Parent.Parent

local Circle = require(dirComponents.Circle)
local NewAlertIndicator = require(dirComponents.NewAlertIndicator)

type ButtonProps = {
	onClick: () -> ()?,
	Size: ("sm" | "md" | "lg")?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Image: string,
	Name: string?,

	imageTransparency: number?,
	hoverBgColor: Color3?,
	hoverStripeColor: Color3?,

	activeBgColor: Color3?,
	activeStripeColor: Color3?,

	active: boolean?,

	layoutOrder: number?,
	frameToOpen: string?,

	iconColor: Color3?,
}

return function(props: ButtonProps)
	local buttonRef = React.useRef()

	props.Size = props.Size or "md"

	local hovered, setHovered = React.useState(false)

	local styles = RoactSpring.useSpring({
		scale = if hovered then SETTINGS.ScaleFactor else 1,
		config = {
			damping = 5,
			mass = 0.5,
			tension = 500,
			clamp = true,
		},
	})

	return e(Circle, {
		Size = UDim2.new(1, 0, 1, 0),
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),

		LayoutOrder = props.layoutOrder,
		imageTransparency = props.imageTransparency or 1,

		onMouseEnter = function()
			setHovered(true)
		end,

		onMouseLeave = function()
			setHovered(false)
		end,

		onClick = props.onClick,
	}, {
		e("UIScale", {
			Scale = styles.scale,
		}),
		e("UISizeConstraint", {
			MaxSize = props.Size == "sm" and Vector2.new(48, 48)
				or props.Size == "md" and Vector2.new(56, 56)
				or props.Size == "lg" and Vector2.new(72, 72),
			MinSize = Vector2.new(40, 40),
		}),
		e("UIPadding", {
			PaddingTop = UDim.new(0.3, 0),
			PaddingBottom = UDim.new(0.3, 0),
			PaddingLeft = UDim.new(0.3, 0),
			PaddingRight = UDim.new(0.3, 0),
		}),
		e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = SETTINGS.CloseAssetId,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ImageColor3 = props.iconColor or Color3.new(0, 0, 0),
		}),
	})
end
