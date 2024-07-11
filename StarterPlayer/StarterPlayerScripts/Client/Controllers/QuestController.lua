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

	_quest = nil,
	_questStep = 1,
	_additionalCommentIndex = 1,
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

	local plotPromise = PlotController:GetPlotAsync()

	plotPromise:andThen(function(plot)
		task.wait(1)
		--self:StartQuest(SETTINGS.TutorialQuestId, 1)
	end)

	local QuestService = LMEngine.GetService("QuestService")

	QuestService.QuestStarted:Connect(function(id: string, step: number)
		questControllerTrove:Destroy()
		self:StartQuest(id, step)
	end)

	QuestService.QuestProgressed:Connect(function(id: string, step: number)
		questControllerTrove:Destroy()
		self:StartQuest(id, step)
	end)

	QuestService.QuestEnded:Connect(function(questId: string)
		self._quest.Ended = true

		---@type UIController
		local UIController = LMEngine.GetController("UIController")
		---@type FrameController
		local FrameController = LMEngine.GetController("FrameController")

		FrameController:CloseFrame("QuestObjectiveFrame")

		UIController:ShowQuestDialog(
			"Quest Complete",
			"Congratulations! You have completed the quest."
		)

		questControllerTrove:Connect(UIController.QuestDialogAdvanced, function()
			print("TEST")
			self:AdvanceQuestEndingDialog()
		end)
	end)
end

function QuestController:StartQuest(id: string, step: number)
	local quest = getQuest(id)
	assert(quest ~= nil, "[QuestController] StartQuest: Quest does not exist")

	if quest then
		---@type UIController
		local UIController = LMEngine.GetController("UIController")
		---@type FrameController
		local FrameController = LMEngine.GetController("FrameController")

		self._quest = quest
		self._questStep = step
		quest.Ended = false

		if quest.Id == SETTINGS.TutorialQuestId and step == 1 then
			FrameController:CloseFrame("MainHUDPrimaryButtons")
		end

		if quest.Id == SETTINGS.TutorialQuestId then
			---@type PlacementController
			local PlacementController = LMEngine.GetController("PlacementController")

			PlacementController:StopPlacement()
			FrameController:CloseFrame("PlacementScreen")
		end

		FrameController:CloseFrame("QuestObjectiveFrame")

		questControllerTrove:Connect(UIController.QuestDialogAdvanced, function()
			self:AdvanceQuestDialog()
		end)

		coroutine.wrap(function()
			local quest1 = quest.Quests[step]
			if quest1 then
				if quest1.Type ~= "Dialog" then
					---@type UIController
					UIController:ShowQuestDialog(quest.Name, quest1.Narrative)
				else
					UIController:ShowQuestDialog(quest.Name, quest1.Narrative)
				end
			end
		end)()
	end
end

function QuestController:AdvanceQuestDialog()
	if self._quest then
		local quest = self._quest
		local step = self._questStep

		if quest.Quests[step] == nil then
			return
		end

		local additionalComments = quest.Quests[step].AdditionalComments

		if additionalComments and additionalComments[self._additionalCommentIndex] then
			---@type UIController
			local UIController = LMEngine.GetController("UIController")
			UIController:ShowQuestDialog(
				quest.Name,
				additionalComments[self._additionalCommentIndex]
			)
			self._additionalCommentIndex = self._additionalCommentIndex + 1
			return
		end

		self._additionalCommentIndex = 1

		-- at this point, the quest dialog is complete, so just show the objective

		---@type UIController
		local UIController = LMEngine.GetController("UIController")
		---@type FrameController
		local FrameController = LMEngine.GetController("FrameController")

		FrameController:CloseFrame("QuestDialogFrame")
		FrameController:OpenFrame("QuestObjectiveFrame")

		UIController:UpdateQuestObjective(quest.Name, quest.Quests[step].Objective)

		if quest.Id == "Tutorial" then
			FrameController:OpenFrame("MainHUDPrimaryButtons")
		end
	end
end

function QuestController:AdvanceQuestEndingDialog()
	if self._quest then
		local quest = self._quest
		local step = self._questStep

		if quest.Quests[step] == nil then
			return
		end

		local additionalComments = quest.Quests[step].EndingDialogue

		if additionalComments and additionalComments[self._additionalCommentIndex] then
			---@type UIController
			local UIController = LMEngine.GetController("UIController")
			UIController:ShowQuestDialog(
				quest.Name,
				additionalComments[self._additionalCommentIndex]
			)
			self._additionalCommentIndex = self._additionalCommentIndex + 1
			return
		end

		self._additionalCommentIndex = 1

		-- at this point, the quest dialog is complete, so hide everything

		---@type UIController
		local UIController = LMEngine.GetController("UIController")
		---@type FrameController
		local FrameController = LMEngine.GetController("FrameController")

		FrameController:CloseFrame("QuestDialogFrame")
		FrameController:OpenFrame("QuestObjectiveFrame")
	end
end

function QuestController:GetCurrentQuest()
	return self._quest
end

function QuestController:IsOnTutorial()
	return self._quest and self._quest.Id == SETTINGS.TutorialQuestId
end

function QuestController:GetQuestStep()
	return self._questStep
end

return QuestController
