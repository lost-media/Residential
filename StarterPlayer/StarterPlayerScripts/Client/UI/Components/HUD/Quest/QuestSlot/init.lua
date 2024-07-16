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

local Button = require(dirComponents.Button)

type CircleProps = {
	Position: UDim2?,
	ImageColor3: Color3?,
}

local function ProgressBar(props)
	local progress = props.Progress or 10
	local total = props.Total or 100

	local calculatedProgress = math.clamp(progress / total, 0, 1)

	return e("CanvasGroup", {
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		BackgroundColor3 = props.bgColor or Color3.fromRGB(238, 238, 238),
		Size = props.Size or UDim2.new(1, 0, 0.1, 0),
	}, {
		e("UICorner", {
			CornerRadius = UDim.new(0, 0),
		}),
		e("Frame", {
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			BackgroundColor3 = props.fgColor or Color3.fromRGB(146, 206, 142),
			Size = UDim2.new(calculatedProgress, 0, 1, 0),
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0, 0, 0, 0),
		}),
	})
end

type RewardProps = {
	Position: UDim2?,
	Image: string?,
	ImageColor3: Color3?,
	Amount: number?,
	Size: UDim2?,
	currencyName: string?,
}

local function Reward(props: RewardProps)
	local amountAsText = React.useMemo(function()
		return NumberFormatter.MonetaryFormat(props.Amount or 0)
	end, { props.Amount })

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(0.5, 0, 0.5, 0),
		Position = props.Position or UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
	}, {
		e("UISizeConstraint", {
			MaxSize = Vector2.new(120, 32),
			MinSize = Vector2.new(24, 16),
		}),
		e("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
		}),
		e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
		}),
		e("ImageLabel", {
			LayoutOrder = 1,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.4, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			Image = props.Image or "rbxassetid://18491523583",
			ImageColor3 = props.ImageColor3 or Color3.fromRGB(255, 255, 255),
		}, {
			e("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
		}),
		e("TextLabel", {
			Interactable = false,
			LayoutOrder = 2,
			--ClearTextOnFocus = false,
			--TextEditable = false,
			BackgroundTransparency = 1,
			Text = amountAsText,
			TextColor3 = Color3.fromRGB(92, 92, 92),
			FontFace = BuilderSans.SemiBold,
			Size = UDim2.new(0.6, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Left,

			TextScaled = true,
			TextWrapped = false,
		}, {
			e("UITextSizeConstraint", {
				MaxTextSize = 20,
				MinTextSize = 12,
			}),
		}),
	})
end

return function(props)
	local showContent, setShowContent = React.useState(true)

	return e("CanvasGroup", {
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),

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
			Color = Color3.fromRGB(146, 206, 142),
			Thickness = 2,
		}),
		Top = e("TextButton", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(181, 255, 176),
			Size = UDim2.new(1, 0, 0, 50),
			LayoutOrder = 0,
			Text = "",
			TextTransparency = 1,
			AutoButtonColor = false,

			[React.Event.Activated] = function()
				setShowContent(not showContent)
			end,
		}, {
			e("UIPadding", {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 16),
			}),
			QuestName = e("TextLabel", {
				BackgroundTransparency = 1,
				Text = "Welcome to your New City!",
				TextColor3 = Color3.fromRGB(73, 103, 71),
				FontFace = BuilderSans.Medium,
				TextScaled = true,
				Size = UDim2.new(0.75, 0, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
			}, {
				e("UITextSizeConstraint", {
					MaxTextSize = 24,
				}),
			}),

			QuestStep = e("TextLabel", {
				BackgroundTransparency = 1,
				Text = "1/7",
				TextColor3 = Color3.fromRGB(73, 103, 71),
				FontFace = BuilderSans.Bold,
				TextScaled = true,
				Size = UDim2.new(0.25, 0, 1, 0),
				Position = UDim2.new(0.75, 0, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Right,
			}, {
				e("UITextSizeConstraint", {
					MaxTextSize = 24,
				}),
			}),
		}),

		e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0.3, 0),

			LayoutOrder = 1,

			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = showContent,
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

			e(ProgressBar, {
				Progress = 1,
				Total = 7,
				Size = UDim2.new(1, 0, 0, 16),
				bgColor = Color3.fromRGB(238, 238, 238),
				fgColor = Color3.fromRGB(146, 206, 142),
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
				}, {
					e("TextLabel", {
						BackgroundTransparency = 1,
						Text = "Build a Road (0/1)",
						TextColor3 = Color3.fromRGB(73, 103, 71),
						FontFace = BuilderSans.Bold,
						TextScaled = true,
						Size = UDim2.new(0.5, 0, 1, 0),
						Position = UDim2.new(0, 0, 0, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}, {
						e("UITextSizeConstraint", {
							MaxTextSize = 24,
						}),
					}),

					e("TextLabel", {
						BackgroundTransparency = 1,
						Text = "You will earn:",
						TextColor3 = Color3.fromRGB(156, 156, 156),
						FontFace = BuilderSans.SemiBold,
						TextScaled = true,
						Size = UDim2.new(0.5, 0, 1, 0),
						Position = UDim2.new(0.5, 0, 0, 0),
						TextXAlignment = Enum.TextXAlignment.Right,
						TextYAlignment = Enum.TextYAlignment.Top,
					}, {
						e("UITextSizeConstraint", {
							MaxTextSize = 18,
						}),
						e("UIPadding", {
							PaddingTop = UDim.new(0, 8),
						}),
					}),
				}),

				e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0.8, 0, 0, 0),
					Position = UDim2.new(0.5, 0, 0.4, 0),
					AnchorPoint = Vector2.new(0.5, 0),

					AutomaticSize = Enum.AutomaticSize.Y,
				}, {
					e("UIGridLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						StartCorner = Enum.StartCorner.TopRight,

						FillDirectionMaxCells = 3,
						CellPadding = UDim2.new(0, 8, 0, 8),
						CellSize = UDim2.new(0.3, -8, 0, 32),
					}),
					e(Reward, {
						Image = "rbxassetid://18520836581",
						Amount = 99,
						currencyName = "Roadbucks",
					}),

					e(Reward, {
						Image = "rbxassetid://18521714111",
						Amount = 999999,
						currencyName = "Kloins",
					}),
				}),
			}),
		}),
	})
end
