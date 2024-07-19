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

local LMEngine = require(ReplicatedStorage.LMEngine)

local NumberFormatter = require(LMEngine.SharedDir.NumberFormatter)

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local dirComponents = script.Parent.Parent.Parent
local dirProviders = dirComponents.Providers
local dirFonts = dirComponents.Parent.Fonts

local BuilderSans = require(dirFonts.BuilderSans)
local StripeTexture = require(dirComponents.StripeTexture)
local TooltipProvider = require(dirProviders.TooltipProvider)

type StructureEntryProps = {
	structureType: "City" | "Residential" | "Industrial" | "Commercial" | "Decoration" | "Road",
	name: string,
	price: {
		value: number,
		currency: string,
	},
	model: Model,
}

return function(props: StructureEntryProps)
	local viewportRef = React.useRef(nil)
	local viewportCameraRef = React.useRef(nil)

	React.useEffect(function()
		local model = props.model

		local newModel = model and model:Clone()
		if newModel then
			-- clone the model
			newModel.Parent = viewportRef.current

			-- Calculate the model's center position
			local modelCFrame = newModel:GetModelCFrame()
			local size = newModel:GetExtentsSize()
			local modelCenter = modelCFrame.Position -- Assuming the model's CFrame is at its center

			-- Calculate the distance and direction for the camera to look at the model's center
			local distance = size.magnitude * 1.5
			local cameraPosition = modelCenter + Vector3.new(0, 0, distance)

			if viewportCameraRef.current then
				viewportCameraRef.current.CFrame = CFrame.new(cameraPosition, modelCenter)
			end
		end

		return function()
			if newModel then
				newModel:Destroy()
			end
		end
	end, { props.model })

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
			MaxSize = Vector2.new(128, 128),
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

			Top = e("Frame", {
				Size = UDim2.new(1, 0, 0.175, 0),
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
			Viewport = e("ViewportFrame", {
				ref = viewportRef,
				Size = UDim2.new(1, 0, 0.475, 0),
				BackgroundTransparency = 1,
				CurrentCamera = viewportCameraRef.current,

				LayoutOrder = 2,
			}, {
				e("Camera", {
					ref = viewportCameraRef,
					FieldOfView = 30,
				}),
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
					Text = props.price and NumberFormatter.MonetaryFormat(props.price.value, false)
						or "$100.0k",
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
