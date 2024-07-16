local SETTINGS = {
	StripeAssetId = "rbxassetid://18491043608",
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

	size: UDim2,
}

return function(props: StripeTextureProps)
	return e("ImageLabel", {
		BackgroundTransparency = 1,
		Size = props.size or UDim2.new(1, 0, 1, 0),
		Image = SETTINGS.StripeAssetId,
		ImageColor3 = props.color or Color3.fromRGB(255, 255, 255),
		ImageTransparency = props.transparency or 0,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = props.tileSize or UDim2.new(1, 0, 1, 0),
	}, {
		props.children,
	})
end
