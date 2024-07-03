--!strict

--[[
{Lost Media}

-[UIController] Controller
    A controller that manages the UI in the game.
--]]

local SETTINGS = {
	FadeDuration = 0.1,
}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ui_Extras = ReplicatedStorage.Extras.UI

---@type LMEngineClient
local UserInputService = game:GetService("UserInputService")
local LMEngine = require(ReplicatedStorage.LMEngine.Client)
local Player = LMEngine.Player
local PlayerGui = Player.PlayerGui

local Trove = require(LMEngine.SharedDir.Trove)

---@type Signal
local Signal = LMEngine.GetShared("Signal")

local settFadeDuration = SETTINGS.FadeDuration

---@class UIController
local UIController = LMEngine.CreateController({
	Name = "UIController",

	_frames = {},
})

----- Private functions -----

local function GenerateRandom3LetterString()
	local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local random_string = ""

	for _ = 1, 3 do
		local random_index = math.random(1, #letters)
		random_string = random_string .. letters:sub(random_index, random_index)
	end

	return random_string
end

----- Public functions -----

function UIController:Start()
	-- wait for the GUIs to load
	LMEngine.GameLoaded():andThen(function()
		-- inside this promise, we don't need WaitForChild

		local title_screen = PlayerGui["Title Screen"]
		local placementScreen = PlayerGui.Placement

		local DataService = LMEngine.GetService("DataService")

		-- get all the players plots
		---@type Promise

		local function ClearCityLoader()
			local safe_buttons = {
				"CreatePlot",
				"UnlimitedPlotsGamepass",
			}
			local city_loader = title_screen:FindFirstChild("CityLoader")
			if city_loader then
				for _, child: Instance in
					city_loader:FindFirstChildWhichIsA("ScrollingFrame"):GetChildren()
				do
					if
						child:IsA("GuiObject") == true
						and table.find(safe_buttons, child.Name) == nil
					then
						child:Destroy()
					end
				end
			end
		end

		local PlotsLoadedConnection

		PlotsLoadedConnection = DataService.PlayerPlotsLoaded:Connect(
			function(plots, last_loaded_plot_id)
				ClearCityLoader()

				if plots == nil then
					return
				end

				-- render the plots
				for plot_id, plot_name in plots do
					local plot_button = ui_Extras.CityLoadButton:Clone()
					plot_button.Name = plot_id
					plot_button.Label.Text = plot_name
					plot_button.Parent = title_screen.CityLoader.ScrollingFrame

					if last_loaded_plot_id ~= plot_id then
						plot_button:FindFirstChild("LLI_Indicator").Visible = false
					end

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

				local create_plot_connection

				-- set up connections to the buttons
				create_plot_connection = title_screen.CityLoader.ScrollingFrame.CreatePlot.MouseButton1Click:Connect(
					function()
						create_plot_connection:Disconnect()

						-- disable the Title Screen UI
						title_screen.Enabled = false

						-- create a new plot
						DataService:CreatePlot(GenerateRandom3LetterString())
					end
				)

				PlotsLoadedConnection:Disconnect()
			end
		)

		-- Register all frames

		-- Build Mode
		local buildModeFrame: CanvasGroup = placementScreen.Frame.Modes
		local buildModeUIScale = buildModeFrame.UIScale
		local buildModeContainer = buildModeFrame.Container
		local buildModeButtons = buildModeContainer.Buttons

		self:RegisterFrame("BuildModeFrame", function(trove)
			TweenService:Create(buildModeFrame, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 0,
				Visible = true,
			}):Play()

			TweenService:Create(buildModeUIScale, TweenInfo.new(settFadeDuration), {
				Scale = 1,
			}):Play()

			TweenService:Create(buildModeFrame.UIStroke, TweenInfo.new(settFadeDuration), {
				Transparency = 0,
			}):Play()

			-- set up connections
			trove:Connect(buildModeButtons.Close.MouseButton1Click, function()
				self:CloseFrame("PlacementScreen")
				self:OpenFrame("MainHUDPrimaryButtons")
			end)

			trove:Connect(buildModeButtons.Delete.MouseButton1Click, function()
				self:CloseFrame("PlacementScreen")
				self:OpenFrame("DeleteStructureFrame")
			end)
		end, function(trove)
			TweenService:Create(buildModeFrame, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 1,
				Visible = false,
			}):Play()

			TweenService:Create(buildModeUIScale, TweenInfo.new(settFadeDuration), {
				Scale = 0.5,
			}):Play()

			TweenService:Create(buildModeFrame.UIStroke, TweenInfo.new(settFadeDuration), {
				Transparency = 1,
			}):Play()
		end)

		-- Delete Structure UI in Placement UI

		local deleteStructureFrame: CanvasGroup = placementScreen.Frame.DeleteStructure

		self:RegisterFrame("DeleteStructureFrame", function(trove)
			TweenService:Create(deleteStructureFrame, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 0,
				Visible = true,
			}):Play()

			TweenService:Create(deleteStructureFrame.UIScale, TweenInfo.new(settFadeDuration), {
				Scale = 1,
			}):Play()

			TweenService:Create(deleteStructureFrame.UIStroke, TweenInfo.new(settFadeDuration), {
				Transparency = 0,
			}):Play()

			trove:Connect(deleteStructureFrame.Button.MouseButton1Click, function()
				self:CloseFrame("DeleteStructureFrame")
				self:OpenFrame("PlacementScreen")
			end)

			trove:Connect(UserInputService.InputBegan, function(input, gameProcessed)
				if gameProcessed == true then
					return
				end

				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.C then
					self:CloseFrame("DeleteStructureFrame")
					self:OpenFrame("PlacementScreen")
				end
			end)
		end, function(trove)
			TweenService:Create(deleteStructureFrame, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 1,
				Visible = false,
			}):Play()

			TweenService:Create(deleteStructureFrame.UIScale, TweenInfo.new(settFadeDuration), {
				Scale = 0.5,
			}):Play()

			TweenService:Create(deleteStructureFrame.UIStroke, TweenInfo.new(settFadeDuration), {
				Transparency = 1,
			}):Play()
		end)

		-- Selection in Placement UI
		local selectionFrame: CanvasGroup = placementScreen.Frame.Selections

		self:RegisterFrame("SelectionFrame", function(trove)
			TweenService:Create(selectionFrame, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 0,
				Visible = true,
			}):Play()

			TweenService:Create(selectionFrame.UIScale, TweenInfo.new(settFadeDuration), {
				Scale = 1,
			}):Play()
		end, function(trove)
			TweenService:Create(selectionFrame, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 1,
				Visible = false,
			}):Play()

			TweenService:Create(selectionFrame.UIScale, TweenInfo.new(settFadeDuration), {
				Scale = 0.5,
			}):Play()
		end)

		-- Group the Selection and Build Mode
		self:RegisterFrame("PlacementScreen", function(trove)
			self:OpenFrame("SelectionFrame")
			self:OpenFrame("BuildModeFrame")
			self:CloseFrame({
				"MainHUDPrimaryButtons",
			})
		end, function(trove)
			self:CloseFrame({ "SelectionFrame", "BuildModeFrame" })
		end)

		local mainHudScreen = PlayerGui.MainHUD
		local mainHudPrimaryButtons = mainHudScreen.PrimaryButtons
		local mainHudPrimaryButtonsContainer: CanvasGroup = mainHudPrimaryButtons.Container

		self:RegisterFrame("MainHUDPrimaryButtons", function(trove)
			TweenService:Create(mainHudPrimaryButtonsContainer, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 0,
				Visible = true,
			}):Play()

			TweenService
				:Create(mainHudPrimaryButtonsContainer.UIScale, TweenInfo.new(settFadeDuration), {
					Scale = 1,
				})
				:Play()

			-- set up connections
			trove:Connect(mainHudPrimaryButtonsContainer.Build.MouseButton1Click, function()
				self:OpenFrame("PlacementScreen")
			end)
		end, function(trove)
			TweenService:Create(mainHudPrimaryButtonsContainer, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 1,
				Visible = false,
			}):Play()

			TweenService
				:Create(mainHudPrimaryButtonsContainer.UIScale, TweenInfo.new(settFadeDuration), {
					Scale = 0.5,
				})
				:Play()
		end)

		-- Open the main HUD
		self:OpenFrame("MainHUDPrimaryButtons")
	end)
end

function UIController:RegisterFrame(
	name: string,
	openFunction: (trove: Trove.Trove) -> (),
	closeFunction: (trove: Trove.Trove) -> ()
)
	-- Handle the logic

	local cleanupTrove = Trove.new()

	self._frames[name] = {
		openFunction = openFunction,
		closeFunction = closeFunction,
		cleanupTrove = cleanupTrove,
		isOpen = false,
	}

	self:CloseFrame(name)
end

function UIController:OpenFrame(name: string)
	local frame = self._frames[name]

	if frame == nil then
		return
	end

	if frame.isOpen == true then
		--return
	end

	frame.isOpen = true

	coroutine.wrap(function()
		frame.openFunction(frame.cleanupTrove)
	end)()
end

function UIController:CloseFrame(name: string | { string })
	if name == nil then
		return
	end

	if type(name) == "table" then
		for _, frame_name in ipairs(name) do
			self:CloseFrame(frame_name)
		end

		return
	end

	local frame = self._frames[name]

	if frame == nil then
		return
	end

	if frame.isOpen == false then
		--return
	end

	frame.isOpen = false

	coroutine.wrap(function()
		frame.closeFunction(frame.cleanupTrove)
		frame.cleanupTrove:Destroy()
	end)()
end

return UIController
