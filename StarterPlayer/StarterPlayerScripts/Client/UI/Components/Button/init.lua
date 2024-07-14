local SETTINGS = {
	CircleAssetId = "rbxassetid://18416727845",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local Tooltip = require(script.Parent.Tooltip)

type ButtonProps = {
	OnClick: () -> ()?,
	Size: ("sm" | "md" | "lg")?,
	Position: UDim2?,
	Image: string,
	Name: string?,
}

return function(props: ButtonProps)
	local buttonRef = React.useRef()

	props.Size = props.Size or "md"

	local hovered, setHovered = React.useState(false)

	local styles = RoactSpring.useSpring({
		color = if hovered then Color3.fromRGB(176, 243, 121) else Color3.fromRGB(255, 255, 255),
		scale = if hovered then 1.1 else 1,
		config = {
			damping = 5,
			mass = 0.5,
			tension = 500,
		},
	})

	return e("ImageLabel", {
		BackgroundTransparency = 1,
		Image = SETTINGS.CircleAssetId,
		Size = UDim2.new(1, 0, 1, 0),
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
	}, {
		e("UIAspectRatioConstraint", {
			AspectRatio = 1,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width,
		}),
		e("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
		}),
		e("UIScale", {
			Scale = styles.scale,
		}),
		e("UISizeConstraint", {
			MaxSize = props.Size == "sm" and Vector2.new(48, 48)
				or props.Size == "md" and Vector2.new(56, 56)
				or props.Size == "lg" and Vector2.new(72, 72),
			MinSize = Vector2.new(24, 24),
		}),
		e("ImageButton", {
			ref = buttonRef,
			Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://18476903270",
			ImageColor3 = styles.color,

			[React.Event.MouseEnter] = function()
				setHovered(true)
			end,

			[React.Event.MouseLeave] = function()
				setHovered(false)
			end,

			[React.Event.MouseButton1Click] = props.OnClick,
		}, {
			e("UIPadding", {
				PaddingTop = UDim.new(0.2, 0),
				PaddingBottom = UDim.new(0.2, 0),
				PaddingLeft = UDim.new(0.2, 0),
				PaddingRight = UDim.new(0.2, 0),
			}),
			e("ImageLabel", {
				BackgroundTransparency = 1,
				Image = props.Image or "rbxassetid://18476991644",
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ImageColor3 = Color3.new(0, 0, 0),
			}),

			e(Tooltip, {
				Text = props.Name or "Button",
				Visible = hovered,
				Direction = "top",
				ParentRef = buttonRef,
			}),
		}),
	})
end
