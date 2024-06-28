--!strict

--[[
{Lost Media}

-[UIController] Controller
    A controller that manages the UI in the game.
--]]

local SETTINGS = {
	GuisToWaitFor = {
		"Title Screen",
	},
}

----- Private variables -----

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ui_Extras = ReplicatedStorage.Extras.UI

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)
local Player = LMEngine.Player
local PlayerGui = Player.PlayerGui

local TableUtil = require(LMEngine.SharedDir.TableUtil)

---@type Signal
local Signal = LMEngine.GetShared("Signal")

---@class UIController
local UIController = LMEngine.CreateController({
	Name = "UIController",
})

----- Private functions -----

----- Public functions -----

function UIController:Start()
	-- wait for the GUIs to load
	for _, gui_name in SETTINGS.GuisToWaitFor do
		PlayerGui:WaitForChild(gui_name)
	end

	local title_screen = PlayerGui:FindFirstChild("Title Screen")

	local DataService = LMEngine.GetService("DataService")

	-- get all the players plots
	---@type Promise

	local function ClearCityLoader()
		local city_loader = title_screen:FindFirstChild("CityLoader")
		if city_loader then
			for _, child: Instance in city_loader:FindFirstChildWhichIsA("ScrollingFrame"):GetChildren() do
				if child:IsA("GuiObject") == true then
					child:Destroy()
				end
			end
		end
	end

	local PlotsLoadedConnection

	PlotsLoadedConnection = DataService.PlayerPlotsLoaded:Connect(function(plots)
		ClearCityLoader()

		-- render the plots
		for plot_id, plot_name in plots do
			local plot_button = ui_Extras.CityLoadButton:Clone()
			plot_button.Name = plot_id
			plot_button.Label.Text = plot_name
			plot_button.Parent = title_screen.CityLoader.ScrollingFrame

			local click_connection

			click_connection = plot_button.MouseButton1Click:Connect(function()
				click_connection:Disconnect()
				PlotsLoadedConnection:Disconnect()

				-- disable the Title Screen UI
				title_screen.Enabled = false

				-- load the plot
				DataService:LoadPlot(plot_id)
			end)
		end

		PlotsLoadedConnection:Disconnect()
	end)
end

return UIController
