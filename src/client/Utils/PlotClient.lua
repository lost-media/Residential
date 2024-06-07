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

function PlotClient.new(plot: PlotTypes.Plot)
    local self = setmetatable({}, PlotClient);

    if (PlotTypes.isPlotValid(plot) == false) then
        error("PlotClient: Invalid plot object");
    end

    self.plot = plot;

    return self;
end
