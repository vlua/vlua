local lu = require("test.luaunit")
local Effect = require("reactivity.effect")
local track, trigger, ITERATE_KEY, effect, stop =
    Effect.track,
    Effect.trigger,
    Effect.ITERATE_KEY,
    Effect.effect,
    Effect.stop

local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")

local Reactive = require("reactivity.reactive")
local computed = require("reactivity.computed").computed
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local reactive, markRaw, isReactive, readonly, isReadonly, shallowReadonly, isShallow, shallowReactive =
    Reactive.reactive,
    Reactive.markRaw,
    Reactive.isReactive,
    Reactive.readonly,
    Reactive.isReadonly,
    Reactive.shallowReadonly,
    Reactive.isShallow,
    Reactive.shallowReactive

local Ref = require("reactivity.ref")(Reactive)
local ref, isRef, unref, shallowRef, triggerRef, customRef, toRef, toRefs =
    Ref.ref,
    Ref.isRef,
    Ref.unref,
    Ref.shallowRef,
    Ref.triggerRef,
    Ref.customRef,
    Ref.toRef,
    Ref.toRefs

local Scheduler = require("reactivity.scheduler")
local NextTick = require("reactivity.nextTick")
local flushCallbacks, nextTick = NextTick.flushCallbacks, NextTick.nextTick

local queueJob, invalidateJob, queuePostFlushCb =
    Scheduler.queueJob,
    Scheduler.invalidateJob,
    Scheduler.queuePostFlushCb

local ApiWatch = require("reactivity.apiWatch")
local watch, watchEffect = ApiWatch.watch, ApiWatch.watchEffect

describe(
    "api: watch",
    function()
        it(
            "effect",
            function()
                local state = reactive({count = 0})
                local dummy = nil
                watchEffect(
                    function()
                        dummy = state.count
                    end
                )
                lu.assertEquals(dummy, 0)
                state.count = state.count + 1
                waitForUpdate()
                lu.assertEquals(dummy, 1)
            end
        )
        it(
            "watching single source: getter",
            function()
                local state = reactive({count = 0})
                local dummy = nil
                watch(
                    function()
                        return state.count
                    end,
                    function(instance, count, prevCount)
                        dummy = {count, prevCount}
                        local a = count + 1
                        if prevCount then
                            return prevCount + 1
                        end
                    end
                )
                state.count = state.count + 1
                waitForUpdate()
                lu.assertEquals(dummy, {1, 0})
            end
        )
        it(
            "watching single source: ref",
            function()
                local count = ref(0)
                local dummy = nil
                watch(
                    count,
                    function(instance, count, prevCount)
                        dummy = {count, prevCount}
                        local a = count + 1
                        if prevCount then
                            return prevCount + 1
                        end
                    end
                )
                count.value = count.value + 1
                waitForUpdate()
                lu.assertEquals(dummy, {1, 0})
            end
        )
        it(
            "watching single source: computed ref",
            function()
                local count = ref(0)
                local plus =
                    computed(
                    function()
                        return count.value + 1
                    end
                )
                local dummy = nil
                watch(
                    plus,
                    function(instance, count, prevCount)
                        dummy = {count, prevCount}
                        local a = count + 1
                        if prevCount then
                            return prevCount + 1
                        end
                    end
                )
                count.value = count.value + 1
                waitForUpdate()
                lu.assertEquals(dummy, {2, 1})
            end
        )
        it(
            "watching primitive with deep: true",
            function()
                local count = ref(0)
                local dummy = nil
                watch(
                    count,
                    function(instance, c, prevCount)
                        dummy = {c, prevCount}
                    end,
                    {deep = true}
                )
                count.value = count.value + 1
                waitForUpdate()
                lu.assertEquals(dummy, {1, 0})
            end
        )
        it(
            "directly watching reactive object (with automatic deep: true)",
            function()
                local src = reactive({count = 0})
                local dummy = nil
                watch(
                    src,
                    function(instance, s)
                        dummy = s.count
                    end
                )
                src.count = src.count + 1
                waitForUpdate()
                lu.assertEquals(dummy, 1)
            end
        )
        it(
            "watching multiple sources",
            function()
                local state = reactive({count = 1})
                local count = ref(1)
                local plus =
                    computed(
                    function()
                        return count.value + 1
                    end
                )
                local dummy = nil
                watch(
                    {
                        function()
                            return state.count
                        end,
                        count,
                        plus
                    },
                    function(instance, vals, oldVals)
                        dummy = {vals, oldVals}
                        -- table.merge(vals, 1)
                        -- table.merge(oldVals, 1)
                    end
                )
                state.count = state.count + 1
                count.value = count.value + 1
                waitForUpdate()
                lu.assertEquals(dummy, {{2, 2, 3}, {1, 1, 2}})
            end
        )
        it(
            "watching multiple sources: readonly array",
            function()
                local state = reactive({count = 1})
                local status = ref(false)
                local dummy = nil
                watch(
                    {
                        function()
                            return state.count
                        end,
                        status
                    },
                    function(instance, vals, oldVals)
                        dummy = {vals, oldVals}
                        local a = vals
                        local b = oldVals
                    end
                )
                state.count = state.count + 1
                status.value = true
                waitForUpdate()
                lu.assertEquals(dummy, {{2, true}, {1, false}})
            end
        )
        it(
            "watching multiple sources: reactive object (with automatic deep: true)",
            function()
                local src = reactive({count = 0})
                local dummy = nil
                watch(
                    {src},
                    function(instance, state)
                        dummy = state[1]
                        return dummy.count == 1
                    end
                )
                src.count = src.count + 1
                waitForUpdate()
                lu.assertEquals(dummy, {count = 1})
            end
        )
        it(
            "warn invalid watch source",
            function()
                watch(
                    1,
                    function()
                    end
                )
                lu.toHaveBeenWarned("Invalid watch source")
            end
        )
        it(
            "warn invalid watch source: multiple sources",
            function()
                watch(
                    {1},
                    function()
                    end
                )
                lu.toHaveBeenWarned("Invalid watch source")
            end
        )
        it(
            "stopping the watcher (effect)",
            function()
                local state = reactive({count = 0})
                local dummy = nil
                local stop =
                    watchEffect(
                    function()
                        dummy = state.count
                    end
                )
                lu.assertEquals(dummy, 0)
                stop()
                state.count = state.count + 1
                lu.assertEquals(dummy, 0)
            end
        )
        it(
            "stopping the watcher (with source)",
            function()
                local state = reactive({count = 0})
                local dummy = nil
                local stop =
                    watch(
                    function()
                        return state.count
                    end,
                    function(instance, count)
                        dummy = count
                    end
                )
                state.count = state.count + 1
                waitForUpdate()
                lu.assertEquals(dummy, 1)
                waitForUpdate()
                stop()
                waitForUpdate()
                state.count = state.count + 1
                waitForUpdate()
                lu.assertEquals(dummy, 1)
            end
        )
        it(
            "cleanup registration (effect)",
            function()
                local state = reactive({count = 0})
                local cleanup = lu.createSpy("")
                local dummy = nil
                local stop =
                    watchEffect(
                    function(instance, onCleanup)
                        onCleanup(cleanup)
                        dummy = state.count
                    end
                )
                lu.assertEquals(dummy, 0)
                state.count = state.count + 1
                waitForUpdate()
                cleanup.toHaveBeenCalledTimes(1)
                waitForUpdate()
                lu.assertEquals(dummy, 1)
                waitForUpdate()
                stop()
                waitForUpdate()
                cleanup.toHaveBeenCalledTimes(2)
            end
        )
        it(
            "cleanup registration (with source)",
            function()
                local count = ref(0)
                local cleanup = lu.createSpy("")
                local dummy = nil
                local stop =
                    watch(
                    count,
                    function(instance, count, prevCount, onCleanup)
                        onCleanup(cleanup)
                        dummy = count
                    end
                )
                count.value = count.value + 1
                waitForUpdate()
                cleanup.toHaveBeenCalledTimes(0)
                waitForUpdate()
                lu.assertEquals(dummy, 1)
                waitForUpdate()
                count.value = count.value + 1
                waitForUpdate()
                cleanup.toHaveBeenCalledTimes(1)
                waitForUpdate()
                lu.assertEquals(dummy, 2)
                waitForUpdate()
                stop()
                waitForUpdate()
                cleanup.toHaveBeenCalledTimes(2)
            end
        )
        -- it(
        --     "flush timing: post (default)",
        --     function()
        --         local count = ref(0)
        --         local callCount = 0
        --         local assertion =
        --             lu.createSpy(
        --             function(count)
        --                 callCount = callCount + 1
        --                 -- [ts2lua]lua中0和空字符串也是true，此处callCount == 1需要确认
        --                 local expectedDOM = (callCount == 1 and {} or {})[1]
        --                 lu.assertEquals(serializeInner(root), expectedDOM)
        --             end
        --         )
        --         local Comp = {
        --             setup = function()
        --                 watchEffect(
        --                     function()
        --                         assertion(count.value)
        --                     end
        --                 )
        --                 return function()
        --                     return count.value
        --                 end
        --             end
        --         }
        --         local root = nodeOps:createElement("div")
        --         render(h(Comp), root)
        --         expect(assertion):toHaveBeenCalledTimes(1)
        --         count.value = count.value + 1
        --         expect(assertion):toHaveBeenCalledTimes(2)
        --     end
        -- )
        -- it(
        --     "flush timing: pre",
        --     function()
        --         local count = ref(0)
        --         local count2 = ref(0)
        --         local callCount = 0
        --         local assertion =
        --             jest:fn(
        --             function(count, count2Value)
        --                 callCount = callCount + 1
        --                 -- [ts2lua]lua中0和空字符串也是true，此处callCount == 1需要确认
        --                 local expectedDOM = (callCount == 1 and {} or {})[1]
        --                 lu.assertEquals(serializeInner(root), expectedDOM)
        --                 -- [ts2lua]lua中0和空字符串也是true，此处callCount == 1需要确认
        --                 local expectedState = (callCount == 1 and {0} or {1})[1]
        --                 lu.assertEquals(count2Value, expectedState)
        --             end
        --         )
        --         local Comp = {
        --             setup = function()
        --                 watchEffect(
        --                     function()
        --                         assertion(count.value, count2.value)
        --                     end,
        --                     {flush = "pre"}
        --                 )
        --                 return function()
        --                     return count.value
        --                 end
        --             end
        --         }
        --         local root = nodeOps:createElement("div")
        --         render(h(Comp), root)
        --         expect(assertion):toHaveBeenCalledTimes(1)
        --         count.value = count.value + 1
        --         count2.value = count2.value + 1
        --         expect(assertion):toHaveBeenCalledTimes(2)
        --     end
        -- )
        -- it(
        --     "flush timing: sync",
        --     function()
        --         local count = ref(0)
        --         local count2 = ref(0)
        --         local callCount = 0
        --         local assertion =
        --             jest:fn(
        --             function(count)
        --                 callCount = callCount + 1
        --                 -- [ts2lua]lua中0和空字符串也是true，此处callCount == 1需要确认
        --                 local expectedDOM = (callCount == 1 and {} or {})[1]
        --                 lu.assertEquals(serializeInner(root), expectedDOM)
        --                 -- [ts2lua]lua中0和空字符串也是true，此处callCount < 3需要确认
        --                 local expectedState = (callCount < 3 and {0} or {1})[1]
        --                 lu.assertEquals(count2.value, expectedState)
        --             end
        --         )
        --         local Comp = {
        --             setup = function()
        --                 watchEffect(
        --                     function()
        --                         assertion(count.value)
        --                     end,
        --                     {flush = "sync"}
        --                 )
        --                 return function()
        --                     return count.value
        --                 end
        --             end
        --         }
        --         local root = nodeOps:createElement("div")
        --         render(h(Comp), root)
        --         expect(assertion):toHaveBeenCalledTimes(1)
        --         count.value = count.value + 1
        --         count2.value = count2.value + 1
        --         expect(assertion):toHaveBeenCalledTimes(3)
        --     end
        -- )
        it(
            "deep",
            function()
                local state =
                    reactive(
                    {
                        nested = {count = ref(0)},
                        array = {1, 2, 3},
                        map = {a = 1, b = 2},
                        set = {[1] = true, [2] = true, [3] = true}
                    }
                )
                local dummy = nil
                watch(
                    function()
                        return state
                    end,
                    function(instance, state)
                        dummy = {state.nested.count, state.array[0 + 1], state.map.a, state.set[1] ~= nil}
                    end,
                    {deep = true}
                )
                state.nested.count = state.nested.count + 1
                waitForUpdate()
                lu.assertEquals(dummy, {1, 1, 1, true})
                state.array[0 + 1] = 2
                waitForUpdate()
                lu.assertEquals(dummy, {1, 2, 1, true})
                state.map.a = 2
                waitForUpdate()
                lu.assertEquals(dummy, {1, 2, 2, true})
                state.set[1] = nil
                waitForUpdate()
                lu.assertEquals(dummy, {1, 2, 2, false})
            end
        )
        it(
            "immediate",
            function()
                local count = ref(0)
                local cb = lu.createSpy("")
                watch(count, cb, {immediate = true})
                waitForUpdate()
                cb.toHaveBeenCalledTimes(1)
                count.value = count.value + 1
                waitForUpdate()
                cb.toHaveBeenCalledTimes(2)
            end
        )
        it(
            "immediate: triggers when initial value is null",
            function()
                local state = ref(nil)
                local spy = lu.createSpy()
                watch(
                    function()
                        return state.value
                    end,
                    spy,
                    {immediate = true}
                )
                spy.toHaveBeenCalled()
            end
        )
        it(
            "immediate: triggers when initial value is nil",
            function()
                local state = ref()
                local spy = lu.createSpy()
                watch(
                    function()
                        return state.value
                    end,
                    spy,
                    {immediate = true}
                )
                spy.toHaveBeenCalled()
                state.value = 3
                waitForUpdate()
                spy.toHaveBeenCalledTimes(2)
                state.value = nil
                waitForUpdate()
                spy.toHaveBeenCalledTimes(3)
                state.value = nil
                waitForUpdate()
                spy.toHaveBeenCalledTimes(3)
            end
        )
        it(
            "warn immediate option when using effect",
            function()
                local count = ref(0)
                local dummy = nil
                watchEffect(
                    function()
                        dummy = count.value
                    end,
                    {immediate = false}
                )
                lu.assertEquals(dummy, 0)
                lu.toHaveBeenWarned('immediate" option is only respected')
                count.value = count.value + 1
                waitForUpdate()
                lu.assertEquals(dummy, 1)
            end
        )
        it(
            "warn and not respect deep option when using effect",
            function()
                local arr = ref({1, {2}})
                local spy = lu.createSpy()
                watchEffect(
                    function()
                        spy()
                        return arr
                    end,
                    {deep = true}
                )
                waitForUpdate()
                spy.toHaveBeenCalledTimes(1)
                arr.value[1 + 1][0 + 1] = 3
                waitForUpdate()
                spy.toHaveBeenCalledTimes(1)
                lu.toHaveBeenWarned('"deep" option is only respected')
            end
        )
        it(
            "onTrack",
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
                watchEffect(
                    function()
                        local keys = {}
                        for i, v in pairs(obj) do
                            table.insert(keys, i)
                        end
                        table.sort(keys)
                        dummy = {obj.foo, obj["bar"] ~= nil, keys}
                    end,
                    {onTrack = onTrack}
                )
                waitForUpdate()
                lu.assertEquals(dummy, {1, true, {"bar", "foo"}})
                onTrack.toHaveBeenCalledTimes(3)
                lu.assertEquals(
                    events,
                    {
                        {[1] = events[1][1], [2] = obj, [3] = TrackOpTypes.ITERATE, [4] = ITERATE_KEY},
                        {[1] = events[2][1], [2] = obj, [3] = TrackOpTypes.GET, [4] = "foo"},
                        {[1] = events[3][1], [2] = obj, [3] = TrackOpTypes.GET, [4] = "bar"}
                    }
                )
            end
        )
        it(
            "onTrigger",
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
                watchEffect(
                    function()
                        dummy = obj.foo
                    end,
                    {onTrigger = onTrigger}
                )
                waitForUpdate()
                lu.assertEquals(dummy, 1)
                obj.foo = obj.foo + 1
                waitForUpdate()
                lu.assertEquals(dummy, 2)
                waitForUpdate()
                onTrigger.toHaveBeenCalledTimes(1)
                waitForUpdate()
                -- effect, target, type, key, newValue, oldValue
                lu.assertEquals(events[1], {events[1][1], obj, TriggerOpTypes.SET, "foo", 2, 1})
                obj.foo = nil
                waitForUpdate()
                lu.assertIsNil(dummy)
                waitForUpdate()
                onTrigger.toHaveBeenCalledTimes(2)
                waitForUpdate()
                lu.assertEquals(events[2], {events[2][1], obj, TriggerOpTypes.DELETE, "foo", nil, 2})
            end
        )
    end
)
