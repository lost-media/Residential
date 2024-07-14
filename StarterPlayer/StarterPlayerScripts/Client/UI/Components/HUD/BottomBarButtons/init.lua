local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local ButtonList = require(script.Parent.ButtonList)

local e = React.createElement

local buttonData = {
	{
		Image = "rbxassetid://18476991644",
		Size = "lg",
		Name = "Build",
		hoverBgColor = Color3.fromRGB(150, 255, 140),
		hoverStripeColor = Color3.fromRGB(102, 255, 88),
	},
	{
		Image = "rbxassetid://18477186326",
		Size = "lg",
		Name = "Stats",
		hoverBgColor = Color3.fromRGB(133, 255, 235),
		hoverStripeColor = Color3.fromRGB(172, 255, 241),
	},
	{
		Image = "rbxassetid://18477206156",
		Size = "lg",
		Name = "Quests",
		hasNewAlert = true,
		hoverBgColor = Color3.fromRGB(255, 160, 242),
		hoverStripeColor = Color3.fromRGB(255, 178, 245),
	},
}

return function(props: any)
	return e(ButtonList, {
		Position = UDim2.new(0.5, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0.5, 0, 0.15, 0),

		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		ListPadding = UDim.new(0, 8),

		buttons = buttonData,
	})
end
