local SETTINGS = {
	MouseOffset = Vector2.new(12, 0), -- The default offset of the tooltip from the mouse
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)

local dirComponents = script.Parent.Parent

local StructureTooltip = require(dirComponents.Tooltip.StructureTooltip)
local Tooltip = require(dirComponents.Tooltip)

local e = React.createElement

type ShowParams = {
	text: string,
	visible: boolean,
	offset: UDim2,
}

type ShowStructureParams = {
	structure: any,
	offset: UDim2,
	visible: boolean,
}

export type TooltipContext = {
	text: string,
	visible: boolean,
	setText: (text: string) -> (),
	setVisible: (Visible: boolean) -> (),
	offset: Vector2,
	setOffset: (Offset: UDim2) -> (),

	show: (params: ShowParams) -> (),
	showStructureTooltip: (params: ShowStructureParams) -> (),
}

local TooltipContext = React.createContext({
	text = "Tooltip",
	visible = false,
	setText = function() end,
	setVisible = function() end,
	offset = Vector2.new(0, 0),
	setOffset = function() end,

	show = function() end,
})

local function TooltipProvider(props)
	local tooltipToShow, setTooltipToShow = React.useState("small")

	local text, setText = React.useState("Tooltip")
	local visible, setVisible = React.useState(false)
	local offset, setOffset = React.useState(Vector2.new(0, 0))

	local mousePosition, setMousePosition = React.useState(Vector2.new(0, 0))

	local structure, setStructure = React.useState({
		name = "Structure",
	})

	-- Structure Tooltip state
	local function show(params: ShowParams)
		setTooltipToShow("small")
		setText(params.text)
		setVisible(params.visible)
		setOffset(params.offset)
	end

	local function showStructureTooltip(params: ShowStructureParams)
		setTooltipToShow("structure")
		setVisible(params.visible or false)
		if params.offset then
			setOffset(params.offset)
		end

		setStructure(params.structure)
	end

	local context = {
		text = text,
		visible = visible,
		setText = setText,
		setVisible = setVisible,
		offset = offset,
		setOffset = setOffset,

		show = show,
		showStructureTooltip = showStructureTooltip,
	}

	React.useEffect(function()
		local function updateMousePosition()
			local newMousePosition = UserInputService:GetMouseLocation()
			-- calculate the position from the parent
			newMousePosition = newMousePosition + (offset or SETTINGS.MouseOffset)

			setMousePosition(newMousePosition)
		end

		updateMousePosition() -- Update immediately in case the mouse isn't moving

		local connection = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				updateMousePosition()
			end
		end)

		-- Cleanup function to disconnect the event listener
		return function()
			connection:Disconnect()
		end
	end, { visible })

	return e(TooltipContext.Provider, {
		value = context,
	}, {
		tooltipToShow == "small" and e(Tooltip, {
			text = text,
			visible = visible,

			position = UDim2.fromOffset(
				mousePosition.X + SETTINGS.MouseOffset.X,
				mousePosition.Y + SETTINGS.MouseOffset.Y
			),
		}),
		tooltipToShow == "structure" and e(StructureTooltip, {
			structure = structure,
			visible = visible,

			position = UDim2.fromOffset(
				mousePosition.X + SETTINGS.MouseOffset.X,
				mousePosition.Y + SETTINGS.MouseOffset.Y
			),
		}),
		props.children,
	})
end

return {
	Provider = TooltipProvider,
	Context = TooltipContext,
}
