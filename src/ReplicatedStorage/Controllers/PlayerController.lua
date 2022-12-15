local PlayerController = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Structures = ReplicatedStorage:WaitForChild("Structures")

local ClientSettings = require(Structures:WaitForChild("ClientSettings"))
local RemoteSpace = require(Structures:WaitForChild("RemoteSpace"))

local Engine = require(ReplicatedStorage:WaitForChild("BingoEngine"))
local Network = Engine.Network
local Maths = Engine.Utils.Maths

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 1/0)

local camera = workspace.CurrentCamera

local this = nil

local isDead = false

local connections = {
	DeathConnection = nil,
	RequestDeploy = nil
}

local function handle_equip(item: string)
	warn(item)
end

local function OnInputBegan(inputObject: InputObject, isTyping: boolean)
	if (isTyping == true or isDead) then
		return
	end
	
	for index, key_name: string in ClientSettings.Hotbar do
		if (inputObject.KeyCode == Enum.KeyCode[key_name]) then
			local result = Network.InvokeServer(RemoteSpace.Players.Equip_Request, index)
			handle_equip(result)
		end
	end
	
end

local function OnInputEnded(inputObject: InputObject, isTyping: boolean)
	if (isTyping == true or this == nil) then
		return
	end

end

local function onDeath()
	isDead = true
end

local function onSpawn(character)
	isDead = false
	local humanoid = character:WaitForChild("Humanoid")
	
	if (connections.DeathConnection) then
		connections.DeathConnection:Disconnect()
	end

	connections.DeathConnection = humanoid.Died:Connect(onDeath)
end

function PlayerController:OnInit()
	-- Initialises the module for use by others or for itself
	UserInputService.InputBegan:Connect(OnInputBegan)
	UserInputService.InputEnded:Connect(OnInputEnded)

	player.CharacterAdded:Connect(onSpawn)
	onSpawn(player.Character or player.CharacterAdded:Wait())


    Network.ToServer(RemoteSpace.Players.OptIn)
end


function PlayerController:OnStart()
	
end

return PlayerController