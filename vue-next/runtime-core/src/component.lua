require("runtime-core/src/vnode")
require("@vue/reactivity")
require("runtime-core/src/componentProxy")
require("runtime-core/src/componentProps")
require("runtime-core/src/componentSlots")
require("runtime-core/src/warning")
require("runtime-core/src/errorHandling/ErrorCodes")
require("runtime-core/src/errorHandling")
require("runtime-core/src/apiCreateApp")
require("runtime-core/src/directives")
require("runtime-core/src/componentOptions")
require("runtime-core/src/componentEmits")
require("@vue/shared")
require("@vue/shared/ShapeFlags")
require("runtime-core/src/componentRenderUtils")
require("runtime-core/src/profiling")
require("runtime-core/src/component/LifecycleHooks")

undefined
local emptyAppContext = createAppContext()
local uid = 0
function createComponentInstance(vnode, parent, suspense)
  -- [ts2lua]lua中0和空字符串也是true，此处parent需要确认
  local appContext = ((parent and {parent.appContext} or {vnode.appContext})[1]) or emptyAppContext
  -- [ts2lua]lua中0和空字符串也是true，此处parent需要确认
  local instance = {uid=uid=uid+1, vnode=vnode, parent=parent, appContext=appContext, type=vnode.type, root=, next=nil, subTree=, update=, render=nil, proxy=nil, withProxy=nil, effects=nil, provides=(parent and {parent.provides} or {Object:create(appContext.provides)})[1], accessCache=, renderCache={}, ctx=EMPTY_OBJ, data=EMPTY_OBJ, props=EMPTY_OBJ, attrs=EMPTY_OBJ, slots=EMPTY_OBJ, refs=EMPTY_OBJ, setupState=EMPTY_OBJ, setupContext=nil, components=Object:create(appContext.components), directives=Object:create(appContext.directives), suspense=suspense, asyncDep=nil, asyncResolved=false, isMounted=false, isUnmounted=false, isDeactivated=false, bc=nil, c=nil, bm=nil, m=nil, bu=nil, u=nil, um=nil, bum=nil, da=nil, a=nil, rtg=nil, rtc=nil, ec=nil, emit=nil}
  if __DEV__ then
    instance.ctx = createRenderContext(instance)
  else
    instance.ctx = {_=instance}
  end
  -- [ts2lua]lua中0和空字符串也是true，此处parent需要确认
  instance.root = (parent and {parent.root} or {instance})[1]
  instance.emit = emit:bind(nil, instance)
  return instance
end

local currentInstance = nil
local getCurrentInstance = function()
  currentInstance or currentRenderingInstance
end

local setCurrentInstance = function(instance)
  currentInstance = instance
end

local isBuiltInTag = makeMap('slot,component')
function validateComponentName(name, config)
  local appIsNativeTag = config.isNativeTag or NO
  if isBuiltInTag(name) or appIsNativeTag(name) then
    warn('Do not use built-in or reserved HTML elements as component id: ' .. name)
  end
end

local isInSSRComponentSetup = false
function setupComponent(instance, isSSR)
  if isSSR == nil then
    isSSR=false
  end
  isInSSRComponentSetup = isSSR
  local  = instance.vnode
  local isStateful = shapeFlag & ShapeFlags.STATEFUL_COMPONENT
  initProps(instance, props, isStateful, isSSR)
  initSlots(instance, children)
  -- [ts2lua]lua中0和空字符串也是true，此处isStateful需要确认
  local setupResult = (isStateful and {setupStatefulComponent(instance, isSSR)} or {undefined})[1]
  isInSSRComponentSetup = false
  return setupResult
end

function setupStatefulComponent(instance, isSSR)
  local Component = instance.type
  if __DEV__ then
    if Component.name then
      validateComponentName(Component.name, instance.appContext.config)
    end
    if Component.components then
      local names = Object:keys(Component.components)
      local i = 0
      repeat
        validateComponentName(names[i+1], instance.appContext.config)
        i=i+1
      until not(i < #names)
    end
    if Component.directives then
      local names = Object:keys(Component.directives)
      local i = 0
      repeat
        validateDirectiveName(names[i+1])
        i=i+1
      until not(i < #names)
    end
  end
  instance.accessCache = {}
  instance.proxy = Proxy(instance.ctx, PublicInstanceProxyHandlers)
  if __DEV__ then
    exposePropsOnRenderContext(instance)
  end
  local  = Component
  if setup then
    -- [ts2lua]lua中0和空字符串也是true，此处#setup > 1需要确认
    instance.setupContext = (#setup > 1 and {createSetupContext(instance)} or {nil})[1]
    local setupContext = instance.setupContext
    currentInstance = instance
    pauseTracking()
    -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
    local setupResult = callWithErrorHandling(setup, instance, ErrorCodes.SETUP_FUNCTION, {(__DEV__ and {shallowReadonly(instance.props)} or {instance.props})[1], setupContext})
    resetTracking()
    currentInstance = nil
    if isPromise(setupResult) then
      if isSSR then
        return setupResult:tsvar_then(function(resolvedResult)
          handleSetupResult(instance, resolvedResult, isSSR)
        end
        )
      elseif __FEATURE_SUSPENSE__ then
        instance.asyncDep = setupResult
      elseif __DEV__ then
        warn( + )
      end
    else
      handleSetupResult(instance, setupResult, isSSR)
    end
  else
    finishComponentSetup(instance, isSSR)
  end
end

function handleSetupResult(instance, setupResult, isSSR)
  if isFunction(setupResult) then
    instance.render = setupResult
  elseif isObject(setupResult) then
    if __DEV__ and isVNode(setupResult) then
      warn( + )
    end
    instance.setupState = reactive(setupResult)
    if __DEV__ then
      exposeSetupStateOnRenderContext(instance)
    end
  elseif __DEV__ and setupResult ~= undefined then
    warn()
  end
  finishComponentSetup(instance, isSSR)
end

local compile = nil
function registerRuntimeCompiler(_compile)
  compile = _compile
end

function finishComponentSetup(instance, isSSR)
  local Component = instance.type
  if __NODE_JS__ and isSSR then
    if Component.render then
      instance.render = Component.render
    end
  elseif not instance.render then
    if (compile and Component.template) and not Component.render then
      if __DEV__ then
        startMeasure(instance, )
      end
      Component.render = compile(Component.template, {isCustomElement=instance.appContext.config.isCustomElement or NO})
      if __DEV__ then
        endMeasure(instance, )
      end
      Component.render._rc = true
    end
    if __DEV__ and not Component.render then
      if not compile and Component.template then
        -- [ts2lua]lua中0和空字符串也是true，此处__GLOBAL__需要确认
        -- [ts2lua]lua中0和空字符串也是true，此处__ESM_BROWSER__需要确认
        -- [ts2lua]lua中0和空字符串也是true，此处__ESM_BUNDLER__需要确认
        warn( +  + (__ESM_BUNDLER__ and {} or {(__ESM_BROWSER__ and {} or {(__GLOBAL__ and {} or {})[1]})[1]})[1])
      else
        warn()
      end
    end
    instance.render = Component.render or NOOP
    if instance.render._rc then
      instance.withProxy = Proxy(instance.ctx, RuntimeCompiledPublicInstanceProxyHandlers)
    end
  end
  if __FEATURE_OPTIONS__ then
    currentInstance = instance
    applyOptions(instance, Component)
    currentInstance = nil
  end
end

local attrHandlers = {get=function(target, key)
  if __DEV__ then
    markAttrsAccessed()
  end
  -- [ts2lua]target下标访问可能不正确
  return target[key]
end
, set=function()
  warn()
  return false
end
, deleteProperty=function()
  warn()
  return false
end
}
function createSetupContext(instance)
  if __DEV__ then
    return Object:freeze({attrs=function()
      return Proxy(instance.attrs, attrHandlers)
    end
    , slots=function()
      return shallowReadonly(instance.slots)
    end
    , emit=function()
      return function(event, ...)
        instance:emit(event, ...)
      end
      
    
    end
    })
  else
    return {attrs=instance.attrs, slots=instance.slots, emit=instance.emit}
  end
end

function recordInstanceBoundEffect(effect)
  if currentInstance then
    
    table.insert((currentInstance.effects or (currentInstance.effects = {})), effect)
  end
end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local classifyRE = /(?:^|[-_])(\w)/g
local classify = function(str)
  str:gsub(classifyRE, function(c)
    c:toUpperCase()
  end
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  ):gsub(/[-_]/g, '')
end

function formatComponentName(instance, Component, isRoot)
  if isRoot == nil then
    isRoot=false
  end
  -- [ts2lua]lua中0和空字符串也是true，此处isFunction(Component)需要确认
  local name = (isFunction(Component) and {Component.displayName or Component.name} or {Component.name})[1]
  if not name and Component.__file then
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    local match = Component.__file:match(/([^/\\]+)\.vue$/)
    if match then
      name = match[1+1]
    end
  end
  if (not name and instance) and instance.parent then
    local registry = instance.parent.components
    for key in pairs(registry) do
      -- [ts2lua]registry下标访问可能不正确
      if registry[key] == Component then
        name = key
        break
      end
    end
  end
  -- [ts2lua]lua中0和空字符串也是true，此处isRoot需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处name需要确认
  return (name and {classify(name)} or {(isRoot and {} or {})[1]})[1]
end
