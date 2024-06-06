--!strict

local RS = game:GetService("ReplicatedStorage");

local Knit = require(RS.Packages.Knit);

local PlotController = Knit.CreateController {
    Name = "PlotController";
    Plot = nil;
};

function PlotController:KnitInit()
    print("PlotController initialized");

    
end

function PlotController:KnitStart()
    print("PlotController started");
    
    local PlotService = Knit.GetService("PlotService");

    PlotService.PlotAssigned:Connect(function(plot)
        print("PlotController: Plot assigned");
        PlotController.Plot = plot;
    end)
end

function PlotController:GetPlot()
    return self.Plot;
end

return PlotController;