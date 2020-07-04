local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")

local config = require("reactivity.config")
local __DEV__ = config.__DEV__

local type, ipairs, pairs, tinsert, xpcall, getmetatable = type, ipairs, pairs, table.insert, xpcall, getmetatable

local effect = require("reactivity.effect")
local track, trigger, ITERATOR_KEY = effect.track, effect.trigger, effect.ITERATOR_KEY

local reactiveUtils = require("reactivity.reactiveUtils")
local isObject, hasChanged, extend, warn, NOOP, EMPTY_OBJ, isFunction, traceback =
    reactiveUtils.isObject,
    reactiveUtils.hasChanged,
    reactiveUtils.extend,
    reactiveUtils.warn,
    reactiveUtils.NOOP,
    reactiveUtils.EMPTY_OBJ,
    reactiveUtils.isFunction,
    reactiveUtils.traceback

local Reactive = {}

local ref = require("reactivity.ref")(Reactive)
local isRef, toRef = ref.isRef, ref.toRef

local baseHandlers = require("reactivity.baseHandlers")(Reactive)
local mutableHandlers, shallowReactiveHandlers, readonlyHandlers, shallowReadonlyHandlers, createProxy =
    baseHandlers.mutableHandlers,
    baseHandlers.shallowReactiveHandlers,
    baseHandlers.readonlyHandlers,
    baseHandlers.shallowReadonlyHandlers,
    baseHandlers.createProxy

local function toRaw(observed)
    return type(observed) == 'table' and toRaw(observed[ReactiveFlags.RAW]) or observed
end

local canObserve = function(value)
    return getmetatable(value) == nil and not value[ReactiveFlags.SKIP] and isObject(value)
end

local function createReactiveObject(target, isReadonly, baseHandlers)
    if not isObject(target) then
        if __DEV__ then
            warn("target is not a object")
        end
        return target
    end
    -- target is already a Proxy, return it.
    -- exception: calling readonly() on a reactive object
    if target[ReactiveFlags.RAW] and not (isReadonly and target[ReactiveFlags.IS_REACTIVE]) then
        return target
    end
    -- target already has corresponding Proxy
    if target[isReadonly and ReactiveFlags.READONLY or ReactiveFlags.REACTIVE] ~= nil then
        return isReadonly and target[ReactiveFlags.READONLY] or target[ReactiveFlags.REACTIVE]
    end
    -- only a whitelist of value types can be observed.
    if not canObserve(target) then
        return target
    end
    local observed = createProxy(target, baseHandlers)
    target[isReadonly and ReactiveFlags.READONLY or ReactiveFlags.REACTIVE] = observed
    return observed
end

local function reactive(target)
    -- if trying to observe a readonly proxy, return the readonly version.
    if target and target[ReactiveFlags.IS_READONLY] then
        return target
    end
    return createReactiveObject(target, false, mutableHandlers)
end

-- Return a reactive-copy of the original object, where only the root level
-- properties are reactive, and does NOT unwrap refs nor recursively convert
-- returned properties.
local function shallowReactive(target)
    return createReactiveObject(target, false, shallowReactiveHandlers)
end

local function readonly(target)
    return createReactiveObject(target, true, readonlyHandlers)
end

-- Return a reactive-copy of the original object, where only the root level
-- properties are readonly, and does NOT unwrap refs nor recursively convert
-- returned properties.
-- This is used for creating the props proxy object for stateful components.
local function shallowReadonly(target)
    return createReactiveObject(target, true, shallowReadonlyHandlers)
end

local function isReadonly(value)
    return not (not (value and value[ReactiveFlags.IS_READONLY]))
end
local function isReactive(value)
    if isReadonly(value) then
        return isReactive(value[ReactiveFlags.RAW])
    end
    return not (not (value and value[ReactiveFlags.IS_REACTIVE]))
end

local function isProxy(value)
    return isReactive(value) or isReadonly(value)
end

local function markRaw(value)
    value[ReactiveFlags.SKIP] = true
    return value
end

Reactive.reactive = reactive
Reactive.shallowReactive = shallowReactive
Reactive.isReadonly = isReadonly
Reactive.isReactive = isReactive
Reactive.isProxy = isProxy
Reactive.toRaw = toRaw
Reactive.markRaw = markRaw
Reactive.canObserve = canObserve
return Reactive
