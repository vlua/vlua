local Util = require("vlua.util")
local Watcher = require("vlua.watcher")
local pairs = pairs
local warn, isRef = Util.warn, Util.isRef
local xpcall = xpcall
local tinsert, tpop = table.insert, table.remove

---@class Binder
---@field children Binder[]
---@field events table<string, fun():nil>
local Binder = Util.class("Binder")

function Binder:ctor(source, parent)
    self.source = source
    self.parent = parent
end

local HookIds = {
    mounted = 1,
    unmount = 2,
    destroy = 3,
    errorCaptured = 4
}
Binder.HookIds = HookIds

-- The current target watcher being evaluated.
-- This is globally unique because only one watcher
-- can be evaluated at a time.
---@type Binder
local target = nil
local targetStack = {}

---@param context Binder
local function pushContext(context)
    tinsert(targetStack, context)
    target = context
end

local function popContext()
    tpop(targetStack)
    target = targetStack[#targetStack]
end

function Binder:emit(event, ...)
    local events = self[event]
    if not events then
        return
    end
    for _, cb in pairs(events) do
        cb(...)
    end
end

function Binder:on(event, cb)
    local events = self[event]
    if not events then
        events = {}
        self[event] = events
    end
    events[cb] = cb
end

function Binder:off(event, cb)
    local events = self[event]
    if events then
        events[cb] = nil
    end
end

function Binder:once(event, cb)
    local function callback(...)
        self:off(event, callback)
        cb(...)
    end
    self:on(event, callback)
end

--- unwatch all watcher and teardown
function Binder:teardown()
    self:emit(HookIds.unmount)
    self:emit(HookIds.destroy)
end

function Binder:createChild(source)
    local child = Binder.new(source, self)
    self:onUnmount(
        function()
            child:teardown()
        end
    )
    return child
end


function Binder.apiNewBinder(source)
    if target then
        return target:createChild(source)
    else
        return Binder.new(source)
    end
end

--- create a reactive function
---@param fn fun():nil
function Binder:newFunction(fn)
    -- a content hold my watches and all children
    ---@type Binder
    local binder = self and self:createChild() or Binder.new()

    local reactiveFn = function()
        binder:emit(HookIds.unmount)
        pushContext(binder)
        local value =
            xpcall(
            fn,
            function(msg)
                warn("error when new:" .. msg .. " stack :" .. debug.traceback())
                binder:emit(HookIds.errorCaptured, msg)
            end,
            binder
        )
        popContext(binder)
        binder:emit(HookIds.mounted, value)
    end
    -- watch and run one time
    local watcher = Watcher.new(nil, reactiveFn)
    -- only teardown when destory, but not unmount
    binder:once(
        HookIds.destroy,
        function()
            watcher:teardown()
        end
    )
    return binder
end

--- create a reactive function
---@param fn fun():nil
function Binder.apiNew(fn)
    return Binder.newFunction(target, fn)
end

function Binder:onMounted(cb)
    self:on(HookIds.mounted, cb)
end

function Binder:onUnmount(cb)
    self:on(HookIds.unmount, cb)
end

function Binder:onDestroy(cb)
    self:on(HookIds.destroy, cb)
end

function Binder:onErrorCaptured(cb)
    self:on(HookIds.errorCaptured, cb)
end

--- call cb when expr changed
---@param expOrFn string | Function | Ref | Computed
---@param cb Function
---@param immediacy boolean @call cb when start
function Binder:watch(expOrFn, cb, immediacy)
    -- support to watch ref or computed value
    if isRef(expOrFn) then
        local ref = expOrFn
        expOrFn = function()
            return ref.value
        end
    end
    -- watch and run one time
    local watcher = Watcher.new(self.source, expOrFn, cb)
    self:onUnmount(
        function()
            watcher:teardown()
        end
    )
    if immediacy then
        cb(self.source, watcher.value, watcher.value)
    end
end
return Binder
