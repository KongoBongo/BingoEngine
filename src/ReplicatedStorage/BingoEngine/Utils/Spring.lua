--[=[
    @class Spring

    Implementation of a spring module for the BingoEngine
]=]--

local ITERATIONS = 8

local Spring = {}
Spring.__index = Spring
Spring.ClassName = "Spring"

function Spring.new(data)
    --@ params {Table} Data: A list of default data sets to use within the base spring.

    --@ public
    local self = setmetatable({}, Spring)

    self.Target = Vector3.new()
    self.Position = Vector3.new()
    self.Velocity = Vector3.new()

    self.Mass = data.Mass or 5
    self.Force = data.Force or 50
    self.Damping = data.Damping or 4
    self.Speed = data.Speed or 4

    return self
end

function Spring:Shove(force: Vector3)
    local x = force.X
    local y = force.Y
    local z = force.Z

    if (x ~= x or x == math.huge or x == -math.huge) then
        x	= 0
    end
    if (y ~= y or y == math.huge or y == -math.huge) then
        y	= 0
    end
    if (z ~= z or z == math.huge or z == -math.huge) then
        z	= 0
    end

    self.Velocity = self.Velocity + Vector3.new(x, y, z)
end

function Spring:Update(dt: number)
    local scaledDeltaTime = dt * self.Speed / ITERATIONS

    for _ = 1, ITERATIONS do
        local iterationForce = (self.Target - self.Position)
        local acceleration	= (iterationForce * self.Force) / self.Mass

        acceleration = acceleration - self.Velocity * self.Damping

        self.Velocity = self.Velocity + acceleration * scaledDeltaTime
        self.Position = self.Position + self.Velocity * scaledDeltaTime
    end

    return self.Position
end


return Spring