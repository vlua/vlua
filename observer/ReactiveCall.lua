
local Watcher = require("observer.Watcher")
local Util = require("util.Util")
local Lang = require("util.Lang")
local warn = Util.warn
local debug = debug
local pcall = pcall
local tinsert, tpop = table.insert, table.remove

---@class CallContext
---@field children CallContext[]
local CallContext = Lang.class("EvalContent")

function CallContext:constructor()
    ---@type Watcher[]
    self._watchers = {}
end

--- unwatch all watcher and children's watcher
function CallContext:tearDown()
    -- unwatch my watcher
    for i = #self._watchers, 1, -1 do
        self._watchers[i]:teardown()
    end
    self._watchers = nil

    -- unwatch all children
    if self.children then
        for i = #self.children, 1, -1 do
            self.children[i]:tearDown()
        end
        self.children = nil
    end
end

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
            context.children[i]:tearDown()
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

    local reactiveFn = function()
        pushContext(context)
        local status, value = pcall(fn)
        popContext()
        if not status then
            warn("error when reactiveCall:" .. value .. " stack :" .. debug.traceback())
        end
    end
    -- watch and run one time
    local watcher = Watcher.new(context, reactiveFn, reactiveFn, {})
    -- add to parent
    if target then
        if not target.children then
            target.children = {}
        end
        tinsert(target.children, context)
    end
    return context
end

return {
    reactiveCall = reactiveCall
}