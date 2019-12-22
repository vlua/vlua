local config = require("vlua.config")
local lu = require("test.luaunit")
local vlua = require("vlua.vlua")


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
            "simple computed",
            function()
                vlua.reactiveCall(
                    function()
                        print(computedValue.value)
                    end
                )

                print.allWith({{1}})

                computedValue.value = 2
                lu.assertEquals(computedValue.value, 2)
                print.allWith({{2}})
                computedValue.value = 3
                lu.assertEquals(computedValue.value, 3)
                computedValue.value = 4
                lu.assertEquals(computedValue.value, 4)
                print.allWith({{3}, {4}})

                computedValue.set(2)
                lu.assertEquals(computedValue.get(), 2)
                print.allWith({{2}})
                computedValue.set(3)
                lu.assertEquals(computedValue.get(), 3)
                computedValue.set(4)
                lu.assertEquals(computedValue.get(), 4)
                print.allWith({{3}, {4}})
            end
        )
        it(
            "get or get self",
            function()
                local v = 1

                local get = lu.createSpy("get")
                local set = lu.createSpy("set")
                computedValue =
                    vlua.computed(
                    function(self)
                        get(self, v)
                        return v
                    end,
                    function(self, newValue)
                        set(self, newValue, v)
                        v = newValue
                    end
                )

                local data = {id = computedValue}
                vlua.reactive(data)
                local aa = data.id

                get.allWith({{data, 1}}, "self is data")
                set.toHaventBeenCalled()

                get.clear()
                set.clear()

                local a = computedValue.value
                get.allWith({{nil, 1}}, "self is nil")
                set.toHaventBeenCalled()
                get.clear()
                set.clear()

                data.id = 2
                get.toHaventBeenCalled()
                set.allWith({{data, 2, 1}}, "self is data")
                get.clear()
                set.clear()

                computedValue.value = 3
                get.toHaventBeenCalled()
                set.allWith({{nil, 3, 2}}, "self is data")
                get.clear()
                set.clear()
            end
        )

        it(
            "computed function",
            function()
                
                local get = lu.createSpy("get")
                local data = {
                    idAddOne = function(self)
                        get(self)
                        return self.id + 1
                    end,
                    id = 1
                }
                vlua.reactive(data)

                lu.assertEquals(data.id , 1)
                lu.assertEquals(data.idAddOne , 2)
                get.allWith({{data}}, "self is data")
                
                data.id = 2
                lu.assertEquals(data.id , 2)
                lu.assertEquals(data.idAddOne , 3)
                get.allWith({{data}}, "self is data")
                
            end
        )
    end
)
