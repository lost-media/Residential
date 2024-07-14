local SETTINGS = {
	ExclamationPointAssetId = "rbxassetid://18489688803",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

local Circle = require(script.Parent.Circle)
local Tooltip = require(script.Parent.Tooltip)

type NewAlertIndicator = {
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
}

return function(props: NewAlertIndicator)
	return e(Circle, {
		Size = props.Size or UDim2.new(1, 0, 1, 0),
		ImageColor3 = Color3.fromRGB(255, 90, 90),
		Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
	}, {
		e("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
		}),

		e("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
		}),
		e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = SETTINGS.ExclamationPointAssetId,
			Size = UDim2.new(0.7, 0, 0.7, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ImageColor3 = Color3.new(1, 1, 1),
		}),
	})
end
