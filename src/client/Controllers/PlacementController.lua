--!strict

local RS = game:GetService("ReplicatedStorage");

local Knit = require(RS.Packages.Knit);
local Mouse = require(script.Parent.Parent.Utils.Mouse);

local PlacementController = Knit.CreateController {
    Name = "PlacementController";
    Mouse = Mouse.new();
}

function PlacementController:KnitInit()
    print("PlacementController initialized");
end

function PlacementController:KnitStart()
    print("PlacementController started");
end

return PlacementController;