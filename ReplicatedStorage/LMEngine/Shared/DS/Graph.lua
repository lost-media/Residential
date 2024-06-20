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

type INode<K, V> = {
	__index: INode<K, V>,
	new: (id: K, val: V) -> Node<K, V>,

	GetId: (self: Node<K, V>) -> K,
	GetValue: (self: Node<K, V>) -> V,
}

type NodeMembers<K, V> = {
	_id: K,
	_value: V,
}

export type Node<K, V> = typeof(setmetatable({} :: NodeMembers<K, V>, {} :: INode<K, V>))

type IGraph<K, V> = {
	__index: IGraph<K, V>,
	new: () -> Graph<K, V>,
    Node: (id: K, val: V) -> Node<K, V>,

	AddNode: (self: Graph<K, V>, node: Node<K, V>) -> (),
	RemoveNode: (self: Graph<K, V>, node: Node<K, V>) -> (),
	AddEdge: (self: Graph<K, V>, node1: Node<K, V>, node2: Node<K, V>) -> (),
	RemoveEdge: (self: Graph<K, V>, node1: Node<K, V>, node2: Node<K, V>) -> (),
	GetNeighbors: (self: Graph<K, V>, node: Node<K, V>) -> { Node<K, V> }?,
	GetNodes: (self: Graph<K, V>) -> { Node<K, V> },
	HasNode: (self: Graph<K, V>, node: Node<K, V>) -> boolean,
	HasEdge: (self: Graph<K, V>, node1: Node<K, V>, node2: Node<K, V>) -> boolean,
	Clear: (self: Graph<K, V>) -> (),
	Size: (self: Graph<K, V>) -> number,
    GetRandomNode: (self: Graph<K, V>) -> Node<K, V>?,
}

type GraphMembers<K, V> = {
	_nodes: { [K]: Node<K, V> },
}

export type Graph<K, V> = typeof(
    setmetatable({} :: GraphMembers<K, V>,
    {} :: IGraph<K, V>)
)

----- Private variables -----

---@generic K, V
---@class Node
local Node = {}
Node.__index = Node

---@generic K, V
---@class Graph
local Graph = {};
Graph.__index = Graph

----- Private functions -----

----- Public functions -----

function Node.new<K, V>(id: K, val: V): Node<K, V>
	local self = setmetatable({
		_id = id,
		_value = val,
	}, Node);
	return self;
end

function Node:GetId()
	return self._id;
end

function Node:GetValue()
	return self._value;
end

function Graph.new<K, V>(): Graph<K, V>
	local self = setmetatable({
		_nodes = {},
	}, Graph)
	return self;
end

function Graph.Node<K, V>(id: K, val: V): Node<K, V>
    return Node.new(id, val)
end

function Graph:AddNode<K, V>(node: Node<K, V>)
	self._nodes[node:GetId()] = node
end

function Graph:RemoveNode<K, V>(node: Node<K, V>)
	self._nodes[node:GetId()] = nil
end

function Graph:AddEdge<K, V>(node1: Node<K, V>, node2: Node<K, V>)
	local id1 = node1:GetId()
	local id2 = node2:GetId()

	if self._nodes[id1] == nil or self._nodes[id2] == nil then
		return
	end

	self._nodes[id1][id2] = true
	self._nodes[id2][id1] = true
end

function Graph:RemoveEdge<K, V>(node1: Node<K, V>, node2: Node<K, V>)
	local id1 = node1:GetId()
	local id2 = node2:GetId()

	if self._nodes[id1] == nil or self._nodes[id2] == nil then
		return
	end

	self._nodes[id1][id2] = nil
	self._nodes[id2][id1] = nil
end

function Graph:GetNeighbors<K, V>(node: Node<K, V>): { Node<K, V> }?
	local id = node:GetId()
	local neighbors = {}

	for neighbor_id, _ in pairs(self._nodes[id]) do
		table.insert(neighbors, self._nodes[neighbor_id])
	end

	return neighbors
end

function Graph:GetNodes<K, V>(): { Node<K, V> }
	local nodes = {}

	for _, node in pairs(self._nodes) do
		table.insert(nodes, node)
	end

	return nodes
end

function Graph:HasNode<K, V>(node: Node<K, V>): boolean
	return self._nodes[node:GetId()] ~= nil
end

function Graph:HasEdge<K, V>(node1: Node<K, V>, node2: Node<K, V>): boolean
	local id1 = node1:GetId()
	local id2 = node2:GetId()

	return self._nodes[id1][id2] ~= nil
end

function Graph:Clear<K, V>()
	self._nodes = {}
end

function Graph:Size<K, V>(): number
	local count = 0;

    for _, _ in self._nodes do
        count += 1;
    end

    return count;
end

function Graph:GetRandomNode<K, V>(): Node<K, V>?
    local nodes = self:GetNodes()

    if #nodes == 0 then
        return nil
    end

    return nodes[math.random(1, #nodes)]
end

return Graph
