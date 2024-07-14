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

	BuildingIndicatorGuiName = "BuildingIndicatorGui",
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
local Signal = require(LMEngine.SharedDir.Signal)
type Graph = Graph.Graph

local RoadNetwork: IRoadNetwork = {} :: IRoadNetwork
RoadNetwork.__index = RoadNetwork

----- Private functions -----

----- Public functions -----

function RoadNetwork.new(plot): RoadNetwork
	local self = setmetatable({}, RoadNetwork)

	self._plot = plot
	self._graph = Graph.new()
	self._buildings = {}
	self._buildingRoadPairs = {}

	self.RoadConnected = Signal.new()
	self.BuildingConnected = Signal.new()
	self.AllBuildingsConnected = Signal.new()

	self._allBuildingsConnected = false

	return self
end

function RoadNetwork:AddRoad(road)
	-- update connectivity
	self:UpdateConnectivity()

	-- see if the new road has connected to any other

	local roadGraph = self._graph

	-- get the roads neighbors

	local node = roadGraph:GetNodeWithVal(road)

	if node == nil then
		return
	end

	-- neighbors
	local neighbors = roadGraph:GetNeighbors(node)

	if neighbors == nil then
		return
	end

	if #neighbors == 0 then
		return
	end

	-- fire event that the road has been connected to another road
	self.RoadConnected:Fire(road, neighbors)
end

function RoadNetwork:AddBuilding(structure: Model)
	table.insert(self._buildings, structure)

	-- update connectivity
	self:UpdateBuildingConnectivity()

	-- check if buildings are connected to city hall
	self:UpdateBuildingCityHallConnectivity()

	-- check if the newly placed building is connected to a road
	local road = self._buildingRoadPairs[structure]

	if road == nil then
		return
	end

	-- fire event that the building has been connected to a road
	self.BuildingConnected:Fire(structure, road)

	-- check if the building is connected to city hall
	local connectedToCityHall = self:BuildingIsConnectedToCityHall(structure)

	if connectedToCityHall == false then
		self._allBuildingsConnected = false
	end
end

function RoadNetwork:UpdateRoadConnectivity()
	-- first, update road connectivity
	local roadGraph = Graph.new()
	local roads = self:GetRoads()

	local allRoadConnections = self:GetRoadConnectionAttachments()

	for _, road in ipairs(roads) do
		local node = Graph.Node(road, road)
		roadGraph:AddNode(node)

		local primaryPart = road.PrimaryPart

		for _, roadConnection: Attachment in ipairs(allRoadConnections) do
			if roadConnection:IsA("Attachment") == false then
				continue
			end

			local structure = roadConnection:FindFirstAncestorWhichIsA("Model")

			if structure == nil then
				continue
			end

			for _, roadAttachment: Attachment in ipairs(primaryPart:GetChildren()) do
				if roadAttachment:IsA("Attachment") == false then
					continue
				end

				if CollectionService:HasTag(roadAttachment, settRoadConnectionTag) == false then
					continue
				end

				if
					roadAttachment.WorldCFrame.Position:FuzzyEq(roadConnection.WorldCFrame.Position)
				then
					local neighborRoad = structure

					if neighborRoad ~= nil then
						local neighborNode = roadGraph:GetNodeWithVal(neighborRoad)

						if neighborNode ~= nil then
							roadGraph:AddEdge(node, neighborNode)
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

		local buildingHasRoadConnection = false

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
					attachment.WorldCFrame.Position:FuzzyEq(
						roadBuildingConnection.WorldCFrame.Position
					)
				then
					local road = self._graph:GetNodeWithVal(
						roadBuildingConnection:FindFirstAncestorWhichIsA("Model")
					)

					if road ~= nil then
						buildingRoadPairs[building] = road

						buildingHasRoadConnection = true
					end
				end
			end
		end

		if buildingHasRoadConnection == false then
			-- show indicator
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
			local gui = primaryPart:FindFirstChild(SETTINGS.BuildingIndicatorGuiName)

			if gui == nil then
				gui = Instance.new("BillboardGui")
				gui.Name = SETTINGS.BuildingIndicatorGuiName
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
			local gui = primaryPart:FindFirstChild(SETTINGS.BuildingIndicatorGuiName)

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

	-- if all buildings are connected to city hall, then fire event
	local allConnected = true

	local buildings = self:GetBuildings()

	for _, building in ipairs(buildings) do
		local connectedToCityHall = self:BuildingIsConnectedToCityHall(building)

		if connectedToCityHall == false then
			allConnected = false
			self._allBuildingsConnected = false
			break
		end
	end

	if allConnected == true then
		self._allBuildingsConnected = true
		self.AllBuildingsConnected:Fire()
	end

	return allConnected
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

function RoadNetwork:GetRoadConnectionAttachments()
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

			if CollectionService:HasTag(attachment, settRoadConnectionTag) == false then
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
