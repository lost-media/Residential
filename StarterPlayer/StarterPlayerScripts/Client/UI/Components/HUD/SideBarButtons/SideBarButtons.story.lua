local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local ReactRoblox = require(Packages.reactroblox)

local SideBarButtons = require(script.Parent)

return function(target)
	local handle = ReactRoblox.createRoot(target)

	local createdElement = React.createElement(SideBarButtons, {})

	handle:render(createdElement)

	return function()
		handle:unmount()
	end
end
