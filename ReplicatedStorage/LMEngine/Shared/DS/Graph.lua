--!strict

--[[
{Lost Media}

-[Graph] Data Structure
    Represents a graph data structure that can be used to represent
    a network of nodes and edges. The graph can be used to represent
    relationships between objects in the game.

	Members:

        Graph._nodes   [table] -- Node -> Node
            Stores the mapping of nodes to nodes

    Functions:

        Graph.new  [Graph] -- Constructor
            Creates a new instance of the Graph class

	Methods:

        Graph:AddNode(node: Node) [void]
            Adds a node to the graph

        Graph:RemoveNode(node: Node) [void]
            Removes a node from the graph

        Graph:AddEdge(node1: Node, node2: Node) [void]
            Adds an edge between two nodes

        Graph:RemoveEdge(node1: Node, node2: Node) [void]
            Removes an edge between two nodes

        Graph:GetNeighbors(node: Node) {Node[]}?
            Returns the neighbors of a node

		Graph:GetNode(key: any) Node?
			Returns the node with the given key

		Graph:GetNodeWithVal(val: any) Node?
			Returns the node with the given value
			This should ONLY be used for unique values, otherwise
			it will return the first node with the value

		Graph:GetRandomNode() Node?
			Returns a random node from the graph

        Graph:GetNodes() {Node[]}
            Returns the nodes in the graph

        Graph:HasNode(node: Node) boolean
            Returns true if the graph contains the node

        Graph:HasEdge(node1: Node, node2: Node) boolean
            Returns true if the graph contains an edge between the two nodes

        Graph:Clear() [void]
            Clears the graph

        Graph:Size() number
            Returns the number of nodes in the graph

--]]

local SETTINGS = {}

----- Types -----

type INode = {
	__index: INode,
	new: (id: any, val: any) -> Node,

	GetId: (self: Node) -> any,
	GetValue: (self: Node) -> any,
}

type NodeMembers = {
	_id: any,
	_value: any,
}

export type Node = typeof(setmetatable({} :: NodeMembers, {} :: INode))

type IGraph = {
	__index: IGraph,
	new: () -> Graph,
	Node: (id: any, val: any) -> Node,

	AddNode: (self: Graph, node: Node) -> (),
	RemoveNode: (self: Graph, node: Node) -> (),
	AddEdge: (self: Graph, node1: Node, node2: Node) -> (),
	RemoveEdge: (self: Graph, node1: Node, node2: Node) -> (),
	GetNode: (self: Graph, key: any) -> Node?,
	GetNodeWithVal: (self: Graph, val: any) -> Node?,
	GetNeighbors: (self: Graph, node: Node) -> { Node }?,
	GetNodes: (self: Graph) -> { Node },
	HasNode: (self: Graph, node: Node) -> boolean,
	HasEdge: (self: Graph, node1: Node, node2: Node) -> boolean,
	Clear: (self: Graph) -> (),
	Size: (self: Graph) -> number,
	GetRandomNode: (self: Graph) -> Node?,
}

type GraphMembers = {
	_nodes: { [any]: Node },
}

export type Graph = typeof(setmetatable({} :: GraphMembers, {} :: IGraph))

----- Private variables -----

---@generic K, V
---@class Node
local Node = {}
Node.__index = Node

---@generic K, V
---@class Graph
local Graph = {}
Graph.__index = Graph

----- Private functions -----

----- Public functions -----

function Node.new(id: any, val: any): Node
	local self = setmetatable({
		_id = id,
		_value = val,
	}, Node)
	return self
end

function Node:GetId()
	return self._id
end

function Node:GetValue()
	return self._value
end

function Graph.new(): Graph
	local self = setmetatable({
		_nodes = {},
	}, Graph)
	return self
end

function Graph.Node(id: any, val: any): Node
	return Node.new(id, val)
end

function Graph:AddNode(node: Node)
	self._nodes[node:GetId()] = node
end

function Graph:RemoveNode(node: Node)
	self._nodes[node:GetId()] = nil
end

function Graph:AddEdge(node1: Node, node2: Node)
	local id1 = node1:GetId()
	local id2 = node2:GetId()

	if self._nodes[id1] :: any == nil or self._nodes[id2] :: any == nil then
		return
	end

	self._nodes[id1][id2] = true
	self._nodes[id2][id1] = true
end

function Graph:RemoveEdge(node1: Node, node2: Node)
	local id1 = node1:GetId()
	local id2 = node2:GetId()

	if self._nodes[id1] :: any == nil or self._nodes[id2] :: any == nil then
		return
	end

	self._nodes[id1][id2] = nil
	self._nodes[id2][id1] = nil
end

function Graph:GetNode(key: any): Node?
	return self._nodes[key]
end

function Graph:GetNodeWithVal(val: any): Node?
	for _, node in pairs(self._nodes) do
		if node:GetValue() == val then
			return node
		end
	end

	return nil
end

function Graph:GetNeighbors(node: Node): { Node }?
	local id = node:GetId()
	local neighbors = {}

	for neighbor_id, _ in pairs(self._nodes[id]) do
		table.insert(neighbors, self._nodes[neighbor_id])
	end

	return neighbors
end

function Graph:GetNodes(): { Node }
	local nodes = {}

	for _, node in pairs(self._nodes) do
		table.insert(nodes, node)
	end

	return nodes
end

function Graph:HasNode(node: Node): boolean
	local id = node:GetId()

	return self._nodes[id] :: any ~= nil
end

function Graph:HasEdge(node1: Node, node2: Node): boolean
	local id1 = node1:GetId()
	local id2 = node2:GetId()

	return self._nodes[id1][id2] ~= nil
end

function Graph:Clear()
	self._nodes = {}
end

function Graph:Size(): number
	local count = 0

	for _, _ in self._nodes do
		count += 1
	end

	return count
end

function Graph:GetRandomNode(): Node?
	local nodes = self:GetNodes()

	if #nodes == 0 then
		return nil
	end

	return nodes[math.random(1, #nodes)]
end

return Graph
