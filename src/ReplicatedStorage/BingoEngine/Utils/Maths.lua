--[=[
	Holds utilty Maths functions not available on Roblox's Maths library.
	@class Maths
]=]

local Maths = {
    acos = math.acos,
    floor = math.floor,
    ceil	 = math.ceil,
    pi = math.pi,

    sin = math.sin,
    cos = math.cos,
    atan2 = math.atan2,
    atan = math.atan,
    tan = math.tan,
    perlin = math.noise,

    abs = math.abs,
    asin = math.asin,
    clamp = math.clamp,
    cosh = math.cosh,
    log = math.log,
    log10 = math.log10,
    max = math.max,
    min = math.min,
    modf = math.modf,
    seed = math.randomseed,
    sign = math.sign,
    sinh = math.sinh,
    sqrt = math.sqrt,
    tanh = math.tanh,

    inf = 1/0,
    nan = 0/0,

}


--[=[
	Interpolates betweeen two numbers, given an percent. The percent is
	a number in the range that will be used to define how interpolated
	it is between num0 and num1.

	```lua
	print(Maths.lerp(-1000, 1000, 0.75)) --> 500
	```

	@param num0 number -- Number
	@param num1 number -- Second number
	@param percent number -- The percent
	@return number -- The interpolated
]=]
function Maths.lerp(num0: number, num1: number, percent: number): number
	return num0 + ((num1 - num0) * percent)
end

--[=[
	Solving for angle across from c

	@param a number
	@param b number
	@param c number
	@return number? -- Returns nil if this cannot be solved for
]=]
function Maths.lawOfCosines(a: number, b: number, c: number): number?
	local l = (a*a + b*b - c*c) / (2 * a * b)
	local angle = Maths.acos(l)
	if angle ~= angle then
		return nil
	end
	return angle
end

--[=[
	Round the given number to given precision

	```lua
	print(Maths.round(72.1, 5)) --> 75
	```

	@param number number
	@param precision number? -- Defaults to 1
	@return number
]=]
function Maths.round(number: number, precision: number?): number
	if precision then
		return Maths.floor((number/precision) + 0.5) * precision
	else
		return Maths.floor(number + 0.5)
	end
end

--[=[
	Rounds up to the given precision

	@param number number
	@param precision number
	@return number
]=]
function Maths.roundUp(number: number, precision: number): number
	return Maths.ceil(number/precision) * precision
end

--[=[
	Rounds down to the given precision

	@param number number
	@param precision number
	@return number
]=]
function Maths.roundDown(number: number, precision: number): number
	return Maths.floor(number/precision) * precision
end



function Maths.toDeg(radians: number)
    return radians * (180 / Maths.pi)
end

function Maths.toRad(degrees: number)
    return degrees * (Maths.pi / 180);
end


return Maths