local Util = require("util.Util")
local Dep = require("observer.Dep")
local warn = Util.warn
local setmetatable = setmetatable
local type = type

---@class Computed
---@field value any
---@field get fun():any
---@param set fun(newValue:any):nil

---@param getter fun(self:any):any
---@param setter fun(self:any, newValue:any):nil
---@return Computed
local function computed(getter, setter)
    local dep = Dep.new()

    if not getter then
        getter = function(self)
            warn("set only computed value")
        end
    end
    if not setter then
        setter = function(self, newValue)
            warn("readonly computed value")
        end
    end

    local function computedGetter(self)
        local value = getter(self)
        if (Dep.target) then
            dep:depend()
        end
        return value
    end

    local function computedSetter(self, newValue)
        setter(self, newValue)
        dep:notify()
    end

    local RefMetatable = {
        __index = function(self, key)
            assert(key == "value", 'only access Computed getter with "value" key')
            return computedGetter(self)
        end,
        __newindex = function(self, key, newValue)
            assert(key == "value", 'only access Computed setter with "value" key')
            computedSetter(self, newValue)
        end
    }
    local obj = {
        get = function()
            return computedGetter(nil)
        end,
        set = function(newValue)
            computedSetter(nil, newValue)
        end,
        getter = computedGetter,
        setter = computedSetter,
        __iscomputed = true
    }
    setmetatable(obj, RefMetatable)
    return obj
end

local function isComputed(val)
    return type(val) == "table" and val.__iscomputed == true
end

return {
    computed = computed,
    isComputed = isComputed
}
