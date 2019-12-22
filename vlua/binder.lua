local Util = require("vlua.util")
local Watcher = require('vlua.watcher')
local tinsert, tpop = table.insert, table.remove
local pairs = pairs

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
    errorCaptured = 4,
}
Binder.HookIds = HookIds

-- The current target watcher being evaluated.
-- This is globally unique because only one watcher
-- can be evaluated at a time.
---@type Binder
Binder.target = nil
local targetStack = {}

---@param context Binder
function Binder.pushContext(context)
    tinsert(targetStack, context)
    Binder.target = context
end

function Binder.popContext()
    tpop(targetStack)
    Binder.target = targetStack[#targetStack]
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
    self:autoTeardown(function()
        child:teardown()
    end)
    return child
end

function Binder:autoTeardown(teardownFn)
    self:once(
        HookIds.unmount,
        function()
            teardownFn()
        end
    )
end

--- call cb when expr changed
---@param expOrFn string | Function
---@param cb Function
---@param immediacy boolean @call cb when start
function Binder:watch(expOrFn, cb, immediacy)
    -- watch and run one time
    local watcher = Watcher.new(self.source, expOrFn, cb)
    self:autoTeardown(function()
        watcher:teardown()
    end)
    if immediacy then
        cb(self.source, watcher.value, watcher.value)
    end
end
return Binder