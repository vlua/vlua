local Lang = require("util.Lang")

---@class CallContext
---@field children CallContext[]
---@field hooks table<string, fun():nil>
local CallContext = Lang.class("EvalContent")

local HookIds = {
    beforeMount = 'beforeMount',
    mounted = 'mounted',
    beforeCreate = "beforeCreate",
    created = "created",
    beforeUpdate = "beforeUpdate",
    updated = "updated",
    beforeDestroy = "beforeDestroy",
    destroyed = "destroyed",
    activated = "activated",
    deactivated = "deactivated",
    errorCaptured = "errorCaptured",
}
CallContext.HookIds = HookIds

function CallContext:constructor()
    ---@type Watcher[]
    self._watchers = {}
end

function CallContext:callHook(hook, ...)
    if not self.hooks then
        return
    end
    local hooks = self.hooks[hook]
    for i = 1, #hooks do
        hooks[i](...)
    end
end

--- unwatch all watcher and children's watcher
function CallContext:teardown()
    self:callHook(HookIds.beforeDestroy)
    -- unwatch my watcher
    for i = #self._watchers, 1, -1 do
        self._watchers[i]:teardown()
    end
    -- unwatch all children
    if self.children then
        for i = #self.children, 1, -1 do
            self.children[i]:teardown()
        end
        self.children = nil
    end
    self._watchers = nil
    self.children = nil
    self:callHook(HookIds.destroyed)
    self.hooks = nil
end

return CallContext