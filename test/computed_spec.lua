local config = require("config")
local lu = require("luaunit")

local vlua = require("vlua")

describe(
    "computed sync",
    function()
        ---@type Computed
        local data
        ---@type Spy
        local print
        beforeEach(
            function()
                config.async = false
                local v = 1
                data =
                    vlua.computed(
                    function(self)
                        return v
                    end,
                    function(self, newValue)
                        v = newValue
                    end
                )

                print = lu.createSpy("print")
            end
        )

        it(
            "value",
            function()
                vlua.reactiveEval(
                    function()
                        print(data.value)
                    end
                )

                print.allWith({{1}})

                data.value = 2
                lu.assertEquals(data.value , 2)
                print.allWith({{2}})
                data.value = 3
                lu.assertEquals(data.value , 3)
                data.value = 4
                lu.assertEquals(data.value , 4)
                print.allWith({{3}, {4}})

                data.set(2)
                lu.assertEquals(data.get() , 2)
                print.allWith({{2}})
                data.set(3)
                lu.assertEquals(data.get() , 3)
                data.set(4)
                lu.assertEquals(data.get() , 4)
                print.allWith({{3}, {4}})
            end
        )
    end
)
