local ReactiveFlags = require("reactivity.reactive.ReactiveFlags")
local TrackOpTypes = require("reactivity.operations.TrackOpTypes")
local TriggerOpTypes = require("reactivity.operations.TriggerOpTypes")
local V_GETTER, V_SETTER, SKIP, IS_REACTIVE, IS_SHALLOW, IS_READONLY, RAW, REACTIVE, READONLY =
    ReactiveFlags.V_GETTER,
    ReactiveFlags.V_SETTER,
    ReactiveFlags.SKIP,
    ReactiveFlags.IS_REACTIVE,
    ReactiveFlags.IS_SHALLOW,
    ReactiveFlags.IS_READONLY,
    ReactiveFlags.RAW,
    ReactiveFlags.REACTIVE,
    ReactiveFlags.READONLY

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

local createReactiveObject

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
    --     val = Computed.computed(val)
    -- end

    -- -- support computed and ref
    -- if isRef(val) then
    --     mt.__properties[key] = val
    --     return
    -- end

    local childOb = not shallow and createReactiveObject(val, isReadonly, shallow)

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
            childOb = not shallow and createReactiveObject(newVal, isReadonly, shallow)
            local oldValue = val
            val = newVal
            -- 删除元素
            if newVal == nil then
                -- 修改元素
                trigger(target, TriggerOpTypes.DELETE, key, nil, oldValue)
            else
                trigger(target, TriggerOpTypes.SET, key, newVal, oldValue)
            end
        end
    end
end

local function walk(obj, isReadonly, shallow, properties)
    for k, v in pairs(obj) do
        defineReactive(obj, k, nil, isReadonly, shallow, properties)
    end
end

createReactiveObject = function(target, isReadonly, shallow)
    if (type(target) ~= "table") then
        return
    end

    local observed = getmetatable(target)

    if (observed == nil or (observed and not observed[IS_REACTIVE])) and not target[SKIP] then
        observed = {}
        observed[RAW] = target
        observed[IS_READONLY] = isReadonly
        observed[IS_SHALLOW] = shallow
        observed[IS_REACTIVE] = true

        local properties = {}
        observed.__properties = properties
        walk(target, isReadonly, shallow, properties)

        -- 只读模式数据不会改变，所以不需要通知被引用
        observed.__index = function(self, key)
            if not isReadonly then
                track(target, TrackOpTypes.GET, key)
            end
            local property = properties[key]
            if property then
                return property[V_GETTER](self)
            end
        end

        -- 只读不更改
        if isReadonly then
            if __DEV__ then
                warn(sformat("%s is readonly", tostring(self[RAW])))
            end
        else
            observed.__newindex = function(self, key, newValue)
                local property = properties[key]
                if property then
                    property[V_SETTER](self, newValue)
                else
                    defineReactive(target, key, newValue, isReadonly, shallow, properties)
                    -- 增加元素
                    trigger(target, TriggerOpTypes.ADD, key, newValue)
                end
            end
        end

        -- map遍历
        observed.__pairs = function(self)
            if not isReadonly then
                track(target, TrackOpTypes.ITERATOR, ITERATOR_KEY)
            end
            local key, valueStore
            return function()
                key, valueStore = next(properties, key)
                return key, valueStore and valueStore[V_GETTER](self)
            end
        end

        -- 数组遍历
        observed.__ipairs = function(self)
            if not isReadonly then
                track(target, TrackOpTypes.ITERATOR, ITERATOR_KEY)
            end
            local i = 1
            local valueStore
            return function()
                valueStore = properties[i]
                i = i + 1
                return i, valueStore and valueStore[V_GETTER](self)
            end
        end

        -- 获取table大小
        observed.__len = function()
            if not isReadonly then
                track(target, TrackOpTypes.ITERATOR, ITERATOR_KEY)
            end
            return #properties
        end
        setmetatable(target, observed)
    end

    return target
end

local function reactive(target)
    return createReactiveObject(target, false, false)
end

-- Return a reactive-copy of the original object, where only the root level
-- properties are reactive, and does NOT unwrap refs nor recursively convert
-- returned properties.
local function shallowReactive(target)
    return createReactiveObject(target, false, true)
end

local function readonly(target)
    return createReactiveObject(target, true, false)
end

-- Return a reactive-copy of the original object, where only the root level
-- properties are readonly, and does NOT unwrap refs nor recursively convert
-- returned properties.
-- This is used for creating the props proxy object for stateful components.
local function shallowReadonly(target)
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
    return observed and observed[IS_READONLY]
end

local function markRaw(value)
    value[SKIP] = true
    return value
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
