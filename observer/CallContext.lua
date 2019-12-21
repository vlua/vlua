local Lang = require("util.Lang")
local tinsert, tpop = table.insert, table.remove
---@class CallContext
---@field children CallContext[]
---@field events table<string, fun():nil>
local CallContext = Lang.class("EvalContent")

local HookIds = {
    beforeMount = 'beforeMount',
    mounted = 'mounted',
    beforeCreate = "beforeCreate",
    created = "created",
    beforeDestroy = "beforeDestroy",
    destroyed = "destroyed",
    errorCaptured = "errorCaptured",
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
    -- unwatch all children
    if context.children then
        for i = #context.children, 1, -1 do
            context.children[i]:teardown()
        end
        context.children = nil
    end
end

function CallContext.popContext()
    tpop(targetStack)
    CallContext.target = targetStack[#targetStack]
end

function CallContext:constructor()
    ---@type Watcher[]
    self._watchers = {}
end

function CallContext:emit(event, ...)
    local events = self.events
    if not events then
        return
    end
    local cbs = events[event]
    if not cbs then
        return
    end
    for _, cb in pairs(cbs) do
        cb(...)
    end
end

function CallContext:on(event, cb)
    local events = self.events
    if not events then
        events = {}
        self.events = events
    end
    local cbs = events[event]
    if not cbs then
        cbs = {}
        events[event] = cbs
    end
    cbs[cb] = cb
end

function CallContext:off(event, cb)
    local events = self.events
    if events then
        local cbs = events[event]
        if cbs then
            cbs[cb] = nil
        end
    end
end

function CallContext:once(event, cb)
    local function callback(...)
        self:off(event, callback)
        cb(...)
    end
    self:on(event, callback)
end

--- unwatch all watcher and children's watcher
function CallContext:teardown()
    self:emit(HookIds.beforeDestroy)
    -- unwatch my watcher
    for i = #self._watchers, 1, -1 do
        self._watchers[i]:teardown()
    end
    self._watchers = nil
    -- unwatch all children
    if self.children then
        for i = #self.children, 1, -1 do
            self.children[i]:teardown()
        end
        self.children = nil
    end
    self:emit(HookIds.destroyed)
    self.events = nil
end

return CallContext