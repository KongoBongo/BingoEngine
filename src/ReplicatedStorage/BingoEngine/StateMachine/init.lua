--[[
By: @KingofHolywater (Bingus) aka KongoBongo

This module serves as an "Abstract Base Class", meaning that you should never directly
instantiate it for use but rather instantiate it for another class, i.e a state.

function StateMachine.new()

]]--

local RunService = game:GetService("RunService")

-- @abstract class
local StateMachine = {}
StateMachine.__index = StateMachine
StateMachine.ClassName = StateMachine

local Signal = require(script.Signal)
local Trove = require(script.Trove)

local Registry = {}

function StateMachine.construct(root_state)
	-- @param {Table} root_state: The state that the machine starts off with.
	-- @return {StateMachine} self: The Handler to handle the state machine
	
	assert(root_state, "Root state needs to be specified.")
	local self = setmetatable({}, StateMachine)
	
	-- @public
	self.StateChanged = Signal.new()
	
	--[[
	self.StateChanged:Connect(function(old_state: string, new_state: string)
		warn(("old %s. new %s."):format(old_state, new_state))
	end)
	
	]]--
	
	
	self.State = root_state
	self.States = {
		root_state = root_state
	}
	
	-- @private
	self._cleanup_task = Trove.new()
	self._previous_state = nil
	
	self._cleanup_task:Add(self.StateChanged)
	
	-- When we exit a state, we'd like to handle what happens
	self._exit_state = function(previous_state, new_state) end
	
	-- When we enter a new state, we'd like to handle what happens on the first frame
	self._enter_state = function(new_state, previous_state) end
	
	-- Handles when each state should transition between one another
	self._get_transition = function(delta: number) end
	
	-- Handles how each state behaves
	self._state_logic = function (delta: number) end
	
	-- @setup
	if (RunService:IsServer()) then
		self._cleanup_task:Add(RunService.Heartbeat:Connect(function(delta: number)
			self:_update(delta)
		end))
	else
		self._cleanup_task:Add(RunService.RenderStepped:Connect(function(delta: number)
			self:_update(delta)
		end))
	end
	
	return self	
end

function StateMachine.Get(player)
	return Registry[player]
end



-- @public
function StateMachine:SetState(new_state)
	self._previous_state = self.State
	self.State = new_state
	
	if (self._previous_state ~= nil) then
		self:_exit_state(self._previous_state, new_state)
	end
	
	if (new_state ~= nil) then
		self.StateChanged:Fire(new_state, self._previous_state)
		self:_enter_state(new_state, self._previous_state)
	end
end

function StateMachine:AddState(name: string)
	self.States[name] = name
end


function StateMachine:_update(delta: number)
	if (self.State == nil) then
		return
	end
	
	self:_state_logic(delta)
	local transition = self:_get_transition(delta)
	
	if (transition ~= nil and transition ~= self.State) then
		self:SetState(transition)
	end
end


return StateMachine