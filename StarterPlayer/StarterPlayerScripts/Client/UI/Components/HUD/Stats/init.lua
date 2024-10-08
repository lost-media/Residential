local SETTINGS = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local dirFonts = script.Parent.Parent.Parent.Fonts
local dirComponents = script.Parent.Parent
local dirProviders = dirComponents.Providers

local BuilderSans = require(dirFonts.BuilderSans)

local CloseButton = require(dirComponents.Button.CloseButton)
local FrameProvider = require(dirProviders.FrameProvider)
local Star = require(dirComponents.Star)
local StripeTexture = require(dirComponents.StripeTexture)
local TooltipProvider = require(dirProviders.TooltipProvider)

local StatBar = require(script.StatBar)

local QuestSlot = require(script.QuestSlot)

type QuestFrameProps = {
	isOpen: boolean,
}

return function(props: QuestFrameProps)
	local frames = React.useContext(FrameProvider.Context)
	local tooltip: TooltipProvider.TooltipContext = React.useContext(TooltipProvider.Context)

	local scrollingFrameRef = React.useRef(nil)
	local contentSize, setContentSize = React.useState(UDim2.new(0, 0, 0, 0))

	local value = 2.8

	return e("CanvasGroup", {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,

		Size = UDim2.new(0.8, 0, 0.65, 0),

		Visible = props.isOpen,
	}, {
		e("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(0, 0, 0),
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 3,
		}),
		e("UISizeConstraint", {
			MaxSize = Vector2.new(900, 900),
		}),

		e("UIAspectRatioConstraint", {
			AspectRatio = 1.4,
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

		-- Top bar
		e("CanvasGroup", {
			BackgroundColor3 = Color3.fromRGB(113, 161, 199),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0.15, 0),
		}, {
			-- Stripe
			e(StripeTexture, {
				tileSize = UDim2.new(2, 0, 10, 0),
				color = Color3.fromRGB(108, 155, 191),
			}),
			e("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, 0, 1, 0),
				FontFace = Font.fromName("BuilderSans", Enum.FontWeight.SemiBold),
				Text = "Stats",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 36,

				TextXAlignment = Enum.TextXAlignment.Left,
			}, {
				e("UITextSizeConstraint", {
					MaxTextSize = 32,
				}),
				e("UIPadding", {
					PaddingLeft = UDim.new(0, 16),
				}),
			}),

			e(CloseButton, {
				Position = UDim2.new(1, 0, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				iconColor = Color3.fromRGB(255, 255, 255),
				onClick = function()
					frames.setFrameOpen("Stats", false)
					frames.setFrameOpen("BottomBarButtons", true)
				end,
			}),
		}),

		-- Small divider
		e("Frame", {
			BackgroundColor3 = Color3.fromRGB(97, 139, 172),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 4),
		}),

		-- Main content
		e(StripeTexture, {
			color = Color3.fromRGB(250, 250, 250),
			tileSize = UDim2.new(2, 0, 2, 0),
		}, {
			e("UIPadding", {
				PaddingTop = UDim.new(0, 16),
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 8),
			}),
			e("ScrollingFrame", {
				ref = scrollingFrameRef,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				CanvasSize = contentSize,

				ScrollBarImageColor3 = Color3.fromRGB(197, 80, 187),
				ScrollBarImageTransparency = 0.5,

				ScrollBarThickness = 4,
				ScrollingDirection = Enum.ScrollingDirection.Y,
			}, {
				e("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					Padding = UDim.new(0, 8),

					[React.Change.AbsoluteContentSize] = function(rbx)
						setContentSize(UDim2.new(0, 0, 0, rbx.AbsoluteContentSize.Y + 80))
					end,
				}),
				e("UIPadding", {
					PaddingRight = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 4),
				}),

				e("Frame", {
					BackgroundColor3 = Color3.fromRGB(238, 238, 238),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0.2, 0),

					[React.Event.MouseEnter] = function()
						tooltip.show({
							text = string.format(
								"<font color='rgb(195, 150, 55)'><b>%.1f</b></font> stars (Click to view more)",
								value
							),
							visible = true,
						})
					end,

					[React.Event.MouseLeave] = function()
						tooltip.show({
							visible = false,
						})
					end,
				}, {
					e("UICorner", {
						CornerRadius = UDim.new(0, 16),
					}),
					e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						Padding = UDim.new(0.05, 0),
					}),
					e("UIPadding", {
						PaddingRight = UDim.new(0, 10),
						PaddingLeft = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 10),
						PaddingBottom = UDim.new(0, 10),
					}),
					e(Star, {
						Size = UDim2.new(0.2, 0, 1, 0),

						value = value,
						starValue = 1,
					}),
					e(Star, {
						Size = UDim2.new(0.2, 0, 1, 0),
						value = value,
						starValue = 2,
					}),
					e(Star, {
						Size = UDim2.new(0.2, 0, 1, 0),
						value = value,
						starValue = 3,
					}),
					e(Star, {
						Size = UDim2.new(0.2, 0, 1, 0),
						value = value,
						starValue = 4,
					}),
					e(Star, {
						Size = UDim2.new(0.2, 0, 1, 0),
						value = value,
						starValue = 5,
					}),
				}),

				e("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0.12, 0),
					FontFace = BuilderSans.Bold,
					Text = "Your city could be improved! ",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextSize = 24,
					TextScaled = true,

					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
				}, {
					e("UITextSizeConstraint", {
						MaxTextSize = 24,
					}),
					e("UIPadding", {
						PaddingLeft = UDim.new(0, 16),
					}),
				}),

				e("CanvasGroup", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(1, 0, 0.38, 0),
					BorderSizePixel = 0,
				}, {
					e("UICorner", {
						CornerRadius = UDim.new(0, 16),
					}),
					e("UIStroke", {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.fromRGB(0, 0, 0),
						LineJoinMode = Enum.LineJoinMode.Round,
						Thickness = 3,
					}),
					e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Top,

						Wraps = true,
					}),
					e(StatBar, {
						size = UDim2.new(0.5, 0, 1 / 3, 0),
					}),
					e(StatBar, {
						size = UDim2.new(0.5, 0, 1 / 3, 0),
					}),
					e(StatBar, {
						isDark = true,
						size = UDim2.new(0.5, 0, 1 / 3, 0),
					}),
					e(StatBar, {
						isDark = true,
						size = UDim2.new(0.5, 0, 1 / 3, 0),
					}),
					e("TextButton", {
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1 / 3, 0),
						Text = "View More",
						Font = Enum.Font.SourceSans,
						TextSize = 24,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
					}, {
						e("UITextSizeConstraint", {
							MaxTextSize = 24,
						}),
					}),
				}),
			}),
		}),
	})
end
