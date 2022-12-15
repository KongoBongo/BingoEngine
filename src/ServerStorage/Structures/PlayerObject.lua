local PlayerObject = {}
PlayerObject.__index = PlayerObject
PlayerObject.ClassName = "PlayerObject"

local PLAYER_EXISTS = "%s already exists, returning existing object."

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Structures = ReplicatedStorage:WaitForChild("Structures")
local Items = ReplicatedStorage:WaitForChild("Items")

local RemoteSpace = require(Structures:WaitForChild("RemoteSpace"))
local Engine = require(ReplicatedStorage:WaitForChild("BingoEngine"))
local Network = Engine.Network

local Signal = Engine.Utils.Signal
local Trove = Engine.Utils.Trove

local Register = {}

local function playerAdded(player: Player)
	if (Register[player]) then
		return
	end
	
	PlayerObject.new(player)
end

local function playerRemoving(player: Player)
	local self = PlayerObject.Get(player)
	if (self) then
		self.OptdIn = false
		self:Destroy()
	end
end

function PlayerObject:_handle_equip(item: any)
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

function PlayerObject.new(player: Player)
	if (Register[player]) then
		warn(PLAYER_EXISTS:format(player.Name))
		return Register[player]
	end
	--@ public
	local self = setmetatable({}, PlayerObject)
	self.Player = player
	self.Equipped = ""
	self.Hotbar = {}

	self.OptdIn = false
	
	self.MAX_HOTBAR_SPACE = 5
	
	self.OnEquipped = Signal.new()
	self.OnUnequipped = Signal.new()
	
	self.HasDeployed = false
	self.CanDeploy = false
	self.IsDead = false
	
	--@ private
	self._task = Trove.new()
	
	
	--@ setup
	self._task:Add(self.OnEquipped)
	self._task:Add(self.OnUnequipped)

	Register[player] = self
	
	return self
end

function PlayerObject:_characterAdded(player: Player)
    local character = player.Character

	self.IsDead = false
	warn("Alive")
end

function PlayerObject:Init()
	if (self.OptdIn == false) then
		return
	end

	local player: Player = self.Player
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	self._task:Add(humanoid.Died:Connect(function()
		self.IsDead = true
		warn("Dead")
	end))

	self:_characterAdded(player)

	self._task:Add(player.CharacterAdded:Connect(function()
		self:_characterAdded(player)
	end))
end

function PlayerObject.Get(player)
	return Register[player]	
end


function PlayerObject:AddItem(name: string)
	-- Block the ability to AddItems when dead or not deployed.
	if (self.IsDead == true) then
		return
	end
	
	-- Check if there's any space
	if (#self.Hotbar >= self.MAX_HOTBAR_SPACE) then
		warn("no more space")
		return
	end
	
	-- Check if the item exists
	local item_folder = Items:FindFirstChild(name)
	if (item_folder == nil) then
		warn("item folder doesn't exist")
		return
	end
	
	-- Check if the item is already in our inventory
	if (table.find(self.Hotbar, name)) then
		warn(name.." already exists.")
		return
	end
	
	-- Add Item
	warn("Added "..name)
	table.insert(self.Hotbar, name)
end

function PlayerObject:RemoveItem()
	
end

function PlayerObject:Equip(query: any)
	-- Block the ability to equip when dead or not deployed.
	if (self.IsDead == true) then
		return
	end
	
	local item
	
	if (typeof(query) == "number") then
		if (query ~= query) then
			warn("item is nan")
			return
		end

		if (query > #self.Hotbar) then
			if (self.Equipped) then
				warn("unequipping")
				self:Unequip()
			end
			
			return
		end

		if (query <= 0) then
			warn("index is less than or equal to 0")
			return
		end
		
		item = self.Hotbar[query]
	else
		item = self.Hotbar[table.find(self.Hotbar, query)]
	end
	
	if (item == nil) then
		warn("could not find item")
		return
	end
	
	-- If we have something equipped then we unequip it then equip it
	if (self.Equipped == item) then
		warn("cannot equip the same item twice")
		return
	end
	
	if (self.Equipped ~= "") then
		self:Unequip()
	end
	
	-- Find the item and check if it exists
	if (table.find(self.Hotbar, item) == nil) then
		print("item no exist in inventoryoyoyoyy")
		return
	end
	
	warn(item.."!")
	self.Equipped = item
	
	self.OnEquipped:Fire(self.Equipped)
	
	return self.Equipped
end

function PlayerObject:Unequip()
	self.Equipped = ""
	
	self.OnUnequipped:Fire(self.Equipped)
end

function PlayerObject:Destroy()
	self._task:Destroy()
end


function Runtime()
	Players.PlayerAdded:Connect(playerAdded)
	Players.PlayerRemoving:Connect(playerRemoving)
	
	for _, player: Player in Players:GetPlayers() do
		task.spawn(playerAdded, player)
	end

	Network.ListenTo(RemoteSpace.Players.Equip_Request, function(player: Player, item: any)
		local self = PlayerObject.Get(player)
		if (self) then
			return self:_handle_equip(item)
		end
	end)
	
	Network.ListenTo(RemoteSpace.Players.Unequip_Request, function(player: Player)
		local self = PlayerObject.Get(player)
		if (self) then
			return self:Unequip()
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


return PlayerObject