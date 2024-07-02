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

local SETTINGS = {
	Neigbors = {
		Vector3.new(0, 0, 8),
		Vector3.new(0, 0, -8),
		Vector3.new(8, 0, 0),
		Vector3.new(-8, 0, 0),
	},
}

----- Types -----

local RoadNetworkTypes = require(script.Types)
type IRoadNetwork = RoadNetworkTypes.IRoadNetwork
type RoadNetwork = RoadNetworkTypes.RoadNetwork

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LMEngine = require(ReplicatedStorage.LMEngine.Client)

local Graph = require(LMEngine.SharedDir.DS.Graph)
type Graph = Graph.Graph

local RoadNetwork: IRoadNetwork = {} :: IRoadNetwork
RoadNetwork.__index = RoadNetwork

----- Private functions -----

local function GetAdjacentPositions(position: Vector3): { Vector3 }
	local neighbors = SETTINGS.Neigbors
	local adjacentPositions = {}

	for _, neighbor in ipairs(neighbors) do
		table.insert(adjacentPositions, position + neighbor)
	end

	return adjacentPositions
end

----- Public functions -----

function RoadNetwork.new(plot): RoadNetwork
	local self = setmetatable({}, RoadNetwork)

	self._plot = plot
	self._graph = Graph.new()

	return self
end

function RoadNetwork:AddRoad(road)
	local node = Graph.Node(road, road);

	(self._graph :: Graph):AddNode(node)

	local adjacentPositions = GetAdjacentPositions(road.PrimaryPart.Position)

	for _, neighbor_position in ipairs(adjacentPositions) do
		local primaryPart = road.PrimaryPart
		local neighbor_road = self._plot:GetStructureAtPosition(neighbor_position)

		local foundRoad = (self._graph :: Graph):GetNodeWithVal(neighbor_road)

		if foundRoad ~= nil then
			-- check if any attachments line up
			local neighborPrimaryPart = neighbor_road.PrimaryPart
			local neighborAttachments = neighborPrimaryPart:GetChildren()
			local roadAttachments = primaryPart:GetChildren()

			local matchFound = false

			for _, neighborAttachment: Attachment in ipairs(neighborAttachments) do
				if matchFound == true then
					break
				end

				if neighborAttachment:IsA("Attachment") == false then
					continue
				end

				if neighborAttachment.Name ~= "RoadConnection" then
					continue
				end

				for _, roadAttachment: Attachment in ipairs(roadAttachments) do
					if roadAttachment:IsA("Attachment") == false then
						continue
					end

					if roadAttachment.Name ~= "RoadConnection" then
						continue
					end

					if
						neighborAttachment.WorldCFrame.Position
						== roadAttachment.WorldCFrame.Position
					then
						(self._graph :: Graph):AddEdge(node, foundRoad)
						matchFound = true
						break
					end
				end
			end
		end
	end

	print(self._graph:GetNumComponents())
end

function RoadNetwork:GetPlot()
	return self._plot
end

function RoadNetwork:GetRoads()
	local plot = self:GetPlot()
	local roads = plot:GetRoads()

	return roads
end

return RoadNetwork
