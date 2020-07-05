local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")

local SET, ADD, DELETE, CLEAR = TriggerOpTypes.SET, TriggerOpTypes.ADD, TriggerOpTypes.DELETE, TriggerOpTypes.CLEAR
local GET, HAS, ITERATE = TrackOpTypes.GET, TrackOpTypes.HAS, TrackOpTypes.ITERATE

local computed = require("reactivity.computed").computed
local V_GETTER, V_SETTER, SKIP, IS_REACTIVE, IS_SHALLOW, IS_READONLY, RAW, REACTIVE, READONLY, DEPSMAP =
    ReactiveFlags.V_GETTER,
    ReactiveFlags.V_SETTER,
    ReactiveFlags.SKIP,
    ReactiveFlags.IS_REACTIVE,
    ReactiveFlags.IS_SHALLOW,
    ReactiveFlags.IS_READONLY,
    ReactiveFlags.RAW,
    ReactiveFlags.REACTIVE,
    ReactiveFlags.READONLY,
    ReactiveFlags.DEPSMAP

local config = require("reactivity.config")
local __DEV__ = config.__DEV__

local next, rawget, rawset, type, ipairs, pairs, tinsert, xpcall, getmetatable, setmetatable, sformat, tostring =
    next,
    rawget,
    rawset,
    type,
    ipairs,
    pairs,
    table.insert,
    xpcall,
    getmetatable,
    setmetatable,
    string.format,
    tostring

local effect = require("reactivity.effect")
local track, trigger, ITERATE_KEY = effect.track, effect.trigger, effect.ITERATE_KEY

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
local isRef, toRef, triggerRef = ref.isRef, ref.toRef, ref.triggerRef

local createReactiveObject

local createRefWrapper

createRefWrapper = function(properties, key, value)
    local setter = value[V_SETTER]
    properties[key] = {
        [V_GETTER] = value[V_GETTER],
        [V_SETTER] = function(self, newVal)
            -- 引用覆盖
            if isRef(newVal) then
                createRefWrapper(properties, key, newVal)
                trigger(value, SET, "value", newVal[V_GETTER](self), value[V_GETTER](self))
                return
            end
            setter(self, newVal)
        end
    }
end

--- Define a reactive property on an Object.
---@param target ReactiveObject
---@param key string
---@param val any
---@param customSetter fun():any
---@param shallow boolean
---@param observed ReactiveMetatable
local function defineReactive(target, key, val, isReadonly, shallow, properties)
    if val == nil then
        val = target[key]
        rawset(target, key, nil)
    end

    -- -- support function to computed
    -- if type(val) == "function" then
    --     val = computed(val)
    -- end

    -- support computed and ref
    if isRef(val) then
        createRefWrapper(properties, key, val)
        return
    end

    local childOb = not shallow and type(val) == "table" and createReactiveObject(val, isReadonly, shallow)

    local property = {}
    properties[key] = property

    property[V_GETTER] = function(self)
        return val
    end

    -- 不是只读，才需要setter
    if not isReadonly then
        property[V_SETTER] = function(self, newVal)
            if newVal == val then
                return
            end
            local oldValue = val

            -- 对于新的Ref要处理
            if isRef(newVal) then
                createRefWrapper(properties, key, newVal)
                trigger(target, SET, key, newVal[V_GETTER](self), oldValue)
                return
            else
                childOb = not shallow and type(newVal) == "table" and createReactiveObject(newVal, isReadonly, shallow)
            end

            val = newVal
            -- 删除元素
            if newVal == nil then
                properties[key] = nil
                trigger(target, DELETE, key, newVal, oldValue)
            else
                trigger(target, SET, key, newVal, oldValue)
            end
        end
    end
end

local function walk(obj, isReadonly, shallow, properties)
    local keyOb
    for k, v in pairs(obj) do
        -- 同时支持key的响应式
        keyOb = not shallow and type(k) == "table" and createReactiveObject(k, isReadonly, shallow)
        -- 把value响应式
        defineReactive(obj, k, nil, isReadonly, shallow, properties)
    end
end

createReactiveObject = function(target, isReadonly, shallow)
    local observed = getmetatable(target)

    if observed == nil then
        -- 不允许改变只读状态
        observed = {}
        observed[RAW] = target
        observed[IS_READONLY] = isReadonly
        observed[IS_SHALLOW] = shallow
        observed[IS_REACTIVE] = true
        observed[DEPSMAP] = {}

        local properties = {}
        observed.__properties = properties
        walk(target, isReadonly, shallow, properties)

        -- 只读模式数据不会改变，所以不需要通知被引用
        observed.__index = function(self, key)
            if not isReadonly then
                track(target, GET, key)
            end
            local property = properties[key]
            if property then
                return property[V_GETTER](self)
            end
        end

        -- 只读不更改
        if isReadonly then
            observed.__newindex = function(self, key, newValue)
                if __DEV__ then
                    if newValue ~= nil then
                        warn('Set operation on key "' .. tostring(key) .. '" failed: target is readonly.')
                    else
                        warn('Delete operation on key "' .. tostring(key) .. '" failed: target is readonly.')
                    end
                end
            end
        else
            observed.__newindex = function(self, key, newValue)
                local property = properties[key]
                if property then
                    property[V_SETTER](self, newValue)
                elseif newValue ~= nil then
                    defineReactive(target, key, newValue, isReadonly, shallow, properties)
                    -- 增加元素
                    trigger(target, ADD, key, newValue)
                end
            end
        end

        -- map遍历
        observed.__pairs = function(self)
            if not isReadonly then
                track(target, ITERATE, ITERATE_KEY)
            end
            local key, valueStore
            return function()
                key, valueStore = next(properties, key)
                if valueStore then
                    return key, valueStore[V_GETTER](self)
                end
            end
        end

        -- 数组遍历
        observed.__ipairs = function(self)
            if not isReadonly then
                track(target, ITERATE, ITERATE_KEY)
            end
            local i = 1
            local valueStore
            return function(a, b, c)
                valueStore = properties[i]
                i = i + 1
                if valueStore ~= nil then
                    return i, valueStore[V_GETTER](self)
                end
            end
        end

        -- 获取table大小
        observed.__len = function()
            if not isReadonly then
                track(target, ITERATE, ITERATE_KEY)
            end
            return #properties
        end
        setmetatable(target, observed)
    elseif observed[IS_REACTIVE] and (observed[IS_READONLY] ~= isReadonly or observed[IS_SHALLOW] ~= shallow) then
        warn("cannot change readonly or shallow on a reactive object")
    end

    return target
end

local function reactive(target)
    if (type(target) ~= "table") then
        if __DEV__ then
            warn("target cannot be made reactive: ", tostring(target))
        end
        return target
    end
    return createReactiveObject(target, false, false)
end

-- Return a reactive-copy of the original object, where only the root level
-- properties are reactive, and does NOT unwrap refs nor recursively convert
-- returned properties.
local function shallowReactive(target)
    if (type(target) ~= "table") then
        if __DEV__ then
            warn("target cannot be made shallow reactive: ", tostring(target))
        end
        return target
    end
    return createReactiveObject(target, false, true)
end

local function readonly(target)
    if (type(target) ~= "table") then
        if __DEV__ then
            warn("target cannot be made readonly reactive: ", tostring(target))
        end
        return target
    end
    return createReactiveObject(target, true, false)
end

-- Return a reactive-copy of the original object, where only the root level
-- properties are readonly, and does NOT unwrap refs nor recursively convert
-- returned properties.
-- This is used for creating the props proxy object for stateful components.
local function shallowReadonly(target)
    if (type(target) ~= "table") then
        if __DEV__ then
            warn("target cannot be made shallow readonly reactive: ", tostring(target))
        end
        return target
    end
    return createReactiveObject(target, true, true)
end

local function isReadonly(value)
    local observed = getmetatable(value)
    return observed and observed[IS_READONLY]
end

local function isShallow(value)
    local observed = getmetatable(value)
    return observed and observed[IS_SHALLOW]
end

local function isReactive(value)
    local observed = getmetatable(value)
    return observed and observed[IS_REACTIVE]
end

local function markRaw(target)
    if (type(target) ~= "table") then
        if __DEV__ then
            warn("target cannot be made raw: ", tostring(target))
        end
        return target
    end
    if getmetatable(target) == nil then
        return setmetatable(target, SKIP)
    else
        if __DEV__ then
            warn("target with metatable cannot be made raw: ", tostring(target))
        end
        return target
    end
end

Reactive.reactive = reactive
Reactive.readonly = readonly
Reactive.shallowReadonly = shallowReadonly
Reactive.shallowReactive = shallowReactive
Reactive.isReadonly = isReadonly
Reactive.isReactive = isReactive
Reactive.isShallow = isShallow
Reactive.markRaw = markRaw
return Reactive
