type StoredQuest = {
	Step: number,
	Progress: number,
	Completed: boolean,
}

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
		QuestProgressUpdated = LMEngine.CreateSignal(),
		QuestStepUpdated = LMEngine.CreateSignal(),
		QuestCompleted = LMEngine.CreateSignal(),
	},

	---@type table<Player, table>
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
	---@type PlotService
	local PlotService = LMEngine.GetService("PlotService")

	PlayerService:RegisterPlayerAdded(function(player: Player)
		self._quests[player] = {}
		self._connections[player] = {}

		table.insert(
			self._connections[player],
			DataService.PlotLoaded:Connect(function(player: Player, plot: any)
				local completedTutorial = plot.CompletedTutorial or false
				if completedTutorial then
					return
				end
				self:StartQuest(player, "Tutorial")
			end)
		)
	end, "LOW")

	PlayerService:RegisterPlayerRemoved(function(player: Player)
		self._quests[player] = nil
		-- disconnect all connections
		for _, connection in pairs(self._connections[player]) do
			connection:Disconnect()
		end
		self._connections[player] = nil
	end)

	-- Listen for events that trigger quest progress
	PlotService.StructurePlaced:Connect(function(player: Player, structure: Model)
		self:OnBuildStructure(player, structure)
	end)

	-- Listen for plot events
	for _, plot in ipairs(PlotService:GetPlots()) do
		local roadNetwork = plot:GetRoadNetwork()
		roadNetwork.AllBuildingsConnected:Connect(function()
			self:OnAllBuildingsConnected(plot:GetPlayer())
		end)
	end
end

function QuestService:AddQuest(player: Player, questId: string)
	assert(player, "[QuestService] AddQuest: Player is nil")
	assert(questId, "[QuestService] AddQuest: QuestId is nil")

	---@type DataService
	local DataService = LMEngine.GetService("DataService")

	local isQuestCompleted = DataService:IsQuestCompleted(player, questId)

	if isQuestCompleted then
		return
	end

	if self._quests[player] == nil then
		self._quests[player] = {}
	end

	if self._quests[player][questId] == nil then
		self._quests[player][questId] = {
			Step = 1,
			Progress = 0,
			Completed = false,
		}
	end
end

function QuestService:GetQuest(player: Player, questId: string): StoredQuest?
	assert(player, "[QuestService] GetQuest: Player is nil")
	assert(questId, "[QuestService] GetQuest: QuestId is nil")

	if self._quests[player] == nil then
		return nil
	end

	return self._quests[player][questId]
end

function QuestService:UpdateQuestProgress(
	player: Player,
	questId: string,
	progressIncrement: number
)
	assert(player ~= nil, "[QuestService] UpdateQuestProgress: Player is nil")
	assert(questId ~= nil, "[QuestService] UpdateQuestProgress: QuestId is nil")
	assert(progressIncrement ~= nil, "[QuestService] UpdateQuestProgress: ProgressIncrement is nil")

	local quest = self:GetQuest(player, questId)
	if not quest or quest.Completed then
		return
	end

	-- Update progress
	quest.Progress = quest.Progress + progressIncrement

	-- Fire the QuestProgressUpdated event
	self.Client.QuestProgressUpdated:Fire(player, questId, quest.Progress)

	-- Get current quest step data
	local questStepData = getQuestStep(questId, quest.Step)
	if not questStepData or not questStepData.Action.Amount then
		return
	end

	-- Check if current step is completed
	if quest.Progress >= questStepData.Action.Amount then
		-- Reward the player and reset progress for the next step
		quest.Step = quest.Step + 1
		quest.Progress = 0

		-- Check if the quest is completed
		local questData = getQuest(questId)
		if quest.Step > #questData.Quests then
			quest.Completed = true
			-- Handle quest completion, e.g., reward player

			-- Fire the QuestCompleted event
			self.Client.QuestCompleted:Fire(player, questId)

			-- Remove the quest from the player's quest list
			self:RemoveQuest(player, questId)
		else
			-- Fire the QuestStepUpdated event
			self.Client.QuestStepUpdated:Fire(player, questId, quest.Step)

			-- Optionally handle the transition to the next step, if needed
			-- e.g., update the quest objective in the UI
			-- Additionally, reward the player for completing the step if needed
			local stepRewards = questStepData.Rewards
		end
	end
end

function QuestService:CheckQuestCompletion(player, questId)
	-- Check if a quest is completed
	local quest = self.quests[player][questId]
	if quest == nil then
		return false
	end

	return quest.Completed
end

function QuestService:RemoveQuest(player, questId)
	-- Remove a quest from a player
	if self._quests[player] then
		local quest = self._quests[player][questId]
		if quest == nil then
			return
		end

		local completed = quest.Completed
		if completed == true then
			-- Save the quest data to the player's plot profile
			---@type DataService
			local DataService = LMEngine.GetService("DataService")

			DataService:SetQuestCompleted(player, questId)
		end

		self._quests[player][questId] = nil
	end
end

function QuestService:StartQuest(player: Player, questId: string)
	-- Validate the input
	assert(player, "[QuestService] StartQuest: Player is nil")
	assert(questId, "[QuestService] StartQuest: QuestId is nil")

	-- Check if the quest exists
	assert(getQuest(questId) ~= nil, "[QuestService] StartQuest: Quest does not exist")

	---@type DataService
	local DataService = LMEngine.GetService("DataService")

	local isQuestCompleted = DataService:IsQuestCompleted(player, questId)

	if isQuestCompleted then
		return
	end

	local isQuestStarted = DataService:IsQuestStarted(player, questId)

	if isQuestStarted then
		return
	end

	self:AddQuest(player, questId)

	DataService:UpdateQuestProgress(player, questId, {
		Step = 1,
		Progress = 0,
	})

	-- Fire the QuestStarted event
	self.Client.QuestStarted:Fire(player, questId)

	print("[QuestService] StartQuest: Started quest " .. questId .. " for player " .. player.Name)
end

function QuestService:OnBuildStructure(player: Player, structure: Model)
	-- Validate the input
	assert(player, "[QuestService] OnBuildStructure: Player is nil")
	assert(structure, "[QuestService] OnBuildStructure: Structure is nil")

	local quests = self._quests[player]
	if quests == nil then
		return
	end

	-- Check if the player has a quest to build a structure
	for questId, questData in pairs(quests) do
		local quest = getQuest(questId)
		if quest == nil then
			continue
		end

		local questStepData = getQuestStep(questId, questData.Step)
		if questStepData == nil then
			continue
		end

		if questStepData.Action.Type == "BuildStructure" then
			local structureId = structure:GetAttribute("Id")
			if structureId == questStepData.Action.StructureId then
				self:UpdateQuestProgress(player, questId, 1)
			end
		end
	end
end

function QuestService:OnAllBuildingsConnected(player: Player)
	if player == nil then
		return
	end

	local quests = self._quests[player]
	if quests == nil then
		return
	end

	-- Check if the player has a quest to build a structure
	for questId, questData in pairs(quests) do
		local quest = getQuest(questId)
		if quest == nil then
			continue
		end

		local questStepData = getQuestStep(questId, questData.Step)
		if questStepData == nil then
			continue
		end

		if questStepData.Action.Type == "ConnectAllBuildings" then
			self:UpdateQuestProgress(player, questId, 1)
		end
	end
end

return QuestService
