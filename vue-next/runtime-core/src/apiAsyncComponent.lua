require("runtime-core/src/component")
require("@vue/shared")
require("runtime-core/src/vnode")
require("runtime-core/src/apiDefineComponent")
require("runtime-core/src/warning")
require("@vue/reactivity")
require("runtime-core/src/errorHandling")
require("runtime-core/src/errorHandling/ErrorCodes")

function defineAsyncComponent(source)
  if isFunction(source) then
    source = {loader=source}
  end
  local  = source
  local pendingRequest = nil
  local resolvedComp = nil
  local retries = 0
  local retry = function()
    retries=retries+1
    pendingRequest = nil
    return load()
  end
  
  local load = function()
    local thisRequest = nil
    return pendingRequest or (pendingRequest = loader():catch(function(err)
      -- [ts2lua]lua中0和空字符串也是true，此处err:instanceof(Error)需要确认
      err = (err:instanceof(Error) and {err} or {Error(String(err))})[1]
      if userOnError then
        return Promise(function(resolve, reject)
          local userRetry = function()
            resolve(retry())
          end
          
          local userFail = function()
            reject(err)
          end
          
          userOnError(err, userRetry, userFail, retries + 1)
        end
        )
      else
        error(err)
      end
    end
    ):tsvar_then(function(comp)
      if thisRequest ~= pendingRequest and pendingRequest then
        return pendingRequest
      end
      if __DEV__ and not comp then
        warn( + )
      end
      -- [ts2lua]comp下标访问可能不正确
      if comp and (comp.__esModule or comp[Symbol.toStringTag] == 'Module') then
        comp = comp.default
      end
      if ((__DEV__ and comp) and not isObject(comp)) and not isFunction(comp) then
        error(Error())
      end
      resolvedComp = comp
      return comp
    end
    )
    thisRequest = pendingRequest)
  end
  
  return defineComponent({__asyncLoader=load, name='AsyncComponentWrapper', setup=function()
    local instance = nil
    if resolvedComp then
      return function()
        createInnerComp(instance)
      end
      
    
    end
    local onError = function(err)
      pendingRequest = nil
      handleError(err, instance, ErrorCodes.ASYNC_COMPONENT_LOADER)
    end
    
    if (__FEATURE_SUSPENSE__ and suspensible) and instance.suspense or __NODE_JS__ and isInSSRComponentSetup then
      return load():tsvar_then(function(comp)
        return function()
          createInnerComp(comp, instance)
        end
        
      
      end
      ):catch(function(err)
        onError(err)
        return function()
          -- [ts2lua]lua中0和空字符串也是true，此处errorComponent需要确认
          (errorComponent and {createVNode(errorComponent, {error=err})} or {nil})[1]
        end
        
      
      end
      )
    end
    local loaded = ref(false)
    local error = ref()
    local delayed = ref(not (not delay))
    if delay then
      setTimeout(function()
        delayed.value = false
      end
      , delay)
    end
    if timeout ~= nil then
      setTimeout(function()
        if not loaded.value then
          local err = Error()
          onError(err)
          error.value = err
        end
      end
      , timeout)
    end
    load():tsvar_then(function()
      loaded.value = true
    end
    ):catch(function(err)
      onError(err)
      error.value = err
    end
    )
    return function()
      if loaded.value and resolvedComp then
        return createInnerComp(resolvedComp, instance)
      elseif error.value and errorComponent then
        return createVNode(errorComponent, {error=error.value})
      elseif loadingComponent and not delayed.value then
        return createVNode(loadingComponent)
      end
    end
    
  
  end
  })
end

function createInnerComp(comp, )
  return createVNode(comp, props, children)
end
