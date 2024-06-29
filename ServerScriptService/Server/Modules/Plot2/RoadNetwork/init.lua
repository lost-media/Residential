--!strict

--[[
{Lost Media}

-[RoadNetwork] Class
    Represents a road network for a plot in the game.

	Members:

        RoadNetwork._plot       [Plot]  -- The plot that the road network is on

    Functions:

        RoadNetwork.new(plot: Plot) -- Constructor
            Creates a new instance of the RoadNetwork class

	Methods:

        RoadNetwork:GetPlot() -> Plot
            Returns the plot that the road network is on
            
--]]

local SETTINGS = {}

----- Types -----

local RoadNetworkTypes = require(script.Types)
type IRoadNetwork = RoadNetworkTypes.IRoadNetwork
type RoadNetwork = RoadNetworkTypes.RoadNetwork

----- Private variables -----

local RoadNetwork: IRoadNetwork = {} :: IRoadNetwork
RoadNetwork.__index = RoadNetwork

----- Private functions -----

----- Public functions -----

function RoadNetwork.new(plot): RoadNetwork
	local self = setmetatable({
		_plot = plot,
	}, RoadNetwork)

	return self
end

function RoadNetwork:GetPlot()
	return self._plot
end

return RoadNetwork
