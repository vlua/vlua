
local Watcher = require("observer.Watcher")
local Util = require("util.Util")
local CallContext = require("observer.CallContext")
local warn = Util.warn
local debug = debug
local pcall = pcall
local tinsert = table.insert
local HookIds = CallContext.HookIds
local pushContext, popContext = CallContext.pushContext, CallContext.popContext

---@param fn fun():nil
local function reactiveCall(fn)
    -- a content hold my watches and all children
    local context = CallContext.new()

    local reactiveFn = function()
        context:emit(HookIds.update)
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
    local watcher = Watcher.new(context, reactiveFn, nil, {})
    -- add to parent
    local target = CallContext.target
    if target then
        local children = target.children
        if not children then
            children = {}
            target.children = children
        end
        tinsert(children, context)
    end
    context:emit(HookIds.created, watcher.value)
    return context
end

return {
    reactiveCall = reactiveCall
}