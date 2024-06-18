--!strict
--!version: 1.0.0

--[[
{Lost Media}

-[StateMachine] Module
    A simple state machine module that can be used to manage states
    in a game. This module is used to manage the state of the game
    and transition between different states.
   
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

type IStateMachine = {
	__index: IStateMachine,
	new: (States) -> IStateMachine,
	SetState: (self: StateMachine, string) -> (),
	Update: (self: StateMachine, any) -> (),
}

type StateMachineMembers = {
	states: States,
	current_state: State,
}

export type StateMachine = typeof(setmetatable({} :: StateMachineMembers, {} :: IStateMachine))

----- Private variables -----
---@class StateMachine
local StateMachine: IStateMachine = {} :: IStateMachine
StateMachine.__index = StateMachine

----- Public functions -----

function StateMachine.new(states)
	local self = setmetatable({}, StateMachine)
	self.states = states or {} -- a table that holds all states
	self.current_state = nil
	return self
end

function StateMachine:SetState(state_name: string)
	assert(self.states[state_name], "Invalid state: " .. state_name)
	self.current_state = self.states[state_name]
end

function StateMachine:Handle(event: string)
	if self.current_state and self.current_state.Transitions and self.current_state.Transitions[event] then
		self:SetState(self.current_state.Transitions[event])
	end
end

function StateMachine:Update(...)
	if self.current_state and self.current_state.Update then
		self.current_state.Update(...)
	end
end

return StateMachine
