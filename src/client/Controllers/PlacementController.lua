--!strict

local RS = game:GetService("ReplicatedStorage");

local Knit = require(RS.Packages.Knit);

local PlacementController = Knit.CreateController {
    Name = "PlacementController";

    State = {
        Placing = false;
        CurrentPlaceable = nil;
    };
};

function PlacementController:KnitInit()
    print("PlacementController initialized");
end

function PlacementController:KnitStart()
    print("PlacementController started");
end

return PlacementController;