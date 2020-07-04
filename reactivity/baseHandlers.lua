local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")

local effect = require("reactivity.effect")
local track, trigger, ITERATOR_KEY = effect.track, effect.trigger, effect.ITERATOR_KEY

local config = require("reactivity.config")
local __DEV__ = config.__DEV__

local type, ipairs, pairs, setmetatable = type, ipairs, pairs, setmetatable

local reactiveUtils = require("reactivity.reactiveUtils")
local isObject, hasChanged, extend, warn =
    reactiveUtils.isObject,
    reactiveUtils.hasChanged,
    reactiveUtils.extend,
    reactiveUtils.warn

return function(Reactive)
    local ref = require("reactivity.ref")(Reactive)
    local isRef = ref.isRef

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
                    return Reactive.readonly(res)
                else
                    return Reactive.reactive(res)
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
                value = Reactive.toRaw(value)
                if isRef(oldValue) and not isRef(value) then
                    oldValue.value = value
                    return true
                end

            -- in shallow mode, objects are set as-is regardless of reactive or not
            end
            target[key] = value
            -- don't trigger if target is something up in the prototype chain of original
            if target == Reactive.toRaw(receiver) then
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
        del = deleteProperty,
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
        del = function(target, key)
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

    local function createProxy(target, handlers)
        local proxy = {}

        local mt = {
            __index = function(self, key)
                return handlers.get(target, key, self)
            end,
            __newindex = function(self, key, value)
                if value ~= nil then
                    handlers.set(target, key, value, self)
                else
                    handlers.del(target, key, self)
                end
            end,
            __pairs = function(self)
                handlers.iterator(target)
                return pairs(target)
            end,
            __ipairs = function(self)
                handlers.iterator(target)
                return ipairs(target)
            end,
            __len = function(self)
                handlers.iterator(target)
                return #target
            end
        }
        return setmetatable(proxy, mt)
    end

    return {
        get = get,
        shallowGet = shallowGet,
        readonlyGet = readonlyGet,
        shallowReadonlyGet = shallowReadonlyGet,
        set = set,
        shallowSet = shallowSet,
        deleteProperty = deleteProperty,
        has = has,
        iterator = iterator,
        mutableHandlers = mutableHandlers,
        readonlyHandlers = readonlyHandlers,
        shallowReactiveHandlers = shallowReactiveHandlers,
        shallowReadonlyHandlers = shallowReadonlyHandlers,
        createProxy = createProxy
    }
end
