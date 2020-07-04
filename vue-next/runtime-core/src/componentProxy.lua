require("runtime-core/src/scheduler")
require("runtime-core/src/apiWatch")
require("@vue/shared")
require("@vue/reactivity")
require("@vue/reactivity/ReactiveFlags")
require("@vue/reactivity/TrackOpTypes")
require("runtime-core/src/componentOptions")
require("runtime-core/src/componentProps")
require("runtime-core/src/componentRenderUtils")
require("runtime-core/src/warning")
local AccessTypes = {
  SETUP = 0,
  DATA = 1,
  PROPS = 2,
  CONTEXT = 3,
  OTHER = 4
}

local publicPropertiesMap = extend(Object:create(nil), {tsvar_=function(i)
  i
end
, tsvar_el=function(i)
  i.vnode.el
end
, tsvar_data=function(i)
  i.data
end
, tsvar_props=function(i)
  -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
  (__DEV__ and {shallowReadonly(i.props)} or {i.props})[1]
end
, tsvar_attrs=function(i)
  -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
  (__DEV__ and {shallowReadonly(i.attrs)} or {i.attrs})[1]
end
, tsvar_slots=function(i)
  -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
  (__DEV__ and {shallowReadonly(i.slots)} or {i.slots})[1]
end
, tsvar_refs=function(i)
  -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
  (__DEV__ and {shallowReadonly(i.refs)} or {i.refs})[1]
end
, tsvar_parent=function(i)
  i.parent and i.parent.proxy
end
, tsvar_root=function(i)
  i.root and i.root.proxy
end
, tsvar_emit=function(i)
  i.emit
end
, tsvar_options=function(i)
  -- [ts2lua]lua中0和空字符串也是true，此处__FEATURE_OPTIONS__需要确认
  (__FEATURE_OPTIONS__ and {resolveMergedOptions(i)} or {i.type})[1]
end
, tsvar_forceUpdate=function(i)
  function()
    queueJob(i.update)
  end
  

end
, tsvar_nextTick=function()
  nextTick
end
, tsvar_watch=(__FEATURE_OPTIONS__ and {function(i)
  instanceWatch:bind(i)
end
-- [ts2lua]lua中0和空字符串也是true，此处__FEATURE_OPTIONS__需要确认
} or {NOOP})[1]})
local PublicInstanceProxyHandlers = {get=function(, key)
  local  = instance
  if key == ReactiveFlags.SKIP then
    return true
  end
  local normalizedProps = nil
  if key[0+1] ~= '$' then
    -- [ts2lua]()下标访问可能不正确
    local n = ()[key]
    if n ~= undefined then
      local switch = {
        [AccessTypes.SETUP] = function()
          -- [ts2lua]setupState下标访问可能不正确
          return setupState[key]
        end,
        [AccessTypes.DATA] = function()
          -- [ts2lua]data下标访问可能不正确
          return data[key]
        end,
        [AccessTypes.CONTEXT] = function()
          -- [ts2lua]ctx下标访问可能不正确
          return ctx[key]
        end,
        [AccessTypes.PROPS] = function()
          -- [ts2lua]()下标访问可能不正确
          return ()[key]
        end
      }
      local casef = switch[n]
      if not casef then casef = switch["default"] end
      if casef then casef() end
    elseif setupState ~= EMPTY_OBJ and hasOwn(setupState, key) then
      -- [ts2lua]()下标访问可能不正确
      ()[key] = AccessTypes.SETUP
      -- [ts2lua]setupState下标访问可能不正确
      return setupState[key]
    elseif data ~= EMPTY_OBJ and hasOwn(data, key) then
      -- [ts2lua]()下标访问可能不正确
      ()[key] = AccessTypes.DATA
      -- [ts2lua]data下标访问可能不正确
      return data[key]
    elseif (normalizedProps = normalizePropsOptions(type)[0+1]) and hasOwn(normalizedProps, key) then
      -- [ts2lua]()下标访问可能不正确
      ()[key] = AccessTypes.PROPS
      -- [ts2lua]()下标访问可能不正确
      return ()[key]
    elseif ctx ~= EMPTY_OBJ and hasOwn(ctx, key) then
      -- [ts2lua]()下标访问可能不正确
      ()[key] = AccessTypes.CONTEXT
      -- [ts2lua]ctx下标访问可能不正确
      return ctx[key]
    else
      -- [ts2lua]()下标访问可能不正确
      ()[key] = AccessTypes.OTHER
    end
  end
  -- [ts2lua]publicPropertiesMap下标访问可能不正确
  local publicGetter = publicPropertiesMap[key]
  local cssModule = nil
  local globalProperties = nil
  if publicGetter then
    if key == '$attrs' then
      track(instance, TrackOpTypes.GET, key)
      __DEV__ and markAttrsAccessed()
    end
    return publicGetter(instance)
  -- [ts2lua]cssModule下标访问可能不正确
  elseif (cssModule = type.__cssModules) and (cssModule = cssModule[key]) then
    return cssModule
  elseif ctx ~= EMPTY_OBJ and hasOwn(ctx, key) then
    -- [ts2lua]()下标访问可能不正确
    ()[key] = AccessTypes.CONTEXT
    -- [ts2lua]ctx下标访问可能不正确
    return ctx[key]
  elseif globalProperties = appContext.config.globalProperties; hasOwn(globalProperties, key) then
    -- [ts2lua]globalProperties下标访问可能不正确
    return globalProperties[key]
  elseif (__DEV__ and currentRenderingInstance) and key:find('__v') ~= 0 then
    if (data ~= EMPTY_OBJ and key[0+1] == '$') and hasOwn(data, key) then
      warn( + )
    else
      warn( + )
    end
  end
end
, set=function(, key, value)
  local  = instance
  if setupState ~= EMPTY_OBJ and hasOwn(setupState, key) then
    -- [ts2lua]setupState下标访问可能不正确
    setupState[key] = value
  elseif data ~= EMPTY_OBJ and hasOwn(data, key) then
    -- [ts2lua]data下标访问可能不正确
    data[key] = value
  elseif instance.props[key] then
    __DEV__ and warn(instance)
    return false
  end
  if key[0+1] == '$' and instance[key:slice(1)] then
    __DEV__ and warn( + , instance)
    return false
  else
    if __DEV__ and instance.appContext.config.globalProperties[key] then
      Object:defineProperty(ctx, key, {enumerable=true, configurable=true, value=value})
    else
      -- [ts2lua]ctx下标访问可能不正确
      ctx[key] = value
    end
  end
  return true
end
, has=function(, key)
  local normalizedProps = nil
  -- [ts2lua]()下标访问可能不正确
  return (((((()[key] ~= undefined or data ~= EMPTY_OBJ and hasOwn(data, key)) or setupState ~= EMPTY_OBJ and hasOwn(setupState, key)) or (normalizedProps = normalizePropsOptions(type)[0+1]) and hasOwn(normalizedProps, key)) or hasOwn(ctx, key)) or hasOwn(publicPropertiesMap, key)) or hasOwn(appContext.config.globalProperties, key)
end
}
if __DEV__ and not __TEST__ then
  PublicInstanceProxyHandlers.ownKeys = function(target)
    warn( + )
    return Reflect:ownKeys(target)
  end
  

end
local RuntimeCompiledPublicInstanceProxyHandlers = extend({}, PublicInstanceProxyHandlers, {get=function(target, key)
  if key == Symbol.unscopables then
    return
  end
  return (target, key, target)
end
, has=function(_, key)
  local has = key[0+1] ~= '_' and not isGloballyWhitelisted(key)
  if (__DEV__ and not has) and (_, key) then
    warn()
  end
  return has
end
})
function createRenderContext(instance)
  local target = {}
  Object:defineProperty(target, , {configurable=true, enumerable=false, get=function()
    instance
  end
  })
  Object:keys(publicPropertiesMap):forEach(function(key)
    Object:defineProperty(target, key, {configurable=true, enumerable=false, get=function()
      -- [ts2lua]publicPropertiesMap下标访问可能不正确
      publicPropertiesMap[key](instance)
    end
    , set=NOOP})
  end
  )
  local  = instance.appContext.config
  Object:keys(globalProperties):forEach(function(key)
    Object:defineProperty(target, key, {configurable=true, enumerable=false, get=function()
      -- [ts2lua]globalProperties下标访问可能不正确
      globalProperties[key]
    end
    , set=NOOP})
  end
  )
  return target
end

function exposePropsOnRenderContext(instance)
  local  = instance
  local propsOptions = normalizePropsOptions(type)[0+1]
  if propsOptions then
    Object:keys(propsOptions):forEach(function(key)
      Object:defineProperty(ctx, key, {enumerable=true, configurable=true, get=function()
        -- [ts2lua]instance.props下标访问可能不正确
        instance.props[key]
      end
      , set=NOOP})
    end
    )
  end
end

function exposeSetupStateOnRenderContext(instance)
  local  = instance
  Object:keys(toRaw(setupState)):forEach(function(key)
    Object:defineProperty(ctx, key, {enumerable=true, configurable=true, get=function()
      -- [ts2lua]setupState下标访问可能不正确
      setupState[key]
    end
    , set=NOOP})
  end
  )
end
