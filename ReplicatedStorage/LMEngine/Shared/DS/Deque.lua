--!strict

--[[
	*{LM Engine} -[Deque]- v1.0.0 -----------------------------------
	Represents a double-ended queue data structure for FIFO and LIFO operations.

	Author: Pierre 'catwell' Chapuis, brandon-kong (ijmod)
	Last Modified: 2024-07-01

	Dependencies:
		- None

	Usage:
		local deque = Deque.new()
		deque:PushRight(value)
		deque:PushLeft(value)
		local rightValue = deque:PeekRight()
		local leftValue = deque:PeekLeft()

	Functions:
		- Deque.new(): Deque (Creates a new instance of the Deque class)

	Members [Deque]:
		- head: number (The index of the head of the deque)
		- tail: number (The index of the tail of the deque)

	Methods [Deque]:
		- PushRight(x: any): void (Adds an element to the right end of the deque)
		- PushLeft(x: any): void (Adds an element to the left end of the deque)
		- PeekRight(): any? (Returns the element at the right end of the deque)
		- PeekLeft(): any? (Returns the element at the left end of the deque)
		- PopRight(): any? (Removes and returns the element at the right end of the deque)
		- PopLeft(): any? (Removes and returns the element at the left end of the deque)
		- RotateRight(n: number): void (Rotates the deque to the right by n elements)
		- RotateLeft(n: number): void (Rotates the deque to the left by n elements)
		- RemoveRight(x: any): boolean (Removes the first occurrence of x from the right end of the deque)
		- RemoveLeft(x: any): boolean (Removes the first occurrence of x from the left end of the deque)
		- Length(): number (Returns the number of elements in the deque)
		- IsEmpty(): boolean (Returns true if the deque is empty)
		- Contents(): {any} (Returns the elements in the deque)

	Changelog:
		v1.0.0 - Initial implementation
--]]

----- Types -----

type IDeque = {
	__index: IDeque,

	new: () -> Deque,
	PushRight: (self: Deque, x: any) -> (),
	PushLeft: (self: Deque, x: any) -> (),
	PeekRight: (self: Deque) -> any?,
	PeekLeft: (self: Deque) -> any?,
	PopRight: (self: Deque) -> any?,
	PopLeft: (self: Deque) -> any?,
	RotateRight: (self: Deque, n: number) -> (),
	RotateLeft: (self: Deque, n: number) -> (),
	RemoveRight: (self: Deque, x: any) -> boolean,
	RemoveLeft: (self: Deque, x: any) -> boolean,
	IterRight: (self: Deque) -> () -> any?,
	IterLeft: (self: Deque) -> () -> any?,
	Length: (self: Deque) -> number,
	IsEmpty: (self: Deque) -> boolean,
	Contents: (self: Deque) -> { any },

	_RemoveAtInternal: (self: Deque, i: number) -> (),
}

type DequeMembers = {
	_head: number,
	_tail: number,
}

export type Deque = typeof(setmetatable({} :: DequeMembers, {} :: IDeque))

----- Private variables -----

---@class Deque
local Deque: IDeque = {} :: IDeque
Deque.__index = Deque

----- Public functions -----

function Deque.new()
	local self = setmetatable({}, Deque)
	self._head = 0
	self._tail = 0
	return self
end

function Deque:PushRight(x: any)
	assert(x ~= nil)
	self._tail = self._tail + 1
	self[self._tail] = x
end

function Deque:PushLeft(x: any)
	assert(x ~= nil)
	self[self._head] = x
	self._head = self._head - 1
end

function Deque:PeekRight(): any?
	return self[self._tail]
end

function Deque:PeekLeft(): any?
	return self[self._head + 1]
end

function Deque:PopRight(): any?
	if self:IsEmpty() then
		return nil
	end

	local r = self[self._tail]
	self[self._tail] = nil
	self._tail = self._tail - 1
	return r
end

function Deque:PopLeft(): any?
	if self:IsEmpty() then
		return nil
	end

	local r = self[self._head + 1]
	self._head = self._head + 1
	r = self[self._head]
	self[self._head] = nil
	return r
end

function Deque:RotateRight(n: number)
	n = n or 1
	if self:IsEmpty() then
		return nil
	end

	for i = 1, n do
		self:PushLeft(self:PopRight())
	end
end

function Deque:RotateLeft(n: number)
	n = n or 1
	if self:IsEmpty() then
		return nil
	end

	for i = 1, n do
		self:PushRight(self:PopLeft())
	end
end

function Deque:RemoveRight(x: any): boolean
	for i = self._tail, self._head + 1, -1 do
		if self[i] == x then
			self:_RemoveAtInternal(i)
			return true
		end
	end

	return false
end

function Deque:RemoveLeft(x: any): boolean
	for i = self._head + 1, self._tail do
		if self[i] == x then
			self:_RemoveAtInternal(i)
			return true
		end
	end

	return false
end

function Deque:Length(): number
	return self._tail - self._head
end

function Deque:IsEmpty(): boolean
	return self:Length() == 0
end

function Deque:Contents(): { any }
	local r = {}
	for i = self._head + 1, self._tail do
		r[i - self._head] = self[i]
	end

	return r
end

function Deque:_RemoveAtInternal(i: number)
	for j = i, self._tail do
		self[j] = self[j + 1]
	end

	self._tail = self._tail - 1
end

return Deque
