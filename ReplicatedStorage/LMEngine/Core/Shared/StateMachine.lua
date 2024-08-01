--!strict

--[[
*{LM Engine} -[StateMachine]- v1.0.0 -----------------------------------
A simple state machine implementation.

Author: brandon-kong (ijmod)
Last Modified: 2024-07-01

Dependencies:
	- None

Usage:
	local stateMachine = StateMachine.new(states)
	stateMachine:SetState("state_name")
	stateMachine:Update()

Functions:
	- StateMachine.new(states: States): StateMachine (Creates a new state machine)

Members [StateMachine]:
	- _states: States (A table that holds all states)
	- current_state: State? (The current state)

Methods [StateMachine]:
	- SetState(state_name: string): void (Sets the current state)
	- Handle(event: string): void (Handles an event)

Changelog:
	v1.0.0 - Initial implementation
--]]

type State = {
	Update: (any) -> (),
	Transitions: {
		[string]: string,
	},
}

type States = {
	[string]: State,
}

type StateMachineMembers = {
	_states: States,
	current_state: State?,
}

----- Private variables -----

---@class StateMachine
local StateMachine = {}
StateMachine.__index = StateMachine

export type StateMachine = typeof(setmetatable({} :: StateMachineMembers, StateMachine))

----- Public functions -----

function StateMachine.new(states): StateMachine
	local self = setmetatable({}, StateMachine)
	self._states = states or {} -- a table that holds all states
	self.current_state = nil
	return self
end

function StateMachine:SetState(state_name: string)
	assert(self._states[state_name], "Invalid state: " .. state_name)
	self.current_state = self._states[state_name]
end

function StateMachine:Handle(event: string)
	if
		self.current_state
		and self.current_state.Transitions
		and self.current_state.Transitions[event]
	then
		self:SetState(self.current_state.Transitions[event])
	end
end

function StateMachine:Update(...)
	if self.current_state and self.current_state.Update then
		self.current_state.Update(...)
	end
end

return StateMachine
