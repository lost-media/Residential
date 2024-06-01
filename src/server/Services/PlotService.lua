--!strict

local RS = game:GetService("ReplicatedStorage");

local Knit = require(RS.Packages.Knit);
local Plot = require(RS.Shared.Plot);

local PLOTS_LOCATION: Folder = workspace.Plots

local PlotService = Knit.CreateService {
    Name = "PlotService";
    Client = {};

    Plots = {};
};

function PlotService:KnitInit()
    print("PlotService initialized");

    -- Create a Plot instance for each model in the Plots folder

    for i, plotModel in ipairs(PLOTS_LOCATION:GetChildren()) do
        local success, err = pcall(function()
            local plot = Plot.new(plotModel, i);
            self.Plots[i] = plot;
        end);

        if (not success) then
            warn("PlotService: Failed to create plot: " .. err);
        end
    end

    print("PlotService: Created " .. #self.Plots .. " plots")
end

function PlotService:KnitStart()
    print("PlotService started");
end

function PlotService:AssignPlot(player: Player)
    -- type Plot
    local plot = nil;
    
    for i, v in ipairs(self.Plots) do
        if (v:getPlayer() == nil) then
            plot = v;
            break;
        end
    end

    if (plot == nil) then
        warn("No available plots");
        return;
    end

    plot:assignPlayer(player);
end

function PlotService:RemovePlayerFromPlot(player: Player)
    local plot = player:GetAttribute("Plot");

    if (not plot) then
        warn("PlotService: Player is not assigned to a plot");
        return;
    end

    if (self.Plots[plot]) then
        self.Plots[plot]:removePlayer();
    end
end



return PlotService;