local config = require("vlua.config")
local lu = require("luaunit")

local vlua = require("vlua.vlua")

describe(
    "reactiveCall sync",
    function()
        ---@type reactiveCallData
        local data

        beforeEach(
            function()
                config.async = false
                ---@class reactiveCallData
                data = {
                    a = 1,
                    b = {
                        c = 2,
                        d = 4
                    },
                    c = "c",
                    msg = "yo"
                }
                vlua.reactive(data)
            end
        )

        it(
            "simple",
            function()
                local print = lu.createSpy("print")

                local context = vlua.reactiveCall(
                    function()
                        print(data.a, data.c, data.b.d)
                    end
                )


                lu.assertEquals(#print.calls, 1)
                print.toHaveBeenCalledWith(1, "c", 4)

                data.a = 2
                lu.assertEquals(#print.calls, 2)
                print.toHaveBeenCalledWith(2, "c", 4)

                data.c = "e"
                data.b.d = 5
                lu.assertEquals(#print.calls, 4)
                print.toHaveBeenCalledWith(2, "e", 5)
            end
        )

        it(
            "child",
            function()
                local print = lu.createSpy("print")

                local content =
                    vlua.reactiveCall(
                    function()
                        print(data.a)

                        vlua.reactiveCall(
                            function()
                                print(data.c)
                            end
                        )

                        vlua.reactiveCall(
                            function()
                                print(data.b.d)
                            end
                        )
                    end
                )

                print.allWith({{1}, {"c"}, {4}})

                data.a = 2
                print.allWith({{2}, {"c"}, {4}})

                data.c = "e"
                print.allWith({{"e"}})

                data.b.d = 9
                data.c = "f"
                print.allWith({{9}, {"f"}})

                data.b.d = 10
                data.a = 11
                print.allWith({{10}, {11}, {"f"}, {10}})
            end
        )
        it(
            "deep child",
            function()
                local print = lu.createSpy("print")

                local content =
                    vlua.reactiveCall(
                    function()
                        print(data.a)

                        vlua.reactiveCall(
                            function()
                                print(data.c)
                                vlua.reactiveCall(
                                    function()
                                        print(data.b.d)
                                        vlua.reactiveCall(
                                            function()
                                                print(data.b.d)
                                            end
                                        )
                                    end
                                )
                            end
                        )
                    end
                )

                print.allWith({{1}, {"c"}, {4}, {4}})

                data.a = 2
                print.allWith({{2}, {"c"}, {4}, {4}})

                data.c = "e"
                print.allWith({{"e"}, {4}, {4}})

                data.b.d = 9
                data.c = "f"
                print.allWith({{9}, {9}, {"f"}, {9}, {9}})

                data.b.d = 10
                data.a = 11
                print.allWith({{10}, {10}, {11}, {"f"}, {10}, {10}})
            end
        )
    end
)

describe(
    "reactiveCall async",
    function()
        ---@type reactiveCallData
        local data

        beforeEach(
            function()
                config.async = true
                ---@class reactiveCallData
                data = {
                    a = 1,
                    b = {
                        c = 2,
                        d = 4
                    },
                    c = "c",
                    msg = "yo"
                }
                vlua.reactive(data)
            end
        )

        it(
            "simple",
            function()
                local print = lu.createSpy("print")

                vlua.reactiveCall(
                    function()
                        print(data.a, data.c, data.b.d)
                    end
                )

                lu.assertEquals(#print.calls, 1)
                print.toHaveBeenCalledWith(1, "c", 4)

                data.a = 2
                lu.assertEquals(#print.calls, 1)

                waitForUpdate()

                lu.assertEquals(#print.calls, 2)
                print.toHaveBeenCalledWith(2, "c", 4)

                data.c = "e"
                lu.assertEquals(#print.calls, 2)
                data.b.d = 5
                lu.assertEquals(#print.calls, 2)

                waitForUpdate()
                lu.assertEquals(#print.calls, 3)
                print.toHaveBeenCalledWith(2, "e", 5)
            end
        )

        it(
            "child",
            function()
                local print = lu.createSpy("print")

                local content =
                    vlua.reactiveCall(
                    function()
                        print(data.a)

                        vlua.reactiveCall(
                            function()
                                print(data.c)
                            end
                        )

                        vlua.reactiveCall(
                            function()
                                print(data.b.d)
                            end
                        )
                    end
                )

                print.allWith({{1}, {"c"}, {4}})

                data.a = 2
                lu.assertEquals(#print.calls, 0)

                waitForUpdate()
                print.allWith({{2}, {"c"}, {4}})

                data.c = "e"
                lu.assertEquals(#print.calls, 0)

                waitForUpdate()
                print.allWith({{"e"}})

                data.b.d = 9
                data.c = "f"
                lu.assertEquals(#print.calls, 0)

                waitForUpdate()
                print.allWith({{"f"}, {9}})

                data.b.d = 10
                data.a = 11
                lu.assertEquals(#print.calls, 0)

                waitForUpdate()
                print.allWith({{11}, {"f"}, {10}})
            end
        )
        it(
            "deep child",
            function()
                local print = lu.createSpy("print")

                local content =
                    vlua.reactiveCall(
                    function()
                        print(data.a)

                        vlua.reactiveCall(
                            function()
                                print(data.c)
                                vlua.reactiveCall(
                                    function()
                                        print(data.b.d)
                                        vlua.reactiveCall(
                                            function()
                                                print(data.b.d)
                                            end
                                        )
                                    end
                                )
                            end
                        )
                    end
                )

                print.allWith({{1}, {"c"}, {4}, {4}})

                data.a = 2
                lu.assertEquals(#print.calls, 0)

                waitForUpdate()
                print.allWith({{2}, {"c"}, {4}, {4}})

                data.c = "e"
                lu.assertEquals(#print.calls, 0)

                waitForUpdate()
                print.allWith({{"e"}, {4}, {4}})

                data.b.d = 9
                data.c = "f"
                lu.assertEquals(#print.calls, 0)

                waitForUpdate()
                print.allWith({{"f"}, {9}, {9}})

                data.b.d = 10
                data.a = 11
                lu.assertEquals(#print.calls, 0)

                waitForUpdate()
                print.allWith({{11}, {"f"}, {10}, {10}})
            end
        )
    end
)
