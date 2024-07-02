-- A ModuleScript inside your hooks folder.

local Admins = {
	[1039001211] = true, -- ijmod
	[124114472] = true, --LightColorz
}

local LostMediaGroupId = 11103783

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		if
			context.Group == "Admin"
			and ((context.Executor :: Player):GetRankInGroup(LostMediaGroupId) < 254)
		then
			return "You don't have permission to run this command"
		end
	end)
end
