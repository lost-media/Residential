--!strict

local RS = game:GetService("ReplicatedStorage");

local Knit = require(RS.Packages.Knit);
local PlacementClient = require(script.Parent.Parent.Utils.PlacementClient);
local PlotTypes = require(RS.Shared.Types.Plot);

export type PlacementController = {
	Name: string,
    [any]: any,

    Plot: PlotTypes.Plot?,
    PlacementClient: PlacementClient.PlacementClient?,
}

local PlacementController: PlacementController = Knit.CreateController {
    Name = "PlacementController";

    Plot = nil;
    PlacementClient = nil;
}

function PlacementController:KnitInit()
    print("PlacementController initialized");
end

function PlacementController:KnitStart()
    print("PlacementController started");

    local PlotService = Knit.GetController("PlotController");
    local plot = PlotService:GetPlot();

    if (plot == nil) then
        PlotService.OnPlotAssigned:Connect(function(plotN: PlotTypes.Plot)
            self.Plot = plotN;
            self:StartPlacement("Road/Normal Road");
        end);
    end
end

--[[
    Start the placement process for a structure
    @param structureId The identifier of the structure to place
]]
function PlacementController:StartPlacement(structureId: string)
    -- Get the plot the player is currently on
    if (self.PlacementClient == nil) then
        -- Get the plot the player is currently on

        if (self.Plot == nil) then
            warn("PlacementController: Plot is nil");
            return;
        end

        self.PlacementClient = PlacementClient.new(self.Plot);
    end

    self.PlacementClient:StartPlacement(structureId);
end

function PlacementController:StopPlacement()
    if (self.PlacementClient ~= nil) then
        self.PlacementClient:Destroy();
        -- Garbage collect the PlacementClient instance
        self.PlacementClient = nil;
    end
end

return PlacementController;