
local Watcher = require("observer.Watcher")
local Util = require("util.Util")
local CallContext = require("observer.CallContext")
local warn = Util.warn
local debug = debug
local pcall = pcall
local tinsert, tpop = table.insert, table.remove
local HookIds = CallContext.HookIds

-- The current target watcher being evaluated.
-- This is globally unique because only one watcher
-- can be evaluated at a time.
---@type CallContext
local target = nil
local targetStack = {}

---@param context CallContext
local function pushContext(context)
    tinsert(targetStack, context)
    target = context
    -- unwatch all children
    if context.children then
        for i = #context.children, 1, -1 do
            context.children[i]:teardown()
        end
        context.children = nil
    end
end

local function popContext()
    tpop(targetStack)
    target = targetStack[#targetStack]
end

---@param fn fun():nil
local function reactiveCall(fn)
    -- a content hold my watches and all children
    local context = CallContext.new()
    context:callHook(HookIds.beforeCreate)

    local reactiveFn = function()
        context:callHook(HookIds.beforeMount)
        pushContext(context)
        local status, value = pcall(fn)
        popContext()
        if not status then
            warn("error when reactiveCall:" .. value .. " stack :" .. debug.traceback())
            context:callHook(HookIds.errorCaptured, value)
            value = nil
        end
        context:callHook(HookIds.mounted, value)
    end
    -- watch and run one time
    local watcher = Watcher.new(context, reactiveFn, nil, {})
    -- add to parent
    if target then
        if not target.children then
            target.children = {}
        end
        tinsert(target.children, context)
    end
    context:callHook(HookIds.created, watcher.value)
    return context
end

return {
    reactiveCall = reactiveCall
}