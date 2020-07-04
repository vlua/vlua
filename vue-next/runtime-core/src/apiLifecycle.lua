require("runtime-core/src/component/LifecycleHooks")
require("runtime-core/src/component")
require("runtime-core/src/errorHandling")
require("runtime-core/src/warning")
require("@vue/reactivity")

undefined
function injectHook(type, hook, target, prepend)
  if target == nil then
    target=currentInstance
  end
  if prepend == nil then
    prepend=false
  end
  if target then
    -- [ts2lua]target下标访问可能不正确
    -- [ts2lua]target下标访问可能不正确
    local hooks = target[type] or (target[type] = {})
    local wrappedHook = hook.__weh or (hook.__weh = function(...)
      if target.isUnmounted then
        return
      end
      pauseTracking()
      setCurrentInstance(target)
      local res = callWithAsyncErrorHandling(hook, target, type, args)
      setCurrentInstance(nil)
      resetTracking()
      return res
    end
    )
    if prepend then
      hooks:unshift(wrappedHook)
    else
      table.insert(hooks, wrappedHook)
    end
  elseif __DEV__ then
    local apiName = nil
    -- [ts2lua]lua中0和空字符串也是true，此处__FEATURE_SUSPENSE__需要确认
    warn( +  +  + (__FEATURE_SUSPENSE__ and { + } or {})[1])
  end
end

local createHook = function(lifecycle)
  function(hook, target = currentInstance)
    if target == nil then
      target=currentInstance
    end
    not isInSSRComponentSetup and injectHook(lifecycle, hook, target)
  end
  

end

local onBeforeMount = createHook(LifecycleHooks.BEFORE_MOUNT)
local onMounted = createHook(LifecycleHooks.MOUNTED)
local onBeforeUpdate = createHook(LifecycleHooks.BEFORE_UPDATE)
local onUpdated = createHook(LifecycleHooks.UPDATED)
local onBeforeUnmount = createHook(LifecycleHooks.BEFORE_UNMOUNT)
local onUnmounted = createHook(LifecycleHooks.UNMOUNTED)
local onRenderTriggered = createHook(LifecycleHooks.RENDER_TRIGGERED)
local onRenderTracked = createHook(LifecycleHooks.RENDER_TRACKED)
local onErrorCaptured = function(hook, target = currentInstance)
  if target == nil then
    target=currentInstance
  end
  injectHook(LifecycleHooks.ERROR_CAPTURED, hook, target)
end
