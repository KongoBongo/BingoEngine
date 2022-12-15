local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Engine = require(ReplicatedStorage:WaitForChild("BingoEngine"))
local TestEZ = require(ReplicatedStorage:WaitForChild("TestEZ"))

local function Runtime()
	Engine.Start(ServerStorage.Services, "Service$"):catch(warn)

	TestEZ.TestBootstrap:run {}
end

Runtime()