
local Watcher = require("observer.Watcher")
local Util = require("util.Util")
local Lang = require("util.Lang")
local warn = Util.warn
local debug = debug
local pcall = pcall
local tinsert, tpop = table.insert, table.remove

---@class EvalContent
---@field children EvalContent[]
local EvalContent = Lang.class("EvalContent")

function EvalContent:constructor()
    self._watchers = {}
end

function EvalContent:tearDown()
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
---@type Eval
local target = nil
local targetStack = {}

---@param content EvalContent
local function pushEval(content)
    tinsert(targetStack, content)
    target = content
    -- unwatch all children
    if content.children then
        for i = #content.children, 1, -1 do
            content.children[i]:tearDown()
        end
        content.children = nil
    end
end

local function popEval()
    tpop(targetStack)
    target = targetStack[#targetStack]
end

---@param fn fun():nil
local function reactiveEval(fn)
    -- a content hold my watches and all children
    local content = EvalContent.new()

    local reactiveFn = function()
        pushEval(content)
        local status, err = pcall(fn)
        popEval()
        if not status then
            warn("error when reactiveEval:" .. err .. " stack :" .. debug.traceback())
        end
    end
    -- watch and run one time
    Watcher.new(content, reactiveFn, reactiveFn, {})

    -- add to parent
    if target then
        if not target.children then
            target.children = {}
        end
        tinsert(target.children, content)
    end
    return content
end

return {
    reactiveEval = reactiveEval
}