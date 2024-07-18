local SETTINGS = {
	CityAssetId = "rbxassetid://18539171639",
	ResidentialAssetId = "rbxassetid://18312606125",
	IndustrialAssetId = "rbxassetid://18313003018",
	CommercialAssetId = "rbxassetid://18539219318",
	DecorationAssetId = "rbxassetid://18312572742",
	RoadAssetId = "rbxassetid://18539219318",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local dirComponents = script.Parent.Parent.Parent
local dirFonts = dirComponents.Parent.Fonts

local BuilderSans = require(dirFonts.BuilderSans)
local StripeTexture = require(dirComponents.StripeTexture)

type StructureEntryProps = {
	structureType: "City" | "Residential" | "Industrial" | "Commercial" | "Decoration" | "Road",
	name: string,
	price: string,
}

return function(props)
	return e("CanvasGroup", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 0,
		LayoutOrder = props.LayoutOrder,

		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	}, {
		e("UIAspectRatioConstraint", {
			AspectRatio = 1,
		}),
		e("UISizeConstraint", {
			MaxSize = Vector2.new(256, 256),
		}),
		e("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		e("UIStroke", {
			Color = Color3.fromRGB(172, 172, 172),
			Thickness = 2,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
		e(StripeTexture, {
			color = Color3.fromRGB(246, 248, 246),
			tileSize = UDim2.new(4, 0, 4, 0),
			transparency = 1,
			reversed = false,
		}, {
			e("UIPadding", {
				PaddingTop = UDim.new(0.05, 0),
				PaddingBottom = UDim.new(0.05, 0),
				PaddingLeft = UDim.new(0.05, 0),
				PaddingRight = UDim.new(0.05, 0),
			}),
			e("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				--Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			e("Frame", {
				Size = UDim2.new(1, 0, 0.2, 0),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			}, {
				e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 8),
					SortOrder = Enum.SortOrder.LayoutOrder,

					HorizontalFlex = "SpaceBetween",
				}),

				e("ImageLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					-- TODO: make this a function that returns the correct asset id
					Image = if props.structureType
						then SETTINGS[props.structureType .. "AssetId"]
						else SETTINGS.CityAssetId,
					ImageColor3 = Color3.fromRGB(0, 0, 0),
					ImageTransparency = 0.8,
					ScaleType = Enum.ScaleType.Fit,
				}, {
					e("UIAspectRatioConstraint", {
						AspectRatio = 1,
					}),
				}),

				e("ImageLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					-- TODO: make this a function that returns the correct asset id
					Image = "rbxassetid://18540666611",
					ImageColor3 = Color3.fromRGB(0, 0, 0),
					ImageTransparency = 0.8,
					ScaleType = Enum.ScaleType.Fit,
				}, {
					e("UIAspectRatioConstraint", {
						AspectRatio = 1,
					}),
				}),
			}),

			-- TODO: make this a viewport frame
			Image = e("ImageLabel", {
				Size = UDim2.new(1, 0, 0.45, 0),
				BackgroundTransparency = 1,
				Image = props.Image or "rbxassetid://18476991644",
				ImageColor3 = Color3.fromRGB(0, 0, 0),
				ScaleType = Enum.ScaleType.Fit,

				LayoutOrder = 2,
			}),

			e("Frame", {
				Size = UDim2.new(1, 0, 0.35, 0),
				BackgroundTransparency = 1,
				LayoutOrder = 3,
			}, {
				e("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Name = e("TextLabel", {
					Size = UDim2.new(1, 0, 0.5, 0),
					BackgroundTransparency = 1,
					Text = props.name or "Classic City Hall",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					FontFace = BuilderSans.SemiBold,

					TextScaled = true,

					LayoutOrder = 3,
					TextYAlignment = Enum.TextYAlignment.Bottom,
				}, {
					e("UITextSizeConstraint", {
						MaxTextSize = 20,
					}),
				}),
				Price = e("TextLabel", {
					Size = UDim2.new(1, 0, 0.5, 0),
					BackgroundTransparency = 1,
					Text = props.price or "$100.0k",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextSize = 24,
					FontFace = BuilderSans.Regular,
					TextXAlignment = Enum.TextXAlignment.Center,

					TextScaled = true,

					LayoutOrder = 3,
				}, {
					e("UITextSizeConstraint", {
						MaxTextSize = 18,
					}),
				}),
			}),
		}),
	})
end
