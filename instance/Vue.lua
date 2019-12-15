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
local Util = require("util.Util")
local createPlainObject = Util.createPlainObject
---@class Vue
local Vue = {}

-- 创建实例时的元表
---@class Component
Vue.prototype = {options = {}}

--- 创建Vue实例
---@return Component
Vue.new = function(options)
    local instance = createPlainObject()
    local mt = getmetatable(instance)
    local index, newindex = mt.__index, mt.__newindex
    mt.__index, mt.__newindex = nil, nil

    for i, v in pairs(Vue.prototype) do
        instance[i] = v
    end
    instance.__proto = Vue.prototype

    instance:_init(options)

    mt.__index, mt.__newindex = index, newindex
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
