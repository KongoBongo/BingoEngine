local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Struct = ReplicatedStorage:WaitForChild("Structures")
local ServerStruct = ServerStorage.Structures

local RemoteSpace = require(Struct:WaitForChild("RemoteSpace"))
local Engine = require(ReplicatedStorage:WaitForChild("BingoEngine"))
local Network = Engine.Network

local PlayerObject = ServerStruct.PlayerObject

local function playerAdded(player: Player)
    PlayerObject.new(player)
end

local function playerRemoving(player: Player)
	local self = PlayerObject.Get(player)
	if (self) then
		self.OptdIn = false
		self:Destroy()
	end
end

local function handle_equip(self, item: any)
    -- Deploy testEZ


	--@ param {Any} Item: Can be either a "string" or "number" which will correspond
	-- to the players item within their inventory.
	if (typeof(item) == "number") then
		item = math.floor(item)
		return self:Equip(item)
	
	elseif (typeof(item) == "string") then
		if (item == "") then
			return
		end
		
		return self:Equip(item)
	else
		warn("Item can only be of type 'string' or 'number'.")
		return
	end
end

local function handle_unequip(self)
    return self:Unequip()
end

local function Runtime()
    Players.PlayerAdded(playerAdded)
    Players.PlayerRemoving(playerRemoving)

    for _, player: Player in Players:GetPlayers() do
        task.spawn(playerAdded, player)
    end


   Network.ListenTo("Ping", function()
        return true
   end)

   Network.ListenTo(RemoteSpace.Players.Equip_Request, function(player: Player, item: any)
        local self = PlayerObject.Get(player)
        if (self) then
            return handle_equip(self, item)
        end
    end)

    Network.ListenTo(RemoteSpace.Players.Unequip_Request, function(player: Player)
        local self = PlayerObject.Get(player)
        if (self) then
            return handle_unequip(self)
        end
    end)

    Network.ListenTo(RemoteSpace.Players.OptIn, function(player: Player)
        warn(player.Name.." opt'd in!")

        local self = PlayerObject.Get(player)
        if (self) then
            self.OptdIn = true
            self:Init()
        end
    end)
end

Runtime()
