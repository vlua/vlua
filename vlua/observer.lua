local config = require("vlua.config")
local Dep = require("vlua.dep")
local Util = require("vlua.util")
local Computed = require("vlua.apiComputed")
local pairs = pairs
local ipairs = ipairs
local next = next
local type = type
local warn = Util.warn
local rawset = rawset
local getmetatable = getmetatable
local setmetatable = setmetatable
local class = Util.class
local createPlainObjectMetatable, isRef = Util.createPlainObjectMetatable, Util.isRef
local isObject = function(v)
    return type(v) == "table"
end

local V_GETTER = 1
local V_SETTER = 2

--[[
 * In some cases we may want to disable observation inside a component's
 * update computation.
]]
local _shouldObserve = true

---@param value boolean
local function toggleObserving(value)
    _shouldObserve = value
end

local function shouldObserve()
    return _shouldObserve
end

local function isReactivableObject(obj)
    return type(obj) == "table" and (getmetatable(obj) == nil)
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
    if (type(value) ~= "table") then
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

    if val == nil then
        val = obj[key]
        rawset(obj, key, nil)
    end

    -- support function to computed
    if type(val) == "function" then
        val = Computed.computed(val)
    end

    -- support computed and ref
    if isRef(val) then
        mt.__properties[key] = val
        return
    end

    local childOb = not shallow and observe(val)

    local property = {}
    mt.__properties[key] = property

    property[V_GETTER] = function(self)
        if (Dep.target) then
            dep:depend()
            if (childOb) then
                childOb.dep:depend()
            end
        end
        return val
    end

    local ownerOb = mt.__ob__

    property[V_SETTER] = function(self, newVal)
        if (newVal == val) then
            return
        end

        if (config.env ~= "production" and customSetter) then
            customSetter()
        end
        childOb = not shallow and observe(newVal)
        val = newVal
        --- delete notify
        if newVal == nil then
            mt.__properties[key] = nil
            dep:notify()
            ownerOb.dep:notify()
        else
            dep:notify()
        end
    end
end

--[[
* Walk through all properties and convert them into
* getter/setters. This method should only be called when
* value type is Object.
]]
---@param obj table
local function walk(obj, mt)
    for k, v in pairs(obj) do
        defineReactive(obj, k, nil, nil, nil, mt)
    end
end

---@param value ReactiveObject
function Observer:ctor(value)
    self.value = value
    local dep = Dep.new()
    self.dep = dep
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

    local properties = mt.__properties

    mt.__index = function(self, key)
        local property = properties[key]
        if property then
            return property[V_GETTER](self)
        end
    end
    mt.__newindex = function(self, key, newValue)
        local property = properties[key]
        if property then
            property[V_SETTER](self, newValue)
        else
            defineReactive(value, key, newValue, nil, nil, mt)
            --- add notify
            dep:notify()
        end
    end
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
                "Avoid adding reactive properties to a Vue instance or its root $data " ..
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
    if config.env ~= "production" and not isObject(target) then
        warn("Cannot delete reactive property on undefined, null, or primitive value: ${(target: any)}")
    end

    local ob
    local mt = getmetatable(target)
    if mt then
        ob = mt.__ob__
    end

    if (target._isVue or (ob and ob.vmCount ~= 0)) then
        if config.env ~= "production" then
            warn("Avoid deleting properties on a Vue instance or its root $data " .. "- just set it to null.")
            return
        end
    end
    if (target[key] == nil) then
        return
    end
    target[key] = nil
    if ob then
        ob.dep:notify()
    end
end

Observer.toggleObserving = toggleObserving
Observer.set = set
Observer.del = del
Observer.defineReactive = defineReactive
Observer.observe = observe
Observer.shouldObserve = shouldObserve

Observer.reactive = function(value)
    observe(value)
    return value
end

return Observer
