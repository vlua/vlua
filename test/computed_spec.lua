local config = require("config")
local lu = require("luaunit")

local vlua = require("vlua")

describe(
    "computed sync",
    function()
        ---@type Computed
        local computedValue
        ---@type Spy
        local print
        beforeEach(
            function()
                config.async = false
                local v = 1
                computedValue =
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
                        print(computedValue.value)
                    end
                )

                print.allWith({{1}})

                computedValue.value = 2
                lu.assertEquals(computedValue.value , 2)
                print.allWith({{2}})
                computedValue.value = 3
                lu.assertEquals(computedValue.value , 3)
                computedValue.value = 4
                lu.assertEquals(computedValue.value , 4)
                print.allWith({{3}, {4}})

                computedValue.set(2)
                lu.assertEquals(computedValue.get() , 2)
                print.allWith({{2}})
                computedValue.set(3)
                lu.assertEquals(computedValue.get() , 3)
                computedValue.set(4)
                lu.assertEquals(computedValue.get() , 4)
                print.allWith({{3}, {4}})
            end
        )
        it(
            "value",
            function()
                local v = 1
                
                local get = lu.createSpy("get")
                local set = lu.createSpy("set")
                computedValue = vlua.computed(
                    function(self)
                        get(self, v)
                        return v
                    end,
                    function(self, newValue)
                        set(self, newValue, v)
                        v = newValue
                    end
                )

                local data = vlua.reactive({id = computedValue})

                vlua.reactiveEval(
                    function()
                        print(data.id)
                    end
                )

                print.allWith({{1}})

                data.id = 2
                lu.assertEquals(data.id , 2)
                print.allWith({{2}})

                data.id = 3
                lu.assertEquals(data.id , 3)
                data.id = 4
                lu.assertEquals(data.id , 4)
                print.allWith({{3}, {4}})

                computedValue.set(2)
                lu.assertEquals(computedValue.get() , 2)
                print.allWith({{2}})
                computedValue.set(3)
                lu.assertEquals(computedValue.get() , 3)
                computedValue.set(4)
                lu.assertEquals(computedValue.get() , 4)
                print.allWith({{3}, {4}})
            end
        )
    end
)
