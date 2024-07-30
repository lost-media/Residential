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

local LMEngine = require(ReplicatedStorage.LMEngine)
local Structures2 = require(LMEngine.Game.Shared.Structures2)

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local dirComponents = script.Parent.Parent
local dirFonts = dirComponents.Parent.Fonts

local BuilderSans = require(dirFonts.BuilderSans)

local Button = require(dirComponents.Button)
local StripeTexture = require(dirComponents.StripeTexture)

local StructureEntry = require(script.StructureEntry)

type BuildMenuProps = {
	isOpen: boolean,
}

return function(props: BuildMenuProps)
	local currentCategory: Structures2.StructureCategory, setCurrentCategory = React.useState(Structures2.getCategory("City"))
	local currentTab, setCurrentTab = React.useState("City")


	local scroillCanvasSize, setScrollCanvasSize = React.useState(UDim2.new(0, 0, 0, 0))

	local newButtonTabs = {}

	local categories = Structures2.getCategories()

	for _, category in pairs(categories) do
		local buttonInfo = {
			Name = category.verboseNamePlural,
			Image = category.icon,
			toolTipOffset = Vector2.new(-32, -32),

			active = category.verboseName == currentCategory.verboseName,
			layoutOrder = category.layoutOrder,

			onClick = function()
				setCurrentCategory(category)
				setCurrentTab(category.verboseName)
			end,
		}

		table.insert(newButtonTabs, e(Button, buttonInfo))
	end

	table.sort(newButtonTabs, function(a, b)
		return a.props.layoutOrder < b.props.layoutOrder
	end)

	local entries = React.useMemo(function()
		local structures = Structures2.getStructuresInCategory(currentTab)
		local category = Structures2.getCategory(currentTab)

		if category == nil then
			warn("Category not found: " .. currentTab)
			return {}
		end

		local newEntries = {}

		for _, structure in pairs(structures) do
			table.insert(
				newEntries,
				e(StructureEntry, {
					name = structure.name,
					price = structure.price,
					model = structure.model,
					category = category,
					viewportZoomScale = structure.viewportZoomScale,
				})
			)
		end

		return newEntries
	end, { currentTab })

	return e("Frame", {
		ZIndex = -1,
		Position = UDim2.new(0.5, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,

		Size = UDim2.new(0.8, 0, 0.2, 0),

		AutomaticSize = Enum.AutomaticSize.Y,

		Visible = props.isOpen,
	}, {
		e("UISizeConstraint", {
			MaxSize = Vector2.new("inf", 480),
		}),
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

				SortOrder = Enum.SortOrder.LayoutOrder,
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

					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Top = e("Frame", {
					LayoutOrder = 0,
					Position = UDim2.new(0.5, 0, 0, 0),
					AnchorPoint = Vector2.new(0.5, 0),
					Size = UDim2.new(1, 0, 0.2, 0),

					BackgroundColor3 = Color3.fromRGB(62, 163, 52),
					BorderSizePixel = 0,
				}, {
					e(StripeTexture, {
						size = UDim2.new(1, 0, 1, 0),
						color = Color3.fromRGB(60, 158, 51),
						tileSize = UDim2.new(1, 0, 25, 0),
					}),

					e("UIStroke", {
						Thickness = 3,
						LineJoinMode = Enum.LineJoinMode.Round,
						Color = Color3.fromRGB(50, 133, 42),
					}),

					e("TextLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(0.35, 0, 1, 0),
						Text = currentCategory.verboseNamePlural,
						FontFace = BuilderSans.Bold,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,

						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.new(0.5, 0, 0, 0),
					}, {
						e("UITextSizeConstraint", {
							MaxTextSize = 24,
						}),
					}),
				}),

				e("ScrollingFrame", {
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0.8, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					ScrollBarThickness = 8,
					ScrollBarImageTransparency = 0,
					ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
					ScrollingDirection = Enum.ScrollingDirection.X,

					CanvasSize = scroillCanvasSize,
				}, {
					e("UIPadding", {
						PaddingTop = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 16),
						PaddingLeft = UDim.new(0, 16),
						PaddingRight = UDim.new(0, 8),
					}),
					e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 16),

						[React.Change.AbsoluteContentSize] = function(rbx)
							setScrollCanvasSize(UDim2.new(0, rbx.AbsoluteContentSize.X + 32, 0, 0))
						end,
					}),

					entries,
				}),
			}),
		}),
	})
end
