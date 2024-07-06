local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LMEngine = require(ReplicatedStorage.LMEngine.Client)

local QuestController = LMEngine.CreateController({
	Name = "QuestController",
})

function QuestController:StartDialog(dialog: Dialog)
	self._dialog = dialog
	self._dialog:Start()
end

return QuestController
