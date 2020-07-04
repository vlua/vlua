require("trycatch")
require("runtime-core/src/component/LifecycleHooks")
require("runtime-core/src/warning")
require("@vue/shared")
require("runtime-core/src/errorHandling/ErrorCodes")

local ErrorTypeStrings = {LifecycleHooks.BEFORE_CREATE='beforeCreate hook', LifecycleHooks.CREATED='created hook', LifecycleHooks.BEFORE_MOUNT='beforeMount hook', LifecycleHooks.MOUNTED='mounted hook', LifecycleHooks.BEFORE_UPDATE='beforeUpdate hook', LifecycleHooks.UPDATED='updated', LifecycleHooks.BEFORE_UNMOUNT='beforeUnmount hook', LifecycleHooks.UNMOUNTED='unmounted hook', LifecycleHooks.ACTIVATED='activated hook', LifecycleHooks.DEACTIVATED='deactivated hook', LifecycleHooks.ERROR_CAPTURED='errorCaptured hook', LifecycleHooks.RENDER_TRACKED='renderTracked hook', LifecycleHooks.RENDER_TRIGGERED='renderTriggered hook', ErrorCodes.SETUP_FUNCTION='setup function', ErrorCodes.RENDER_FUNCTION='render function', ErrorCodes.WATCH_GETTER='watcher getter', ErrorCodes.WATCH_CALLBACK='watcher callback', ErrorCodes.WATCH_CLEANUP='watcher cleanup function', ErrorCodes.NATIVE_EVENT_HANDLER='native event handler', ErrorCodes.COMPONENT_EVENT_HANDLER='component event handler', ErrorCodes.VNODE_HOOK='vnode hook', ErrorCodes.DIRECTIVE_HOOK='directive hook', ErrorCodes.TRANSITION_HOOK='transition hook', ErrorCodes.APP_ERROR_HANDLER='app errorHandler', ErrorCodes.APP_WARN_HANDLER='app warnHandler', ErrorCodes.FUNCTION_REF='ref function', ErrorCodes.ASYNC_COMPONENT_LOADER='async component loader', ErrorCodes.SCHEDULER='scheduler flush. This is likely a Vue internals bug. ' .. 'Please open an issue at https://new-issue.vuejs.org/?repo=vuejs/vue-next'}
function callWithErrorHandling(fn, instance, type, args)
  local res = nil
  try_catch{
    main = function()
      -- [ts2lua]lua中0和空字符串也是true，此处args需要确认
      res = (args and {fn(...)} or {fn()})[1]
    end,
    catch = function(err)
      handleError(err, instance, type)
    end
  }
  return res
end

function callWithAsyncErrorHandling(fn, instance, type, args)
  if isFunction(fn) then
    local res = callWithErrorHandling(fn, instance, type, args)
    if res and isPromise(res) then
      res:catch(function(err)
        handleError(err, instance, type)
      end
      )
    end
    return res
  end
  local values = {}
  local i = 0
  repeat
    table.insert(values, callWithAsyncErrorHandling(fn[i+1], instance, type, args))
    i=i+1
  until not(i < #fn)
  return values
end

function handleError(err, instance, type)
  -- [ts2lua]lua中0和空字符串也是true，此处instance需要确认
  local contextVNode = (instance and {instance.vnode} or {nil})[1]
  if instance then
    local cur = instance.parent
    local exposedInstance = instance.proxy
    -- [ts2lua]ErrorTypeStrings下标访问可能不正确
    -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
    local errorInfo = (__DEV__ and {ErrorTypeStrings[type]} or {type})[1]
    while(cur)
    do
    local errorCapturedHooks = cur.ec
    if errorCapturedHooks then
      local i = 0
      repeat
        if errorCapturedHooks[i+1](err, exposedInstance, errorInfo) then
          return
        end
        i=i+1
      until not(i < #errorCapturedHooks)
    end
    cur = cur.parent
    end
    local appErrorHandler = instance.appContext.config.errorHandler
    if appErrorHandler then
      callWithErrorHandling(appErrorHandler, nil, ErrorCodes.APP_ERROR_HANDLER, {err, exposedInstance, errorInfo})
      return
    end
  end
  logError(err, type, contextVNode)
end

local forceRecover = false
function setErrorRecovery(value)
  forceRecover = value
end

function logError(err, type, contextVNode)
  if __DEV__ and (forceRecover or not __TEST__) then
    -- [ts2lua]ErrorTypeStrings下标访问可能不正确
    local info = ErrorTypeStrings[type]
    if contextVNode then
      pushWarningContext(contextVNode)
    end
    warn()
    console:error(err)
    if contextVNode then
      popWarningContext()
    end
  else
    error(err)
  end
end
