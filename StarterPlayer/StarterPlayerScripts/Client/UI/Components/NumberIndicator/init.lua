local SETTINGS = {
	StripeAssetId = "rbxassetid://18491043608",

	DefaultBgColor = Color3.fromRGB(255, 255, 255),
	DefaultStripeColor = Color3.fromRGB(243, 243, 243),

	DefaultHoverBgColor = Color3.fromRGB(150, 255, 140),
	DefaultHoverStripeColor = Color3.fromRGB(102, 255, 88),

	ScaleFactor = 1.1,

	ClickSoundId = "rbxassetid://8755541422",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)

local e = React.createElement

local dirComponents = script.Parent
local dirProviders = dirComponents.Providers

local TooltipProvider = require(dirProviders.TooltipProvider)

local OvalFrame = require(dirComponents.OvalFrame)
local Tooltip = require(dirComponents.Tooltip)

type NumberIndicatorProps = {
	Image: string,
	Name: string?,
	Position: UDim2?,
	toolTipOffset: Vector2?,
	Size: UDim2?,

	Text: string,

	onClick: () -> ()?,
}

return function(props: NumberIndicatorProps)
	local tooltip = React.useContext(TooltipProvider.Context)
	local buttonRef = React.useRef()

	local hovered, setHovered = React.useState(false)

	return e(OvalFrame, {
		Size = props.Size or UDim2.new(1, 0, 1, 0),
		ImageColor3 = Color3.fromRGB(200, 200, 200),
		Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
	}, {
		e("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
		}),
		e("UISizeConstraint", {
			MaxSize = Vector2.new(176, 48),
			MinSize = Vector2.new(106, 32),
		}),

		e("CanvasGroup", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(1, 0, 1, 0),
		}, {
			e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			e("ImageLabel", {
				Image = SETTINGS.StripeAssetId,
				BackgroundTransparency = 1,
				ImageColor3 = Color3.fromRGB(245, 245, 245),
				Size = UDim2.new(1, 0, 1, 0),
				ScaleType = Enum.ScaleType.Tile,
				TileSize = UDim2.new(2, 0, 5, 0),
			}),
			e("TextButton", {
				ref = buttonRef,
				Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				TextTransparency = 1,
				Text = "",

				[React.Event.MouseEnter] = function()
					setHovered(true)
					tooltip.setOffset(props.toolTipOffset or Vector2.new(-32, 48))
					tooltip.setVisible(true)
					tooltip.setText(props.Name)
				end,

				[React.Event.MouseLeave] = function()
					setHovered(false)
					tooltip.setVisible(false)
				end,

				[React.Event.Activated] = function()
					if props.onClick then
						props.OnClick()
					end

					local clickSound = Instance.new("Sound")
					clickSound.SoundId = SETTINGS.ClickSoundId
					clickSound.Parent = game:GetService("SoundService")
					clickSound.PlayOnRemove = true
					clickSound:Destroy()
				end,
			}, {
				e("UIPadding", {
					PaddingTop = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 12),
				}),
				e("ImageLabel", {
					BackgroundTransparency = 1,
					Image = props.Image or "rbxassetid://18491523583",
					Size = UDim2.new(0.25, 0, 1, 0),
					Position = UDim2.new(0, 0, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
				}, {
					e("UIAspectRatioConstraint", {
						AspectRatio = 1.33,
					}),
				}),
				e("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0.75, 0, 1, 0),
					Position = UDim2.new(0.25, 0, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					Text = props.Text or "$999.9M",

					FontFace = Font.fromName("BuilderSans", Enum.FontWeight.SemiBold),
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Right,
				}, {
					e("UITextSizeConstraint", {
						MaxTextSize = 32,
					}),
				}),
			}),
		}),
	})
end
