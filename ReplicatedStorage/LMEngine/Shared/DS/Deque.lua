--!strict

--[[
{Lost Media}

--- Deque implementation by Pierre 'catwell' Chapuis
--- MIT licensed

-[Deque] Data Structure
    Represents a double-ended queue data structure that can be used to store
    elements in a first-in-first-out order. The deque can be used to store
    elements that need to be accessed from both ends.

	Members:

        Deque.head   [number] -- The head of the deque
            The index of the head of the deque

        Deque.tail   [number] -- The tail of the deque
            The index of the tail of the deque

    Functions:

        Deque.new  [Deque] -- Constructor
            Creates a new instance of the Deque class

	Methods:

        Deque:PushRight(x: any) [void]
            Adds an element to the right end of the deque

        Deque:PushLeft(x: any) [void]
            Adds an element to the left end of the deque

        Deque:PeekRight() any?
            Returns the element at the right end of the deque

        Deque:PeekLeft() any?
            Returns the element at the left end of the deque

        Deque:PopRight() any?
            Removes and returns the element at the right end of the deque

        Deque:PopLeft() any?
            Removes and returns the element at the left end of the deque

        Deque:RotateRight(n: number) [void]
            Rotates the deque to the right by n elements

        Deque:RotateLeft(n: number) [void]
            Rotates the deque to the left by n elements

        Deque:RemoveRight(x: any) boolean
            Removes the first occurrence of x from the right end of the deque

        Deque:RemoveLeft(x: any) boolean
            Removes the first occurrence of x from the left end of the deque

        Deque:Length() number
            Returns the number of elements in the deque

        Deque:IsEmpty() boolean
            Returns true if the deque is empty

        Deque:Contents() {any}
            Returns the elements in the deque

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
	head: number,
	tail: number,
}

export type Deque = typeof(setmetatable({} :: DequeMembers, {} :: IDeque))

----- Private variables -----

---@class Deque
local Deque: IDeque = {} :: IDeque
Deque.__index = Deque

----- Public functions -----

function Deque.new()
	local self = setmetatable({}, Deque)
	self.head = 0
	self.tail = 0
	return self
end

function Deque:PushRight(x: any)
	assert(x ~= nil)
	self.tail = self.tail + 1
	self[self.tail] = x
end

function Deque:PushLeft(x: any)
	assert(x ~= nil)
	self[self.head] = x
	self.head = self.head - 1
end

function Deque:PeekRight(): any?
	return self[self.tail]
end

function Deque:PeekLeft(): any?
	return self[self.head + 1]
end

function Deque:PopRight(): any?
	if self:IsEmpty() then
		return nil
	end

	local r = self[self.tail]
	self[self.tail] = nil
	self.tail = self.tail - 1
	return r
end

function Deque:PopLeft(): any?
	if self:IsEmpty() then
		return nil
	end

	local r = self[self.head + 1]
	self.head = self.head + 1
	local r = self[self.head]
	self[self.head] = nil
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
	for i = self.tail, self.head + 1, -1 do
		if self[i] == x then
			self:_RemoveAtInternal(i)
			return true
		end
	end

	return false
end

function Deque:RemoveLeft(x: any): boolean
	for i = self.head + 1, self.tail do
		if self[i] == x then
			self:_RemoveAtInternal(i)
			return true
		end
	end

	return false
end

function Deque:Length(): number
	return self.tail - self.head
end

function Deque:IsEmpty(): boolean
	return self:Length() == 0
end

function Deque:Contents(): { any }
	local r = {}
	for i = self.head + 1, self.tail do
		r[i - self.head] = self[i]
	end

	return r
end

function Deque:_RemoveAtInternal(i: number)
	for j = i, self.tail do
		self[j] = self[j + 1]
	end

	self.tail = self.tail - 1
end

return Deque
