local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local ReactRoblox = require(Packages.reactroblox)

local BottomBarButtons = require(script.Parent)

return function(target)
	local handle = ReactRoblox.createRoot(target)

	local createdBtn = React.createElement(BottomBarButtons, {})

	handle:render(createdBtn)

	return function()
		handle:unmount()
	end
end
