--!strict

local RS = game:GetService("ReplicatedStorage");

local Knit = require(RS.Packages.Knit);
local PlacementClient = require(script.Parent.Parent.Utils.PlacementClient);

local PlacementController = Knit.CreateController {
    Name = "PlacementController";

    PlacementClient = nil;
}

function PlacementController:KnitInit()
    print("PlacementController initialized");
end

function PlacementController:KnitStart()
    print("PlacementController started");

    self:StartPlacement();
end

--[[
    Start the placement process for a structure
    @param structureId The identifier of the structure to place
]]
function PlacementController:StartPlacement(structureId: string)
    -- Get the plot the player is currently on
    if (self.PlacementClient == nil) then
        -- Get the plot the player is currently on
        local PlotService = Knit.GetController("PlotController");
        local plot = PlotService:GetPlot();

        if (plot == nil) then
            warn("Plot is nil");
            return;
        end

        self.PlacementClient = PlacementClient.new(plot);
    end
end

function PlacementController:StopPlacement()
    if (self.PlacementClient ~= nil) then
        self.PlacementClient:Destroy();
        -- Garbage collect the PlacementClient instance
        self.PlacementClient = nil;
    end
end

return PlacementController;