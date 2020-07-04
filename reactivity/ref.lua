local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")

local effect = require("reactivity.effect")
local track, trigger, IPAIR_KEY, PAIR_KEY = effect.track, effect.trigger, effect.IPAIR_KEY, effect.PAIR_KEY

local config = require("reactivity.config")
local __DEV__ = config.__DEV__

local type, ipairs, pairs = type, ipairs, pairs

local reactiveUtils = require("reactivity.reactiveUtils")
local isObject, hasChanged, extend, warn, NOOP, isFunction =
    reactiveUtils.isObject,
    reactiveUtils.hasChanged,
    reactiveUtils.extend,
    reactiveUtils.warn,
    reactiveUtils.NOOP,
    reactiveUtils.isFunction

local RefSymbol = nil
local convert = function(val)
    if type(val) == "table" then
        return reactive(val)
    else
        return val
    end
end
local function createRef(rawValue, shallow)
    if shallow == nil then
        shallow = false
    end
    if isRef(rawValue) then
        return rawValue
    end
    local value = (shallow and {rawValue} or {convert(rawValue)})[1]
    local r
    r = {
        __v_isRef = true,
        value = function()
            track(r, TrackOpTypes.GET, "value")
            return value
        end,
        value = function(newVal)
            if hasChanged(toRaw(newVal), rawValue) then
                rawValue = newVal
                value = (shallow and {newVal} or {convert(newVal)})[1]
                trigger(r, TriggerOpTypes.SET, "value", __DEV__ and {newValue = newVal} or nil)
            end
        end
    }
    return r
end

local function isRef(r)
    return (r and {r.__v_isRef == true} or {false})[1]
end

local function ref(value)
    return createRef(value)
end

local function shallowRef(value)
    return createRef(value, true)
end

local function triggerRef(ref)
    trigger(ref, TriggerOpTypes.SET, "value", __DEV__ and {newValue = ref.value} or nil)
end

local function unref(ref)
    if isRef(ref) then
        return ref.value
    else
        return ref
    end
end

local function customRef(factory)
    local r
    local get, set =
        factory(
        function()
            track(r, TrackOpTypes.GET, "value")
        end,
        function()
            trigger(r, TriggerOpTypes.SET, "value")
        end
    )
    r = {
        __v_isRef = true,
        value = function()
            return get()
        end,
        value = function(v)
            set(v)
        end
    }
    return r
end

local function toRefs(object)
    if __DEV__ and not isProxy(object) then
        warn()
    end
    local ret = {}
    for key in pairs(object) do
        ret[key] = toRef(object, key)
    end
    return ret
end

local function toRef(object, key)
    return {
        __v_isRef = true,
        value = function()
            return object[key]
        end,
        value = function(newVal)
            object[key] = newVal
        end
    }
end

return {
    isRef = isRef
}
