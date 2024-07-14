local SETTINGS = {
	MouseOffset = Vector2.new(5, -20), -- The offset of the tooltip from the mouse
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
	ParentRef: { current: GuiObject },
}

return function(props: TooltipProps)
	local ref = React.useRef(nil)

	local mousePosition, setMousePosition = React.useState(Vector2.new(0, 0))

	local tooltipSpring = RoactSpring.useSpring({
		opacity = props.Visible and 1 or 0,
		scale = props.Visible and 1 or 0,
	})

	React.useEffect(function()
		tooltipSpring.opacity = props.Visible and 1 or 0
		tooltipSpring.scale = props.Visible and 1 or 0

		local parent = props.ParentRef and props.ParentRef.current

		local function updateMousePosition()
			local newMousePosition = UserInputService:GetMouseLocation()
			-- calculate the position from the parent
			if parent then
				newMousePosition = newMousePosition - parent.AbsolutePosition
				-- add the offset

				newMousePosition = newMousePosition + SETTINGS.MouseOffset
			end

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
	end, { props.Visible, mousePosition })

	return e("TextBox", {
		ref = ref,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		FontFace = Font.fromName("Inter", Enum.FontWeight.SemiBold),
		Text = props.Text,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextSize = 20,
		TextWrapped = false,
		Visible = props.Visible,
		TextEditable = false,
		ZIndex = 100,
		Size = UDim2.new(0, 0, 0, 30),
		Position = UDim2.fromOffset(
			mousePosition.X + SETTINGS.MouseOffset.X,
			mousePosition.Y + SETTINGS.MouseOffset.Y
		),

		AnchorPoint = Vector2.new(0.5, 0.5),
		TextScaled = false,
		AutomaticSize = Enum.AutomaticSize.X,
		ClearTextOnFocus = false,
	}, {
		e("UIPadding", {
			PaddingTop = UDim.new(0.1, 0),
			PaddingBottom = UDim.new(0.1, 0),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
		}),
		e("UIScale", {
			Scale = tooltipSpring.scale,
		}),
		e("UICorner", {
			CornerRadius = UDim.new(0, 16),
		}),
		e("UITextSizeConstraint", {
			MaxTextSize = 20,
		}),
	})
end
