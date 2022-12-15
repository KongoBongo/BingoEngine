local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Engine = require(ReplicatedStorage:WaitForChild("BingoEngine"))

local function Runtime()
	Engine.Start(ServerStorage.Services, "Service$"):catch(warn)
end

Runtime()