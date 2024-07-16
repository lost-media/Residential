local SETTINGS = {
	MouseOffset = Vector2.new(12, 0), -- The offset of the tooltip from the mouse
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

type TooltipProps = {
	Visible: boolean,
	Text: string,
	Offset: Vector2?,
}

return function(props: TooltipProps)
	local ref = React.useRef(nil)

	local mousePosition, setMousePosition = React.useState(Vector2.new(0, 0))

	local styles = RoactSpring.useSpring({
		from = { scale = 0.25, opacity = 1 },
		to = {
			scale = if props.Visible then 1 else 0.25,
			opacity = if props.Visible then 0 else 1,
		},
		config = {
			damping = 100,
			mass = 1,
			tension = 500,
			clamp = true,
		},
	})

	React.useEffect(function()
		local function updateMousePosition()
			local newMousePosition = UserInputService:GetMouseLocation()
			-- calculate the position from the parent
			newMousePosition = newMousePosition + (props.Offset or SETTINGS.MouseOffset)

			setMousePosition(newMousePosition)
		end

		updateMousePosition() -- Update immediately in case the mouse isn't moving

		local connection = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				updateMousePosition()
			end
		end)

		-- Cleanup function to disconnect the event listener
		return function()
			connection:Disconnect()
		end
	end, { props.Visible })

	return e("CanvasGroup", {
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		GroupTransparency = styles.opacity,
		ref = ref,
		ZIndex = 100,
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.fromOffset(
			mousePosition.X + SETTINGS.MouseOffset.X,
			mousePosition.Y + SETTINGS.MouseOffset.Y
		),
		Size = UDim2.new(0, 0, 0, 30),
		AnchorPoint = Vector2.new(0, 0.5),
	}, {
		e("UIStroke", {
			Color = Color3.fromRGB(190, 190, 190),
			Transparency = styles.opacity,
			Thickness = 2,
		}),
		e("UICorner", {
			CornerRadius = UDim.new(0, 16),
		}),
		e("UIScale", {
			Scale = styles.scale,
		}),
		e("UIPadding", {
			PaddingTop = UDim.new(0.1, 0),
			PaddingBottom = UDim.new(0.1, 0),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
		}),
		e("TextBox", {
			TextTransparency = styles.opacity,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Font.fromName("Inter", Enum.FontWeight.SemiBold),
			Text = props.Text,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextSize = 20,
			TextWrapped = false,
			TextEditable = false,
			Size = UDim2.new(1, 0, 1, 0),
			TextScaled = false,
			AutomaticSize = Enum.AutomaticSize.X,
			ClearTextOnFocus = false,
			ZIndex = 101,
			Interactable = false,
		}, {
			e("UITextSizeConstraint", {
				MaxTextSize = 20,
			}),
		}),
	})
end
