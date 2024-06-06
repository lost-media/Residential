--!strict

local RS = game:GetService("ReplicatedStorage");
local PlotTypes = require(RS.Shared.Types.Plot);

type IPlotClient = {
    __index: IPlotClient,
    new: (plot: PlotTypes.Plot) -> PlotClient,

    
}

export type PlotClient = typeof(setmetatable({} :: {
    plot: PlotTypes.Plot
}, {} :: IPlotClient))

local PlotClient: IPlotClient = {} :: IPlotClient;
PlotClient.__index = PlotClient;

local function plotIsValid(plot: PlotTypes.Plot): boolean
    return (plot.Tiles and plot.Structures and plot.Debris);
end

function PlotClient.new(plot: PlotTypes.Plot)
    local self = setmetatable({}, PlotClient);

    if (plotIsValid(plot) == false) then
        error("PlotClient: Invalid plot object");
    end

    self.plot = plot;

    return self;
end
