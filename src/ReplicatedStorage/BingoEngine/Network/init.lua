-- Inspired by Bricey and Knit's Networker Module

local Network = {}

local NO_LISTENER_CONNECTED = "%s is not being listened to."
local DISABLE_LISTENER_WARNINGS = false
local SERVER_CLIENT_INVOKATION_ERROR = "Trying to invoke the client from the server, which poses security issues"

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local Promise = require(script.Promise)
local Trove = require(script.Trove)

local getData: RemoteFunction = script.remotes:WaitForChild("GetData")
local sendData: RemoteEvent = script.remotes:WaitForChild("SendData")
local getCommonData: BindableFunction = script.remotes:WaitForChild("GetCommonData")
local sendCommonData: BindableEvent = script.remotes:WaitForChild("SendCommonData")

local listeners = {}

export type Listener = {
	Scope: string,
	Callback: () -> nil,
	Disconnect: () -> nil
}

--[[

Implement a system where when you Invoke an event it'll create a unique event and invoke that instead of using cached
events. This prevents throttling (I think)
]]--

local function  serverRecieve (player: Player, scope: string, ...)
	local args = {...}

	local promise
	promise = Promise.new(function(resolve, reject)
		for _, listener in listeners do
			if (listener.Scope == scope) then
				listener._promise_task:AddPromise(promise)
				resolve(listener.Callback(player, unpack(args)))
			end
		end
		
		-- No listeners
		if (DISABLE_LISTENER_WARNINGS) then
			reject()
		end
		reject(string.format(NO_LISTENER_CONNECTED, scope))
	end);

	return promise
end

local function clientRecieve(scope: string, ...)
	local args = {...}
	local promise
	promise = Promise.new(function(resolve, reject)
		for _, listener in listeners do
			if (listener.Scope == scope) then
				listener._promise_task:AddPromise(promise)
				resolve(listener.Callback(unpack(args)))
			end
		end

		-- No listeners
		if (DISABLE_LISTENER_WARNINGS) then
			reject()
		end

		-- Add some better warnings/traceback. Use a promise!
		reject(string.format(NO_LISTENER_CONNECTED, scope))
	end);


	return promise
end

function Network.ListenTo(scope: string, func): Listener
	local listener: Listener = {
		Scope = scope,
		Callback = func,
		Disconnect = function(self)
			local index = table.find(listeners, self)
			if (index) then
				table.remove(listeners, index)
			end
			self._promise_task:Destroy()
		end,
		_promise_task = Trove.new()
	}
	
	table.insert(listeners, listener)
	return listener
end

function Network.ToServer(scope: string, ...)
	if (IsServer) then
		sendCommonData:Fire(scope, ...)
		return
	end
	
	sendData:FireServer(scope, ...)
end

function Network.ToClient(scope: string, player,  ...)
	if (IsClient) then
		sendCommonData:Fire(scope, ...)
		return
	end
	
	sendData:FireClient(player, scope, ...)
end


function Network.ToAllClients(scope: string, ...)
	sendData:FireAllClients(scope, ...)
end


function Network.ToAllClientsExcept(scope: string, player, ...)
	for _, plr in Players:GetPlayers() do
		if (plr ~= player) then
			Network.ToClient(scope, player, ...)
		end
	end
	
end

function Network.InvokeServer(scope: string, ...)
	if (IsServer) then
		return getCommonData:Invoke(scope, ...)	
	end
	
	return getData:InvokeServer(scope, ...)
end

function Network.InvokeClient(scope: string, ...)
	if (IsClient) then
		return getCommonData:Invoke(scope, ...)	
	end
	
	warn(SERVER_CLIENT_INVOKATION_ERROR)
end


--[=[ Work on Server/Client pinging. ]=]--
function Network.Ping(scope: string, player)
	if (IsClient) then
		local s = os.clock()
		Network.InvokeServer()
	end
end

if (IsServer) then
	-- Add connection handlers for the server
	sendData.OnServerEvent:Connect(function(player: Player, scope: string, ...)
		serverRecieve(player, scope, ...):catch(warn)
	end)

	getData.OnServerInvoke = function(player: Player, scope: string, ...)
		serverRecieve(player, scope, ...):catch(warn)
	end
	
	-- Bindables
	sendCommonData.Event:Connect(function(scope: string, ...)
		serverRecieve(scope, ...):catch(warn)
	end)
	getCommonData.OnInvoke = function(scope: string, ...)
		serverRecieve(scope, ...):catch(warn)
	end
	
elseif (IsClient) then
	-- Add connection handlers for the client
	sendData.OnClientEvent:Connect(function(scope: string, ...)
		clientRecieve(scope, ...)
	end)
	
	-- Bindables
	sendCommonData.Event:Connect(function(scope: string, ...)
		clientRecieve(scope, ...)
	end)
	getCommonData.OnInvoke = clientRecieve
end


return Network