local test = {}

test.a = 0

function test:add(num)
    test.a += num
    
    return test.a
end

function test:sub(num)
    test.a -= num

    return test.a
end

function test:out()
    print(test.a)
end


return test