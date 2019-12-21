local Util = require("util.Util")
local Dep = require("observer.Dep")
local warn = Util.warn
local setmetatable = setmetatable
local type = type

---@class Ref
---@field value any
---@field get fun():any
---@param set fun(newValue:any):nil

---@param getter fun(self:any):any
---@param setter fun(self:any, newValue:any):nil
---@return Ref
local function ref(value, isReadonly)
    local dep = Dep.new()

    local function get(self)
        if (Dep.target) then
            dep:depend()
        end
        return value
    end

    local selfSet, set
    if isReadonly then
        set = function()
            warn("readonly ref value")
        end
        selfSet = set
    else
        selfSet = function(self, newValue)
            value = newValue
            dep:notify()
        end
        set = function(newValue)
            value = newValue
            dep:notify()
        end
    end

    local RefMetatable = {
        __index = function(self, key)
            assert(key == "value", 'only access Ref getter with "value" key')
            return get()
        end,
        __newindex = function(self, key, newValue)
            assert(key == "value", 'only access Ref setter with "value" key')
            set(newValue)
        end
    }
    local obj = {
        get = get,
        set = set,
        getter = get,
        setter = selfSet,
        __isref = true
    }
    setmetatable(obj, RefMetatable)
    return obj
end

local function isRef(val)
    return type(val) == "table" and val.__isref == true
end

return {
    ref = ref,
    isRef = isRef
}
