--!strict

local RS = game:GetService("ReplicatedStorage");

local Knit = require(RS.Packages.Knit);
local Plot = require(RS.Shared.Plot);

local PLOTS_LOCATION: Folder = workspace.Plots

local PlotService = Knit.CreateService {
    Name = "PlotService";
    Client = {
        PlotAssigned = Knit.CreateSignal();
        --PlaceStructure = Knit.CreateSignal();
    };

    Plots = {};
};

function PlotService:KnitInit()
    print("PlotService initialized");

    -- Set up event connections

    

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

    self.Client.PlotAssigned:Fire(player, plot:getInstance());
end

function PlotService:RemovePlayerFromPlot(player: Player)
    local plot = player:GetAttribute("Plot");

    if (plot == nil) then
        warn("PlotService: Player is not assigned to a plot");
        return;
    end

    if (self.Plots[plot]) then
        self.Plots[plot]:removePlayer();
    end
end

function PlotService:GetPlotFromInstance(instance: Model)
    for i, plot in ipairs(self.Plots) do
        if (plot:getInstance() == instance) then
            return plot;
        end
    end

    return nil;
end

function PlotService:GetPlotFromPlayer(player: Player)
    local plot = player:GetAttribute("Plot");

    if (plot == nil) then
        warn("PlotService: Player is not assigned to a plot");
        return nil;
    end

    return self.Plots[plot];
end

function PlotService:PlaceStructure(
    player: Player,
    structureId: string,
    state: table
)
    if (structureId == nil) then
        warn("PlotService: No structure identifier provided");
        return;
    end

    if (state == nil) then
        warn("PlotService: No state provided");
        return;
    end

    local plot = self:GetPlotFromPlayer(player);

    if (plot == nil) then
        return;
    end
    
    print(state)
    local success, err = plot:placeObject(structureId, state);

    if (err) then
        warn("PlotService: Failed to place object: ");
        return;
    end
end

function PlotService.Client:PlaceStructure(player: Player, structureId: string, state: table)
    self.Server:PlaceStructure(player, structureId, state);
end

return PlotService;