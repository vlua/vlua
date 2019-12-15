local config = require("config")
local Dep = require("observer.Dep")
local Util = require("util.Util")
local Utils = require("observer.Utils")
local Lang = require("util.Lang")
local pairs = pairs
local ipairs = ipairs
local next = next
local type = type
local warn = print
local getmetatable = getmetatable
local setmetatable = setmetatable
local class = Utils.class
local createPlainObjectMetatable, PlainObject = Util.createPlainObjectMetatable, Util.PlainObject
local instanceof = Lang.instanceof
local isObject = function(v)
    return type(v) == "table"
end

local V_GETTER = 1
local V_SETTER = 2
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

local function isReactivableObject(obj)
    return type(obj) == "table" and (getmetatable(obj) == nil or instanceof(obj, PlainObject))
end

--[[
 * Observer class that is attached to each observed
 * object. Once attached, the observer converts the target
 * object's property keys into getter/setters that
 * collect dependencies and dispatch updates.
]]
---@class Observer
---@field value ReactiveObject
---@field dep Dep
---@field vmCount integer @number of vms that have self object as root $data
local Observer = class("Observer")
--[[
 * Attempt to create an observer instance for a value,
 * returns the new observer if successfully observed,
 * or the existing observer if the value already has one.
]]
---@param asRootData boolean
---@return Observer | void
---@alias ReactiveObject table

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
    if (ob == nil and _shouldObserve and isReactivableObject(value)) and not value._isVue then
        ob = Observer.new(value)
    end
    if (asRootData and ob) then
        ob.vmCount = ob.vmCount + 1
    end
    return ob
end

--- Define a reactive property on an Object.
---@param obj ReactiveObject
---@param key string
---@param val any
---@param customSetter fun():any
---@param shallow boolean
---@param mt ReactiveMetatable
local function defineReactive(obj, key, val, customSetter, shallow, mt)
    local dep = Dep.new()
    mt = mt or getmetatable(obj)

    local getter, setter

    local hasProperty = false
    if val == nil then
        ---@type ReactiveMetatable
        local plainObjectMetatable = getmetatable(obj)
        if plainObjectMetatable then
            local prop = plainObjectMetatable.__properties[key]
            if prop then
                getter = prop[V_GETTER]
                setter = prop[V_SETTER]
                hasProperty = true
            end
        end
        if not hasProperty then
            val = obj[key]
            obj[key] = nil
        end
    end

    if not hasProperty then
        getter = function()
            return val
        end
        setter = function(newValue)
            val = newValue
        end
    end

    local childOb = not shallow and observe(val)

    local property = {}
    mt.__properties[key] = property

    property[V_GETTER] = function()
        local value = getter()
        if (Dep.target) then
            dep:depend()
            if (childOb) then
                childOb.dep:depend()
            end
        end
        return value
    end

    property[V_SETTER] = function(newVal)
        local value = getter()

        if (newVal == value) then
            return
        end

        if (config.env ~= "production" and customSetter) then
            customSetter()
        end
        childOb = not shallow and observe(newVal)
        setter(newVal)
        dep:notify()
    end
end ---@param obj table
--

--[[
* Walk through all properties and convert them into
* getter/setters. This method should only be called when
* value type is Object.
]] local function walk(
    obj,
    mt)
    for k, v in pairs(obj) do
        defineReactive(obj, k, nil, nil, nil, mt)
    end
end

---@param value ReactiveObject
function Observer:constructor(value)
    self.value = value
    self.dep = Dep.new()
    self.vmCount = 0

    local mt = createPlainObjectMetatable()
    mt.__ob__ = self
    -- if (Array.isArray(value)) {
    --   if (hasProto) {
    --     protoAugment(value, arrayMethods)
    --   } else {
    --     copyAugment(value, arrayMethods, arrayKeys)
    --   }
    --   self.observeArray(value)
    -- } else {
    walk(value, mt)
    -- }

    setmetatable(value, mt)
end ---@param target ReactiveObject
--

--[[
 * Set a property on an object. Adds the new property and
 * triggers change notification if the property doesn't
 * already exist.
]]
---@param target ReactiveObject
local function set(target, key, val)
    ---@type ReactiveMetatable
    local mt = getmetatable(target)
    if config.env ~= "production" and (not mt or not mt.__ob__) then
        warn("Cannot set reactive property on undefined, null, or primitive value: ${(target: any)}")
        return
    end

    -- 如果已经有这个值
    if mt.__properties[key] then
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

    defineReactive(ob.value, key, val, nil, nil, mt)
    ob.dep:notify()
    return val
end
--- Delete a property and trigger change if necessary.
---@param target ReactiveObjectlocal
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

Observer.toggleObserving = toggleObserving
Observer.set = set
Observer.del = del
Observer.defineReactive = defineReactive
Observer.observe = observe
Observer.shouldObserve = shouldObserve

return Observer
