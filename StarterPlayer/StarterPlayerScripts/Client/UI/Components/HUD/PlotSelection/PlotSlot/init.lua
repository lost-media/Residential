local SETTINGS = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LMEngine = require(ReplicatedStorage.LMEngine)
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local NumberFormatter = require(LMEngine.SharedDir.NumberFormatter)

local e = React.createElement

local dirComponents = script.Parent.Parent.Parent
local dirFonts = dirComponents.Parent.Fonts
local dirProviders = dirComponents.Providers

local BuilderSans = require(dirFonts.BuilderSans)

type CircleProps = {
	Position: UDim2?,
	ImageColor3: Color3?,
}

type RewardProps = {
	Position: UDim2?,
	Image: string?,
	ImageColor3: Color3?,
	Amount: number?,
	Size: UDim2?,
	currencyName: string?,
}

type QuestSlotProps = {
	color: Color3?,
	strokeColor: Color3?,
	textColor: Color3?,

	questName: string?,
	progressColor: Color3?,

	defaultShowContent: boolean?,
}

return function(props: QuestSlotProps)
	return e("CanvasGroup", {
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),

		AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 0),
		}),
		e("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		e("UIStroke", {
			Color = props.strokeColor or Color3.fromRGB(146, 206, 142),
			Thickness = 2,
		}),
		Top = e("TextButton", {
			BorderSizePixel = 0,
			BackgroundColor3 = props.color or Color3.fromRGB(181, 255, 176),
			Size = UDim2.new(1, 0, 0, 50),
			LayoutOrder = 0,
			Text = "",
			TextTransparency = 1,
			AutoButtonColor = false,
		}, {
			e("UIPadding", {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 16),
			}),
			QuestName = e("TextLabel", {
				BackgroundTransparency = 1,
				Text = props.questName or "Plot Name",
				TextColor3 = props.textColor or Color3.fromRGB(73, 103, 71),
				FontFace = BuilderSans.Medium,
				TextScaled = true,
				Size = UDim2.new(0.5, 0, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
			}, {
				e("UITextSizeConstraint", {
					MaxTextSize = 24,
				}),
			}),

			QuestStep = e("TextLabel", {
				BackgroundTransparency = 1,
				Text = "Last played 1 day ago",
				TextColor3 = props.textColor or Color3.fromRGB(73, 103, 71),
				FontFace = BuilderSans.Regular,
				TextScaled = true,
				Size = UDim2.new(0.5, 0, 1, 0),
				Position = UDim2.new(0.5, 0, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Right,
			}, {
				e("UITextSizeConstraint", {
					MaxTextSize = 20,
				}),
			}),
		}),

		e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0.3, 0),

			LayoutOrder = 1,

			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			e("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				Padding = UDim.new(0, 8),
			}),
			e("UIPadding", {
				PaddingTop = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 4),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
			}),

			e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0.1, 0),

				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				e("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),
				e("UIPadding", {
					PaddingTop = UDim.new(0, 8),
					PaddingBottom = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
				}),
				e("Frame", {
					Size = UDim2.new(1, 0, 0, 48),
					BackgroundTransparency = 1,
				}, {}),
			}),
		}),
	})
end
