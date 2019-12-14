local tinsert, tremove = table.insert, table.remove
local type = type
local Util = require('util.Util')
local Error = require('util.Error')
local Dep = require('observer.Dep')
local config = require("config")
local setmetatable = setmetatable
local invokeWithErrorHandling = Error.invokeWithErrorHandling
local pushTarget, popTarget = Dep.pushTarget, Dep.popTarget
local
  tip,
  toArray,
  hyphenate,
  formatComponentName,
  createObject
=
Util.tip,
Util.toArray,
Util.hyphenate,
Util.formatComponentName,
Util.createObject
local updateListeners = require('instance.UpdateListeners').updateListeners

local updateComponentListeners

local function callHook(vm, hook)
    -- #7573 disable dep collection when invoking lifecycle hooks
    pushTarget()
    local handlers = vm._options[hook]
    local info = hook .. ' hook'
    if (handlers) then
      local j = #handlers
      for i = 1, j do
        invokeWithErrorHandling(handlers[i], vm, info, vm)
      end
    end
    if (vm._hasHookEvent) then
      vm:_emit('hook:' .. hook)
    end
    popTarget()
  end
---@param vm Component
local function initEvents (vm)
    vm._events = {}
    vm._hasHookEvent = false
    -- init parent attached events
    local listeners = vm._options._parentListeners
    if (listeners) then
        updateComponentListeners(vm, listeners)
    end
end

---@type any
local target

local function add(event, fn)
  target._on(event, fn)
end

local function remove(event, fn)
  target._off(event, fn)
end

local function createOnceHandler(event, fn)
    local _target = target
    local onceHandler
    onceHandler = function(...)
        local res = fn(...)
        if (res ~= nil) then
            _target._off(event, onceHandler)
        end
    end
    return onceHandler
end

---@param vm Component
---@param listeners Object
---@param oldListeners Object
updateComponentListeners = function(
  vm,
  listeners,
  oldListeners
)
    target = vm
    updateListeners(listeners, oldListeners or {}, add, remove, createOnceHandler, vm)
    target = nil
end

---@param Vue Vue
local function eventsMixin (Vue)
    local hookRE = '^hook:'
    ---@param event string | string[]
    ---@param fn Function
    ---@return Component
    function Vue.prototype:_on(event, fn)
        ---@type Component
        local vm = self
        if (type(event) == "table") then
            for i = 1, #event do
                vm:_on(event[i], fn)
            end
        else
            local events = vm._events[event]
            if not events then
                events = {}
                vm._events[event] = events
            end
            tinsert(events , fn)
            -- optimize hook:event cost by using a boolean flag marked at registration
            -- instead of a hash lookup
            if (string.match(event, hookRE)) then
                vm._hasHookEvent = true
            end
        end
        return vm
    end

    ---@param event string
    ---@param fn Function
    ---@return Component
    function Vue.prototype:_once(event, fn)
        ---@type Component
        local vm = self
        local callable
        local function on (...)
            vm:_off(event, callable)
            fn(vm, ...)
        end
        callable = {fn = fn , __call = on}
        setmetatable(callable, callable)
        vm:_on(event, callable)
        return vm
    end

    ---@param event string | string[]
    ---@param fn Function
    ---@return Component
    function Vue.prototype:_off(event, fn)
        ---@type Component
        local vm = self
        -- all
        if (event == nil and fn == nil) then
            vm._events = {}
            return vm
        end
        -- array of events
        if (type(event) == "table") then
            for i = 1, #event do
                vm:_off(event[i], fn)
            end
            return vm
        end
        -- specific event
        local cbs = vm._events[event]
        if not cbs then
            return vm
        end
        if not fn then
            vm._events[event] = nil
            return vm
        end
        -- specific handler
        local cb
        for i = #cbs, 1, -1 do
            cb = cbs[i]
            if (cb == fn or (type(cb) == "table" and cb.fn == fn)) then
                tremove(cbs, i)
                break
            end
        end
        return vm
    end

    ---@param event string
    ---@return Component
    function Vue.prototype:_emit(event, ...)
        ---@type Component
        local vm = self
        if (config.env ~= 'production') then
            local lowerCaseEvent = string.lower(event)
            if (lowerCaseEvent ~= event and vm._events[lowerCaseEvent]) then
                tip(
                    'Event "${lowerCaseEvent}" is emitted in component ' ..
                    '${formatComponentName(vm)} but the handler is registered for "${event}". ' ..
                    'Note that HTML attributes are case-insensitive and you cannot use ' ..
                    'v-on to listen to camelCase events when using in-DOM templates. ' ..
                    'You should probably use "${hyphenate(event)}" instead of "${event}".'
                )
            end
        end
        local cbs = vm._events[event]
        if (cbs) then
            cbs = #cbs > 1 and toArray(cbs) or cbs
            local info = 'event handler for "${event}"'
            local l = #cbs
            for i = 1, l do
                invokeWithErrorHandling(cbs[i], vm, info, vm, ...)
            end
        end
        return vm
    end
end

return {
    initEvents = initEvents,
    eventsMixin = eventsMixin,
    callHook = callHook,
    updateComponentListeners = updateComponentListeners
}