local nextTick = require("reactivity.nextTick").nextTick
local type, tinsert,tremove, tsort = type, table.insert,table.remove, table.sort
local __DEV__ = require("reactivity.config").__DEV__
local ErrorCodes = require("reactivity.ErrorCodes")
local reactiveUtils = require("reactivity.reactiveUtils")
local warn, callWithErrorHandling = reactiveUtils.warn, reactiveUtils.callWithErrorHandling

local queue = {}
local postFlushCbs = {}
local isFlushing = false
local isFlushPending = false
local RECURSION_LIMIT = 100

local function queue_includes(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

local getId = function(job)
    return job.id == nil and 0 or job.id
end

local function checkRecursiveUpdates(seen, fn)
    if not seen[fn] then
        seen[fn] = 1
    else
        local count = nil
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
    if #postFlushCbs then
        local cbs = {...}
        postFlushCbs = {}
        if __DEV__ then
            seen = seen or {}
        end
        for i = 1, #cbs do
            if __DEV__ then
                checkRecursiveUpdates(cbs[i])
            end
            cbs[i]()
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
    tsort(
        queue,
        function(a, b)
            return getId(a) - getId(b)
        end
    )
    job = tremove(queue, 1)
    while (job) do
        if job == nil then
            break
        end
        if __DEV__ then
            checkRecursiveUpdates(job)
        end
        callWithErrorHandling(job, nil, ErrorCodes.SCHEDULER)
        job = tremove(queue, 1)
    end

    flushPostFlushCbs(seen)
    isFlushing = false
    if #queue or #postFlushCbs then
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
    if not queue_includes(queue, job) then
        tinsert(queue, job)
        queueFlush()
    end
end

local function invalidateJob(job)
    local i = queue:find(job)
    if i > -1 then
        queue[i + 1] = nil
    end
end

local function queuePostFlushCb(cb)
    if type(cb) ~= 'table' then
        tinsert(postFlushCbs, cb)
    else
        tinsert(postFlushCbs, ...)
    end
    queueFlush()
end

return {
  queueJob = queueJob,
  queuePostFlushCb = queuePostFlushCb
}