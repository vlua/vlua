local lu = require("test.luaunit")
local Effect = require("reactivity.effect")
local track, trigger, ITERATE_KEY, effect,stop = Effect.track, Effect.trigger, Effect.ITERATE_KEY, Effect.effect, Effect.stop

local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")

local Reactive = require("reactivity.reactive")
local computed = require("reactivity.computed").computed
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local reactive,markRaw = Reactive.reactive, Reactive.markRaw
local Ref = require("reactivity.ref")(Reactive)
local ref = Ref.ref

describe(
    "reactivity/effect",
    function()
        it(
            "should run the passed function once (wrapped by a effect)",
            function()
                local fnSpy =
                    lu.createSpy(
                    function()
                    end
                )
                effect(fnSpy)
                lu.assertEquals(#fnSpy.calls, 1)
            end
        )
        it(
            "should observe basic properties",
            function()
                local dummy = nil
                local counter = reactive({num = 0})
                effect(
                    function()
                        dummy = counter.num
                    end
                )
                lu.assertEquals(dummy, 0)
                counter.num = 7
                lu.assertEquals(dummy, 7)
            end
        )
        it(
            "should observe multiple properties",
            function()
                local dummy = nil
                local counter = reactive({num1 = 0, num2 = 0})
                effect(
                    function()
                        dummy = counter.num1 + counter.num1 + counter.num2
                    end
                )
                lu.assertEquals(dummy, 0)
                counter.num2 = 7
                counter.num1 = counter.num2
                lu.assertEquals(dummy, 21)
            end
        )
        it(
            "should handle multiple effects",
            function()
                local dummy1 = nil
                local dummy2 = nil
                local counter = reactive({num = 0})
                effect(
                    function()
                        dummy1 = counter.num
                    end
                )
                effect(
                    function()
                        dummy2 = counter.num
                    end
                )
                lu.assertEquals(dummy1, 0)
                lu.assertEquals(dummy2, 0)
                counter.num = counter.num + 1
                lu.assertEquals(dummy1, 1)
                lu.assertEquals(dummy2, 1)
            end
        )
        it(
            "should observe nested properties",
            function()
                local dummy = nil
                local counter = reactive({nested = {num = 0}})
                effect(
                    function()
                        dummy = counter.nested.num
                    end
                )
                lu.assertEquals(dummy, 0)
                counter.nested.num = 8
                lu.assertEquals(dummy, 8)
            end
        )
        it(
            "should observe delete operations",
            function()
                local dummy = nil
                local obj = reactive({prop = "value"})
                effect(
                    function()
                        dummy = obj.prop
                    end
                )
                lu.assertEquals(dummy, "value")
                obj.prop = nil
                lu.assertEquals(dummy, nil)
            end
        )
        it(
            "should observe has operations",
            function()
                local dummy = nil
                local obj = reactive({prop = "value"})
                effect(
                    function()
                        dummy = obj["prop"] ~= nil
                    end
                )
                lu.assertEquals(dummy, true)
                obj.prop = nil
                lu.assertEquals(dummy, false)
                obj.prop = 12
                lu.assertEquals(dummy, true)
            end
        )
        --   it('should observe properties on the prototype chain', function()
        --     local dummy = nil
        --     local counter = reactive({num=0})
        --     local parentCounter = reactive({num=2})

        --     setmetatable(toRaw(counter), {__index = function(self, key)
        --       return parentCounter[key]
        --     end})

        --     -- Object:setPrototypeOf(counter, parentCounter)
        --     effect(function()
        --       dummy = counter.num
        --     end
        --     )
        --     lu.assertEquals(dummy, 0)
        --     counter.num = nil
        --     lu.assertEquals(dummy, 2)
        --     parentCounter.num = 4
        --     lu.assertEquals(dummy, 4)
        --     counter.num = 3
        --     lu.assertEquals(dummy, 3)
        --   end
        --   )
        --   it('should observe has operations on the prototype chain', function()
        --     local dummy = nil
        --     local counter = reactive({num=0})
        --     local parentCounter = reactive({num=2})
        --     Object:setPrototypeOf(counter, parentCounter)
        --     effect(function()
        --       dummy = counter['num']
        --     end
        --     )
        --     lu.assertEquals(dummy, true)
        --     counter.num = nil
        --     lu.assertEquals(dummy, true)
        --     parentCounter.num = nil
        --     lu.assertEquals(dummy, false)
        --     counter.num = 3
        --     lu.assertEquals(dummy, true)
        --   end
        --   )
        --   it('should observe inherited property accessors', function()
        --     local dummy = nil
        --     local parentDummy = nil
        --     local hiddenValue = nil
        --     local obj = reactive({})
        --     local parent = reactive({prop=function(value)
        --       hiddenValue = value
        --     end
        --     , prop=function()
        --       return hiddenValue
        --     end
        --     })
        --     Object:setPrototypeOf(obj, parent)
        --     effect(function()
        --       dummy = obj.prop
        --     end
        --     )
        --     effect(function()
        --       parentDummy = parent.prop
        --     end
        --     )
        --     lu.assertEquals(dummy, nil)
        --     lu.assertEquals(parentDummy, nil)
        --     obj.prop = 4
        --     lu.assertEquals(dummy, 4)
        --     parent.prop = 2
        --     lu.assertEquals(dummy, 2)
        --     lu.assertEquals(parentDummy, 2)
        --   end
        --   )
        it(
            "should observe function call chains",
            function()
                local dummy = nil
                local counter = reactive({num = 0})

                local function getNum()
                    return counter.num
                end
                effect(
                    function()
                        dummy = getNum()
                    end
                )

                lu.assertEquals(dummy, 0)
                counter.num = 2
                lu.assertEquals(dummy, 2)
            end
        )
        it(
            "should observe iteration",
            function()
                local dummy = nil
                local list = reactive({"Hello"})
                effect(
                    function()
                        dummy = table.concat(list, " ")
                    end
                )
                lu.assertEquals(dummy, "Hello")
                table.insert(list, "World!")
                lu.assertEquals(dummy, "Hello World!")
                table.remove(list, 1)
                lu.assertEquals(dummy, "World!")
            end
        )
        it(
            "should observe implicit array length changes",
            function()
                local dummy = nil
                local list = reactive({"Hello"})
                effect(
                    function()
                        dummy = table.concat(list, " ")
                    end
                )
                lu.assertEquals(dummy, "Hello")
                list[2] = "World!"
                lu.assertEquals(dummy, "Hello World!")
                list[3] = "Hello!"
                lu.assertEquals(dummy, "Hello World! Hello!")
            end
        )
        it(
            "should observe sparse array mutations",
            function()
                local dummy = nil
                local list = reactive({})
                list[1] = "World!"
                effect(
                    function()
                        dummy = table.concat(list, " ")
                    end
                )
                lu.assertEquals(dummy, "World!")
                list[2] = "Hello"
                lu.assertEquals(dummy, "World! Hello")
                table.remove(list)
                lu.assertEquals(dummy, "World!")
            end
        )
        it(
            "should observe enumeration",
            function()
                local dummy = 0
                local numbers = reactive({num1 = 3})
                effect(
                    function()
                        dummy = 0
                        for key in pairs(numbers) do
                            -- [ts2lua]numbers下标访问可能不正确
                            dummy = dummy + numbers[key]
                        end
                    end
                )
                lu.assertEquals(dummy, 3)
                numbers.num2 = 4
                lu.assertEquals(dummy, 7)
                numbers.num1 = nil
                lu.assertEquals(dummy, 4)
            end
        )
        it(
            "should observe symbol keyed properties",
            function()
                local key = {"symbol keyed prop"}
                local dummy = nil
                local hasDummy = nil
                local obj = reactive({[key] = "value"})
                effect(
                    function()
                        -- [ts2lua]obj下标访问可能不正确
                        dummy = obj[key]
                    end
                )
                effect(
                    function()
                        hasDummy = obj[key] ~= nil
                    end
                )
                lu.assertEquals(dummy, "value")
                lu.assertEquals(hasDummy, true)
                -- [ts2lua]obj下标访问可能不正确
                obj[key] = "newValue"
                lu.assertEquals(dummy, "newValue")
                -- [ts2lua]obj下标访问可能不正确
                obj[key] = nil
                lu.assertEquals(dummy, nil)
                lu.assertEquals(hasDummy, false)
            end
        )
        it(
            "should not observe well-known symbol keyed properties",
            function()
                local key = {"isConcatSpreadable"}
                local dummy = nil
                local array = reactive({})
                effect(
                    function()
                        -- [ts2lua]array下标访问可能不正确
                        dummy = array[key]
                    end
                )
                -- [ts2lua]array下标访问可能不正确
                lu.assertEquals(array[key], nil)
                lu.assertEquals(dummy, nil)
                -- [ts2lua]array下标访问可能不正确
                array[key] = true
                -- [ts2lua]array下标访问可能不正确
                lu.assertEquals(array[key], true)
                lu.assertEquals(dummy, true)
            end
        )
        it(
            "should observe function valued properties",
            function()
                local oldFunc = function()
                    return 1
                end

                local newFunc = function()
                    return 2
                end

                local dummy = nil
                local obj = reactive({func = oldFunc})
                effect(
                    function()
                        dummy = obj.func
                    end
                )
                lu.assertEquals(dummy, oldFunc)
                obj.func = newFunc
                lu.assertEquals(dummy, newFunc)
            end
        )
        it(
            "should observe chained getters relying on this",
            function()
                local obj =
                    reactive(
                    {
                        a = 1,
                        b = computed(
                            function(self)
                                return self.a
                            end
                        )
                    }
                )
                local dummy = nil
                local ef =
                    effect(
                    function()
                        dummy = obj.b
                    end
                )
                lu.assertEquals(dummy, 1)
                obj.a = obj.a + 1
                lu.assertEquals(dummy, 2)
            end
        )
        it(
            "should observe methods relying on this",
            function()
                local obj =
                    reactive(
                    {
                        a = 1,
                        b = function(self)
                            return self.a
                        end
                    }
                )
                local dummy = nil
                effect(
                    function()
                        dummy = obj:b()
                    end
                )
                lu.assertEquals(dummy, 1)
                obj.a = obj.a + 1
                lu.assertEquals(dummy, 2)
            end
        )
        it(
            "should not observe set operations without a value change",
            function()
                local hasDummy = nil
                local getDummy = nil
                local obj = reactive({prop = "value"})
                local getSpy =
                    lu.createSpy(
                    function()
                        getDummy = obj.prop
                    end
                )
                local hasSpy =
                    lu.createSpy(
                    function()
                        hasDummy = obj["prop"] ~= nil
                    end
                )
                effect(getSpy)
                effect(hasSpy)
                lu.assertEquals(getDummy, "value")
                lu.assertEquals(hasDummy, true)
                obj.prop = "value"
                getSpy.toHaveBeenCalledTimes(1)
                hasSpy.toHaveBeenCalledTimes(1)
                lu.assertEquals(getDummy, "value")
                lu.assertEquals(hasDummy, true)
            end
        )
        -- it(
        --     "should not observe raw mutations",
        --     function()
        --         local dummy = nil
        --         local obj = reactive({})
        --         effect(
        --             function()
        --                 dummy = toRaw(obj).prop
        --             end
        --         )
        --         lu.assertEquals(dummy, nil)
        --         obj.prop = "value"
        --         lu.assertEquals(dummy, nil)
        --     end
        -- )
        -- it(
        --     "should not be triggered by raw mutations",
        --     function()
        --         local dummy = nil
        --         local obj = reactive({})
        --         effect(
        --             function()
        --                 dummy = obj.prop
        --             end
        --         )
        --         lu.assertEquals(dummy, nil)
        --         toRaw(obj).prop = "value"
        --         lu.assertEquals(dummy, nil)
        --     end
        -- )
        -- it(
        --     "should not be triggered by inherited raw setters",
        --     function()
        --         local dummy = nil
        --         local parentDummy = nil
        --         local hiddenValue = nil
        --         local obj = reactive({})
        --         local parent =
        --             reactive(
        --             {
        --                 prop = function(value)
        --                     hiddenValue = value
        --                 end,
        --                 prop = function()
        --                     return hiddenValue
        --                 end
        --             }
        --         )
        --         Object:setPrototypeOf(obj, parent)
        --         effect(
        --             function()
        --                 dummy = obj.prop
        --             end
        --         )
        --         effect(
        --             function()
        --                 parentDummy = parent.prop
        --             end
        --         )
        --         lu.assertEquals(dummy, nil)
        --         lu.assertEquals(parentDummy, nil)
        --         toRaw(obj).prop = 4
        --         lu.assertEquals(dummy, nil)
        --         lu.assertEquals(parentDummy, nil)
        --     end
        -- )
        it(
            "should avoid implicit infinite recursive loops with itself",
            function()
                local counter = reactive({num = 0})
                local counterSpy =
                    lu.createSpy(
                    function()
                        counter.num = counter.num + 1
                    end
                )
                effect(counterSpy)
                lu.assertEquals(counter.num, 1)
                counterSpy.toHaveBeenCalledTimes(1)
                counter.num = 4
                lu.assertEquals(counter.num, 5)
                counterSpy.toHaveBeenCalledTimes(2)
            end
        )
        it(
            "should allow explicitly recursive raw function loops",
            function()
                local counter = reactive({num = 0})
                local numSpy
                numSpy =
                    lu.createSpy(
                    function()
                        counter.num = counter.num + 1
                        if counter.num < 10 then
                            numSpy()
                        end
                    end
                )
                effect(numSpy)
                lu.assertEquals(counter.num, 10)
                numSpy.toHaveBeenCalledTimes(10)
            end
        )
        it(
            "should avoid infinite loops with other effects",
            function()
                local nums = reactive({num1 = 0, num2 = 1})
                local spy1 =
                    lu.createSpy(
                    function()
                        nums.num1 = nums.num2
                    end
                )
                local spy2 =
                    lu.createSpy(
                    function()
                        nums.num2 = nums.num1
                    end
                )
                effect(spy1)
                effect(spy2)
                lu.assertEquals(nums.num1, 1)
                lu.assertEquals(nums.num2, 1)
                spy1.toHaveBeenCalledTimes(1)
                spy2.toHaveBeenCalledTimes(1)
                nums.num2 = 4
                lu.assertEquals(nums.num1, 4)
                lu.assertEquals(nums.num2, 4)
                spy1.toHaveBeenCalledTimes(2)
                spy2.toHaveBeenCalledTimes(2)
                nums.num1 = 10
                lu.assertEquals(nums.num1, 10)
                lu.assertEquals(nums.num2, 10)
                spy1.toHaveBeenCalledTimes(3)
                spy2.toHaveBeenCalledTimes(3)
            end
        )
        it(
            "should return a new reactive version of the function",
            function()
                local function greet()
                    return "Hello World"
                end

                local effect1 = effect(greet)
                local effect2 = effect(greet)
                lu.assertEquals(type(effect1), "table")
                lu.assertEquals(type(effect2), "table")
                lu.assertNotEquals(effect1, greet)
                lu.assertNotEquals(effect1, effect2)
            end
        )
        it(
            "should discover new branches while running automatically",
            function()
                local dummy = nil
                local obj = reactive({prop = "value", run = false})
                local conditionalSpy =
                    lu.createSpy(
                    function()
                        -- [ts2lua]lua中0和空字符串也是true，此处obj.run需要确认
                        dummy = (obj.run and {obj.prop} or {"other"})[1]
                    end
                )
                effect(conditionalSpy)
                lu.assertEquals(dummy, "other")
                conditionalSpy.toHaveBeenCalledTimes(1)
                obj.prop = "Hi"
                lu.assertEquals(dummy, "other")
                conditionalSpy.toHaveBeenCalledTimes(1)
                obj.run = true
                lu.assertEquals(dummy, "Hi")
                conditionalSpy.toHaveBeenCalledTimes(2)
                obj.prop = "World"
                lu.assertEquals(dummy, "World")
                conditionalSpy.toHaveBeenCalledTimes(3)
            end
        )
        it(
            "should discover new branches when running manually",
            function()
                local dummy = nil
                local run = false
                local obj = reactive({prop = "value"})
                local runner =
                    effect(
                    function()
                        -- [ts2lua]lua中0和空字符串也是true，此处run需要确认
                        dummy = (run and {obj.prop} or {"other"})[1]
                    end
                )
                lu.assertEquals(dummy, "other")
                runner()
                lu.assertEquals(dummy, "other")
                run = true
                runner()
                lu.assertEquals(dummy, "value")
                obj.prop = "World"
                lu.assertEquals(dummy, "World")
            end
        )
        it(
            "should not be triggered by mutating a property, which is used in an inactive branch",
            function()
                local dummy = nil
                local obj = reactive({prop = "value", run = true})
                local conditionalSpy =
                    lu.createSpy(
                    function()
                        -- [ts2lua]lua中0和空字符串也是true，此处obj.run需要确认
                        dummy = (obj.run and {obj.prop} or {"other"})[1]
                    end
                )
                effect(conditionalSpy)
                lu.assertEquals(dummy, "value")
                conditionalSpy.toHaveBeenCalledTimes(1)
                obj.run = false
                lu.assertEquals(dummy, "other")
                conditionalSpy.toHaveBeenCalledTimes(2)
                obj.prop = "value2"
                lu.assertEquals(dummy, "other")
                conditionalSpy.toHaveBeenCalledTimes(2)
            end
        )
        it(
            "should not double wrap if the passed function is a effect",
            function()
                local runner =
                    effect(
                    function()
                    end
                )
                local otherRunner = effect(runner)
                lu.assertNotEquals(runner, otherRunner)
                lu.assertEquals(runner.raw, otherRunner.raw)
            end
        )
        it(
            "should not run multiple times for a single mutation",
            function()
                local dummy = nil
                local obj = reactive({})
                local fnSpy =
                    lu.createSpy(
                    function()
                        for key in pairs(obj) do
                            -- [ts2lua]obj下标访问可能不正确
                            dummy = obj[key]
                        end
                        dummy = obj.prop
                    end
                )
                effect(fnSpy)
                fnSpy.toHaveBeenCalledTimes(1)
                obj.prop = 16
                lu.assertEquals(dummy, 16)
                fnSpy.toHaveBeenCalledTimes(2)
            end
        )
        it(
            "should allow nested effects",
            function()
                local nums = reactive({num1 = 0, num2 = 1, num3 = 2})
                local dummy = {}
                local childSpy =
                    lu.createSpy(
                    function()
                        dummy.num1 = nums.num1
                    end
                )
                local childeffect = effect(childSpy)
                local parentSpy =
                    lu.createSpy(
                    function()
                        dummy.num2 = nums.num2
                        childeffect()
                        dummy.num3 = nums.num3
                    end
                )
                effect(parentSpy)
                lu.assertEquals(dummy, {num1 = 0, num2 = 1, num3 = 2})
                parentSpy.toHaveBeenCalledTimes(1)
                childSpy.toHaveBeenCalledTimes(2)
                nums.num1 = 4
                lu.assertEquals(dummy, {num1 = 4, num2 = 1, num3 = 2})
                parentSpy.toHaveBeenCalledTimes(1)
                childSpy.toHaveBeenCalledTimes(3)
                nums.num2 = 10
                lu.assertEquals(dummy, {num1 = 4, num2 = 10, num3 = 2})
                parentSpy.toHaveBeenCalledTimes(2)
                childSpy.toHaveBeenCalledTimes(4)
                nums.num3 = 7
                lu.assertEquals(dummy, {num1 = 4, num2 = 10, num3 = 7})
                parentSpy.toHaveBeenCalledTimes(3)
                childSpy.toHaveBeenCalledTimes(5)
            end
        )
        -- it(
        --     "should observe json methods",
        --     function()
        --         local dummy = {}
        --         local obj = reactive({})
        --         effect(
        --             function()
        --                 dummy = JSON:parse(JSON:stringify(obj))
        --             end
        --         )
        --         obj.a = 1
        --         lu.assertEquals(dummy.a, 1)
        --     end
        -- )
        it(
            "should observe class method invocations",
            function()
                local Model = {name = "Model"}

                function Model:__new__()
                    self.count = 0
                end

                function Model:inc()
                    self.count = self.count + 1
                end

                Model:__new__()

                local model = reactive(Model)
                local dummy = nil
                effect(
                    function()
                        dummy = model.count
                    end
                )
                lu.assertEquals(dummy, 0)
                model:inc()
                lu.assertEquals(dummy, 1)
            end
        )
        it(
            "lazy",
            function()
                local obj = reactive({foo = 1})
                local dummy = nil
                local runner =
                    effect(
                    function()
                        dummy = obj.foo
                        return dummy
                    end,
                    {lazy = true}
                )
                lu.assertEquals(dummy, nil)
                lu.assertEquals(runner(), 1)
                lu.assertEquals(dummy, 1)
                obj.foo = 2
                lu.assertEquals(dummy, 2)
            end
        )
        it(
            "scheduler",
            function()
                local runner = nil
                local dummy = nil
                local scheduler =
                    lu.createSpy(
                    function(_runner)
                        runner = _runner
                    end
                )
                local obj = reactive({foo = 1})
                effect(
                    function()
                        dummy = obj.foo
                    end,
                    {scheduler = scheduler}
                )
                scheduler.toHaventBeenCalled()
                lu.assertEquals(dummy, 1)
                obj.foo = obj.foo + 1
                scheduler.toHaveBeenCalledTimes(1)
                lu.assertEquals(dummy, 1)
                runner()
                lu.assertEquals(dummy, 2)
            end
        )
        it(
            "events: onTrack",
            function()
                local events = {}
                local dummy = nil
                local onTrack =
                    lu.createSpy(
                    function(...)
                        table.insert(events, {...})
                    end
                )
                local obj = reactive({foo = 1, bar = 2})
                local runner =
                    effect(
                    function()
                        dummy = obj.foo
                        dummy = obj["bar"] ~= nil

                        dummy = {}
                        for k, v in pairs(obj) do
                            table.insert(dummy, k)
                        end
                    end,
                    {onTrack = onTrack}
                )
                lu.assertTableContains(dummy, "foo")
                lu.assertTableContains(dummy, "bar")
                onTrack.toHaveBeenCalledTimes(3)
                lu.assertEquals(
                    events,
                    {
                        {runner, obj, TrackOpTypes.GET, "foo"},
                        {runner, obj, TrackOpTypes.GET, "bar"},
                        {runner, obj, TrackOpTypes.ITERATE, ITERATE_KEY}
                    }
                )
            end
        )
        it(
            "events: onTrigger",
            function()
                local events = {}
                local dummy = nil
                local onTrigger =
                    lu.createSpy(
                    function(...)
                        table.insert(events, {...})
                    end
                )
                local obj = reactive({foo = 1})
                local runner =
                    effect(
                    function()
                        dummy = obj.foo
                    end,
                    {onTrigger = onTrigger}
                )
                obj.foo = obj.foo + 1
                lu.assertEquals(dummy, 2)
                onTrigger.toHaveBeenCalledTimes(1)
                lu.assertEquals(
                    events[0 + 1],
                    {
                         runner,
                         obj,
                         TriggerOpTypes.SET,
                         "foo",
                         2,
                         1
                    }
                )
                obj.foo = nil
                lu.assertEquals(dummy, nil)
                onTrigger.toHaveBeenCalledTimes(2)
                lu.assertEquals(
                    events[1 + 1],
                    { runner,  obj,  TriggerOpTypes.DELETE,  "foo", nil, 2}
                )
            end
        )
        it(
            "stop",
            function()
                local dummy = nil
                local obj = reactive({prop = 1})
                local runner =
                    effect(
                    function()
                        dummy = obj.prop
                    end
                )
                obj.prop = 2
                lu.assertEquals(dummy, 2)
                stop(runner)
                obj.prop = 3
                lu.assertEquals(dummy, 2)
                runner()
                lu.assertEquals(dummy, 3)
            end
        )
        it(
            "stop with scheduler",
            function()
                local dummy = nil
                local obj = reactive({prop = 1})
                local queue = {}
                local runner =
                    effect(
                    function()
                        dummy = obj.prop
                    end,
                    {
                        scheduler = function(e)
                            table.insert(queue, e)
                        end
                    }
                )
                obj.prop = 2
                lu.assertEquals(dummy, 1)
                lu.assertEquals(#queue, 1)
                stop(runner)
                for _, e in ipairs(queue) do
                        e()
                    end
                lu.assertEquals(dummy, 1)
            end
        )
        it(
            "events: onStop",
            function()
                local onStop = lu.createSpy()
                local runner =
                    effect(
                    function()
                    end,
                    {onStop = onStop}
                )
                stop(runner)
                onStop.toHaveBeenCalled()
            end
        )
        it(
            "stop: a stopped effect is nested in a normal effect",
            function()
                local dummy = nil
                local obj = reactive({prop = 1})
                local runner =
                    effect(
                    function()
                        dummy = obj.prop
                    end
                )
                stop(runner)
                obj.prop = 2
                lu.assertEquals(dummy, 1)
                effect(
                    function()
                        runner()
                    end
                )
                lu.assertEquals(dummy, 2)
                obj.prop = 3
                lu.assertEquals(dummy, 3)
            end
        )
        it(
            "markRaw",
            function()
                local obj = reactive({foo = markRaw({prop = 0})})
                local dummy = nil
                effect(
                    function()
                        dummy = obj.foo.prop
                    end
                )
                lu.assertEquals(dummy, 0)
                obj.foo.prop = obj.foo.prop + 1
                lu.assertEquals(dummy, 0)
                obj.foo = {prop = 1}
                lu.assertEquals(dummy, 1)
            end
        )
        it(
            "should not be trigger when the value and the old value both are NaN",
            function()
                local obj = reactive({foo = 0/0})
                local fnSpy =
                    lu.createSpy(
                    function()
                        return obj.foo
                    end
                )
                effect(fnSpy)
                obj.foo = 0/0
                fnSpy.toHaveBeenCalledTimes(2)
            end
        )
        it(
            "should trigger all effects when array length is set 0",
            function()
                local observed = reactive({1})
                local dummy = nil
                local record = nil
                effect(
                    function()
                        
                        dummy = #observed
                    end
                )
                effect(
                    function()
                        record = observed[1]
                    end
                )
                lu.assertEquals(dummy, 1)
                lu.assertEquals(record, 1)
                observed[1 + 1] = 2
                lu.assertEquals(observed[1 + 1], 2)
                table.insert(observed, 1, 3)
                lu.assertEquals(dummy, 3)
                lu.assertEquals(record, 3)
                
				for i,v in pairs(observed) do
					observed[i] = nil
				end
				lu.assertEquals(dummy, 0)
				lu.assertIsNil(record)
            end
        )
        it(
            "should handle self dependency mutations",
            function()
                local count = ref(0)
                effect(
                    function()
                        count.value = count.value + 1
                    end
                )
                lu.assertEquals(count.value, 1)
                count.value = 10
                lu.assertEquals(count.value, 11)
            end
        )
    end
)
