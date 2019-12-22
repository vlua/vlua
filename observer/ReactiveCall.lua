local Watcher = require("observer.Watcher")
local Util = require("util.Util")
local CallContext = require("observer.CallContext")
local warn = Util.warn
local debug = debug
local pcall = pcall
local HookIds = CallContext.HookIds
local pushContext, popContext = CallContext.pushContext, CallContext.popContext

---@param fn fun():nil
local function reactiveCall(fn)
    -- a content hold my watches and all children
    local context = CallContext.new()

    local reactiveFn = function()
        context:emit(HookIds.unmount)
        pushContext(context)
        local status, value = pcall(fn)
        popContext()
        if not status then
            warn("error when reactiveCall:" .. value .. " stack :" .. debug.traceback())
            context:emit(HookIds.errorCaptured, value)
            value = nil
        end
        context:emit(HookIds.mounted, value)
    end
    -- watch and run one time
    local watcher = Watcher.new(nil, reactiveFn)

    context:once(
        HookIds.destroy,
        function()
            watcher:teardown()
        end
    )
    -- add to parent
    if CallContext.target then
        CallContext.target:once(
            HookIds.unmount,
            function()
                context:teardown()
            end
        )
    end
    return context
end

return {
    reactiveCall = reactiveCall
}
