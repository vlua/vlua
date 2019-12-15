local lu = require("luaunit")
local Vue = require("instance.Vue")
local Watcher = require("observer.Watcher")

describe(
    "Watcher",
    function()
        local vm, spy
        beforeEach(
            function()
                vm =
                    Vue.new(
                    {
                        data = {
                            a = 1,
                            b = {
                                c = 2,
                                d = 4
                            },
                            c = "c",
                            msg = "yo"
                        }
                    }
                ):_mount()
                spy = lu.createSpy("watcher")
            end
        )

        it(
            "path",
            function()
                local watcher = Watcher.new(vm, "b.c", spy)
                lu.assertEquals(watcher.value, 2)
                vm.b.c = 3
                waitForUpdate()

                lu.assertEquals(watcher.value, 3)
                spy.toHaveBeenCalledWith(vm, 3, 2)
                vm.b = {c = 4} -- swapping the object

                waitForUpdate()
                lu.assertEquals(watcher.value, 4)
                spy.toHaveBeenCalledWith(vm, 4, 3)
            end
        )

        it(
            "non-existent path, set later",
            function()
                local watcher1 = Watcher.new(vm, "b.e", spy)
                lu.assertEquals(watcher1.value, nil)
                -- check $add should not affect isolated children
                local child2 = Vue.new({parent = vm})
                local watcher2 = Watcher.new(child2, "b.e", spy)
                lu.assertEquals(watcher2.value, nil)
                Vue.set(vm.b, "e", 123)
                waitForUpdate()
                lu.assertEquals(watcher1.value, 123)
                lu.assertEquals(watcher2.value, nil)
                lu.assertEquals(spy.calls.count(), 1)
                spy.toHaveBeenCalledWith(vm, 123, nil)
            end
        )

        it(
            "delete",
            function()
                local watcher = Watcher.new(vm, "b.c", spy)
                lu.assertEquals(watcher.value, 2)
                Vue.delete(vm.b, "c")
                waitForUpdate()
                lu.assertEquals(watcher.value, nil)
                spy.toHaveBeenCalledWith(vm, nil, 2)
            end
        )

        it(
            "path containing $data",
            function()
                local watcher = Watcher.new(vm, "$data.b.c", spy)
                lu.assertEquals(watcher.value, 2)
                vm.b = {c = 3}
                waitForUpdate()
                lu.assertEquals(watcher.value, 3)
                spy.toHaveBeenCalledWith(vm, 3, 2)
                vm._data.b.c = 4

                waitForUpdate()
                lu.assertEquals(watcher.value, 4)
                spy.toHaveBeenCalledWith(vm, 4, 3)
            end
        )

        it(
            "deep watch",
            function()
                print("deep")
                local oldB
                local watcher =
                    Watcher.new(
                    vm,
                    "b",
                    spy,
                    {
                        deep = true
                    }
                )
                vm.b.c = {d = 4}
                waitForUpdate()
                spy.toHaveBeenCalledWith(vm, vm.b, vm.b)
                oldB = vm.b
                vm.b = {c = {{a = 1}}}

                waitForUpdate()
                spy.toHaveBeenCalledWith(vm, vm.b, oldB)
                lu.assertEquals(#spy.calls, 2)
                vm.b.c[1].a = 2

                waitForUpdate()
                spy.toHaveBeenCalledWith(vm, vm.b, vm.b)
                lu.assertEquals(#spy.calls, 3)
            end
        )

        it(
            "deep watch $data",
            function()
                Watcher.new(
                    vm,
                    "_data",
                    spy,
                    {
                        deep = true
                    }
                )
                vm.b.c = 3
                waitForUpdate()
                spy.toHaveBeenCalledWith(vm, vm._data, vm._data)
            end
        )

        it(
            "deep watch with circular references",
            function()
                Watcher.new(
                    vm,
                    "b",
                    spy,
                    {
                        deep = true
                    }
                )
                Vue.set(vm.b, "_", vm.b)
                waitForUpdate()
                spy.toHaveBeenCalledWith(vm, vm.b, vm.b)
                lu.assertEquals(#spy.calls, 1)
                vm.b._.c = 1
                waitForUpdate()

                spy.toHaveBeenCalledWith(vm, vm.b, vm.b)
                lu.assertEquals(#spy.calls, 2)
            end
        )

        it(
            "fire change for prop addition/deletion in non-deep mode",
            function()
                Watcher.new(vm, "b", spy)
                Vue.set(vm.b, "e", 123)
                waitForUpdate()
                spy.toHaveBeenCalledWith(vm, vm.b, vm.b)
                lu.assertEquals(#spy.calls, 1)
                Vue.delete(vm.b, "e")

                waitForUpdate()
                lu.assertEquals(#spy.calls, 2)
            end
        )

        it(
            "watch function",
            function()
                local watcher =
                    Watcher.new(
                    vm,
                    function(self)
                        return self.a + self.b.d
                    end,
                    spy
                )
                lu.assertEquals(watcher.value, 5)
                vm.a = 2
                waitForUpdate()
                spy.toHaveBeenCalledWith(vm, 6, 5)
                vm.b = {d = 2}
                waitForUpdate()
                spy.toHaveBeenCalledWith(vm, 4, 6)
            end
        )

        it(
            "lazy mode",
            function()
                local watcher =
                    Watcher.new(
                    vm,
                    function(self)
                        return self.a + self.b.d
                    end,
                    nil,
                    {lazy = true}
                )
                lu.assertEquals(watcher.lazy, true)
                lu.assertEquals(watcher.value, nil)
                lu.assertEquals(watcher.dirty, true)
                watcher.evaluate()
                lu.assertEquals(watcher.value, 5)
                lu.assertEquals(watcher.dirty, false)
                vm.a = 2
                waitForUpdate()
                lu.assertEquals(watcher.value, 5)
                lu.assertEquals(watcher.dirty, true)
                watcher.evaluate()
                lu.assertEquals(watcher.value, 6)
                lu.assertEquals(watcher.dirty, false)
            end
        )

        it(
            "teardown",
            function()
                local watcher = Watcher.new(vm, "b.c", spy)
                watcher.teardown()
                vm.b.c = 3
                waitForUpdate()
                lu.assertEquals(watcher.active, false)
                spy.toHaventBeenCalled()
            end
        )

        it(
            "warn not support path",
            function()
                Watcher.new(vm, "d.e + c", spy)
                lu.assertEquals("Failed watching path =").toHaveBeenWarned()
            end
        )
    end
)
