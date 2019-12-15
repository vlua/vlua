local Lang = require("util.Lang")
local config = require("config")
local instanceof = Lang.instanceof
local warn = print
local Init = require("instance.Init")
local State = require("instance.State")
local Events = require("instance.Events")
local Lifecycle = require("instance.Lifecycle")
local Observer = require("observer.Observer")
local NextTick = require("util.NextTick")
-- local Render = require("instance.Render")

---@class Vue
local Vue = {}

-- 创建实例时的元表
---@class Component
Vue.prototype = {options = {}}

--- 创建Vue实例
---@return Component
Vue.new = function(options)
    local properties = {}
    local instance = {__properties = properties}

    for i, v in pairs(Vue.prototype) do
        instance[i] = v
    end

    ---@param self Component
    instance.__index = function(self, key)
        local property = properties[key]
        if property then
            return property[1](self)
        end
    end

    ---@param self Component
    instance.__newindex = function(self, key, value)
        local property = properties[key]
        if property then
            property[2](self, value)
        else
            rawset(self, key, value)
        end
    end

    setmetatable(instance, instance)

    instance:_init(options)
    return instance
end

Vue.set = Observer.set
Vue.get = Observer.get
Vue.delete = Observer.del
Vue.nextTick = NextTick.nextTick

Init.initMixin(Vue)
State.stateMixin(Vue)
Events.eventsMixin(Vue)
Lifecycle.lifecycleMixin(Vue)
-- Render.renderMixin(Vue)

return Vue
