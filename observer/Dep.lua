local config = require("config")
local Utils = require("observer.Utils")
local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local tpop = tremove
local removeArrayItem = Utils.removeArrayItem
local slice = Utils.slice
local class = Utils.class

local uid = 0

--[[
 * A dep is an observable that can have multiple
 * directives subscribing to it.
--]]
---@class Dep
---@field target Watcher
---@field id number
---@field subs Watcher[]
local Dep = class("Dep")
function Dep:ctor()
    uid = uid + 1
    self.id = uid
    self.subs = {}
end

---@param sub Watcher
function Dep:addSub(sub)
    tinsert(self.subs, sub)
end

---@param sub Watcher
function Dep:removeSub(sub)
    removeArrayItem(self.subs, sub)
end

function Dep:depend()
    if Dep.target then
        Dep.target:addDep(self)
    end
end

local sortSub = function(a, b)
    return a.id < b.id
end
function Dep:notify()
    -- stabilize the subscriber list first
    local subs = slice(self.subs)
    if (config.env ~= "production" and not config.async) then
        -- subs aren't sorted in scheduler if not running async
        -- we need to sort them now to make sure they fire in correct
        -- order
        tsort(subs, sortSub)
    end
    for i = 1, #subs do
        subs[i]:update()
    end
end

-- The current target watcher being evaluated.
-- This is globally unique because only one watcher
-- can be evaluated at a time.
Dep.target = nil
local targetStack = {}

---@param target Watcher
Dep.pushTarget = function(target)
    tinsert(targetStack, target)
    Dep.target = target
end

Dep.popTarget = function()
    tpop(targetStack)
    Dep.target = targetStack[#targetStack]
end

return Dep
