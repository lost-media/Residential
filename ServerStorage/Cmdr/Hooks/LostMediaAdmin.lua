-- A ModuleScript inside your hooks folder.

local Admins = {
	[1039001211] = true, -- ijmod
	[124114472] = true, --LightColorz
}

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		if context.Group == "Admin" and Admins[context.Executor.UserId] ~= true then
			return "You don't have permission to run this command"
		end
	end)
end
