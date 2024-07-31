local SETTINGS = {
	MouseOffset = Vector2.new(12, 0), -- The offset of the tooltip from the mouse
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local dirComponents = script.Parent
local dirFonts = dirComponents.Parent.Fonts

local BuilderSans = require(dirFonts.BuilderSans)

type TooltipProps = {
	text: string,
	position: UDim2,
	visible: boolean,
}

return function(props: TooltipProps)
	local ref = React.useRef(nil)

	local styles = RoactSpring.useSpring({
		from = { scale = 0.25, opacity = 1 },
		to = {
			scale = if props.visible then 1 else 0.25,
			opacity = if props.visible then 0 else 1,
		},
		config = {
			damping = 100,
			mass = 1,
			tension = 500,
			clamp = true,
		},
	})

	return e("CanvasGroup", {
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		GroupTransparency = styles.opacity,
		ref = ref,
		ZIndex = 100,
		AutomaticSize = Enum.AutomaticSize.X,
		Position = props.position,
		Size = UDim2.new(0, 0, 0, 30),
		AnchorPoint = Vector2.new(0, 0),
	}, {
		e("UIStroke", {
			Color = Color3.fromRGB(190, 190, 190),
			Transparency = styles.opacity,
			Thickness = 2,
		}),
		e("UICorner", {
			CornerRadius = UDim.new(0, 16),
		}),
		e("UIScale", {
			Scale = styles.scale,
		}),
		e("UIPadding", {
			PaddingTop = UDim.new(0.1, 0),
			PaddingBottom = UDim.new(0.1, 0),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
		}),
		e("TextBox", {
			TextTransparency = styles.opacity,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = BuilderSans.SemiBold,
			Text = props.text,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextSize = 20,
			TextWrapped = false,
			TextEditable = false,
			Size = UDim2.new(1, 0, 1, 0),
			TextScaled = false,
			AutomaticSize = Enum.AutomaticSize.X,
			ClearTextOnFocus = false,
			ZIndex = 999,
			Interactable = false,
		}, {
			e("UITextSizeConstraint", {
				MaxTextSize = 20,
			}),
		}),
	})
end
