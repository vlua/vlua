local config = require("config")
local Dep = require("observer.Dep")
local Utils = require("observer.Utils")
local pairs = pairs
local ipairs = ipairs
local next = next
local type = type
local warn = print
local getmetatable = getmetatable
local setmetatable = setmetatable
local class = Utils.class
local isObject = function(v)
    return type(v) == "table"
end

local V_GETTER = 1
local V_SETTER = 2
local V_GETTER_IMPL = 3
local V_SETTER_IMPL = 4
local V_VALUE = 5
 --
--[[
 * In some cases we may want to disable observation inside a component's
 * update computation.
]] local _shouldObserve =
    true

---@param value boolean
local function toggleObserving(value)
    _shouldObserve = value
end

local function shouldObserve()
    return _shouldObserve
end

local function isPlainObject(obj)
    return type(obj) == "table" and getmetatable(obj) == nil
end
 --

--[[
 * Observer class that is attached to each observed
 * object. Once attached, the observer converts the target
 * object's property keys into getter/setters that
 * collect dependencies and dispatch updates.
]] ---@class Observer
---@field value ReactiveObject
---@field dep Dep
---@field vmCount integer @number of vms that have self object as root $data
local Observer = class("Observer")
 --

---@alias ReactiveObject table

--[[
 * Attempt to create an observer instance for a value,
 * returns the new observer if successfully observed,
 * or the existing observer if the value already has one.
]] ---@param asRootData boolean
---@return Observer | void
local function observe(value, asRootData)
    if (not isObject(value)) --[[|| value instanceof VNode--]] then
        return
    end

    ---@type Observer
    local ob
    ---@type ReactiveMetatable
    local mt = getmetatable(value)
    if mt then
        ob = mt.__ob__
    end
    if (ob == nil and _shouldObserve and isPlainObject(value)) and not value._isVue then
        ob = Observer.new(value)
    end
    if (asRootData and ob) then
        ob.vmCount = ob.vmCount + 1
    end
    return ob
end

local fieldGetter = function(valueStore)
    return valueStore[V_VALUE]
end
local fieldSetter = function(valueStore, value)
    valueStore[V_VALUE] = value
end
 --

--[[
 * Define a reactive property on an Object.
]] ---@param obj ReactiveObject
---@param key string
---@param val any
---@param customSetter fun():any
---@param shallow boolean
local function defineReactive(obj, key, val, customSetter, shallow)
    local dep = Dep.new()
    ---@type ReactiveMetatable
    local mt = getmetatable(obj)
    local vStore = {}
    mt.__valuesStore[key] = vStore
    if val == nil then
        val = obj[key]
        obj[key] = nil
    end
    vStore[V_VALUE] = val

    local childOb = not shallow and observe(val)

    vStore[V_GETTER_IMPL] = fieldGetter
    vStore[V_SETTER_IMPL] = fieldSetter

    vStore[V_GETTER] = function(valueStore)
        local value = valueStore[V_GETTER_IMPL](valueStore)
        if (Dep.target) then
            dep:depend()
            if (childOb) then
                childOb.dep:depend()
            end
        end
        return value
    end

    vStore[V_SETTER] = function(valueStore, newVal)
        local value = valueStore[V_GETTER_IMPL](valueStore)

        if (newVal == value) then
            return
        end

        if (config.env ~= "production" and customSetter) then
            customSetter()
        end
        childOb = not shallow and observe(newVal)
        valueStore[V_SETTER_IMPL](valueStore, newVal)
        dep:notify()
    end
end
 --

--[[
* Walk through all properties and convert them into
* getter/setters. This method should only be called when
* value type is Object.
]] ---@param obj table
local function walk(obj)
    for k, v in pairs(obj) do
        defineReactive(obj, k)
    end
end

---@param value ReactiveObject
function Observer:constructor(value)
    self.value = value
    self.dep = Dep.new()
    self.vmCount = 0

    ---@class ReactiveMetatable
    ---@field __ob__ Observer
    ---@field __valuesStore (fun(valueStore:table):any)[]
    ---@field __index fun(self:ReactiveObject, key:any):any
    ---@field __newindex fun(self:ReactiveObject, key:any, value:any):nil
    local mt = {}
    mt.__ob__ = self
    -- save [key] = {getter, setter, getter_impl, setter_impl, value}
    local valuesStore = {}
    mt.__valuesStore = valuesStore
    mt.__len = function()
        return #valuesStore
    end
    mt.__index = function(self, key)
        local valueStore = valuesStore[key]
        return valueStore and valueStore[V_GETTER](valueStore)
    end
    mt.__newindex = function(self, key, value)
        local valueStore = valuesStore[key]
        return valueStore and valueStore[V_SETTER](valueStore, value)
    end
    setmetatable(value, mt)
    -- if (Array.isArray(value)) {
    --   if (hasProto) {
    --     protoAugment(value, arrayMethods)
    --   } else {
    --     copyAugment(value, arrayMethods, arrayKeys)
    --   }
    --   self.observeArray(value)
    -- } else {
    walk(value)
    -- }

    mt.__pairs = function()
        local key, valueStore
        return function()
            key, valueStore = next(valuesStore, key)
            return key, valueStore and valueStore[V_GETTER](valueStore)
        end
    end
    mt.__ipairs = function()
        local i = 1
        local valueStore
        return function()
            valueStore = valuesStore[i]
            i = i + 1
            return i, valueStore and valueStore[V_GETTER](valueStore)
        end
    end
end
 --

--[[
 * Set a property on an object. Adds the new property and
 * triggers change notification if the property doesn't
 * already exist.
]] ---@param target ReactiveObject
local function set(target, key, val)
    ---@type ReactiveMetatable
    local mt = getmetatable(target)
    if config.env ~= "production" and (not mt or not mt.__ob__) then
        warn("Cannot set reactive property on undefined, null, or primitive value: ${(target: any)}")
        return
    end

    -- 如果已经有这个值
    if mt.__valuesStore[key] then
        target[key] = val
        return val
    end
    local ob = mt.__ob__
    if (target._isVue or (ob and ob.vmCount ~= 0)) then
        if config.env ~= "production" then
            warn(
                "Avoid adding reactive properties to a Vue instance or its root $data " +
                    "at runtime - declare it upfront in the data option."
            )
            return val
        end
    end
    if (not ob) then
        target[key] = val
        return val
    end

    defineReactive(ob.value, key, val)
    ob.dep:notify()
    return val
end
 --

--[[
 * Delete a property and trigger change if necessary.
]] ---@param target ReactiveObject
local function del(target, key)
    ---@type ReactiveMetatable
    local mt = getmetatable(target)
    if config.env ~= "production" and (not mt or not mt.__ob__) then
        warn("Cannot delete reactive property on undefined, null, or primitive value: ${(target: any)}")
    end

    local ob = mt.__ob__
    if (target._isVue or (ob and ob.vmCount ~= 0)) then
        if config.env ~= "production" then
            warn("Avoid deleting properties on a Vue instance or its root $data " + "- just set it to null.")
            return
        end
    end
    target[key] = nil
    ob.dep:notify()
end

return {
    toggleObserving = toggleObserving,
    set = set,
    del = del,
    defineReactive = defineReactive,
    observe = observe,
    shouldObserve = shouldObserve
}
