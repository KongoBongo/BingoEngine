--[=[
	@class Component
	
	Stateful Components for the Bingo Engine, by KingofHolywater.
	
	Stateful Components allow for you to create variables, which hold values but when
	changed will invoke a "changed" event. This is a fundamental building block in my engine
	as I strive to make iterative processes event driven to improve code quality, performance,
	and to improve predictability.

	Stateful Components are very useful and can be used for a lot of things, especially when
	your codebase gets complicated.
	
	You can pair this with my StateMachine module to provide autonomous synchronisation.
	
	E V E N T	D R I V E N	   P R O G R A M M I N G
	
	Basic Usage:
	```lua
	local DEFAULT_HEALTH = 100

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Component = require(ReplicatedStorage:WaitForChild("Component"))
	
	local Health = Component.new(DEFAULT_HEALTH)
	
	local function onHealthChanged(old: number, new: number)
		warn(
			("Previous: %s\t Current: %s"):format(old, new)
		)
	end
	
	local function Runtime()
		Health.Changed:Connect(onHealthChanged)
		
		task.wait(10)
		Health:Destroy() -- cleanup
	end
	```
	
	API:
	Component.new(base: any) : Constructs a new stateful component.
	Component:Set(value: any): Sets the value of the component.
	Component:Get(value: any): Sets the value of the component.
	Component:Destroy()		 : Destroys the stateful component instance.

	
	And just like everything in my engine, I strive to make everything a singleton. This allows
	for people to straight up take the modules and they work without being tied to using
	my framework.
	
]=]--

local ComponentClass = {}
ComponentClass.ClassName = "Component"
ComponentClass.__index = ComponentClass

export type Component = {
	_value: any,
	Changed: () -> nil,
	Destroy: () -> nil,
}

local Signal = require(script.signal)
local Trove = require(script.trove)

function ComponentClass.new(base: any): Component
	
	--@ public
	local self = setmetatable({}, ComponentClass)
	
	self.Changed = Signal.new()
	
	--@ private
	self._value = base
	self._task = Trove.new()
	
	--@ setup
	self._task:Add(self.Changed)
	
	return self
end

function ComponentClass:Set(value: any)
	local old = self._value
	self._value = value
	
	self.Changed:Fire(old, self._value)
end

function ComponentClass:Get(): any
	return self._value
end

function ComponentClass:Destroy()
	self._task:Destroy()
	self._value = nil
end

return ComponentClass