--[[
*{Residential} -[QuestController]- v1.0.0 -----------------------------------
Module description

Author: AuthorName
Last Modified: YYYY-MM-DD

Dependencies:
    - Dependency1
    - Dependency2

Usage:
    local QuestController = require(game.ReplicatedStorage.Modules.QuestController)
    QuestController.someFunction()

Functions:
    - functionName(param1: type, param2: type): returnType
      Brief description of the function
    - ...

Members [ClassName]:
    - memberName: type (brief description)
    - ...

Methods [ClassName]:
    - methodName(param1: type, param2: type): returnType
      Brief description of the method
    - ...

Changelog:
    v1.0.0 - Initial implementation
--]]

local SETTINGS = {
	TutorialQuestId = "Tutorial",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LMEngine = require(ReplicatedStorage.LMEngine.Client)

local Trove = require(LMEngine.SharedDir.Trove)

local questControllerTrove = Trove.new()

local DialogCollection = require(LMEngine.Game.Shared.Quests)
type Quest = DialogCollection.Quest

---@class QuestController
local QuestController = LMEngine.CreateController({
	Name = "QuestController",

	_quests = {},
})

----- Private functions -----

local function getQuests(): { Quest }
	local quests: { Quest } = {}
	for _, quest in pairs(DialogCollection) do
		table.insert(quests, quest)
	end
	return quests
end

local function getQuest(id: string): Quest?
	local quests = getQuests()
	for _, quest in pairs(quests) do
		if quest.Id == id then
			return quest
		end
	end
	return nil
end

----- Public functions -----

function QuestController:Start()
	---@type PlotController
	local PlotController = LMEngine.GetController("PlotController")

	local QuestService = LMEngine.GetService("QuestService")

	QuestService.QuestStarted:Connect(function(id: string, step: number)
		questControllerTrove:Destroy()
		self:StartQuest(id, step)
	end)

	QuestService.QuestStepUpdated:Connect(function(id: string, step: number)
		questControllerTrove:Destroy()
		self:StartQuestStep(id, step)
	end)

	QuestService.QuestCompleted:Connect(function(questId: string)
		local quest = getQuest(questId)
		if quest == nil then
			warn("[QuestController] Quest not found: " .. questId)
			return
		end

		self:StartEndingDialog(questId)
	end)
end

function QuestController:StartQuest(id: string)
	local quest = getQuest(id)
	if quest == nil then
		warn("[QuestController] Quest not found: " .. id)
		return
	end

	self._quests[id] = {
		CurrentStep = 1,
		Completed = false,
	}

	self:StartQuestStep(id, 1)
end

function QuestController:StartQuestStep(id: string, step: number)
	local quest = getQuest(id)
	if quest == nil then
		warn("[QuestController] Quest not found: " .. id)
		return
	end

	local questStep = quest.Quests[step]
	if questStep == nil then
		warn("[QuestController] Quest step not found: " .. id .. " - " .. step)
		return
	end

	---@type UIController
	local UIController = LMEngine.GetController("UIController")
	---@type FrameController
	local FrameController = LMEngine.GetController("FrameController")

	-- Hide all frames
	local framesClosed = FrameController:CloseAllFramesExcept({})

	-- First, show the dialog
	FrameController:OpenFrame("DialogFrame")

	local currentNarrativeIndex = 1
	local currentNarrative = questStep.Narrative[currentNarrativeIndex]

	UIController:UpdateDialog(quest.Name, currentNarrative)

	questControllerTrove:Connect(UIController.DialogAdvanced, function()
		currentNarrativeIndex = currentNarrativeIndex + 1
		currentNarrative = questStep.Narrative[currentNarrativeIndex]

		if currentNarrative == nil then
			FrameController:CloseFrame("DialogFrame")

			FrameController:OpenFrame("QuestObjectiveFrame")
			UIController:UpdateQuestObjective(quest.Name, questStep.Objective)

			-- Open all frames that were closed except the dialog frame
			-- Remove the dialog frame from the list of frames to open
			local dialogFrameIndex = table.find(framesClosed, "DialogFrame")
			if dialogFrameIndex ~= nil then
				table.remove(framesClosed, dialogFrameIndex)
			end

			FrameController:OpenFrame({
				"MainHUDPrimaryButtons",
			})
		else
			UIController:UpdateDialog(quest.Name, currentNarrative)
		end
	end)
end

function QuestController:StartEndingDialog(id: string)
	local quest = getQuest(id)

	if quest == nil then
		warn("[QuestController] Quest not found: " .. id)
		return
	end

	local endingDialog = quest.EndingDialog

	if endingDialog == nil then
		return
	end

	---@type UIController
	local UIController = LMEngine.GetController("UIController")
	---@type FrameController
	local FrameController = LMEngine.GetController("FrameController")

	-- First, show the dialog
	FrameController:OpenFrame("DialogFrame")

	-- Close the quest objective frame
	FrameController:CloseFrame("QuestObjectiveFrame")

	local currentNarrativeIndex = 1
	local currentNarrative = endingDialog[currentNarrativeIndex]

	UIController:UpdateDialog(quest.Name, currentNarrative)

	questControllerTrove:Connect(UIController.DialogAdvanced, function()
		currentNarrativeIndex = currentNarrativeIndex + 1
		currentNarrative = endingDialog[currentNarrativeIndex]

		if currentNarrative == nil then
			FrameController:CloseFrame("DialogFrame")
		else
			UIController:UpdateDialog(quest.Name, currentNarrative)
		end
	end)
end

function QuestController:GetQuests()
	return self._quests
end

function QuestController:IsOnTutorial()
	return self._quests and self._quests[SETTINGS.TutorialQuestId] ~= nil
end

return QuestController
