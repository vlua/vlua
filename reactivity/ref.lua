local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")

local effect = require("reactivity.effect")
local track, trigger, IPAIR_KEY, PAIR_KEY = effect.track, effect.trigger, effect.IPAIR_KEY, effect.PAIR_KEY

local V_GETTER, V_SETTER, IS_REF = ReactiveFlags.V_GETTER, ReactiveFlags.V_SETTER, ReactiveFlags.IS_REF

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
            track(refObject, TrackOpTypes.GET, "value")
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
                trigger(refObject, TriggerOpTypes.SET, "value", value, oldValue)
            end
        end

        local RefMetatable = {
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
            [IS_REF] = true
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
        trigger(ref, TriggerOpTypes.SET, "value", value, value)
    end

    local function unref(ref)
        if isRef(ref) then
            return ref.value
        else
            return ref
        end
    end

    return {
        isRef = isRef,
        ref = ref,
        shallowRef = shallowRef,
        readonlyRef = readonlyRef,
        readonlyShallowRef = readonlyShallowRef,
        triggerRef = triggerRef,
        unref = unref,
    }
end