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
            function(done)
                local watcher = Watcher.new(vm, "b.c", spy)
                expect(watcher.value).toBe(2)
                vm.b.c = 3
                waitForUpdate(
                    function()
                        expect(watcher.value).toBe(3)
                        expect(spy).toHaveBeenCalledWith(3, 2)
                        vm.b = {c = 4} -- swapping the object
                    end
                ).thento(
                    function()
                        expect(watcher.value).toBe(4)
                        expect(spy).toHaveBeenCalledWith(4, 3)
                    end
                ).thento(done)
            end
        )

        it(
            "non-existent path, set later",
            function(done)
                local watcher1 = Watcher.new(vm, "b.e", spy)
                expect(watcher1.value).toBeUndefined()
                -- check $add should not affect isolated children
                local child2 = new
                Vue({parent = vm})
                local watcher2 = Watcher.new(child2, "b.e", spy)
                expect(watcher2.value).toBeUndefined()
                Vue.set(vm.b, "e", 123)
                waitForUpdate(
                    function()
                        expect(watcher1.value).toBe(123)
                        expect(watcher2.value).toBeUndefined()
                        expect(spy.calls.count()).toBe(1)
                        expect(spy).toHaveBeenCalledWith(123, undefined)
                    end
                ).thento(done)
            end
        )

        it(
            "delete",
            function(done)
                local watcher = Watcher.new(vm, "b.c", spy)
                expect(watcher.value).toBe(2)
                Vue.delete(vm.b, "c")
                waitForUpdate(
                    function()
                        expect(watcher.value).toBeUndefined()
                        expect(spy).toHaveBeenCalledWith(undefined, 2)
                    end
                ).thento(done)
            end
        )

        it(
            "path containing $data",
            function(done)
                local watcher = Watcher.new(vm, "$data.b.c", spy)
                expect(watcher.value).toBe(2)
                vm.b = {c = 3}
                waitForUpdate(
                    function()
                        expect(watcher.value).toBe(3)
                        expect(spy).toHaveBeenCalledWith(3, 2)
                        vm._data.b.c = 4
                    end
                ).thento(
                    function()
                        expect(watcher.value).toBe(4)
                        expect(spy).toHaveBeenCalledWith(4, 3)
                    end
                ).thento(done)
            end
        )

        it(
            "deep watch",
            function(done)
                local oldB
                Watcher.new(
                    vm,
                    "b",
                    spy,
                    {
                        deep = true
                    }
                )
                vm.b.c = {d = 4}
                waitForUpdate(
                    function()
                        expect(spy).toHaveBeenCalledWith(vm.b, vm.b)
                        oldB = vm.b
                        vm.b = {c = {{a = 1}}}
                    end
                ).thento(
                    function()
                        expect(spy).toHaveBeenCalledWith(vm.b, oldB)
                        expect(spy.calls.count()).toBe(2)
                        vm.b.c[0].a = 2
                    end
                ).thento(
                    function()
                        expect(spy).toHaveBeenCalledWith(vm.b, vm.b)
                        expect(spy.calls.count()).toBe(3)
                    end
                ).thento(done)
            end
        )

        it(
            "deep watch $data",
            function(done)
                Watcher.new(
                    vm,
                    "$data",
                    spy,
                    {
                        deep = true
                    }
                )
                vm.b.c = 3
                waitForUpdate(
                    function()
                        expect(spy).toHaveBeenCalledWith(vm._data, vm._data)
                    end
                ).thento(done)
            end
        )

        it(
            "deep watch with circular references",
            function(done)
                Watcher.new(
                    vm,
                    "b",
                    spy,
                    {
                        deep = true
                    }
                )
                Vue.set(vm.b, "_", vm.b)
                waitForUpdate(
                    function()
                        expect(spy).toHaveBeenCalledWith(vm.b, vm.b)
                        expect(spy.calls.count()).toBe(1)
                        vm.b._.c = 1
                    end
                ).thento(
                    function()
                        expect(spy).toHaveBeenCalledWith(vm.b, vm.b)
                        expect(spy.calls.count()).toBe(2)
                    end
                ).thento(done)
            end
        )

        it(
            "fire change for prop addition/deletion in non-deep mode",
            function(done)
                Watcher.new(vm, "b", spy)
                Vue.set(vm.b, "e", 123)
                waitForUpdate(
                    function()
                        expect(spy).toHaveBeenCalledWith(vm.b, vm.b)
                        expect(spy.calls.count()).toBe(1)
                        Vue.delete(vm.b, "e")
                    end
                ).thento(
                    function()
                        expect(spy.calls.count()).toBe(2)
                    end
                ).thento(done)
            end
        )

        it(
            "watch function",
            function(done)
                local watcher =
                    Watcher.new(
                    vm,
                    function()
                        return this.a + this.b.d
                    end,
                    spy
                )
                expect(watcher.value).toBe(5)
                vm.a = 2
                waitForUpdate(
                    function()
                        expect(spy).toHaveBeenCalledWith(6, 5)
                        vm.b = {d = 2}
                    end
                ).thento(
                    function()
                        expect(spy).toHaveBeenCalledWith(4, 6)
                    end
                ).thento(done)
            end
        )

        it(
            "lazy mode",
            function(done)
                local watcher =
                    Watcher.new(
                    vm,
                    function()
                        return this.a + this.b.d
                    end,
                    null,
                    {lazy = true}
                )
                expect(watcher.lazy).toBe(true)
                expect(watcher.value).toBeUndefined()
                expect(watcher.dirty).toBe(true)
                watcher.evaluate()
                expect(watcher.value).toBe(5)
                expect(watcher.dirty).toBe(false)
                vm.a = 2
                waitForUpdate(
                    function()
                        expect(watcher.value).toBe(5)
                        expect(watcher.dirty).toBe(true)
                        watcher.evaluate()
                        expect(watcher.value).toBe(6)
                        expect(watcher.dirty).toBe(false)
                    end
                ).thento(done)
            end
        )

        it(
            "teardown",
            function(done)
                local watcher = Watcher.new(vm, "b.c", spy)
                watcher.teardown()
                vm.b.c = 3
                waitForUpdate(
                    function()
                        expect(watcher.active).toBe(false)
                        expect(spy).toHaventBeenCalled()
                    end
                ).thento(done)
            end
        )

        it(
            "warn not support path",
            function()
                Watcher.new(vm, "d.e + c", spy)
                expect("Failed watching path =").toHaveBeenWarned()
            end
        )
    end
)
