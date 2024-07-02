local LMEngine = require(game:GetService("ReplicatedStorage").LMEngine.Client)

local Trove = require(LMEngine.SharedDir.Trove)

export type IUIElement = {
	__index: IUIElement,
	new: (instance: Instance) -> UIElement,

	Connect: (self: UIElement) -> (),
	Disconnect: (self: UIElement) -> (),
}

export type UIElementMembers = {
	_instance: Instance,
	_trove: Trove.Trove,
}

export type UIElement = typeof(setmetatable({} :: UIElementMembers, {} :: IUIElement))

local UIElement = {}

return UIElement
