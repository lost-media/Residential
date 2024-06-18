local LMEngine = require(game:GetService("ReplicatedStorage").LMEngine)

local TestController = LMEngine.CreateController({
	Name = "TestController",
})

function TestController:Start()
	print("[TestController] started")
end

return TestController
