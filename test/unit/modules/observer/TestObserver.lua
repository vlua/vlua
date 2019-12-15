local lu = require("luaunit")
local Vue = require("instance.Vue")
local Dep = require("observer.Dep")
local Util = require("util.Util")
local Lang = require("util.Lang")
local instanceof = Lang.instanceof
local hasOwn, createObject = Util.hasOwn, Util.createObject
local Observer = require("observer.Observer")
local Watcher = require("observer.Watcher")

local observe, setProp, delProp, defineProperty, createPlainObject =
    Observer.observe,
    Observer.set,
    Observer.del,
    Util.defineProperty,
    Util.createPlainObject

describe(
    "Observer",
    function()
        it(
            "create on non-observables",
            function()
                -- skip primitive value
                local ob1 = observe(1)
                lu.assertEquals(ob1, nil)
                -- avoid vue instance
                local ob2 = observe(Vue.new())
                lu.assertEquals(ob2, nil)
                -- avoid frozen objects
                -- local ob3 = observe({})
                -- lu.assertEquals(ob3, nil)
            end
        )

        it(
            "create on object",
            function()
                -- on object
                local obj = {
                    a = {},
                    b = {}
                }
                local ob1 = observe(obj)
                lu.assertEquals(instanceof(ob1, Observer), true)
                lu.assertEquals(ob1.value, obj)
                lu.assertEquals(getmetatable(obj).__ob__, ob1)
                -- should've walked children
                lu.assertEquals(instanceof(getmetatable(obj.a).__ob__, Observer), true)
                lu.assertEquals(instanceof(getmetatable(obj.b).__ob__, Observer), true)
                -- should return existing ob on already observed objects
                local ob2 = observe(obj)
                lu.assertEquals(ob2, ob1)
            end
        )

        it(
            "create on nil",
            function()
                -- on nil
                local obj = createObject(nil)
                obj.a = {}
                obj.b = {}
                local ob1 = observe(obj)
                lu.assertEquals(instanceof(ob1, Observer), true)
                lu.assertEquals(ob1.value, obj)
                lu.assertEquals(getmetatable(obj).__ob__, ob1)
                -- should've walked children
                lu.assertEquals(instanceof(getmetatable(obj.a).__ob__, Observer), true)
                lu.assertEquals(instanceof(getmetatable(obj.b).__ob__, Observer), true)
                -- should return existing ob on already observed objects
                local ob2 = observe(obj)
                lu.assertEquals(ob2, ob1)
            end
        )

        it(
            "create on already observed object",
            function()
                -- on object
                local obj = createPlainObject()
                local val = 0
                local getCount = 0
                defineProperty(
                    obj,
                    "a",
                    function()
                        getCount = getCount + 1
                        return val
                    end,
                    function(v)
                        val = v
                    end
                )

                local ob1 = observe(obj)
                lu.assertEquals(instanceof(ob1, Observer), true)
                lu.assertEquals(ob1.value, obj)
                lu.assertEquals(getmetatable(obj).__ob__, ob1)

                getCount = 0
                -- Each read of 'a' should result in only one get underlying get call
                local aa = obj.a
                lu.assertEquals(getCount, 1)
                local aa = obj.a
                lu.assertEquals(getCount, 2)

                -- should return existing ob on already observed objects
                local ob2 = observe(obj)
                lu.assertEquals(ob2, ob1)

                -- should call underlying setter
                obj.a = 10
                lu.assertEquals(val, 10)
            end
        )

        it(
            "create on property with only getter",
            function()
                -- on object
                local obj = createPlainObject()
                defineProperty(
                    obj,
                    "a",
                    function()
                        return 123
                    end
                )

                local ob1 = observe(obj)
                lu.assertEquals(instanceof(ob1, Observer), true)
                lu.assertEquals(ob1.value, obj)
                lu.assertEquals(getmetatable(obj).__ob__, ob1)

                -- should be able to read
                lu.assertEquals(obj.a, 123)

                -- should return existing ob on already observed objects
                local ob2 = observe(obj)
                lu.assertEquals(ob2, ob1)

                -- since there is no setter, you shouldn't be able to write to it
                -- PhantomJS throws when a property with no setter is set
                -- but other real browsers don't
                xpcall(
                    function()
                        obj.a = 101
                    end,
                    function()
                        lu.assertEquals(obj.a, 123)
                    end
                )
            end
        )

        it(
            "create on property with only setter",
            function()
                -- on object
                local obj = createPlainObject()
                local val = 10
                defineProperty(
                    obj,
                    "a",
                    nil,
                    function(v)
                        val = v
                    end
                )

                local ob1 = observe(obj)
                lu.assertEquals(instanceof(ob1, Observer), true)
                lu.assertEquals(ob1.value, obj)
                lu.assertEquals(getmetatable(obj).__ob__, ob1)

                -- reads should return nil
                lu.assertEquals(obj.a, nil)

                -- should return existing ob on already observed objects
                local ob2 = observe(obj)
                lu.assertEquals(ob2, ob1)

                -- writes should call the set function
                obj.a = 100
                lu.assertEquals(val, 100)
            end
        )

        it(
            "create on property which is marked not configurable",
            function()
                -- on object
                local obj = createPlainObject()
                defineProperty(
                    obj,
                    "a",
                    function()
                        return 10
                    end
                )

                local ob1 = observe(obj)
                lu.assertEquals(instanceof(ob1, Observer), true)
                lu.assertEquals(ob1.value, obj)
                lu.assertEquals(getmetatable(obj).__ob__, ob1)
            end
        )

        it(
            "create on array",
            function()
                -- on object
                local arr = {{}, {}}
                local ob1 = observe(arr)
                lu.assertEquals(instanceof(ob1, Observer), true)
                lu.assertEquals(ob1.value, arr)
                lu.assertEquals(getmetatable(arr).__ob__, ob1)
                -- should've walked children
                lu.assertEquals(instanceof(getmetatable(arr[1]).__ob__, Observer), true)
                lu.assertEquals(instanceof(getmetatable(arr[2]).__ob__, Observer), true)
            end
        )

        it(
            "observing object prop change",
            function()
                local NaN = 0 / 0
                local obj = {a = {b = 2}, c = NaN}
                observe(obj)
                -- mock a watcher!
                local watcher = {
                    deps = {},
                    addDep = function(this, dep)
                        table.insert(this.deps, dep)
                        dep:addSub(this)
                    end,
                    update = lu.createSpy()
                }
                -- collect dep
                Dep.target = watcher
                local ab = obj.a.b
                Dep.target = nil
                lu.assertEquals(#watcher.deps, 3) -- obj.a + a + a.b
                obj.a.b = 3
                lu.assertEquals(#watcher.update.calls, 1)
                -- swap object
                obj.a = {b = 4}
                lu.assertEquals(#watcher.update.calls, 2)
                watcher.deps = {}

                Dep.target = watcher
                local ab = obj.a.b
                local c = obj.c
                Dep.target = nil
                lu.assertEquals(#watcher.deps, 4)
                -- set on the swapped object
                obj.a.b = 5
                lu.assertEquals(#watcher.update.calls, 3)
                -- should not trigger on NaN -> NaN set
                -- will trigger when nan
                obj.c = NaN
                lu.assertEquals(#watcher.update.calls, 4)
                obj.c = NaN
                lu.assertEquals(#watcher.update.calls, 5)
                obj.c = NaN
                lu.assertEquals(#watcher.update.calls, 6)
            end
        )

        it(
            "observing object prop change on defined property",
            function()
                local obj = createPlainObject()
                obj.val = 2
                defineProperty(
                    obj,
                    "a",
                    function()
                        return obj.val
                    end,
                    function(v)
                        obj.val = v
                        return obj.val
                    end
                )

                observe(obj)
                lu.assertEquals(obj.a, 2) -- Make sure 'this' is preserved
                obj.a = 3
                lu.assertEquals(obj.val, 3) -- make sure 'setter' was called
                obj.val = 5
                lu.assertEquals(obj.a, 5) -- make sure 'getter' was called
            end
        )

        it(
            "observing set/delete",
            function()
                local obj1 = {a = 1}
                local ob1 = observe(obj1)
                local dep1 = ob1.dep
                lu.spyOn(dep1, "notify")
                setProp(obj1, "b", 2)
                lu.assertEquals(obj1.b, 2)
                lu.assertEquals(#dep1.notify.calls, 1)
                delProp(obj1, "a")
                lu.assertEquals(hasOwn(obj1, "a"), false)
                lu.assertEquals(#dep1.notify.calls, 2)
                -- set existing key, should be a plain set and not
                -- trigger own ob's notify
                setProp(obj1, "b", 3)
                lu.assertEquals(obj1.b, 3)
                lu.assertEquals(#dep1.notify.calls, 2)
                -- set non-existing key
                setProp(obj1, "c", 1)
                lu.assertEquals(obj1.c, 1)
                lu.assertEquals(#dep1.notify.calls, 3)
                -- should ignore deleting non-existing key
                delProp(obj1, "a")
                lu.assertEquals(#dep1.notify.calls, 3)
                -- should work on non-observed objects
                local obj2 = {a = 1}
                delProp(obj2, "a")
                lu.assertEquals(hasOwn(obj2, "a"), false)
                -- should work on createObject(nil)
                local obj3 = createObject(nil)
                obj3.a = 1
                local ob3 = observe(obj3)
                local dep3 = ob3.dep
                lu.spyOn(dep3, "notify")
                setProp(obj3, "b", 2)
                lu.assertEquals(obj3.b, 2)
                lu.assertEquals(#dep3.notify.calls, 1)
                delProp(obj3, "a")
                lu.assertEquals(hasOwn(obj3, "a"), false)
                lu.assertEquals(#dep3.notify.calls, 2)
                -- set and delete non-numeric key on array
                local arr2 = {"a"}
                local ob2 = observe(arr2)
                local dep2 = ob2.dep
                lu.spyOn(dep2, "notify")
                setProp(arr2, "b", 2)
                lu.assertEquals(arr2.b, 2)
                lu.assertEquals(#dep2.notify.calls, 1)
                delProp(arr2, "b")
                lu.assertEquals(hasOwn(arr2, "b"), false)
                lu.assertEquals(#dep2.notify.calls, 2)
            end
        )

        --[[
        it(
            "warning set/delete on a Vue instance",
            function(done)
                local vm =
                    Vue.new(
                    {
                        template = "<div>{{aendend</div>",
                        data = {a = 1}
                    }
                )._mount()
                lu.assertEquals(vm._el.outerHTML, "<div>1</div>")
                Vue.set(vm, "a", 2)
                waitForUpdate(
                    function()
                        lu.assertEquals(vm._el.outerHTML, "<div>2</div>")
                        lu.assertEquals("Avoid adding reactive properties to a Vue instance").isnot.toHaveBeenWarned()
                        Vue.delete(vm, "a")
                    end
                ).thento(
                    function()
                        lu.assertEquals("Avoid deleting properties on a Vue instance").toHaveBeenWarned()
                        lu.assertEquals(vm._el.outerHTML, "<div>2</div>")
                        Vue.set(vm, "b", 123)
                        lu.assertEquals("Avoid adding reactive properties to a Vue instance").toHaveBeenWarned()
                    end
                ).thento(done)
            end
        )

        it(
            "warning set/delete on Vue instance root $data",
            function(done)
                local data = {a = 1}
                local vm =
                    Vue.new(
                    {
                        template = "<div>{{aendend</div>",
                        data = data
                    }
                )._mount()
                lu.assertEquals(vm._el.outerHTML, "<div>1</div>")
                lu.assertEquals(Vue.set(data, "a", 2), 2)
                waitForUpdate(
                    function()
                        lu.assertEquals(vm._el.outerHTML, "<div>2</div>")
                        lu.assertEquals("Avoid adding reactive properties to a Vue instance").isnot.toHaveBeenWarned()
                        Vue.delete(data, "a")
                    end
                ).thento(
                    function()
                        lu.assertEquals("Avoid deleting properties on a Vue instance").toHaveBeenWarned()
                        lu.assertEquals(vm._el.outerHTML, "<div>2</div>")
                        lu.assertEquals(Vue.set(data, "b", 123), 123)
                        lu.assertEquals("Avoid adding reactive properties to a Vue instance").toHaveBeenWarned()
                    end
                ).thento(done)
            end
        )]]

        it(
            "observing array mutation",
            function()
                local arr = {{}}
                local ob = observe(arr)
                local dep = ob.dep
                lu.spyOn(dep, "notify")
                local objs = {{}, {}, {}}

                local vm = {_watchers = {}}
                local watch = Watcher.new(vm, function()return arr[1] end, function(vm, value, old)
                    print("changed:" , vm , value, old)
                end)

                table.insert(arr, objs[1])
                table.remove(arr)
                table.insert(arr, 2, objs[2])
                table.insert(arr, 1, objs[3])
                table.insert(arr, 1, objs[3])
                lu.assertEquals(#dep.notify.calls, 4)
                -- inserted elements should be observed
                for _, obj in pairs(objs) do
                    lu.assertEquals(instanceof(getmetatable(obj).__ob__, Observer), true)
                end
            end
        )

        -- it(
        --     "warn set/delete on non valid values",
        --     function()
        --         -- try {
        --         setProp(nil, "foo", 1)
        --         -- end catch (e) {}
        --         lu.assertEquals("Cannot set reactive property on nil, nil, or primitive value").toHaveBeenWarned()

        --         -- try {
        --         delProp(nil, "foo")
        --         -- end catch (e) {}
        --         lu.assertEquals("Cannot delete reactive property on nil, nil, or primitive value").toHaveBeenWarned()
        --     end
        -- )

        it(
            "should lazy invoke existing getters",
            function()
                local obj = createPlainObject()
                local called = 0
                defineProperty(
                    obj,
                    "getterProp",
                    function()
                        called = called + 1
                        return "some value"
                    end
                )
                observe(obj)
                lu.assertEquals(called, 1)
            end
        )
    end
)
