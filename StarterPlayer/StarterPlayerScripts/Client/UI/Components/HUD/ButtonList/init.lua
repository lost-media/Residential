local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local Button = require(script.Parent.Parent.Button)

local e = React.createElement

type ButtonListProps = {
	buttons: {
		{
			Image: string,
			Size: string?,
			LayoutOrder: number?,
			Name: string?,
		}
	},
	AnchorPoint: Vector2,
	Position: UDim2,
	AutomaticSize: Enum.AutomaticSize,
	Size: UDim2,

	FillDirection: Enum.FillDirection,
	HorizontalAlignment: Enum.HorizontalAlignment,
	VerticalAlignment: Enum.VerticalAlignment,
	ListPadding: UDim,
}

return function(props: ButtonListProps)
	
	return e("Frame", {
		Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		AutomaticSize = props.AutomaticSize or Enum.AutomaticSize.XY,

		Size = props.Size or UDim2.new(0, 0, 0, 0),
	}, {
		e("UIListLayout", {
			FillDirection = props.FillDirection or Enum.FillDirection.Horizontal,
			HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Center,
			VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Center,
			Padding = props.ListPadding or UDim.new(0, 8),
		}),

		props.children,
	})
end
