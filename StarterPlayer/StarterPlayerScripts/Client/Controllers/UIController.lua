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
local UserInputService = game:GetService("UserInputService")

local uiContainer = ReplicatedStorage.UI
local ui_Extras = ReplicatedStorage.Extras.UI

local dirUiTemplates = uiContainer.Templates
local structureShopPreviewTemplate = dirUiTemplates.StructureShopPreview

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)
local Player = LMEngine.Player
local PlayerGui = Player.PlayerGui

local Signal = require(LMEngine.SharedDir.Signal)
local Trove = require(LMEngine.SharedDir.Trove)

local StructureCollection = require(LMEngine.Game.Shared.Structures)

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

		---@type PlacementController
		local PlacementController = LMEngine.GetController("PlacementController")

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

					click_connection = plot_button.Activated:Connect(function()
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
				create_plot_connection = title_screen.CityLoader.ScrollingFrame.CreatePlot.Activated:Connect(
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
			trove:Connect(buildModeButtons.Close.Activated, function()
				self:CloseFrame("PlacementScreen")
				self:OpenFrame("MainHUDPrimaryButtons")
			end)

			trove:Connect(buildModeButtons.Delete.Activated, function()
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

			local function closeDeleteStructureFrame()
				self:CloseFrame("DeleteStructureFrame")
				self:OpenFrame("PlacementScreen")
				PlacementController:DisableDeleteMode()
			end

			trove:Connect(deleteStructureFrame.Button.Activated, closeDeleteStructureFrame)

			trove:Connect(PlacementController.OnStructureDeleteDisabled, closeDeleteStructureFrame)

			trove:Connect(UserInputService.InputBegan, function(input, gameProcessed)
				if gameProcessed == true then
					return
				end

				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.C then
					closeDeleteStructureFrame()
				end
			end)

			PlacementController:EnableDeleteMode()
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
		local selectionListContainer = selectionFrame.ListContainer
		local selectionBottomContainer = selectionListContainer.Container
		local selectionScrollingFrame = selectionBottomContainer.ScrollingFrame

		local function clearSelectionScrollingFrame()
			for _, child in ipairs(selectionScrollingFrame:GetChildren()) do
				if child:IsA("GuiObject") == true then
					child:Destroy()
				end
			end
		end

		self:RegisterFrame("SelectionFrame", function(trove)
			TweenService:Create(selectionFrame, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 0,
				Visible = true,
			}):Play()

			TweenService:Create(selectionFrame.UIScale, TweenInfo.new(settFadeDuration), {
				Scale = 1,
			}):Play()

			-- add the structure preview buttons to the scrolling frame
			clearSelectionScrollingFrame()

			-- get all structures
			for structureCategory, structureCategoryList in pairs(StructureCollection) do
				for _, structureData in ipairs(structureCategoryList) do
					local structureButton = structureShopPreviewTemplate:Clone()
					structureButton.Name = structureData.Name
					structureButton.Label.Text = structureData.Name
					structureButton.Parent = selectionScrollingFrame

					-- set up the viewport frame
					if structureData.Model then
						local viewport = structureButton.Viewport

						local clonedStructure = structureData.Model:Clone()
						clonedStructure.Parent = viewport

						local camera = Instance.new("Camera")
						camera.Parent = viewport

						viewport.CurrentCamera = camera

						-- set up the camera to look at the model
						local modelSize = clonedStructure.PrimaryPart.Size
						local modelCenter = clonedStructure.PrimaryPart.Position + modelSize / 2

						local cameraDistance = modelSize.Magnitude * 1.5
						local cameraPosition = modelCenter + Vector3.new(0, cameraDistance, 0)

						camera.CFrame = CFrame.new(cameraPosition, modelCenter)
					end

					trove:Add(structureButton)

					trove:Connect(structureButton.Button.Activated, function()
						PlacementController:StartPlacement(structureData.Name)
					end)
				end
			end
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
			self:CloseFrame("all")
			self:OpenFrame("SelectionFrame")
			self:OpenFrame("BuildModeFrame")
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
			trove:Connect(mainHudPrimaryButtonsContainer.Build.Activated, function()
				self:OpenFrame("PlacementScreen")
			end)

			trove:Connect(mainHudPrimaryButtonsContainer.Stats.Activated, function()
				self:ToggleFrame("StatsFrame")
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

		-- Stats frame
		local statsFrame: CanvasGroup = mainHudScreen.CityStats

		self:RegisterFrame("StatsFrame", function(trove)
			TweenService:Create(statsFrame, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 0,
				Position = UDim2.fromScale(0.5, 0.5),
				Visible = true,
			}):Play()

			TweenService:Create(statsFrame.UIScale, TweenInfo.new(settFadeDuration), {
				Scale = 1,
			}):Play()
		end, function(trove)
			TweenService:Create(statsFrame, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.9),
				Visible = false,
			}):Play()

			TweenService:Create(statsFrame.UIScale, TweenInfo.new(settFadeDuration), {
				Scale = 0.5,
			}):Play()
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

	if name == "all" then
		for frame_name, _ in pairs(self._frames) do
			self:CloseFrame(frame_name)
		end

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

function UIController:ToggleFrame(name: string)
	local frame = self._frames[name]

	if frame == nil then
		return
	end

	if frame.isOpen == true then
		self:CloseFrame(name)
	else
		self:OpenFrame(name)
	end
end

return UIController
