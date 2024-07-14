local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local LMEngine = require(ReplicatedStorage.LMEngine)
local Player = LMEngine.Player

local React = require(Packages.react)
local ReactRoblox = require(Packages.reactroblox)

local dirComponents = script.Components
local dirHUD = dirComponents.HUD

local BottomBarButtons = require(dirHUD.BottomBarButtons)
local SideBarButtons = require(dirHUD.SideBarButtons)

local function App(_)
	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 16),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
		}),
		React.createElement(BottomBarButtons, {}),
		React.createElement(SideBarButtons, {}),
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
