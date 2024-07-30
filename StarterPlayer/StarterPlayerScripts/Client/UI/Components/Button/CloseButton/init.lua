local SETTINGS = {
	CircleAssetId = "rbxassetid://18416727845",
	StripeAssetId = "rbxassetid://18490111133",

	ScaleFactor = 1.1,

	ClickSoundId = "rbxassetid://8755541422",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local dirComponents = script.Parent
local dirProviders = dirComponents.Providers

local FrameProvider = require(dirProviders.FrameProvider)
local TooltipProvider = require(dirProviders.TooltipProvider)

local Circle = require(dirComponents.Circle)
local NewAlertIndicator = require(dirComponents.NewAlertIndicator)

type ButtonProps = {
	OnClick: () -> ()?,
	Size: ("sm" | "md" | "lg")?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Image: string,
	Name: string?,

	hasNewAlert: boolean?,
	toolTipOffset: Vector2?,
	hoverBgColor: Color3?,
	hoverStripeColor: Color3?,

	activeBgColor: Color3?,
	activeStripeColor: Color3?,

	active: boolean?,

	layoutOrder: number?,
	frameToOpen: string?,
}

return function(props: ButtonProps)
	local tooltip = React.useContext(TooltipProvider.Context)

	local buttonRef = React.useRef()

	props.Size = props.Size or "md"

	local hovered, setHovered = React.useState(false)

	local styles = RoactSpring.useSpring({
		scale = if hovered then SETTINGS.ScaleFactor else 1,
		config = {
			damping = 5,
			mass = 0.5,
			tension = 500,
			clamp = true,
		},
	})

	return e(Circle, {
		Size = UDim2.new(1, 0, 1, 0),
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),

		LayoutOrder = props.layoutOrder,
	}, {
		e("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
		}),
		e("UIScale", {
			Scale = styles.scale,
		}),
		e("UISizeConstraint", {
			MaxSize = props.Size == "sm" and Vector2.new(48, 48)
				or props.Size == "md" and Vector2.new(56, 56)
				or props.Size == "lg" and Vector2.new(72, 72),
			MinSize = Vector2.new(40, 40),
		}),
		e(Circle, {
			Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(1, 0, 1, 0),
			ImageColor3 = styles.bgColor,
		}, {
			e("ImageButton", {
				ref = buttonRef,
				Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = SETTINGS.StripeAssetId,
				ImageColor3 = styles.stripeColor,

				[React.Event.MouseEnter] = function()
					setHovered(true)
					tooltip.show({
						offset = props.toolTipOffset,
						text = props.Name,
						visible = true,
					})
				end,

				[React.Event.MouseLeave] = function()
					setHovered(false)
					tooltip.setVisible(false)
				end,

				[React.Event.Activated] = function()
					if props.onClick then
						props.onClick()
					end


					local clickSound = Instance.new("Sound")
					clickSound.SoundId = SETTINGS.ClickSoundId
					clickSound.Parent = game:GetService("SoundService")
					clickSound.PlayOnRemove = true
					clickSound:Destroy()
				end,
			}, {
				e("UIPadding", {
					PaddingTop = UDim.new(0.2, 0),
					PaddingBottom = UDim.new(0.2, 0),
					PaddingLeft = UDim.new(0.2, 0),
					PaddingRight = UDim.new(0.2, 0),
				}),
				e("ImageLabel", {
					BackgroundTransparency = 1,
					Image = props.Image or "rbxassetid://18476991644",
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					ImageColor3 = Color3.new(0, 0, 0),
				}),
			}),
		}),

		props.hasNewAlert and e(NewAlertIndicator, {
			Size = UDim2.new(0.4, 0, 0.4, 0),
			Position = UDim2.new(0.95, 0, -0.05, 0),
			AnchorPoint = Vector2.new(0.5, 0),
		}),
	})
end
