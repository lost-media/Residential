local SETTINGS = {
	MouseOffset = Vector2.new(12, 0), -- The default offset of the tooltip from the mouse
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)

local dirComponents = script.Parent.Parent
local dirProviders = dirComponents.Providers

local TooltipProvider = require(dirProviders.TooltipProvider)

local e = React.createElement

type Frame = {
	name: string,
	open: string,
}

export type FrameContextProps = {
	buildMenuOpen: boolean,
	bottomBarButtonsOpen: boolean,
	questLogOpen: boolean,
	statsOpen: boolean,

	setFrameOpen: (name: string, open: boolean) -> (),

	getFrame: (name: string) -> Frame,
	closeFrame: (name: string) -> (),
	openFrame: (name: string) -> (),
	toggleFrame: (name: string) -> (),
	frames: { [string]: Frame },
}

local FrameContext = React.createContext({
	getFrame = function() end,
	closeFrame = function() end,
	openFrame = function() end,
	toggleFrame = function() end,
	frames = {},
})

local function createFrame(name: string)
	return {
		name = name,
		open = false,
	}
end

local function FrameProvider(props)
	local frames, setFrames = React.useState({})

	local buildMenuOpen, setBuildMenuOpen = React.useState(false)
	local bottomBarButtonsOpen, setBottomBarButtonsOpen = React.useState(true)
	local questLogOpen, setQuestLogOpen = React.useState(false)
	local statsOpen, setStatsOpen = React.useState(false)

	local function setFrameOpen(name: string, open: boolean)
		local dict = {
			["BuildMenu"] = setBuildMenuOpen,
			["BottomBarButtons"] = setBottomBarButtonsOpen,
			["Quests"] = setQuestLogOpen,
			["Stats"] = setStatsOpen,
		}

		if dict[name] then
			dict[name](open)
		end
	end

	local function createIfNotExist(name: string)
		if frames[name] then
			return
		end

		local created = createFrame(name)

		setFrames(function(oldFrames)
			oldFrames[name] = created
			return oldFrames
		end)

		return created
	end

	local function openFrame(name: string)
		createIfNotExist(name)

		setFrames(function(oldFrames)
			oldFrames[name].open = true

			return oldFrames
		end)
	end

	local function closeFrame(name: string)
		createIfNotExist(name)

		setFrames(function(oldFrames)
			oldFrames[name].open = false

			return oldFrames
		end)
	end

	local function toggleFrame(name: string)
		-- Create the frame if it doesn't exist
		createIfNotExist(name)

		setFrames(function(oldFrames)
			oldFrames[name].open = not oldFrames[name].open
			return oldFrames
		end)
	end

	local function getFrame(name: string)
		return frames[name] or createIfNotExist(name)
	end

	local context = {
		buildMenuOpen = buildMenuOpen,
		bottomBarButtonsOpen = bottomBarButtonsOpen,
		questLogOpen = questLogOpen,
		statsOpen = statsOpen,

		setFrameOpen = setFrameOpen,

		toggleFrame = toggleFrame,
		getFrame = getFrame,
		openFrame = openFrame,
		closeFrame = closeFrame,
		frames = frames,
	}

	return e(FrameContext.Provider, {
		value = context,
	}, {
		props.children,
	})
end

return {
	Provider = FrameProvider,
	Context = FrameContext,
}
