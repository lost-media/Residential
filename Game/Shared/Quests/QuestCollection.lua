local dirQuestList = script.Parent.QuestList

local QuestCollection = {}

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
