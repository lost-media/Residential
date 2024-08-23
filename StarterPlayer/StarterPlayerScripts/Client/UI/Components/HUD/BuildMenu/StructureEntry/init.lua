local SETTINGS = {
	CityAssetId = "rbxassetid://18539171639",
	ResidentialAssetId = "rbxassetid://18312606125",
	IndustrialAssetId = "rbxassetid://18313003018",
	CommercialAssetId = "rbxassetid://18539219318",
	DecorationAssetId = "rbxassetid://18312572742",
	RoadAssetId = "rbxassetid://18539219318",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Packages = ReplicatedStorage.Packages

local LMEngine = require(ReplicatedStorage.LMEngine)

local Currency = require(LMEngine.Game.Currency)
type Currency = Currency.Currency

local Structures2 = require(LMEngine.Game.Shared.Structures2)
type StructureCategory = Structures2.StructureCategory

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
	id: string,
	name: string,
	price: {
		value: number,
		currency: Currency,
	},
	model: Model,
	category: StructureCategory,

	viewportZoomScale: number?,

	onClick: () -> (),
}

return function(props: StructureEntryProps)
	local viewportRef = React.useRef(nil)

	React.useEffect(function()
		local model = props.model

		local newModel: Model = model and model:Clone()
		local camera = nil
		local renderStepped = nil

		if newModel then
			newModel.Parent = viewportRef.current

			-- Calculate the model's center position
			local modelCFrame = newModel:GetPivot()
			local size = newModel:GetExtentsSize()
			local modelCenter = modelCFrame.Position

			-- Initial distance and angles
			local distance = size.Magnitude * (props.viewportZoomScale or 0.6)
			local angleRight = math.pi / 4 -- Start angle for rotation around the model

			-- Create a camera to look at the model
			camera = Instance.new("Camera")
			camera.Parent = viewportRef.current

			-- Set the viewport's camera to the new camera
			if viewportRef.current then
				viewportRef.current.CurrentCamera = camera
			end

			-- Function to update camera position and rotation
			local function updateCamera()
				angleRight = angleRight + math.rad(0.05) -- Increment the angle for rotation
				local cameraOffset = Vector3.new(
					distance * math.cos(angleRight),
					2, -- Keep the camera at a constant height, adjust if needed
					distance * math.sin(angleRight)
				)
				local cameraPosition = modelCenter + cameraOffset
				camera.CFrame = CFrame.new(cameraPosition, modelCenter)
			end

			-- Connect this function to a game loop or event like RenderStepped in Roblox
			renderStepped = game:GetService("RunService").RenderStepped:Connect(updateCamera)
		end

		return function()
			if newModel then
				newModel:Destroy()
			end
			if camera then
				camera:Destroy()
			end
			if renderStepped then
				renderStepped:Disconnect()
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
		e("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Text = "",
		}),
		e(StripeTexture, {
			color = Color3.fromRGB(246, 248, 246),
			tileSize = UDim2.new(4, 0, 4, 0),
			transparency = 1,
			reversed = false,

			onClick = props.onClick,
		}, {
			e("UIPadding", {
				PaddingTop = UDim.new(0.025, 0),
				PaddingBottom = UDim.new(0.025, 0),
				PaddingLeft = UDim.new(0.025, 0),
				PaddingRight = UDim.new(0.025, 0),
			}),
			e("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				--Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Top = e("Frame", {
				Size = UDim2.new(1, 0, 0.15, 0),
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
					Image = if props.category then props.category.icon else nil,
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

			Viewport = e("ViewportFrame", {
				ref = viewportRef,
				Size = UDim2.new(1, 0, 0.55, 0),
				BackgroundTransparency = 1,

				LayoutOrder = 2,
			}),

			e("Frame", {
				Size = UDim2.new(1, 0, 0.3, 0),
				BackgroundTransparency = 1,
				LayoutOrder = 3,
			}, {
				e("UIPadding", {
					PaddingTop = UDim.new(0.1, 0),
					PaddingBottom = UDim.new(0, 0),
					PaddingLeft = UDim.new(0.05, 0),
					PaddingRight = UDim.new(0.05, 0),
				}),
				e("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Bottom,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Name = e("TextLabel", {
					Size = UDim2.new(1, 0, 0.5, 0),
					BackgroundTransparency = 1,
					Text = props.name or "Classic City Hall",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					FontFace = BuilderSans.Bold,

					TextScaled = true,

					LayoutOrder = 0,
					TextYAlignment = Enum.TextYAlignment.Bottom,
				}, {
					e("UITextSizeConstraint", {
						MaxTextSize = 20,
						MinTextSize = 10,
					}),
				}),
				e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0.5, 0),

					LayoutOrder = 1,
				}, {
					e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0.025, 0),
					}),
					e("ImageLabel", {
						Size = UDim2.new(0.2, 0, 0.9, 0),
						BackgroundTransparency = 1,
						Image = if props.price then props.price.currency.icon else nil,
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						ImageTransparency = 0,
						ScaleType = Enum.ScaleType.Fit,
						Visible = props.price
							and props.price.value
							and props.price.value > 0
							and props.price.currency.icon ~= nil,

						LayoutOrder = 2,
					}),
					Price = e("TextLabel", {
						Size = UDim2.new(0, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = if props.price
							then if props.price.value == 0
								then "Free"
								else NumberFormatter.MonetaryFormat(props.price.value, false)
							else "$100.0k",
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextSize = 24,
						FontFace = BuilderSans.Regular,
						TextXAlignment = Enum.TextXAlignment.Left,

						TextScaled = true,

						LayoutOrder = 3,

						AutomaticSize = Enum.AutomaticSize.X,
					}, {
						e("UITextSizeConstraint", {
							MaxTextSize = 18,
							MinTextSize = 8,
						}),
					}),
				}),
			}),
		}),
	})
end
