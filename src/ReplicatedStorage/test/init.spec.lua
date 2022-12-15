return function()
    local test = require(script.Parent.test)

    describe("add", function()
        it("should include an numeric argument.", function()
            local result = test:add(1)
            expect(typeof(result) == "number").to.be.ok();
        end)
    end)

end