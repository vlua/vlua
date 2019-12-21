local Util = require("util.Util")
local warn = Util.warn

---@class Computed
---@field value any
---@field get fun():any
---@param set fun(newValue:any):nil

---@param getter fun(self:any):any
---@param setter fun(self:any, newValue:any):nil
---@return Computed
local function computed(getter, setter)
    if not getter then
        getter = function(self)
            warn('set only computed value')
        end
    end
    if not setter then
        setter = function(self, newValue)
            warn('readonly computed value')
        end
    end
    local RefMetatable = {
        __index = function(self, key)
            assert(key == 'value', 'only access Computed getter with "value" key')
            return getter(self)
        end,
        __newindex = function(self, key, newValue)
            assert(key == 'value', 'only access Computed setter with "value" key')
            setter(self, newValue)
        end
    }
    local obj = {get = getter, set = setter, __iscomputed = true}
    setmetatable(obj, RefMetatable)
    return obj
end

local function isComputed(val)
    return type(val) == 'table' and val.__iscomputed == true
end

return {
    computed = computed,
    isComputed = isComputed
}
