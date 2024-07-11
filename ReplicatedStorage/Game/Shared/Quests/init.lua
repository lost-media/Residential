export type QuestActionType = "Build" | "Upgrade" | "Destroy"

export type QuestAction = {
	Type: QuestActionType,
	Structure: string,
	Amount: number,
	Accumulative: boolean,
}

export type QuestReward = {
	Structures: {},
	Credits: number,
	Roadbucks: number,
}

export type QuestStep = {
	Narrative: string,
	Objective: string,
	Hint: string,
	CanSkip: boolean,
	Action: QuestAction,

	AdditionalComments: { string },

	Rewards: QuestReward,
}

export type Quest = {
	Id: string,
	Name: string,
	Quests: { [number]: QuestStep },
	Rewards: QuestReward,
}

local dirQuestList = script.QuestList

local QuestCollection: { [string]: Quest } = {}

for _, quest in ipairs(dirQuestList:GetChildren()) do
	if quest:IsA("ModuleScript") == false then
		continue
	end

	local questData = require(quest)

	if questData.Name == nil then
		warn("[QuestCollection] Quest name is nil")
		continue
	end

	if QuestCollection[questData.Name] ~= nil then
		warn("[QuestCollection] Duplicate quest name: " .. questData.Name)
		continue
	end
	QuestCollection[questData.Name] = questData
end

return QuestCollection
