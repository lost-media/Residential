local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)
local ReactRoblox = require(Packages.reactroblox)

local dirComponents = script.Parent.Parent.Parent.Parent
local dirProviders = dirComponents.Providers

local TooltipProvider = require(dirProviders.TooltipProvider)

local QuestSlot = require(script.Parent)

return function(target)
	local handle = ReactRoblox.createRoot(target)

	local createdComponent = React.createElement(TooltipProvider.Provider, {}, {
		React.createElement(QuestSlot),
	})

	handle:render(createdComponent)

	return function()
		handle:unmount()
	end
end
