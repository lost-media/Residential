--!strict

--[[
{Lost Media}

-[UIController] Controller
    A controller that manages the UI in the game.
--]]

local SETTINGS = {
	FadeDuration = 0.1,
	GraphemeWait = 0.025,
	PunctuationWait = {
		["."] = 1,
		[","] = 0.25,
		["!"] = 0.4,
		["?"] = 0.5,
	},
}

----- Private variables -----
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local QuestCollection = require(ReplicatedStorage.Game.Shared.Quests)
type Quest = QuestCollection.Quest

local uiContainer = ReplicatedStorage.UI
local ui_Extras = ReplicatedStorage.Extras.UI

local dirUiTemplates = uiContainer.Templates
local structureShopPreviewTemplate = dirUiTemplates.StructureShopPreview

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)
local Player = LMEngine.Player
local PlayerGui = Player.PlayerGui

local NumberFormatter = require(LMEngine.SharedDir.NumberFormatter)
local Signal = require(LMEngine.SharedDir.Signal)
local Trove = require(LMEngine.SharedDir.Trove)

local StructureCollection = require(LMEngine.Game.Shared.Structures)
local StructureUtils = require(LMEngine.Game.Shared.Structures.Utils)

local settFadeDuration = SETTINGS.FadeDuration

---@class UIController
local UIController = LMEngine.CreateController({
	Name = "UIController",

	_frames = {},
	_lastStructureCategory = "Residence",

	_skipQuestDialog = false,
	_questDialogCompleted = true,
	QuestDialogAdvanced = Signal.new(),
})

----- Private functions -----

local function GetGraphemeCount(text: string): number
	local graphemes = utf8.graphemes(text)
	local count = 0

	for _ in graphemes do
		count = count + 1
	end

	return count
end

local function GenerateRandom3LetterString()
	local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local random_string = ""

	for _ = 1, 3 do
		local random_index = math.random(1, #letters)
		random_string = random_string .. letters:sub(random_index, random_index)
	end

	return random_string
end

local function AllFramesExcept(screens: { string }): { string }
	local all_screens = {}

	local frames = UIController._frames

	if frames == nil then
		return {}
	end

	for frame_name, _ in pairs(frames) do
		if table.find(screens, frame_name) == nil then
			table.insert(all_screens, frame_name)
		end
	end

	return all_screens
end

----- Public functions -----

function UIController:Start()
	-- wait for the GUIs to load

	---@type InputController
	local InputController = LMEngine.GetController("InputController")
	local mouse = InputController:GetMouse()

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

		---@type QuestController
		local QuestController = LMEngine.GetController("QuestController")
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

				PlacementController:StopPlacement()
				PlacementController:DisableDeleteMode()
			end)

			trove:Connect(buildModeButtons.Delete.Activated, function()
				if QuestController:IsOnTutorial() == true then
					-- TODO: show toast message
					print("You cannot do that right now")
				end

				self:CloseFrame("PlacementScreen")
				self:OpenFrame("DeleteStructureFrame")
			end)

			local playerCreditsPromise = DataService:GetPlayerCredits()

			playerCreditsPromise:andThen(function(playerCredits: number?)
				if playerCredits == nil then
					return
				end

				local creditsLabel = buildModeContainer.CreditsDisplay.Label

				creditsLabel.Text = NumberFormatter.MonetaryFormat(playerCredits)
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
		local selectionTopTitle = selectionBottomContainer.Top.Title

		local selectionTabContainer = selectionFrame.TabContainer

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

			trove:Connect(PlacementController.PlacementBegan, function()
				self:CloseFrame("SelectionFrame")
			end)

			-- retirve the players credit value
			local playerCreditsPromise = DataService:GetPlayerCredits()

			-- add the structure preview buttons to the scrolling frame
			clearSelectionScrollingFrame()

			trove:Connect(
				selectionScrollingFrame.UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"),
				function()
					selectionScrollingFrame.CanvasSize = UDim2.new(
						0,
						0,
						0,
						selectionScrollingFrame.UIGridLayout.AbsoluteContentSize.Y + 16
					)

					-- restore the scrolling frame position
					selectionScrollingFrame.CanvasPosition =
						Vector2.new(0, self._selectionFrameScrollingFramePosition or 0)
				end
			)

			local isRenderingCollection = false

			trove:Connect(
				selectionScrollingFrame:GetPropertyChangedSignal("CanvasPosition"),
				function()
					if isRenderingCollection == true then
						return
					end
					self._selectionFrameScrollingFramePosition =
						selectionScrollingFrame.CanvasPosition.Y
				end
			)

			local function sortByPrice(collections: table)
				table.sort(collections, function(a, b)
					return a.Price < b.Price
				end)
			end

			-- render the collection of structures
			-- @param collection: table
			-- @param highlightedStructureId: string? (useful for quests
			-- where the player needs to select a certain structure)
			local function renderCollection(collection: table, highlightedStructureId: string?)
				if isRenderingCollection == true then
					return
				end

				isRenderingCollection = true

				clearSelectionScrollingFrame()

				local function getTweenInfo(i: number)
					return TweenInfo.new(
						settFadeDuration,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out,
						0,
						false,
						i / 25
					)
				end

				playerCreditsPromise:andThen(function(playerCredits: number?)
					-- get all structures
					for i, structureData in pairs(collection) do
						local structureButton = structureShopPreviewTemplate:Clone()
						structureButton.Name = structureData.Name
						structureButton.Label.Text = structureData.Name
						structureButton.Parent = selectionScrollingFrame

						structureButton.UIScale.Scale = 0.5

						structureButton.Price.Text =
							NumberFormatter.MonetaryFormat(structureData.Price)

						if playerCredits ~= nil then
							if playerCredits < structureData.Price then
								structureButton.Price.TextColor3 = Color3.fromRGB(255, 0, 0)
							else
								structureButton.Price.TextColor3 = Color3.fromRGB(0, 100, 0)
							end
						else
							structureButton.Price.TextColor3 = Color3.fromRGB(0, 0, 0)
						end

						structureButton.UIScale.Scale = 0.5
						structureButton.GroupTransparency = 1

						TweenService:Create(structureButton, getTweenInfo(i), {
							GroupTransparency = 0,
							Visible = true,
						}):Play()

						TweenService:Create(structureButton.UIScale, getTweenInfo(i), {
							Scale = 1,
						}):Play()

						if
							highlightedStructureId ~= nil
							and highlightedStructureId ~= structureData.Id
						then
							structureButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
							structureButton.Label.TextColor3 = Color3.fromRGB(100, 100, 100)
							structureButton.Button.Visible = false
						end

						-- set up the viewport frame
						if structureData.Model then
							local viewport = structureButton.Viewport

							local clonedStructure = structureData.Model:Clone()
							clonedStructure.Parent = viewport

							local camera = Instance.new("Camera")
							camera.Parent = viewport

							viewport.CurrentCamera = camera

							-- Calculate the object's bounding box
							local modelCFrame, modelSize = clonedStructure:GetBoundingBox()
							local modelCenter = modelCFrame.Position

							-- Initial camera distance based on the model size
							local cameraDistance = modelSize.Magnitude * 0.7

							local function updateCameraPosition(angle)
								local x = math.sin(angle) * cameraDistance
								local z = math.cos(angle) * cameraDistance
								local aerialAngleRadians =
									math.rad(structureData.AerialViewAngle or 0)
								local y = math.sin(aerialAngleRadians) * cameraDistance
								local cameraPosition = modelCenter + Vector3.new(x, y, z)
								camera.CFrame = CFrame.new(cameraPosition, modelCenter)
							end

							local angle = 0

							local viewportRotationSpeed = 0.8

							trove:Connect(structureButton.MouseEnter, function()
								viewportRotationSpeed = 0.4

								TweenService:Create(structureButton.UIStroke, TweenInfo.new(0.1), {
									Transparency = 0.3,
								}):Play()
							end)

							trove:Connect(structureButton.MouseLeave, function()
								viewportRotationSpeed = 0.8

								-- update the stoke color
								TweenService:Create(structureButton.UIStroke, TweenInfo.new(0.1), {
									Transparency = 0.9,
								}):Play()
							end)

							trove:Connect(RunService.RenderStepped, function(deltaTime)
								angle = angle + viewportRotationSpeed * deltaTime
								updateCameraPosition(angle)
							end)
						end

						trove:Add(structureButton)

						trove:Connect(structureButton.Button.Activated, function()
							PlacementController:StartPlacement(structureData.Id)
						end)
					end

					isRenderingCollection = false
				end)
			end

			local isOnTutorial = QuestController:IsOnTutorial()

			local function filterByStructureCategory(category: string)
				local collection = StructureUtils.GetStructuresFromCategory(category)

				if collection == nil then
					return
				end

				self._lastStructureCategory = category
				selectionTopTitle.Text = category

				-- sort by price
				sortByPrice(collection)

				local highlightedStructureId: string? = nil

				if isOnTutorial == true then
					local currentQuest: Quest = QuestController:GetCurrentQuest()

					if currentQuest ~= nil then
						local step = QuestController:GetQuestStep()

						local questStep = currentQuest.Quests[step]

						if questStep ~= nil then
							if questStep.Action.Type == "Build" then
								local structureId = questStep.Action.Structure

								if structureId ~= nil then
									highlightedStructureId = structureId
								end
							end
						end
					end
				end

				coroutine.wrap(function()
					renderCollection(collection, highlightedStructureId)
				end)()
			end

			for _, tab in ipairs(selectionTabContainer:GetChildren()) do
				if tab:IsA("GuiObject") == true then
					trove:Connect(tab.Button.Activated, function()
						filterByStructureCategory(tab.Name)
					end)
				end
			end

			local category = "Residence"

			if isOnTutorial == true then
				local step = QuestController:GetQuestStep()

				if step == 1 then
					category = "City Hall"
				end
			else
				category = self._lastStructureCategory or "Residence"
			end

			filterByStructureCategory(category)
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
			self:CloseFrame(AllFramesExcept({
				"SelectionFrame",
				"BuildModeFrame",
				"QuestDialogFrame",
				"QuestObjectiveFrame",
			}))
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

		local questDialogScreen = PlayerGui.QuestDialog
		local questDialogFrame: CanvasGroup = questDialogScreen.Frame
		local questDialogContainer = questDialogFrame.Container

		local questObjectiveContainer: CanvasGroup = questDialogScreen.Objective

		self:RegisterFrame("QuestObjectiveFrame", function(trove)
			TweenService:Create(questObjectiveContainer, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 0,
				Visible = true,
			}):Play()

			TweenService:Create(questObjectiveContainer.UIScale, TweenInfo.new(settFadeDuration), {
				Scale = 1,
			}):Play()
		end, function(trove)
			TweenService:Create(questObjectiveContainer, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 1,
				Visible = false,
			}):Play()

			TweenService:Create(questObjectiveContainer.UIScale, TweenInfo.new(settFadeDuration), {
				Scale = 0.5,
			}):Play()
		end)

		self:RegisterFrame("QuestDialogFrame", function(trove)
			TweenService:Create(questDialogFrame, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 0,
				Visible = true,
			}):Play()

			TweenService:Create(questDialogContainer.UIScale, TweenInfo.new(settFadeDuration), {
				Scale = 1,
			}):Play()

			trove:Connect(questDialogContainer.Button.MouseButton1Click, function()
				if self._questDialogCompleted == true then
					-- do something
					self.QuestDialogAdvanced:Fire()
					self._skipQuestDialog = false
					self._questDialogCompleted = false
				else
					self._skipQuestDialog = true
				end
			end)
		end, function(trove)
			self._skipQuestDialog = false
			self._questDialogCompleted = true

			TweenService:Create(questDialogFrame, TweenInfo.new(settFadeDuration), {
				GroupTransparency = 1,
				Visible = false,
			}):Play()

			TweenService:Create(questDialogContainer.UIScale, TweenInfo.new(settFadeDuration), {
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
		return
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

function UIController:IsFrameOpen(name: string): boolean
	local frame = self._frames[name]

	if frame == nil then
		return false
	end

	return frame.isOpen
end

function UIController:ShowQuestDialog(title: string, text: string)
	assert(title ~= nil, "Title is nil")
	assert(text ~= nil, "Text is nil")

	if self:IsFrameOpen("QuestDialogFrame") == false then
		self:OpenFrame("QuestDialogFrame")
	end

	local questDialogFrame = PlayerGui.QuestDialog.Frame
	local questDialogContainer = questDialogFrame.Container
	local questDialogTextContainer = questDialogContainer.Container

	questDialogTextContainer.Title.Text = title
	questDialogTextContainer.Action.Visible = false

	local graphemes = utf8.graphemes(text)
	local bodyText: TextLabel = questDialogTextContainer.Body

	bodyText.Text = text

	bodyText.MaxVisibleGraphemes = 0

	self._questDialogCompleted = false
	self._skipQuestDialog = false

	local first, last = graphemes()

	while last ~= nil do
		if self._skipQuestDialog == true then
			break
		end

		local grapheme = text:sub(first, last)
		local punctuationWait = SETTINGS.PunctuationWait[grapheme]

		bodyText.MaxVisibleGraphemes = last

		if punctuationWait ~= nil then
			task.wait(punctuationWait)
		else
			task.wait(SETTINGS.GraphemeWait)
		end

		first, last = graphemes()
	end

	bodyText.MaxVisibleGraphemes = GetGraphemeCount(text)

	self._questDialogCompleted = true
	self._skipQuestDialog = false

	questDialogTextContainer.Action.Visible = true
end

function UIController:UpdateQuestObjective(title: string, objective: string)
	local questObjectiveFrame = PlayerGui.QuestDialog.Objective

	questObjectiveFrame.Top.Title.Text = title
	questObjectiveFrame.Task.Label.Text = objective

	self:OpenFrame("QuestObjectiveFrame")
end

return UIController
