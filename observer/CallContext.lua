local Lang = require("util.Lang")
local tinsert, tpop = table.insert, table.remove
local pairs = pairs

---@class CallContext
---@field children CallContext[]
---@field events table<string, fun():nil>
local CallContext = Lang.class("EvalContent")
function CallContext:constructor()
end

local HookIds = {
    mounted = 1,
    unmount = 2,
    destroy = 3,
    errorCaptured = 4,
}
CallContext.HookIds = HookIds

-- The current target watcher being evaluated.
-- This is globally unique because only one watcher
-- can be evaluated at a time.
---@type CallContext
CallContext.target = nil
local targetStack = {}

---@param context CallContext
function CallContext.pushContext(context)
    tinsert(targetStack, context)
    CallContext.target = context
end

function CallContext.popContext()
    tpop(targetStack)
    CallContext.target = targetStack[#targetStack]
end

function CallContext:emit(event, ...)
    local events = self[event]
    if not events then
        return
    end
    for _, cb in pairs(events) do
        cb(...)
    end
end

function CallContext:on(event, cb)
    local events = self[event]
    if not events then
        events = {}
        self[event] = events
    end
    events[cb] = cb
end

function CallContext:off(event, cb)
    local events = self[event]
    if events then
        events[cb] = nil
    end
end

function CallContext:once(event, cb)
    local function callback(...)
        self:off(event, callback)
        cb(...)
    end
    self:on(event, callback)
end

--- unwatch all watcher and teardown
function CallContext:teardown()
    self:emit(HookIds.unmount)
    self:emit(HookIds.destroy)
end

return CallContext