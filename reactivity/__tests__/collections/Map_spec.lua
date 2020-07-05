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

local Map = function(t)
    return t or {}
end
local clearMap = function(map)
    for i, v in pairs(map) do
        map[i] = nil
    end
end

local sizeMap = function(map)
    local count = 0
    for i, v in pairs(map) do
        count = count + 1
    end
    return count
end

describe(
    "reactivity/collections",
    function()
        describe(
            "Map",
            function()
                it(
                    "instanceof",
                    function()
                        local original = Map()
                        local observed = reactive(original)
                        lu.assertEquals(isReactive(observed), true)
                        -- lu.assertEquals(original:instanceof(Map), true)
                        -- lu.assertEquals(observed:instanceof(Map), true)
                    end
                )
                it(
                    "should observe mutations",
                    function()
                        local dummy = nil
                        local map = reactive(Map())
                        effect(
                            function()
                                dummy = map["key"]
                            end
                        )
                        lu.assertEquals(dummy, nil)
                        map["key"] = "value"
                        lu.assertEquals(dummy, "value")
                        map["key"] = "value2"
                        lu.assertEquals(dummy, "value2")
                        map["key"] = nil
                        lu.assertEquals(dummy, nil)
                    end
                )
                it(
                    "should observe mutations with observed value as key",
                    function()
                        local dummy = nil
                        local key = reactive({})
                        local value = reactive({})
                        local map = reactive(Map())
                        effect(
                            function()
                                dummy = map[key]
                            end
                        )
                        lu.assertEquals(dummy, nil)
                        map[key] = value
                        lu.assertEquals(dummy, value)
                        map[key] = nil
                        lu.assertEquals(dummy, nil)
                    end
                )
                it(
                    "should observe size mutations",
                    function()
                        local dummy = nil
                        local map = reactive(Map())
                        effect(
                            function()
                                dummy = sizeMap(map)
                            end
                        )
                        lu.assertEquals(dummy, 0)
                        map["key1"] = "value"
                        map["key2"] = "value2"
                        lu.assertEquals(dummy, 2)
                        map["key1"] = nil
                        lu.assertEquals(dummy, 1)
                        clearMap(map)
                        lu.assertEquals(dummy, 0)
                    end
                )
                it(
                    "should observe for of iteration",
                    function()
                        local dummy = nil
                        local map = reactive(Map())
                        effect(
                            function()
                                dummy = 0
                                for _tmpi, num in pairs(map) do
                                    dummy = dummy + num
                                end
                            end
                        )
                        lu.assertEquals(dummy, 0)
                        map["key1"] = 3
                        lu.assertEquals(dummy, 3)
                        map["key2"] = 2
                        lu.assertEquals(dummy, 5)
                        map["key1"] = 4
                        lu.assertEquals(dummy, 6)
                        map["key1"] = nil
                        lu.assertEquals(dummy, 2)
                        clearMap(map)
                        lu.assertEquals(dummy, 0)
                    end
                )
                it(
                    "should observe forEach iteration",
                    function()
                        local dummy = nil
                        local map = reactive(Map())
                        effect(
                            function()
                                dummy = 0
                                for _tmpi, num in pairs(map) do
                                    dummy = dummy + num
                                end
                            end
                        )
                        lu.assertEquals(dummy, 0)
                        map["key1"] = 3
                        lu.assertEquals(dummy, 3)
                        map["key2"] = 2
                        lu.assertEquals(dummy, 5)
                        map["key1"] = 4
                        lu.assertEquals(dummy, 6)
                        map["key1"] = nil
                        lu.assertEquals(dummy, 2)
                        clearMap(map)
                        lu.assertEquals(dummy, 0)
                    end
                )
                it(
                    "should observe keys iteration",
                    function()
                        local dummy = nil
                        local map = reactive(Map())
                        effect(
                            function()
                                dummy = 0
                                for key in pairs(map) do
                                    dummy = dummy + key
                                end
                            end
                        )
                        lu.assertEquals(dummy, 0)
                        map[3] = 3
                        lu.assertEquals(dummy, 3)
                        map[2] = 2
                        lu.assertEquals(dummy, 5)
                        map[3] = nil
                        lu.assertEquals(dummy, 2)
                        clearMap(map)
                        lu.assertEquals(dummy, 0)
                    end
                )
                it(
                    "should observe values iteration",
                    function()
                        local dummy = nil
                        local map = reactive(Map())
                        effect(
                            function()
                                dummy = 0
                                for _tmpi, num in pairs(map) do
                                    dummy = dummy + num
                                end
                            end
                        )
                        lu.assertEquals(dummy, 0)
                        map["key1"] = 3
                        lu.assertEquals(dummy, 3)
                        map["key2"] = 2
                        lu.assertEquals(dummy, 5)
                        map["key1"] = 4
                        lu.assertEquals(dummy, 6)
                        map["key1"] = nil
                        lu.assertEquals(dummy, 2)
                        clearMap(map)
                        lu.assertEquals(dummy, 0)
                    end
                )
                it(
                    "should observe entries iteration",
                    function()
                        local dummy = nil
                        local dummy2 = nil
                        local map = reactive(Map())
                        effect(
                            function()
                                dummy = ""
                                dummy2 = 0
                                for key, num in pairs(map) do
                                    dummy = dummy .. key
                                    dummy2 = dummy2 + num
                                end
                            end
                        )
                        lu.assertEquals(dummy, "")
                        lu.assertEquals(dummy2, 0)
                        map["key1"] = 3
                        lu.assertEquals(dummy, "key1")
                        lu.assertEquals(dummy2, 3)
                        map["key2"] = 2
                        lu.assertStrContains(dummy, "key1")
                        lu.assertStrContains(dummy, "key2")
                        lu.assertEquals(dummy2, 5)
                        map["key1"] = 4
                        lu.assertStrContains(dummy, "key1")
                        lu.assertStrContains(dummy, "key2")
                        lu.assertEquals(dummy2, 6)
                        map["key1"] = nil
                        lu.assertEquals(dummy, "key2")
                        lu.assertEquals(dummy2, 2)
                        clearMap(map)
                        lu.assertEquals(dummy, "")
                        lu.assertEquals(dummy2, 0)
                    end
                )
                it(
                    "should be triggered by clearing",
                    function()
                        local dummy = nil
                        local map = reactive(Map())
                        effect(
                            function()
                                dummy = map["key"]
                            end
                        )
                        lu.assertEquals(dummy, nil)
                        map["key"] = 3
                        lu.assertEquals(dummy, 3)
                        clearMap(map)
                        lu.assertEquals(dummy, nil)
                    end
                )
                it(
                    "should not observe custom property mutations",
                    function()
                        local dummy = nil
                        local map = reactive(Map())
                        effect(
                            function()
                                dummy = map.customProp
                            end
                        )
                        lu.assertEquals(dummy, nil)
                        map.customProp = "Hello World"
                        lu.assertEquals(dummy, "Hello World")
                    end
                )
                it(
                    "should not observe non value changing mutations",
                    function()
                        local dummy = nil
                        local map = reactive(Map())
                        local mapSpy =
                            lu.createSpy(
                            function()
                                dummy = map["key"]
                            end
                        )
                        effect(mapSpy)
                        lu.assertEquals(dummy, nil)
                        mapSpy.toHaveBeenCalledTimes(1)
                        map["key"] = nil
                        lu.assertEquals(dummy, nil)
                        mapSpy.toHaveBeenCalledTimes(1)
                        map["key"] = "value"
                        lu.assertEquals(dummy, "value")
                        mapSpy.toHaveBeenCalledTimes(2)
                        map["key"] = "value"
                        lu.assertEquals(dummy, "value")
                        mapSpy.toHaveBeenCalledTimes(2)
                        map["key"] = nil
                        lu.assertEquals(dummy, nil)
                        mapSpy.toHaveBeenCalledTimes(3)
                        map["key"] = nil
                        lu.assertEquals(dummy, nil)
                        mapSpy.toHaveBeenCalledTimes(3)
                        clearMap(map)
                        lu.assertEquals(dummy, nil)
                        mapSpy.toHaveBeenCalledTimes(3)
                    end
                )
                it(
                    "should not observe raw data",
                    function()
                        local dummy = nil
                        local map = reactive(Map())
                        effect(
                            function()
                                dummy = map["key"]
                            end
                        )
                        lu.assertEquals(dummy, nil)
                        map["key"] = "Hello"
                        lu.assertEquals(dummy, "Hello")
                        map["key"] = nil
                        lu.assertEquals(dummy, nil)
                    end
                )
                it(
                    "should not pollute original Map with Proxies",
                    function()
                        local map = Map()
                        local observed = reactive(map)
                        local value = reactive({})
                        observed["key"] = value
                        lu.assertEquals(map["key"], value)
                        lu.assertEquals(map["key"], value)
                    end
                )
                it(
                    "should return observable versions of contained values",
                    function()
                        local observed = reactive(Map())
                        local value = {}
                        observed["key"] = value
                        local wrapped = observed["key"]
                        lu.assertEquals(isReactive(wrapped), true)
                        lu.assertEquals(wrapped, value)
                    end
                )
                it(
                    "should observed nested data",
                    function()
                        local observed = reactive(Map())
                        observed["key"] = {a = 1}
                        local dummy = nil
                        effect(
                            function()
                                dummy = observed["key"].a
                            end
                        )
                        observed["key"].a = 2
                        lu.assertEquals(dummy, 2)
                    end
                )
                it(
                    "should observe nested values in iterations (forEach)",
                    function()
                        local map = reactive(Map({[1] = {foo = 1}}))
                        local dummy = nil
                        effect(
                            function()
                                dummy = 0
                                for k, value in pairs(map) do
                                    lu.assertEquals(isReactive(value), true)
                                    dummy = dummy + value.foo
                                end
                            end
                        )
                        lu.assertEquals(dummy, 1)
                        map[1].foo = map[1].foo + 1
                        lu.assertEquals(dummy, 2)
                    end
                )
                it(
                    "should observe nested values in iterations (values)",
                    function()
                        local map = reactive(Map({[1]= {foo = 1}}))
                        local dummy = nil
                        effect(
                            function()
                                dummy = 0
                                for _tmpi, value in pairs(map) do
                                    lu.assertEquals(isReactive(value), true)
                                    dummy = dummy + value.foo
                                end
                            end
                        )
                        lu.assertEquals(dummy, 1)
                        map[1].foo = map[1].foo + 1
                        lu.assertEquals(dummy, 2)
                    end
                )
                it(
                    "should observe nested values in iterations (entries)",
                    function()
                        local key = {}
                        local map = reactive(Map({[key] = {foo = 1}}))
                        local dummy = nil
                        effect(
                            function()
                                dummy = 0
                                for key, value in pairs(map) do
                                    lu.assertEquals(isReactive(key), true)
                                    lu.assertEquals(isReactive(value), true)
                                    dummy = dummy + value.foo
                                end
                            end
                        )
                        lu.assertEquals(dummy, 1)
                        map[key].foo = map[key].foo + 1
                        lu.assertEquals(dummy, 2)
                    end
                )
                it(
                    "should observe nested values in iterations (for...of)",
                    function()
                        local key = {}
                        local map = reactive(Map({[key] = {foo = 1}}))
                        local dummy = nil
                        effect(
                            function()
                                dummy = 0
                                for key, value in pairs(map) do
                                    lu.assertEquals(isReactive(key), true)
                                    lu.assertEquals(isReactive(value), true)
                                    dummy = dummy + value.foo
                                end
                            end
                        )
                        lu.assertEquals(dummy, 1)
                        map[key].foo = map[key].foo + 1
                        lu.assertEquals(dummy, 2)
                    end
                )
                it(
                    "should trigger when the value and the old value both are NaN",
                    function()
                        local map = reactive(Map({foo = 0 / 0}))
                        local mapSpy =
                            lu.createSpy(
                            function()
                                return map["foo"]
                            end
                        )
                        effect(mapSpy)
                        map["foo"] = 0 / 0
                        mapSpy.toHaveBeenCalledTimes(2)
                    end
                )
                it(
                    "should work with reactive keys in raw map",
                    function()
                        local raw = Map()
                        local key = reactive({})
                        raw[key] = 1
                        local map = reactive(raw)
                        lu.assertEquals(map[key] ~= nil, true)
                        lu.assertEquals(map[key], 1)

                        map[key] = nil
                        lu.assertIsNil(map[key])
                    end
                )
                it(
                    "should track set of reactive keys in raw map",
                    function()
                        local raw = Map()
                        local key = reactive({})
                        raw[key] = 1
                        local map = reactive(raw)
                        local dummy = nil
                        effect(
                            function()
                                dummy = map[key]
                            end
                        )
                        lu.assertEquals(dummy, 1)
                        map[key] = 2
                        lu.assertEquals(dummy, 2)
                    end
                )
                it(
                    "should track deletion of reactive keys in raw map",
                    function()
                        local raw = Map()
                        local key = reactive({})
                        raw[key] = 1
                        local map = reactive(raw)
                        local dummy = nil
                        effect(
                            function()
                                dummy = map[key] ~= nil
                            end
                        )
                        lu.assertEquals(dummy, true)
                        map[key] = nil
                        lu.assertEquals(dummy, false)
                    end
                )
                it(
                    "should warn when both raw and reactive versions of the same object is used as key",
                    function()
                        local raw = Map()
                        local rawKey = {}
                        local key = reactive(rawKey)
                        raw[rawKey] = 1
                        raw[key] = 1
                        local map = reactive(raw)
                        map[key] = 2
                        lu.toHaventWarned()
                    end
                )
                it(
                    "should not trigger key iteration when setting existing keys",
                    function()
                        local map = reactive(Map())
                        local spy = lu.createSpy('')
                        effect(
                            function()
                                local keys = {}
                                for key in pairs(map) do
                                    table.insert(keys, key)
                                end
                                spy(keys)
                                table.sort(keys)
                            end
                        )
                        spy.toHaveBeenCalledWith({})
                        map["a"] = 0
                        spy.toHaveBeenCalledWith({"a"})
                        map["b"] = 0
                        spy.toHaveBeenCalledWith({"a", "b"})
                        map["b"] = 1
                        spy.toHaveBeenCalledWith({"a", "b"})
                    end
                )
            end
        )
    end
)
