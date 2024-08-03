local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local dirComponents = script.Parent.Parent
local dirProviders = dirComponents.Providers

local FrameProvider = require(dirProviders.FrameProvider)

local Button = require(script.Parent.Parent.Button)
local ButtonList = require(script.Parent.ButtonList)

local e = React.createElement

return function(props: any)
	local frames: FrameProvider.FrameContextProps = React.useContext(FrameProvider.Context)

	return e(ButtonList, {
		Position = UDim2.new(0.5, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0.5, 0, 0.125, 0),

		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		ListPadding = UDim.new(0, 8),

		visible = frames.bottomBarButtonsOpen,
	}, {
		e(Button, {
			Image = "rbxassetid://18775018079",
			Size = "lg",
			Name = "Play",
			hoverBgColor = Color3.fromRGB(150, 255, 140),
			hoverStripeColor = Color3.fromRGB(102, 255, 88),
			toolTipOffset = Vector2.new(-24, -40),

			onClick = function()
				frames.setFrameOpen("TitleScreen", false)
				frames.setFrameOpen("Quests", false)
				frames.setFrameOpen("Stats", false)
				frames.setFrameOpen("BuildMenu", true)
			end,
		}),
	})
end
