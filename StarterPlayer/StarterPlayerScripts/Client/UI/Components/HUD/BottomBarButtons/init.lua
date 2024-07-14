local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local ButtonList = require(script.Parent.ButtonList)

local e = React.createElement

local buttonData = {
	{
		Image = "rbxassetid://18476991644",
		Size = "md",
		Name = "Build",
	},
	{
		Image = "rbxassetid://18477186326",
		Size = "md",
		Name = "Stats",
	},
	{
		Image = "rbxassetid://18477206156",
		Size = "md",
		Name = "Quests",
	},
}

return function(props: any)
	return e(ButtonList, {
		Position = UDim2.new(0.5, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,

		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		ListPadding = UDim.new(0, 16),

		buttons = buttonData,
	})
end
