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

	RoadConnectionTag = "RoadConnection",
	BuildingConnectionTag = "BuildingConnection",

	NotConnectedToCityHallBillboardGuiName = "NotConnectedToCityHall",
}

----- Types -----

local RoadNetworkTypes = require(script.Types)
type IRoadNetwork = RoadNetworkTypes.IRoadNetwork
type RoadNetwork = RoadNetworkTypes.RoadNetwork

----- Private variables -----

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local settRoadConnectionTag = SETTINGS.RoadConnectionTag
local settBuildingConnectionTag = SETTINGS.BuildingConnectionTag

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
	self._buildings = {}
	self._buildingRoadPairs = {}

	return self
end

function RoadNetwork:AddRoad(road)
	-- update connectivity
	self:UpdateConnectivity()
end

function RoadNetwork:AddBuilding(structure: Model)
	table.insert(self._buildings, structure)

	-- update connectivity
	self:UpdateBuildingConnectivity()

	-- check if buildings are connected to city hall
	self:UpdateBuildingCityHallConnectivity()
end

function RoadNetwork:UpdateRoadConnectivity()
	-- first, update road connectivity
	local roadGraph = Graph.new()
	local roads = self:GetRoads()

	for _, road in ipairs(roads) do
		local node = Graph.Node(road, road)
		roadGraph:AddNode(node)

		local adjacentPositions = GetAdjacentPositions(road.PrimaryPart.Position)

		for _, neighbor_position in ipairs(adjacentPositions) do
			local primaryPart = road.PrimaryPart
			local neighbor_road = self._plot:GetStructureAtPosition(neighbor_position)

			local foundRoad = roadGraph:GetNodeWithVal(neighbor_road)

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

					if
						CollectionService:HasTag(neighborAttachment, settRoadConnectionTag) == false
					then
						continue
					end

					for _, roadAttachment: Attachment in ipairs(roadAttachments) do
						if roadAttachment:IsA("Attachment") == false then
							continue
						end

						if
							CollectionService:HasTag(roadAttachment, settRoadConnectionTag) == false
						then
							continue
						end

						if
							neighborAttachment.WorldCFrame.Position
							== roadAttachment.WorldCFrame.Position
						then
							roadGraph:AddEdge(node, foundRoad)
							matchFound = true
							break
						end
					end
				end
			end
		end
	end

	self._graph = roadGraph
end

function RoadNetwork:UpdateBuildingConnectivity()
	local buildingRoadPairs = {}

	local buildings = self:GetBuildings()

	for _, building in ipairs(buildings) do
		local primaryPart = building.PrimaryPart
		local attachments = primaryPart:GetChildren()

		for _, attachment: Attachment in ipairs(attachments) do
			if attachment:IsA("Attachment") == false then
				continue
			end

			if CollectionService:HasTag(attachment, settBuildingConnectionTag) == false then
				continue
			end

			local roadBuildingConnections = self:GetRoadBuildingConnectionAttachments()

			for _, roadBuildingConnection: Attachment in ipairs(roadBuildingConnections) do
				if
					attachment.WorldCFrame.Position
					== roadBuildingConnection.WorldCFrame.Position
				then
					local road = self._graph:GetNodeWithVal(
						roadBuildingConnection:FindFirstAncestorWhichIsA("Model")
					)

					if road ~= nil then
						buildingRoadPairs[building] = road

						print("Building connected to road")
					end
				end
			end
		end
	end

	self._buildingRoadPairs = buildingRoadPairs
end

function RoadNetwork:UpdateBuildingCityHallConnectivity()
	-- check if buildings are connected to city hall
	local buildings = self:GetBuildings()

	for _, building in ipairs(buildings) do
		local connectedToCityHall = self:BuildingIsConnectedToCityHall(building)

		if connectedToCityHall == false then
			local primaryPart = building.PrimaryPart
			local gui = primaryPart:FindFirstChild(SETTINGS.NotConnectedToCityHallBillboardGuiName)

			if gui == nil then
				gui = Instance.new("BillboardGui")
				gui.Name = SETTINGS.NotConnectedToCityHallBillboardGuiName
				gui.Size = UDim2.new(1, 0, 1, 0)
				gui.StudsOffset = Vector3.new(0, 5, 0)
				gui.AlwaysOnTop = true
				gui.Parent = primaryPart

				local textLabel = Instance.new("TextLabel")
				textLabel.Size = UDim2.new(1, 0, 1, 0)
				textLabel.Text = "Not connected to City Hall"
				textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
				textLabel.Parent = gui
			end
		else
			local primaryPart = building.PrimaryPart
			local gui = primaryPart:FindFirstChild(SETTINGS.NotConnectedToCityHallBillboardGuiName)

			if gui ~= nil then
				gui:Destroy()
			end
		end
	end
end

function RoadNetwork:UpdateConnectivity()
	self:UpdateRoadConnectivity()
	self:UpdateBuildingConnectivity()

	-- check if buildings are connected to city hall
	self:UpdateBuildingCityHallConnectivity()
end

function RoadNetwork:BuildingsAreConnected(building1: Model, building2: Model): boolean
	local road1 = self._buildingRoadPairs[building1]
	local road2 = self._buildingRoadPairs[building2]

	if road1 == nil or road2 == nil then
		return false
	end

	return self._graph:IsConnected(road1, road2)
end

function RoadNetwork:BuildingIsConnectedToCityHall(building: Model): boolean
	local cityHall = self._plot:GetCityHall()

	if cityHall == nil then
		return false
	end

	if building == cityHall then
		return true
	end

	local road = self._buildingRoadPairs[building]

	if road == nil then
		return false
	end

	return self:BuildingsAreConnected(building, cityHall)
end

function RoadNetwork:GetRoadBuildingConnectionAttachments()
	local roadBuildingConnections = {}

	-- get all roads
	local roads = self:GetRoads()

	for _, road in ipairs(roads) do
		local primaryPart = road.PrimaryPart
		local attachments = primaryPart:GetChildren()

		for _, attachment: Attachment in ipairs(attachments) do
			if attachment:IsA("Attachment") == false then
				continue
			end

			if CollectionService:HasTag(attachment, settBuildingConnectionTag) == false then
				continue
			end

			table.insert(roadBuildingConnections, attachment)
		end
	end

	return roadBuildingConnections
end

function RoadNetwork:GetPlot()
	return self._plot
end

function RoadNetwork:GetRoads()
	local plot = self:GetPlot()
	local roads = plot:GetRoads()

	return roads
end

function RoadNetwork:GetBuildings()
	return self:GetPlot():GetBuildings()
end

return RoadNetwork
