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
		color = if hovered then Color3.fromRGB(206, 255, 151) else Color3.fromRGB(255, 255, 255),
		config = {
			damping = 5,
			mass = 0.5,
			tension = 700,
		},
	})

	return e("ImageButton", {
		ref = buttonRef,
		Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 100, 0, 100),
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
		e("UIAspectRatioConstraint", {
			AspectRatio = 1,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width,
		}),
		e("UIPadding", {
			PaddingTop = UDim.new(0.2, 0),
			PaddingBottom = UDim.new(0.2, 0),
			PaddingLeft = UDim.new(0.2, 0),
			PaddingRight = UDim.new(0.2, 0),
		}),
		e("UISizeConstraint", {
			MaxSize = props.Size == "sm" and Vector2.new(48, 48)
				or props.Size == "md" and Vector2.new(56, 56)
				or Vector2.new(80, 80),
			MinSize = Vector2.new(24, 24),
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
	})
end
