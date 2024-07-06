local dirQuestList = script.Parent.QuestList

local QuestCollection = {}

for _, quest in ipairs(dirQuestList:GetChildren()) do
	if quest:IsA("ModuleScript") == false then
		continue
	end

	if QuestCollection[quest.Name] ~= nil then
		warn("[QuestCollection] Duplicate quest name: " .. quest.Name)
		continue
	end
	QuestCollection[quest.Name] = require(quest)
end

return QuestCollection
