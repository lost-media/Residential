local SETTINGS = {
	CityAssetId = "rbxassetid://18539171639",
	ResidentialAssetId = "rbxassetid://18312606125",
	IndustrialAssetId = "rbxassetid://18313003018",
	CommercialAssetId = "rbxassetid://18539219318",
	DecorationAssetId = "rbxassetid://18312572742",
	RoadAssetId = "rbxassetid://18312539919",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local dirComponents = script.Parent.Parent
local dirFonts = dirComponents.Parent.Fonts

local BuilderSans = require(dirFonts.BuilderSans)

local Button = require(dirComponents.Button)
local StripeTexture = require(dirComponents.StripeTexture)

local StructureEntry = require(script.StructureEntry)

local buttonTabs = {
	{
		Name = "Road",
		Image = SETTINGS.RoadAssetId,
		toolTipOffset = Vector2.new(-32, -32),

		active = false,
	},
	{
		Name = "City",
		Image = SETTINGS.CityAssetId,
		toolTipOffset = Vector2.new(-32, -32),

		active = true,
	},
	{
		Name = "Residential",
		Image = SETTINGS.ResidentialAssetId,
		toolTipOffset = Vector2.new(-32, -32),
	},
	{
		Name = "Industrial",
		Image = SETTINGS.IndustrialAssetId,
		toolTipOffset = Vector2.new(-32, -32),
	},
	{
		Name = "Commercial",
		Image = SETTINGS.CommercialAssetId,
		toolTipOffset = Vector2.new(-32, -32),
	},
	{
		Name = "Decoration",
		Image = SETTINGS.DecorationAssetId,
		toolTipOffset = Vector2.new(-32, -32),
	},
}

return function(props)
	local scrollingFrameRef = React.useRef(nil)
	local contentSize, setContentSize = React.useState(UDim2.new(0, 0, 0, 0))

	local newButtonTabs = {}

	for i, tab in pairs(buttonTabs) do
		table.insert(newButtonTabs, e(Button, tab))
	end

	return e("Frame", {
		Position = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,

		Size = UDim2.new(1, 0, 0.5, 0),
	}, {
		e("UIListLayout", {
			FillDirection = props.FillDirection or Enum.FillDirection.Vertical,
			HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Center,
			VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Top,
			Padding = props.ListPadding or UDim.new(0.05, 0),
		}),

		e("Frame", {
			Size = UDim2.new(1, 0, 0.3, 0),
			BackgroundTransparency = 1,
		}, {

			e("UIListLayout", {
				FillDirection = props.FillDirection or Enum.FillDirection.Horizontal,
				HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Center,
				VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Bottom,
				Padding = props.ListPadding or UDim.new(0.015, 0),
			}),

			newButtonTabs,
		}),

		e("CanvasGroup", {
			Position = UDim2.new(0, 0, 1, 0),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,

			Size = UDim2.new(1, 0, 0.65, 0),
		}, {
			e("UICorner", {
				CornerRadius = UDim.new(0, 16),
			}),
			e("UIStroke", {
				Thickness = 0, --2,
				Color = Color3.fromRGB(0, 0, 0),
			}),
			e(StripeTexture, {
				size = UDim2.new(1, 0, 1, 0),
				color = Color3.fromRGB(250, 250, 250),
				tileSize = UDim2.new(1, 0, 5, 0),
			}, {
				e("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					Padding = UDim.new(0, 4),
				}),
				e("Frame", {
					Position = UDim2.new(0.5, 0, 0, 0),
					AnchorPoint = Vector2.new(0.5, 0),
					Size = UDim2.new(1, 0, 0.2, 0),

					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
				}, {

					e("UIStroke", {
						Thickness = 2,
						LineJoinMode = Enum.LineJoinMode.Round,
						Color = Color3.fromRGB(226, 226, 226),
					}),

					e("TextLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						Text = "Residential",
						FontFace = BuilderSans.SemiBold,
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextScaled = true,
					}, {
						e("UITextSizeConstraint", {
							MaxTextSize = 24,
						}),
					}),
				}),

				e("ScrollingFrame", {
					Size = UDim2.new(1, 0, 0.8, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					ScrollBarThickness = 8,
					ScrollBarImageTransparency = 0,
					ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
					ScrollingDirection = Enum.ScrollingDirection.X,

					CanvasSize = UDim2.new(2, 0, 0, 0),
				}, {
					e("UIPadding", {
						PaddingTop = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 16),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
					}),
					e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						Padding = UDim.new(0, 16),
					}),

					e(StructureEntry, {
						name = "House",
						price = "$1000",
					}),

					e(StructureEntry, {}),

					e(StructureEntry, {}),

					e(StructureEntry, {}),

					e(StructureEntry, {}),
				}),
			}),
		}),
	})
end
