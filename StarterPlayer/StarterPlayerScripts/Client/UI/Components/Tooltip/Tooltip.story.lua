local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local ReactRoblox = require(Packages.reactroblox)

local dirProviders = script.Parent.Parent.Providers

local Tooltip = require(script.Parent)
local TooltipProvider = require(dirProviders.TooltipProvider)

return function(target)
	local handle = ReactRoblox.createRoot(target)

	local createdComponent = React.createElement(TooltipProvider.Provider, {}, {
		React.createElement(Tooltip, {
			Visible = true,
			Text = "This is a tooltip",
		}),
	})

	handle:render(createdComponent)

	return function()
		handle:unmount()
	end
end
