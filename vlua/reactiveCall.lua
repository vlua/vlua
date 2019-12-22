local Watcher = require("vlua.watcher")
local Util = require("vlua.util")
local CallContext = require("vlua.callContext")
local warn = Util.warn
local debug = debug
local pcall, xpcall = pcall, xpcall
local HookIds = CallContext.HookIds
local pushContext, popContext = CallContext.pushContext, CallContext.popContext

---@param fn fun():nil
local function reactiveCall(fn)
    -- a content hold my watches and all children
    local context = CallContext.new()

    local reactiveFn = function()
        context:emit(HookIds.unmount)
        pushContext(context)
        local value =
            xpcall(
            fn,
            function(msg)
                warn("error when reactiveCall:" .. msg .. " stack :" .. debug.traceback())
                context:emit(HookIds.errorCaptured, msg)
            end
        )
        popContext()
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
