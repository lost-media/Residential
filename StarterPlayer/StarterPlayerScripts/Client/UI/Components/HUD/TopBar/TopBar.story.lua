local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local ReactRoblox = require(Packages.reactroblox)

local TopBar = require(script.Parent)

return function(target)
	local handle = ReactRoblox.createRoot(target)

	local createdBtn = React.createElement(TopBar, {})

	handle:render(createdBtn)

	return function()
		handle:unmount()
	end
end
