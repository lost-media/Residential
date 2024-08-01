local SETTINGS = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local dirFonts = script.Parent.Parent.Parent.Parent.Fonts
local dirComponents = script.Parent.Parent.Parent
local dirProviders = dirComponents.Providers

local BuilderSans = require(dirFonts.BuilderSans)

local CloseButton = require(dirComponents.Button.CloseButton)
local FrameProvider = require(dirProviders.FrameProvider)
local Star = require(dirComponents.Star)
local StripeTexture = require(dirComponents.StripeTexture)
local TooltipProvider = require(dirProviders.TooltipProvider)

type StatBarProps = {
	isDark: boolean,
	size: UDim2,
}

return function(props: StatBarProps)
	return e("Frame", {
		BackgroundColor3 = props.isDark and Color3.fromRGB(230, 230, 230)
			or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Size = props.size or UDim2.new(0.5, 0, 0.25, 0),
	}, {
		e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 0),

			HorizontalFlex = "SpaceBetween",
		}),
		e("UIPadding", {
			PaddingRight = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
		}),
		e("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, 0, 1, 0),
			FontFace = BuilderSans.Bold,
			Text = "Kloins/min",
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextSize = 20,
			TextScaled = true,

			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			e("UITextSizeConstraint", {
				MaxTextSize = 24,
			}),
			e("UIPadding", {
				PaddingLeft = UDim.new(0, 16),
			}),
		}),

		e("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, 0, 1, 0),
			FontFace = BuilderSans.SemiBold,
			Text = "999.9K",
			TextColor3 = Color3.fromRGB(126, 126, 126),
			TextSize = 20,
			TextScaled = true,

			TextXAlignment = Enum.TextXAlignment.Right,
		}, {
			e("UITextSizeConstraint", {
				MaxTextSize = 24,
			}),
			e("UIPadding", {
				PaddingLeft = UDim.new(0, 16),
			}),
		}),
	})
end
