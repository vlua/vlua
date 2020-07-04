require("@vue/reactivity")
require("runtime-core/src/scheduler")
require("@vue/shared")
require("runtime-core/src/component")
require("runtime-core/src/errorHandling/ErrorCodes")
require("runtime-core/src/errorHandling")
require("runtime-core/src/apiLifecycle")
require("runtime-core/src/renderer")
require("runtime-core/src/warning")

local invoke = function(fn)
  fn()
end

function watchEffect(effect, options)
  return doWatch(effect, nil, options)
end

local INITIAL_WATCHER_VALUE = {}
-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

function watch(source, cb, options)
  if __DEV__ and not isFunction(cb) then
    warn( +  + )
  end
  return doWatch(source, cb, options)
end

function doWatch(source, cb, )
  if  == nil then
    =EMPTY_OBJ
  end
  if __DEV__ and not cb then
    if immediate ~= undefined then
      warn( + )
    end
    if deep ~= undefined then
      warn( + )
    end
  end
  local warnInvalidSource = function(s)
    warn(s,  + )
  end
  
  local instance = currentInstance
  local getter = nil
  if isArray(source) then
    getter = function()
      source:map(function(s)
        if isRef(s) then
          return s.value
        elseif isReactive(s) then
          return traverse(s)
        elseif isFunction(s) then
          return callWithErrorHandling(s, instance, ErrorCodes.WATCH_GETTER)
        else
          __DEV__ and warnInvalidSource(s)
        end
      end
      )
    end
    
  
  elseif isRef(source) then
    getter = function()
      source.value
    end
    
  
  elseif isReactive(source) then
    getter = function()
      source
    end
    
    deep = true
  elseif isFunction(source) then
    if cb then
      getter = function()
        callWithErrorHandling(source, instance, ErrorCodes.WATCH_GETTER)
      end
      
    
    else
      getter = function()
        if instance and instance.isUnmounted then
          return
        end
        if cleanup then
          cleanup()
        end
        return callWithErrorHandling(source, instance, ErrorCodes.WATCH_CALLBACK, {onInvalidate})
      end
      
    
    end
  else
    getter = NOOP
    __DEV__ and warnInvalidSource(source)
  end
  if cb and deep then
    local baseGetter = getter
    getter = function()
      traverse(baseGetter())
    end
    
  
  end
  local cleanup = nil
  local onInvalidate = function(fn)
    runner.options.onStop = function()
      callWithErrorHandling(fn, instance, ErrorCodes.WATCH_CLEANUP)
    end
    
    cleanup = runner.options.onStop
  end
  
  if __NODE_JS__ and isInSSRComponentSetup then
    if not cb then
      getter()
    elseif immediate then
      callWithAsyncErrorHandling(cb, instance, ErrorCodes.WATCH_CALLBACK, {getter(), undefined, onInvalidate})
    end
    return NOOP
  end
  -- [ts2lua]lua中0和空字符串也是true，此处isArray(source)需要确认
  local oldValue = (isArray(source) and {{}} or {INITIAL_WATCHER_VALUE})[1]
  local applyCb = (cb and {function()
    if instance and instance.isUnmounted then
      return
    end
    local newValue = runner()
    if deep or hasChanged(newValue, oldValue) then
      if cleanup then
        cleanup()
      end
      -- [ts2lua]lua中0和空字符串也是true，此处oldValue == INITIAL_WATCHER_VALUE需要确认
      callWithAsyncErrorHandling(cb, instance, ErrorCodes.WATCH_CALLBACK, {newValue, (oldValue == INITIAL_WATCHER_VALUE and {undefined} or {oldValue})[1], onInvalidate})
      oldValue = newValue
    end
  end
  -- [ts2lua]lua中0和空字符串也是true，此处cb需要确认
  } or {undefined})[1]
  local scheduler = nil
  if flush == 'sync' then
    scheduler = invoke
  elseif flush == 'pre' then
    scheduler = function(job)
      if not instance or instance.isMounted then
        queueJob(job)
      else
        job()
      end
    end
    
  
  else
    scheduler = function(job)
      queuePostRenderEffect(job, instance and instance.suspense)
    end
    
  
  end
  local runner = effect(getter, {lazy=true, computed=true, onTrack=onTrack, onTrigger=onTrigger, scheduler=(applyCb and {function()
    scheduler(applyCb)
  end
  -- [ts2lua]lua中0和空字符串也是true，此处applyCb需要确认
  } or {scheduler})[1]})
  recordInstanceBoundEffect(runner)
  if applyCb then
    if immediate then
      applyCb()
    else
      oldValue = runner()
    end
  else
    runner()
  end
  return function()
    stop(runner)
    if instance then
      remove(runner)
    end
  end
  

end

function instanceWatch(this, source, cb, options)
  local publicThis = self.proxy
  local getter = (isString(source) and {function()
    -- [ts2lua]publicThis下标访问可能不正确
    publicThis[source]
  end
  -- [ts2lua]lua中0和空字符串也是true，此处isString(source)需要确认
  } or {source:bind(publicThis)})[1]
  local stop = watch(getter, cb:bind(publicThis), options)
  onBeforeUnmount(stop, self)
  return stop
end

function traverse(value, seen)
  if seen == nil then
    seen=Set()
  end
  if not isObject(value) or seen:has(value) then
    return value
  end
  seen:add(value)
  if isArray(value) then
    local i = 0
    repeat
      traverse(value[i+1], seen)
      i=i+1
    until not(i < #value)
  elseif value:instanceof(Map) then
    value:forEach(function(v, key)
      traverse(value:get(key), seen)
    end
    )
  elseif value:instanceof(Set) then
    value:forEach(function(v)
      traverse(v, seen)
    end
    )
  else
    for key in pairs(value) do
      -- [ts2lua]value下标访问可能不正确
      traverse(value[key], seen)
    end
  end
  return value
end
