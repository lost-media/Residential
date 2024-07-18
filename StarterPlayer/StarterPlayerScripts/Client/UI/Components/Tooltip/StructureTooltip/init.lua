local SETTINGS = {
	MouseOffset = Vector2.new(12, 0), -- The offset of the tooltip from the mouse
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local dirComponents = script.Parent.Parent
local dirFonts = dirComponents.Parent.Fonts

local BuilderSans = require(dirFonts.BuilderSans)

type TooltipProps = {
	Visible: boolean,
	Text: string,
	Offset: Vector2?,

	position: UDim2,
}

return function(props: TooltipProps)
	local ref = React.useRef(nil)

	local styles = RoactSpring.useSpring({
		from = { scale = 0.25, opacity = 1 },
		to = {
			scale = if props.Visible then 1 else 0.25,
			opacity = if props.Visible then 0 else 1,
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
		Position = props.position,
		Size = UDim2.new(0.5, 0, 0.25, 0),
		AnchorPoint = Vector2.new(0, 0),
	}, {
		e("UISizeConstraint", {
			MaxSize = Vector2.new(326, 128),
		}),

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
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
		}),
		e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 8),
		}),

		-- TODO: make this an image
		e("ImageLabel", {

			Size = UDim2.new(0.4, 0, 1, 0),
			Position = UDim2.new(0, 8, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 0,
			Image = "rbxassetid://6996359364",

			BackgroundColor3 = Color3.fromRGB(200, 200, 200),
		}, {
			e("UIPadding", {
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 8),
			}),

			e("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
			e("UICorner", {
				CornerRadius = UDim.new(0, 16),
			}),
			e("TextLabel", {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, 0, 0.5, 0),
				Text = "$5000",
				FontFace = BuilderSans.SemiBold,
				TextColor3 = Color3.fromRGB(37, 143, 77),
				TextScaled = true,

				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Bottom,
			}, {
				e("UITextSizeConstraint", {
					MaxTextSize = 32,
				}),
			}),
		}),

		e("Frame", {
			Size = UDim2.new(0.6, 0, 1, 0),
			BackgroundTransparency = 1,
		}, {
			e("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				Padding = UDim.new(0, 4),
			}),

			e("TextLabel", {
				Text = props.Text,
				TextSize = 16,
				TextColor3 = Color3.fromRGB(66, 146, 86),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0.25, 0),
				FontFace = BuilderSans.Bold,
				TextWrapped = true,
				TextScaled = true,
			}, {
				e("UITextSizeConstraint", {
					MaxTextSize = 24,
				}),
			}),

			e("TextLabel", {
				Text = props.description
					or "A description of the structure. This is a placeholder until we get it all figured out.",
				TextSize = 16,
				TextColor3 = Color3.fromRGB(133, 133, 133),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0.4, 0),
				FontFace = BuilderSans.Regular,
				TextWrapped = true,
				TextScaled = true,
			}, {
				e("UITextSizeConstraint", {
					MaxTextSize = 16,
				}),
			}),
		}),
	})
end
