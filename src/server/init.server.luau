local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit);

Knit.AddServices(script.Services);

Knit.Start():andThen(function()
    print("Server started");
end):catch(function(err)
    warn("Server failed to start:", err);
end);