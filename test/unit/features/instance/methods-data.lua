local lu = require("luaunit")
local Vue = require("instance.Vue")

describe(
    "Instance methods data",
    function()
        it(
            "$set/$delete",
            function()
                local vm =
                    Vue.new(
                    {
                        data = {
                            a = {}
                        }
                    }
                )
                vm._set(vm.a, "msg", "hello")
                waitForUpdate()
                vm._delete(vm.a, "msg")
                waitForUpdate()
            end
        )

        describe(
            "$watch",
            function()
                local vm, spy;
                ---@type Spy
                local spyObj
                beforeEach(
                    function()
                        spyObj = lu.createSpy("watch")
                        spy = spyObj.call
                        vm =
                            Vue.new(
                            {
                                data = {
                                    a = {
                                        b = 1
                                    },
                                    ["유니코드"] = {
                                        ["なまえ"] = "ok"
                                    }
                                },
                                methods = {
                                    foo = spy
                                }
                            }
                        )
                    end
                )

                it(
                    "basic usage",
                    function()
                        vm:_watch("a.b", spy)
                        vm.a.b = 2
                        waitForUpdate()
                        lu.assertEquals(#spyObj.calls, 1)
                        spyObj.toHaveBeenCalledWith(vm, 2, 1)
                        vm.a = {b = 3}
                        waitForUpdate()
                        lu.assertEquals(#spyObj.calls, 2)
                        spyObj.toHaveBeenCalledWith(vm, 3, 2)
                    end
                )

                it(
                    "immediate",
                    function()
                        vm:_watch("a.b", spy, {immediate = true})
                        lu.assertEquals(#spyObj.calls, 1)
                        spyObj.toHaveBeenCalledWith(vm, 1)
                    end
                )

                it(
                    "unwatch",
                    function()
                        local unwatch = vm:_watch("a.b", spy)
                        unwatch()
                        vm.a.b = 2
                        waitForUpdate()
                        lu.assertEquals(#spyObj.calls, 0)
                        waitForUpdate()
                    end
                )

                it(
                    "function watch",
                    function()
                        vm:_watch(
                            function(this)
                                return this.a.b
                            end,
                            spy
                        )
                        vm.a.b = 2
                        waitForUpdate()
                        spyObj.toHaveBeenCalledWith(vm, 2, 1)
                        waitForUpdate()
                    end
                )

                it(
                    "deep watch",
                    function()
                        local oldA = vm.a
                        vm:_watch("a", spy, {deep = true})
                        vm.a.b = 2
                        waitForUpdate()
                        spyObj.toHaveBeenCalledWith(vm, oldA, oldA)
                        vm.a = {b = 3}
                        waitForUpdate()
                        spyObj.toHaveBeenCalledWith(vm, vm.a, oldA)
                        waitForUpdate()
                    end
                )

                it(
                    "handler option",
                    function()
                        local oldA = vm.a
                        vm:_watch(
                            "a",
                            {
                                handler = spy,
                                deep = true
                            }
                        )
                        vm.a.b = 2
                        waitForUpdate()
                        spyObj.toHaveBeenCalledWith(vm, oldA, oldA)
                        vm.a = {b = 3}
                        waitForUpdate()
                        spyObj.toHaveBeenCalledWith(vm, vm.a, oldA)
                        waitForUpdate()
                    end
                )

                it(
                    "handler option in string",
                    function()
                        vm:_watch(
                            "a.b",
                            {
                                handler = "foo",
                                immediate = true
                            }
                        )
                        lu.assertEquals(#spyObj.calls, 1)
                        spyObj.toHaveBeenCalledWith(vm, 1)
                    end
                )

                it(
                    "handler option in string",
                    function()
                        vm:_watch(
                            "유니코드.なまえ",
                            {
                                handler = "foo",
                                immediate = true
                            }
                        )
                        lu.assertEquals(#spyObj.calls, 1)
                        spyObj.toHaveBeenCalledWith(vm, "ok")
                    end
                )

                -- it(
                --     "warn expression",
                --     function()
                --         vm:_watch("a + b", spy)
                --         lu.assertEquals("Watcher only accepts simple dot-delimited paths").toHaveBeenWarned()
                --     end
                -- )
            end
        )
    end
)
