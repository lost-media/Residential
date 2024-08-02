local SETTINGS = {
	StripeAssetId = "rbxassetid://18491043608",
	ReverseStripeAssetId = "rbxassetid://18540777218",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local RoactSpring = require(ReplicatedStorage.Packages.reactspring)

local e = React.createElement

type StripeTextureProps = {
	tileSize: UDim2,
	color: Color3,
	transparency: number,
	position: UDim2?,
	size: UDim2,
	rotation: number?,

	reversed: boolean?,

	onClick: () -> (),
}

return function(props: StripeTextureProps)
	return e("ImageButton", {
		BackgroundTransparency = 1,
		Size = props.size or UDim2.new(1, 0, 1, 0),
		Image = if props.reversed then SETTINGS.ReverseStripeAssetId else SETTINGS.StripeAssetId,
		ImageColor3 = props.color or Color3.fromRGB(255, 255, 255),
		ImageTransparency = props.transparency or 0,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = props.tileSize or UDim2.new(1, 0, 1, 0),
		Position = props.position or UDim2.new(0, 0, 0, 0),
		Rotation = props.rotation or 0,

		[React.Event.Activated] = props.onClick,
	}, {
		props.children,
	})
end
