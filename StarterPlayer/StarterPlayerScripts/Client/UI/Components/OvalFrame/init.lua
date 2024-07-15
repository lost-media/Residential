local SETTINGS = {
	FrameAssetId = "rbxassetid://18491367555",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)

local e = React.createElement

type OvalFrameProps = {
	Position: UDim2?,
	AnchorPoint: Vector2?,
	Size: UDim2?,
	ImageColor3: Color3?,
}

return function(props: OvalFrameProps)
	return e("ImageLabel", {
		BackgroundTransparency = 1,
		Image = SETTINGS.FrameAssetId,
		Size = props.Size or UDim2.new(1, 0, 1, 0),
		ImageColor3 = props.ImageColor3 or Color3.fromRGB(255, 255, 255),
		Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),

        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(250, 252, 550, 252),
	}, {
		unpack(props.children or {}),
	})
end
