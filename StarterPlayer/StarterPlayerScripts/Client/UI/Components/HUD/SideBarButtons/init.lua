local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local ButtonList = require(script.Parent.ButtonList)

local e = React.createElement

local buttonData = {
	{
		Image = "rbxassetid://17836127329",
		Name = "Store",
		Size = "md",
	},
	{
		Image = "rbxassetid://18479367139",
		Name = "Promo Codes",
		Size = "md",
	},
	{
		Image = "rbxassetid://18479396499",
		Name = "Settings",
		Size = "md",
	},
}

return function(props: any)
	return e(ButtonList, {
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(0.05, 0, 0.5, 0),

		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		ListPadding = UDim.new(0, 8),

		buttons = buttonData,
	})
end
