require("runtime-core/src/errorHandling/ErrorCodes")
require("runtime-core/src/errorHandling")
require("@vue/shared")

local queue = {}
local postFlushCbs = {}
local p = Promise:resolve()
local isFlushing = false
local isFlushPending = false
local RECURSION_LIMIT = 100
function nextTick(fn)
  -- [ts2lua]lua中0和空字符串也是true，此处fn需要确认
  return (fn and {p:tsvar_then(fn)} or {p})[1]
end

function queueJob(job)
  if not queue:includes(job) then
    table.insert(queue, job)
    queueFlush()
  end
end

function invalidateJob(job)
  local i = queue:find(job)
  if i > -1 then
    queue[i+1] = nil
  end
end

function queuePostFlushCb(cb)
  if not isArray(cb) then
    table.insert(postFlushCbs, cb)
  else
    table.insert(postFlushCbs, ...)
  end
  queueFlush()
end

function queueFlush()
  if not isFlushing and not isFlushPending then
    isFlushPending = true
    nextTick(flushJobs)
  end
end

function flushPostFlushCbs(seen)
  if #postFlushCbs then
    local cbs = {...}
    
    postFlushCbs.length = 0
    if __DEV__ then
      seen = seen or Map()
    end
    local i = 0
    repeat
      if __DEV__ then
        checkRecursiveUpdates(cbs[i+1])
      end
      cbs[i+1]()
      i=i+1
    until not(i < #cbs)
  end
end

local getId = function(job)
  -- [ts2lua]lua中0和空字符串也是true，此处job.id == nil需要确认
  (job.id == nil and {Infinity} or {job.id})[1]
end

function flushJobs(seen)
  isFlushPending = false
  isFlushing = true
  local job = nil
  if __DEV__ then
    seen = seen or Map()
  end
  queue:sort(function(a, b)
    getId() - getId()
  end
  )
  while(job = queue:shift() ~= undefined)
  do
  if job == nil then
    break
  end
  if __DEV__ then
    checkRecursiveUpdates(job)
  end
  callWithErrorHandling(job, nil, ErrorCodes.SCHEDULER)
  end
  flushPostFlushCbs(seen)
  isFlushing = false
  if #queue or #postFlushCbs then
    flushJobs(seen)
  end
end

function checkRecursiveUpdates(seen, fn)
  if not seen:has(fn) then
    seen:set(fn, 1)
  else
    local count = nil
    if count > RECURSION_LIMIT then
      error(Error('Maximum recursive updates exceeded. ' .. "You may have code that is mutating state in your component's " .. 'render function or updated hook or watcher source function.'))
    else
      seen:set(fn, count + 1)
    end
  end
end
