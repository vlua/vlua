local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")

local SET, ADD, DELETE = TriggerOpTypes.SET, TriggerOpTypes.ADD, TriggerOpTypes.DELETE
local GET, ITERATE = TrackOpTypes.GET, TrackOpTypes.ITERATE

local effect = require("reactivity.effect")
local track, trigger, IPAIR_KEY, PAIR_KEY = effect.track, effect.trigger, effect.IPAIR_KEY, effect.PAIR_KEY

local V_GETTER, V_SETTER, SKIP, IS_REACTIVE, IS_SHALLOW, IS_READONLY, RAW, REACTIVE, READONLY, DEPSMAP, IS_REF =
    ReactiveFlags.V_GETTER,
    ReactiveFlags.V_SETTER,
    ReactiveFlags.SKIP,
    ReactiveFlags.IS_REACTIVE,
    ReactiveFlags.IS_SHALLOW,
    ReactiveFlags.IS_READONLY,
    ReactiveFlags.RAW,
    ReactiveFlags.REACTIVE,
    ReactiveFlags.READONLY,
    ReactiveFlags.DEPSMAP,
    ReactiveFlags.IS_REF

local config = require("reactivity.config")
local __DEV__ = config.__DEV__

local type, ipairs, pairs, setmetatable, assert = type, ipairs, pairs, setmetatable, assert

local reactiveUtils = require("reactivity.reactiveUtils")
local isObject, hasChanged, extend, warn, NOOP, isFunction =
    reactiveUtils.isObject,
    reactiveUtils.hasChanged,
    reactiveUtils.extend,
    reactiveUtils.warn,
    reactiveUtils.NOOP,
    reactiveUtils.isFunction

return function(Reactive)
    local function isRef(r)
        if type(r) == "table" and r[IS_REF] == true then
            return true
        else
            return false
        end
    end
    local function createRef(value, isReadonly, shallow)
        if isRef(value) then
            return value
        end

        value = shallow and value or Reactive.reactive(value)

        local refObject
        local function getter(self)
            track(refObject, GET, "value")
            return value
        end

        local setter
        if isReadonly then
            setter = function(self)
                warn("readonly ref value")
            end
        else
            setter = function(self, newValue)
                if newValue == value then
                    return
                end
                local oldValue = value

                value = shallow and newValue or Reactive.reactive(newValue)
                trigger(refObject, SET, "value", value, oldValue)
            end
        end

        local RefMetatable = {
            [IS_READONLY] = isReadonly,
            [IS_SHALLOW] = shallow,
            [IS_REACTIVE] = true,
            __index = function(self, key)
                assert(key == "value", 'only access Ref getter with "value" key')
                return getter(self)
            end,
            __newindex = function(self, key, newValue)
                assert(key == "value", 'only access Ref setter with "value" key')
                setter(self, newValue)
            end
        }
        refObject = {
            [V_GETTER] = getter,
            [V_SETTER] = setter,
            [IS_REF] = true,
            [DEPSMAP] = {}
        }
        setmetatable(refObject, RefMetatable)
        return refObject
    end

    local function ref(value)
        return createRef(value, false, false)
    end

    local function shallowRef(value)
        return createRef(value, false, true)
    end

    local function readonlyShallowRef(value)
        return createRef(value, true, true)
    end

    local function readonlyRef(value)
        return createRef(value, true)
    end

    local function triggerRef(ref)
        local value = ref.value
        trigger(ref, SET, "value", value, value)
    end

    local function unref(ref)
        if isRef(ref) then
            return ref.value
        else
            return ref
        end
    end

    ---@param factory func @func(track: func():nil, trigger: func():nil):func(self: any):any, func(self: any, newVal: any) : nil
    local function customRef(factory)
        local refObject

        local getter, setter =
            factory(
            function()
                track(refObject, GET, "value")
            end,
            function()
                trigger(refObject, SET, "value")
            end
        )

        local RefMetatable = {
            [IS_READONLY] = false,
            [IS_SHALLOW] = false,
            [IS_REACTIVE] = true,
            __index = function(self, key)
                assert(key == "value", 'only access Ref getter with "value" key')
                return getter()
            end,
            __newindex = function(self, key, newValue)
                assert(key == "value", 'only access Ref setter with "value" key')
                setter(self, newValue)
            end
        }
        refObject = {
            [V_GETTER] = getter,
            [V_SETTER] = setter,
            [IS_REF] = true,
            [DEPSMAP] = {}
        }
        setmetatable(refObject, RefMetatable)
        return refObject
    end

    local function toRef(object, key)
        local refObject

        local getter = function(self)
            return object[key]
        end
        local setter = function(self, newVal)
            object[key] = newVal
        end

        local RefMetatable = {
            [IS_READONLY] = false,
            [IS_SHALLOW] = false,
            [IS_REACTIVE] = true,
            __index = function(self, key)
                assert(key == "value", 'only access Ref getter with "value" key')
                return getter()
            end,
            __newindex = function(self, key, newValue)
                assert(key == "value", 'only access Ref setter with "value" key')
                setter(self, newValue)
            end
        }
        refObject = {
            [V_GETTER] = getter,
            [V_SETTER] = setter,
            [IS_REF] = true,
            [DEPSMAP] = {}
        }
        setmetatable(refObject, RefMetatable)
        return refObject
    end

    local function toRefs(object)
        if __DEV__ and not Reactive.isReactive(object) then
            warn("")
        end
        local ret = {}
        for key in pairs(object) do
            ret[key] = toRef(object, key)
        end
        return ret
    end

    return {
        isRef = isRef,
        ref = ref,
        shallowRef = shallowRef,
        readonlyRef = readonlyRef,
        readonlyShallowRef = readonlyShallowRef,
        triggerRef = triggerRef,
        unref = unref,
        toRefs = toRefs,
        toRef = toRef,
        customRef = customRef
    }
end
