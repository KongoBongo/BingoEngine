local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Engine = require(ReplicatedStorage:WaitForChild("BingoEngine"))

local function Runtime()
	Engine.Start(ReplicatedStorage:WaitForChild("Controllers"), "Controller$"):catch(warn)
end

Runtime()