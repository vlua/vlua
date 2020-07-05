local nextTick = require("reactivity.nextTick").nextTick
local select, pairs, type, tinsert, tremove, tsort = select, pairs, type, table.insert, table.remove, table.sort
local __DEV__ = require("reactivity.config").__DEV__
local ErrorCodes = require("reactivity.ErrorCodes")
local reactiveUtils = require("reactivity.reactiveUtils")
local warn, callWithErrorHandling, array_includes =
    reactiveUtils.warn,
    reactiveUtils.callWithErrorHandling,
    reactiveUtils.array_includes

local queue = {}
local postFlushCbs = {}
local isFlushing = false
local isFlushPending = false
local RECURSION_LIMIT = 100
local INFINITE = 1e100

local getId = function(job)
    return type(job) == "function" and INFINITE or job.id
end

local function checkRecursiveUpdates(seen, fn)
    if not seen[fn] then
        seen[fn] = 1
    else
        local count = seen[fn]
        if count > RECURSION_LIMIT then
            warn(
                "Maximum recursive updates exceeded. " ..
                    "You may have code that is mutating state in your component's " ..
                        "render function or updated hook or watcher source function."
            )
        else
            seen[fn] = count + 1
        end
    end
end

local function flushPostFlushCbs(seen)
    if #postFlushCbs > 0 then
        -- 去重
        local cbs = {}
        for i = 1 , #postFlushCbs do
            cbs[postFlushCbs[i]] = true
        end
        postFlushCbs = {}
        if __DEV__ then
            seen = seen or {}
        end
        for cb in pairs(cbs) do
            if __DEV__ then
                checkRecursiveUpdates(seen, cb)
            end
            cb()
        end
    end
end

local function flushJobs(seen)
    isFlushPending = false
    isFlushing = true
    local job = nil
    if __DEV__ then
        seen = seen or {}
    end
    -- Sort queue before flush.
    -- This ensures that:
    -- 1. Components are updated from parent to child. (because parent is always
    --    created before the child so its render effect will have smaller
    --    priority number)
    -- 2. If a component is unmounted during a parent component's update,
    --    its update can be skipped.
    -- Jobs can never be null before flush starts, since they are only invalidated
    -- during execution of another flushed job.
    tsort(
        queue,
        function(a, b)
            return getId(a) < getId(b)
        end
    )
    job = tremove(queue, 1)
    while (job) do
        if job == nil then
            break
        end
        if __DEV__ then
            checkRecursiveUpdates(seen, job)
        end
        callWithErrorHandling(job, nil, ErrorCodes.SCHEDULER)
        job = tremove(queue, 1)
    end

    flushPostFlushCbs(seen)
    isFlushing = false

    -- some postFlushCb queued jobs!
    -- keep flushing until it drains.
    if #queue > 0 or #postFlushCbs > 0 then
        flushJobs(seen)
    end
end

local function queueFlush()
    if not isFlushing and not isFlushPending then
        isFlushPending = true
        nextTick(flushJobs)
    end
end

local function queueJob(job)
    if not array_includes(queue, job) then
        tinsert(queue, job)
        queueFlush()
    end
end

local function invalidateJob(job)
    for i, v in ipairs(queue) do
        if v == job then
            table.remove(queue, i)
            return
        end
    end
end

local function queuePostFlushCb(...)
    local count = select("#", ...)
    for i = 1, count do
        local cb = select(i, ...)
        if cb then
            tinsert(postFlushCbs, cb)
        end
    end
    queueFlush()
end

return {
    queueJob = queueJob,
    invalidateJob = invalidateJob,
    queuePostFlushCb = queuePostFlushCb
}
