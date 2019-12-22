local config = require("config")
local Utils = require("observer.Utils")
local Util = require("util.Util")
local NextTick = require("util.NextTick")

local Events = require("instance.Events")
local callHook = Events.callHook

local warn, nextTick, devtools, inBrowser, isIE = Util.warn, NextTick.nextTick, Util.devtools, Util.inBrowser, Util.isIE

local slice = Utils.slice
local splice = Utils.splice
local tsort = table.sort
local tinsert = table.insert
local tremove = table.remove
local warn = print

local MAX_UPDATE_COUNT = 100

---@type Watcher[]
local queue = {}
---@type table<number, boolean>
local has = {}
---@type table<number, number>
local circular = {}
local waiting = false
local flushing = false
local index = 0--[[
 * Reset the scheduler's state.
 --]]
local function resetSchedulerState()
    index = 1
    queue = {}
    has = {}
    if (config.env ~= "production") then
        circular = {}
    end
    waiting = false
    flushing = false
end

local function compareQueue(a, b)
    return a.id < b.id
end
--[[
 * Flush both queues and run the watchers.
 --]]
local function flushSchedulerQueue()
    flushing = true
    ---@type Watcher
    local watcher
    ---@type integer
    local id

    -- Sort queue before flush.
    -- This ensures that:
    -- 1. Components are updated from parent to child. (because parent is always
    --    created before the child)
    -- 2. A component's user watchers are run before its render watcher (because
    --    user watchers are created before the render watcher)
    -- 3. If a component is destroyed during a parent component's watcher run,
    --    its watchers can be skipped.
    tsort(queue, compareQueue)

    -- do not cache length because more watchers might be pushed
    -- as we run existing watchers
    for index = 1, #queue do
        watcher = queue[index]
        if (watcher.before) then
            watcher:before()
        end
        id = watcher.id
        has[id] = nil
        watcher:run()
        -- in dev build, check and stop circular updates.
        if (config.env ~= "production" and has[id] ~= nil) then
            circular[id] = (circular[id] or 0) + 1
            if (circular[id] > MAX_UPDATE_COUNT) then
                warn(
                    "You may have an infinite update loop " +
                        (watcher.user and 'in watcher with expression "${watcher.expression}"' or
                            "in a component render function."),
                    watcher.vm
                )
                break
            end
        end
    end

    resetSchedulerState()

    -- devtool hook
    --[[ istanbul ignore if --]]
    if (devtools and config.devtools) then
        devtools.emit("flush")
    end
end

--[[
 * Push a watcher into the watcher queue.
 * Jobs with duplicate IDs will be skipped unless it's
 * pushed when the queue is being flushed.
 --]]
---@param watcher Watcher
local function queueWatcher(watcher)
    local id = watcher.id
    if (has[id] == nil) then
        has[id] = true
        if (not flushing) then
            tinsert(queue, watcher)
        else
            -- if already flushing, splice the watcher based on its id
            -- if already past its id, it will be run next immediately.
            local i = queue.length - 1
            while (i > index and queue[i].id > watcher.id) do
                i = i - 1
            end
            splice(queue, i + 1, 0, watcher)
        end
        -- queue the flush
        if (not waiting) then
            waiting = true

            if (config.env ~= "production" and not config.async) then
                flushSchedulerQueue()
                return
            end
            nextTick(flushSchedulerQueue)
        end
    end
end

return {
    queueWatcher = queueWatcher
}
