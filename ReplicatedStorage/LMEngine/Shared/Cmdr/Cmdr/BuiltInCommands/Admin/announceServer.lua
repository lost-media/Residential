local Chat = game:GetService("Chat")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

return function(context, text)
	local filterResult = TextService:FilterStringAsync(
		text,
		context.Executor.UserId,
		Enum.TextFilterContext.PublicChat
	)

	for _, player in ipairs(Players:GetPlayers()) do
		if Chat:CanUsersChatAsync(context.Executor.UserId, player.UserId) then
			context:SendEvent(
				player,
				"Message",
				filterResult:GetChatForUserAsync(player.UserId),
				context.Executor
			)
		end
	end

	return "Created announcement."
end
