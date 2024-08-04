local SETTINGS = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine)

local TableUtil = require(LMEngine.SharedDir.TableUtil)

local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local dirComponents = script.Parent.Parent
local dirProviders = dirComponents.Providers

local CloseButton = require(dirComponents.Button.CloseButton)
local FrameProvider = require(dirProviders.FrameProvider)
local StripeTexture = require(dirComponents.StripeTexture)

local PlotSlot = require(script.PlotSlot)

type QuestFrameProps = {
	isOpen: boolean,
}

return function(props: QuestFrameProps)
	local plots, setPlots = React.useState({})
	local frames = React.useContext(FrameProvider.Context)

	local scrollingFrameRef = React.useRef(nil)
	local contentSize, setContentSize = React.useState(UDim2.new(0, 0, 0, 0))

	React.useEffect(function()
		LMEngine.OnStart():andThen(function()
			-- Load the player's plots
			---@type PlotController
			local PlotController = LMEngine.GetController("PlotController")
			PlotController:GetPlotsAsync():andThen(function(newPlots)
				setPlots(newPlots)
			end)
		end)
	end, {})

	local loadPlot = React.useCallback(function(plotId: string)
		print(plotId)
		local DataService = LMEngine.GetService("DataService")
		DataService:LoadPlot(plotId)
	end, {})

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
			BackgroundColor3 = Color3.fromRGB(226, 91, 213),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0.15, 0),
		}, {
			-- Stripe
			e(StripeTexture, {
				tileSize = UDim2.new(2, 0, 10, 0),
				color = Color3.fromRGB(218, 88, 207),
			}),
			e("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, 0, 1, 0),
				FontFace = Font.fromName("BuilderSans", Enum.FontWeight.SemiBold),
				Text = "Select plot",
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
					frames.setFrameOpen("Quests", false)
					frames.setFrameOpen("BottomBarButtons", true)
				end,
			}),
		}),

		-- Small divider
		e("Frame", {
			BackgroundColor3 = Color3.fromRGB(197, 80, 187),
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
					Padding = UDim.new(0, 16),

					[React.Change.AbsoluteContentSize] = function(rbx)
						setContentSize(UDim2.new(0, 0, 0, rbx.AbsoluteContentSize.Y + 80))
					end,
				}),
				e("UIPadding", {
					PaddingRight = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 4),
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
				}),

				TableUtil.Map(TableUtil.Keys(plots), function(plotId)
					local plot = plots[plotId]
					return e(PlotSlot, {
						plot = plot,
						plotId = plotId,

						onClick = function()
							loadPlot(plotId)
						end,
					})
				end),
			}),
		}),
	})
end
