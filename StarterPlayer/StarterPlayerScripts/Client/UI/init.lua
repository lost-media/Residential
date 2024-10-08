local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local LMEngine = require(ReplicatedStorage.LMEngine)
local Player = LMEngine.Player

local React = require(Packages.react)
local ReactRoblox = require(Packages.reactroblox)

local dirComponents = script.Components
local dirProviders = dirComponents.Providers
local dirHUD = dirComponents.HUD

local FrameProvider = require(dirProviders.FrameProvider)
local TooltipProvider = require(dirProviders.TooltipProvider)

local BottomBarButtons = require(dirHUD.BottomBarButtons)
local SideBarButtons = require(dirHUD.SideBarButtons)
local TopBar = require(dirHUD.TopBar)

-- Frames
local BuildMenu = require(dirHUD.BuildMenu)
local PlotSelection = require(dirHUD.PlotSelection)
local Quest = require(dirHUD.Quest)
local Stats = require(dirHUD.Stats)

local function Frames(_)
	local frames: FrameProvider.FrameContextProps = React.useContext(FrameProvider.Context)

	return React.createElement(
		React.Fragment,
		nil,
		React.createElement(Quest, {
			isOpen = frames.questLogOpen,
		}),
		React.createElement(BottomBarButtons, {
			isOpen = frames.bottomBarButtonsOpen,
		}),
		React.createElement(SideBarButtons, {
			isOpen = frames.getFrame("SideBarButtons").open,
		}),
		React.createElement(TopBar, {
			isOpen = frames.getFrame("TopBar").open,
		}),
		React.createElement(BuildMenu, {
			isOpen = frames.buildMenuOpen,
		}),
		React.createElement(Stats, {
			isOpen = frames.statsOpen,
		}),
		React.createElement(PlotSelection, {
			isOpen = frames.statsOpen,
		})
	)
end

local function App(_)
	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		React.createElement(FrameProvider.Provider, {}, {
			React.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 16),
				PaddingBottom = UDim.new(0, 16),
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 16),
			}),

			React.createElement(TooltipProvider.Provider, {}, {
				React.createElement(Frames),
			}),
		}),
	})
end

local function initialize()
	local playerGui = Player:WaitForChild("PlayerGui")
	local ui = Instance.new("ScreenGui")
	ui.Name = "UI"
	ui.Parent = playerGui
	ui.IgnoreGuiInset = true
	ui.ResetOnSpawn = false
	ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local handle = ReactRoblox.createRoot(ui)

	local createdApp = React.createElement(App, {})

	handle:render(createdApp)

	return function()
		handle:unmount()
	end
end

return {
	Initialize = initialize,
	App = App,
}
