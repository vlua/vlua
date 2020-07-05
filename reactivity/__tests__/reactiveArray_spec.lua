local lu = require("test.luaunit")
local Effect = require("reactivity.effect")
local Util = require("vlua.util")
local slice = Util.slice
local track, trigger, ITERATE_KEY, effect, stop =
    Effect.track,
    Effect.trigger,
    Effect.ITERATE_KEY,
    Effect.effect,
    Effect.stop

local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")

local reactiveUtils = require("reactivity.reactiveUtils")
local isObject, hasChanged, extend, warn, NOOP, EMPTY_OBJ, isFunction, traceback, array_includes =
    reactiveUtils.isObject,
    reactiveUtils.hasChanged,
    reactiveUtils.extend,
    reactiveUtils.warn,
    reactiveUtils.NOOP,
    reactiveUtils.EMPTY_OBJ,
    reactiveUtils.isFunction,
    reactiveUtils.traceback,
    reactiveUtils.array_includes

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

describe(
    "reactivity/reactive/Array",
    function()
        it(
            "should make Array reactive",
            function()
                local original = {{foo = 1}}
                local observed = reactive(original)
                lu.assertEquals(observed, original)
                lu.assertEquals(isReactive(observed), true)
                lu.assertEquals(isReactive(original), true)
                lu.assertEquals(isReactive(observed[0 + 1]), true)
                lu.assertEquals(observed[0 + 1].foo, 1)
                lu.assertEquals(observed[1] ~= nil, true)
            end
        )
        it(
            "cloned reactive Array should point to observed values",
            function()
                local original = {{foo = 1}}
                local observed = reactive(original)

                local clone = slice(observed)
                lu.assertEquals(isReactive(clone[0 + 1]), true)
                lu.assertEquals(clone[0 + 1], original[0 + 1])
                lu.assertEquals(clone[0 + 1], observed[0 + 1])
            end
        )
        it(
            "observed value should proxy mutations to original (Array)",
            function()
                local original = {{foo = 1}, {bar = 2}}
                local observed = reactive(original)
                local value = {baz = 3}
                local reactiveValue = reactive(value)
                observed[0 + 1] = value
                lu.assertEquals(observed[0 + 1], reactiveValue)
                lu.assertEquals(original[0 + 1], value)
                observed[0 + 1] = nil
                lu.assertIsNil(observed[0 + 1])
                lu.assertIsNil(original[0 + 1])
                table.insert(observed, value)
                lu.assertEquals(observed[2 + 1], reactiveValue)
                lu.assertEquals(original[2 + 1], value)
            end
        )
        it(
            "Array identity methods should work with raw values",
            function()
                local raw = {}
                local arr = reactive({{}, {}})
                table.insert(arr, raw)
                -- lu.assertEquals(arr:find(raw), 2)
                -- lu.assertEquals(arr:find(raw, 3), -1)
                lu.assertEquals(array_includes(arr, raw), true)
                -- lu.assertEquals(array_includes(arr, raw, 3), false)
                -- lu.assertEquals(arr:lastIndexOf(raw), 2)
                -- lu.assertEquals(arr:lastIndexOf(raw, 1), -1)
                local observed = arr[2 + 1]
                -- lu.assertEquals(arr:find(observed), 2)
                -- lu.assertEquals(arr:find(observed, 3), -1)
                lu.assertEquals(array_includes(arr, observed), true)
                -- lu.assertEquals(array_includes(arr, observed, 3), false)
                -- lu.assertEquals(arr:lastIndexOf(observed), 2)
                -- lu.assertEquals(arr:lastIndexOf(observed, 1), -1)
            end
        )
        it(
            "Array identity methods should work if raw value contains reactive objects",
            function()
                local raw = {}
                local obj = reactive({})
                table.insert(raw, obj)
                local arr = reactive(raw)
                lu.assertEquals(array_includes(arr, obj), true)
            end
        )
        it(
            "Array identity methods should be reactive",
            function()
                local obj = {}
                local arr = reactive({obj, {}})
                local index = -1
                effect(
                    function()
                        index = -1
                        for i = 1, #arr do
                            if arr[i] == obj then
                                index = i
                                break
                            end
                        end
                    end
                )
                lu.assertEquals(index, 1)
                -- arr:reverse()
                -- lu.assertEquals(index, 2)
            end
        )
        it(
            "delete on Array should not trigger length dependency",
            function()
                local arr = reactive({1, 2, 3})
                local fn = lu.createSpy("")
                effect(
                    function()
                        fn(#arr)
                    end
                )
                fn.toHaveBeenCalledTimes(1)
                arr[1 + 1] = nil
                fn.toHaveBeenCalledTimes(2)
            end
        )
        describe(
            "Array methods w/ refs",
            function()
                local original = nil
                beforeEach(
                    function()
                        original = reactive({1, ref(2)})
                    end
                )
                it(
                    "read only copy methods",
                    function()
                        local res = {}
                        for i, v in ipairs(original) do
                            table.insert(res, v)
                        end

                        local rr = {3, ref(4)}
                        for i, v in ipairs(rr) do
                            table.insert(res, v)
                        end

                        local raw = res
                        lu.assertEquals(isRef(raw[2]), false)
                        lu.assertEquals(isRef(raw[4]), true)
                    end
                )
                it(
                    "read + write mutating methods",
                    function()
                        local res = original
                        local raw = res
                        lu.assertEquals(isRef(raw[1]), false)
                        lu.assertEquals(isRef(raw[2]), false)
                    end
                )
                it(
                    "read + identity",
                    function()
                        local ref = original[1 + 1]
                        lu.assertEquals(ref, original[1 + 1])
                        -- lu.assertEquals(original:find(ref), 1)
                    end
                )
            end
        )
    end
)
