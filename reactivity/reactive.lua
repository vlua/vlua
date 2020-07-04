local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")

local config = require("reactivity.config")
local __DEV__ = config.__DEV__

local effect = require("reactivity.effect")
local track, trigger, ITERATOR_KEY = effect.track, effect.trigger, effect.ITERATOR_KEY

local ref = require("reactivity.ref")
local isRef = ref.isRef

local type, ipairs, pairs, tinsert, xpcall, getmetatable = type, ipairs, pairs, table.insert, xpcall, getmetatable

local reactiveUtils = require("reactivity.reactiveUtils")
local isObject, hasChanged, extend, warn, NOOP, EMPTY_OBJ, isFunction, traceback, proxy =
    reactiveUtils.isObject,
    reactiveUtils.hasChanged,
    reactiveUtils.extend,
    reactiveUtils.warn,
    reactiveUtils.NOOP,
    reactiveUtils.EMPTY_OBJ,
    reactiveUtils.isFunction,
    reactiveUtils.traceback,
    reactiveUtils.proxy

local baseHandlers = require("reactivity.baseHandlers")

local readonly
local reactive

local function toRaw(observed)
    return observed and toRaw(observed[ReactiveFlags.RAW]) or observed
end

local function createGetter(isReadonly, shallow)
    if isReadonly == nil then
        isReadonly = false
    end
    if shallow == nil then
        shallow = false
    end
    return function(target, key, receiver)
        if key == ReactiveFlags.IS_REACTIVE then
            return not isReadonly
        elseif key == ReactiveFlags.IS_READONLY then
            return isReadonly
        elseif
            key == ReactiveFlags.RAW and
                receiver == (isReadonly and target[ReactiveFlags.READONLY] or target[ReactiveFlags.REACTIVE])
         then
            return target
        end

        local res = target[key]
        if key == "__v_isRef" then
            -- ref unwrapping, only for Objects, not for Arrays.
            return res
        end
        if not isReadonly then
            track(target, TrackOpTypes.GET, key)
        end
        if shallow then
            return res
        end
        if isRef(res) then
            return res.value
        end
        if isObject(res) then
            -- Convert returned value into a proxy as well. we do the isObject check
            -- here to avoid invalid value warning. Also need to lazy access readonly
            -- and reactive here to avoid circular dependency.
            if isReadonly then
                return readonly(res)
            else
                return reactive(res)
            end
        end
        return res
    end
end

local get = createGetter()
local shallowGet = createGetter(false, true)
local readonlyGet = createGetter(true)
local shallowReadonlyGet = createGetter(true, true)

local function createSetter(shallow)
    if shallow == nil then
        shallow = false
    end
    return function(target, key, value, receiver)
        local oldValue = target[key]
        if not shallow then
            value = toRaw(value)
            if isRef(oldValue) and not isRef(value) then
                oldValue.value = value
                return true
            end

        -- in shallow mode, objects are set as-is regardless of reactive or not
        end
        target[key] = value
        -- don't trigger if target is something up in the prototype chain of original
        if target == toRaw(receiver) then
            if oldValue == nil then
                trigger(target, TriggerOpTypes.ADD, key, value)
            elseif hasChanged(value, oldValue) then
                trigger(target, TriggerOpTypes.SET, key, value, oldValue)
            end
        end
    end
end

local set = createSetter()
local shallowSet = createSetter(true)

local function deleteProperty(target, key)
    local oldValue = target[key]
    if oldValue ~= nil then
        target[key] = nil
        trigger(target, TriggerOpTypes.DELETE, key, nil, oldValue)
    end
end

local function has(target, key)
    local result = target[key]
    track(target, TrackOpTypes.HAS, key)
    return result ~= nil
end

local function iterator(target)
    track(target, TrackOpTypes.ITERATOR, ITERATOR_KEY)
    return pairs(target)
end

local mutableHandlers = {
    get = get,
    set = set,
    deleteProperty = deleteProperty,
    has = has,
    iterator = iterator
}

local readonlyHandlers = {
    get = readonlyGet,
    has = has,
    iterator = iterator,
    set = function(target, key)
        if __DEV__ then
            warn(target)
        end
        return true
    end,
    deleteProperty = function(target, key)
        if __DEV__ then
            warn(target)
        end
        return true
    end
}

-- Props handlers are special in the sense that it should not unwrap top-level
-- refs (in order to allow refs to be explicitly passed down), but should
-- retain the reactivity of the normal readonly object.
local shallowReactiveHandlers = extend({}, mutableHandlers, {get = shallowGet, set = shallowSet})
local shallowReadonlyHandlers = extend({}, readonlyHandlers, {get = shallowReadonlyGet})

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
    local observed = proxy(target, baseHandlers)
    target[isReadonly and ReactiveFlags.READONLY or ReactiveFlags.REACTIVE] = observed
    return observed
end

reactive = function(target)
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

readonly = function(target)
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

return {
    reactive = reactive,
    shallowReactive = shallowReactive,
    isReadonly = isReadonly,
    isReactive = isReactive,
    isProxy = isProxy,
    toRaw = reactiveUtils.toRaw,
    markRaw = markRaw,
    canObserve = canObserve
}
