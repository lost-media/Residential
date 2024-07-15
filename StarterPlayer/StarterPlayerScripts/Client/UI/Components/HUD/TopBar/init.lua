local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local dirComponents = script.Parent.Parent
local NumberIndicator = require(dirComponents.NumberIndicator)

local e = React.createElement

type TopBarProps = {	
}

return function(props: TopBarProps)
	return e("Frame", {
		Position = props.Position or UDim2.new(0, 0, 0, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
		BackgroundTransparency = 1,

		Size = UDim2.new(1, 0, 0.1, 0),
	}, {
		e("UIListLayout", {
			FillDirection = props.FillDirection or Enum.FillDirection.Horizontal,
			HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Center,
			VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Center,
			Padding = props.ListPadding or UDim.new(0, 16),
		}),

		e(NumberIndicator, {
            Name = "Coins",
            Text = "999.9K",
            Size = UDim2.new(0.25, 0, 1, 0)
        }),

        e(NumberIndicator, {
            Name = "Roadbucks",
            Text = "999.9K",
            Size = UDim2.new(0.25, 0, 1, 0)
        })
	})
end
