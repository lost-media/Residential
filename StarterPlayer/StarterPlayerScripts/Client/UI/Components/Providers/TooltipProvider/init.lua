local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)

local dirComponents = script.Parent.Parent

local Tooltip = require(dirComponents.Tooltip)

local e = React.createElement

type ShowParams = {
	Text: string,
	Visible: boolean,
	Offset: UDim2,
}

export type TooltipContext = {
	Text: string,
	Visible: boolean,
	setText: (text: string) -> (),
	setVisible: (Visible: boolean) -> (),
	Offset: UDim2,
	setOffset: (Offset: UDim2) -> (),

	show: (params: ShowParams) -> (),
}

local TooltipContext = React.createContext({
	text = "Tooltip",
	visible = false,
	setText = function() end,
	setVisible = function() end,
	offset = UDim2.new(0, 0, 0, 0),
	setOffset = function() end,

	show = function() end,
})

local function TooltipProvider(props)
	local text, setText = React.useState("Tooltip")
	local visible, setVisible = React.useState(false)
	local offset, setOffset = React.useState(Vector2.new(0, 0))

	local function show(params: ShowParams)
		setText(params.Text)
		setVisible(params.Visible)
		setOffset(params.Offset)
	end

	local context = {
		text = text,
		visible = visible,
		setText = setText,
		setVisible = setVisible,
		offset = offset,
		setOffset = setOffset,

		show = show,
	}

	return e(TooltipContext.Provider, {
		value = context,
	}, {
		e(Tooltip, {
			Text = text,
			Visible = visible,
			Offset = offset,
		}),
		props.children,
	})
end

return {
	Provider = TooltipProvider,
	Context = TooltipContext,
}
