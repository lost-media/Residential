local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineServer
local LMEngine = require(ReplicatedStorage.LMEngine)

local QuestCollection = require(LMEngine.Game.Shared.Quests)
type Quest = QuestCollection.Quest

---@class QuestService
local QuestService = LMEngine.CreateService({
	Name = "QuestService",
	Client = {
		QuestStarted = LMEngine.CreateSignal(),
		QuestProgressed = LMEngine.CreateSignal(),
	},

	_quests = {},
	_connections = {},
})

----- Private functions -----

local function getQuests(): { Quest }
	local quests: { Quest } = {}
	for _, quest in pairs(QuestCollection) do
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

local function getQuestStep(id: string, step: number)
	local quest = getQuest(id)
	if quest == nil then
		return nil
	end

	for questStep, data in ipairs(quest.Quests) do
		if questStep == step then
			return data
		end
	end

	return nil
end

----- Public functions -----

function QuestService:Start()
	---@type PlayerService
	local PlayerService = LMEngine.GetService("PlayerService")
	---@type DataService
	local DataService = LMEngine.GetService("DataService")

	PlayerService:RegisterPlayerAdded(function(player: Player)
		self._quests[player] = {}
		self._connections[player] = {}

		DataService.PlotLoaded:Connect(function(player: Player, plot: any)
			local completedTutorial = plot.CompletedTutorial or false
			if completedTutorial then
				return
			end
			--self:StartQuest(player, "Tutorial")
		end)
	end, "LOW")

	PlayerService:RegisterPlayerRemoved(function(player: Player)
		self._quests[player] = nil
		-- disconnect all connections
		for _, connection in pairs(self._connections[player]) do
			connection:Disconnect()
		end
		self._connections[player] = nil
	end)
end

function QuestService:StartQuest(player: Player, questId: string)
	assert(player, "[QuestService] StartQuest: Player is nil")
	assert(questId, "[QuestService] StartQuest: QuestId is nil")

	local quest = getQuest(questId)
	assert(quest ~= nil, "[QuestService] StartQuest: Quest does not exist")

	---@type DataService
	local DataService = LMEngine.GetService("DataService")

	local plot = DataService:GetPlot(player)
	assert(plot, "[QuestService] StartQuest: Plot is nil")

	local plotData = plot.Data

	if plotData.CompletedQuests and plotData.CompletedQuests[questId] then
		warn("[QuestService] StartQuest: Quest already completed")
		return
	end

	if plotData.Quests == nil then
		plotData.Quests = {}
	end

	if plotData.Quests[questId] == nil then
		plotData.Quests[questId] = {
			Step = 1,
			Progress = {}, -- progress on the current step
		}
	end

	self._quests[player] = {
		Quest = quest,
		Data = plotData.Quests[questId],
	}

	self:RegisterQuestAction(player, questId, plotData.Quests[questId].Step)

	self.Client.QuestStarted:Fire(player, questId, plotData.Quests[questId].Step)

	print("[QuestService] StartQuest: Started quest " .. questId .. " for player " .. player.Name)
end

function QuestService:RegisterQuestAction(player: string, questId: string, step: number)
	assert(player ~= nil, "[QuestService] RegisterQuestAction: Player is nil")
	assert(questId ~= nil, "[QuestService] RegisterQuestAction: Type is nil")
	assert(step ~= nil, "[QuestService] RegisterQuestAction: Step is nil")

	local questStep = getQuestStep(questId, step)

	if questStep == nil then
		return
	end

	local type = questStep.Action.Type

	---@type PlotService
	local PlotService = LMEngine.GetService("PlotService")

	if self._connections[player] == nil then
		self._connections[player] = {}
	end

	local function checkProgress()
		local progress = self._quests[player].Data.Progress[step] or 0
		if progress >= questStep.Action.Amount then
			self._quests[player].Data.Step = step + 1
			self._quests[player].Data.Progress[step] = nil

			self.Client.QuestProgressed:Fire(player, questId, step + 1)

			-- check if the quest is completed
			if self._quests[player].Quest.Quests[self._quests[player].Data.Step] == false then
				print("[QuestService] RegisterQuestAction: Quest completed")

				-- mark the quest as completed
				local DataService = LMEngine.GetService("DataService")
				local plot = DataService:GetPlot(player)
				plot.Data.CompletedQuests = plot.Data.CompletedQuests or {}
				plot.Data.CompletedQuests[questId] = true
			else
				-- register the next quest action
				self:RegisterQuestAction(player, questId, step + 1)
			end
			return true
		end

		return false
	end

	if type == "Build" then
		local structureType = questStep.Action.Structure

		-- check if the user has already placed the structure
		if questStep.Action.Accumulative == true then
			if PlotService:PlotHasStructure(player, structureType) then
				self._quests[player].Data.Progress[step] = 1

				checkProgress()
			end
		end
		local connection
		connection = PlotService.StructurePlaced:Connect(function(structure: Model)
			if structure == nil then
				return
			end

			local structureId = structure:GetAttribute("Id")
			if structureId == structureType then
				print("[QuestService] RegisterQuestAction: StructurePlaced")

				-- add one to the progress
				self._quests[player].Data.Progress[step] = (
					self._quests[player].Data.Progress[step] or 0
				) + 1

				local finished = checkProgress()
				if finished then
					connection:Disconnect()
				end
			end
		end)

		table.insert(self._connections[player], connection)
	end
end

return QuestService
