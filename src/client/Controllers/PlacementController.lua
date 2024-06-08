--!strict

local RS = game:GetService("ReplicatedStorage");
local UIS = game:GetService("UserInputService");

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
    StructuresIndex = 1;
    StructuresList = {
        "Road/Streetlight",
        "Road/Normal Road",
        "Road/Elevated Normal Road",
    }
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
            self:StartPlacement("Road/Streetlight");
        end);
    end

    UIS.InputBegan:Connect(function(input: InputObject)
        if (input.UserInputType == Enum.UserInputType.MouseButton1) then
            self:StopPlacement();
        end
        if (input.KeyCode == Enum.KeyCode.E) then
            self.StructuresIndex = self.StructuresIndex + 1;
            if (self.StructuresIndex > #self.StructuresList) then
                self.StructuresIndex = 1;
            end
            self:StopPlacement();
            self:StartPlacement(self.StructuresList[self.StructuresIndex]);
        elseif (input.KeyCode == Enum.KeyCode.Q) then
            self.StructuresIndex = self.StructuresIndex - 1;
            if (self.StructuresIndex < 1) then
                self.StructuresIndex = #self.StructuresList;
            end
            self:StopPlacement();
            self:StartPlacement(self.StructuresList[self.StructuresIndex]);
        end
    end);
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