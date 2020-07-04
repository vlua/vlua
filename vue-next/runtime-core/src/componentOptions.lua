require("@vue/shared")
require("runtime-core/src/apiComputed")
require("runtime-core/src/apiWatch")
require("runtime-core/src/apiInject")
require("runtime-core/src/apiLifecycle")
require("@vue/reactivity")
require("runtime-core/src/componentProps")
require("runtime-core/src/warning")
local OptionTypes = {
  PROPS = 'Props',
  DATA = 'Data',
  COMPUTED = 'Computed',
  METHODS = 'Methods',
  INJECT = 'Inject'
}

function createDuplicateChecker()
  local cache = Object:create(nil)
  return function(type, key)
    -- [ts2lua]cache下标访问可能不正确
    if cache[key] then
      warn()
    else
      -- [ts2lua]cache下标访问可能不正确
      cache[key] = type
    end
  end
  

end

function applyOptions(instance, options, deferredData, deferredWatch, asMixin)
  if deferredData == nil then
    deferredData={}
  end
  if deferredWatch == nil then
    deferredWatch={}
  end
  if asMixin == nil then
    asMixin=false
  end
  local  = options
  local publicThis = nil
  local ctx = instance.ctx
  local globalMixins = instance.appContext.mixins
  if not asMixin then
    callSyncHook('beforeCreate', options, publicThis, globalMixins)
    applyMixins(instance, globalMixins, deferredData, deferredWatch)
  end
  if extendsOptions then
    applyOptions(instance, extendsOptions, deferredData, deferredWatch, true)
  end
  if mixins then
    applyMixins(instance, mixins, deferredData, deferredWatch)
  end
  -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
  local checkDuplicateProperties = (__DEV__ and {createDuplicateChecker()} or {nil})[1]
  if __DEV__ then
    local propsOptions = normalizePropsOptions(options)[0+1]
    if propsOptions then
      for key in pairs(propsOptions) do
        (OptionTypes.PROPS, key)
      end
    end
  end
  if injectOptions then
    if isArray(injectOptions) then
      local i = 0
      repeat
        local key = injectOptions[i+1]
        -- [ts2lua]ctx下标访问可能不正确
        ctx[key] = inject(key)
        if __DEV__ then
          (OptionTypes.INJECT, key)
        end
        i=i+1
      until not(i < #injectOptions)
    else
      for key in pairs(injectOptions) do
        -- [ts2lua]injectOptions下标访问可能不正确
        local opt = injectOptions[key]
        if isObject(opt) then
          -- [ts2lua]ctx下标访问可能不正确
          ctx[key] = inject(opt.from, opt.default)
        else
          -- [ts2lua]ctx下标访问可能不正确
          ctx[key] = inject(opt)
        end
        if __DEV__ then
          (OptionTypes.INJECT, key)
        end
      end
    end
  end
  if methods then
    for key in pairs(methods) do
      -- [ts2lua]methods下标访问可能不正确
      local methodHandler = methods[key]
      if isFunction(methodHandler) then
        -- [ts2lua]ctx下标访问可能不正确
        ctx[key] = methodHandler:bind(publicThis)
        if __DEV__ then
          (OptionTypes.METHODS, key)
        end
      elseif __DEV__ then
        warn( + )
      end
    end
  end
  if dataOptions then
    if __DEV__ and not isFunction(dataOptions) then
      warn( + )
    end
    if asMixin then
      table.insert(deferredData, dataOptions)
    else
      resolveData(instance, dataOptions, publicThis)
    end
  end
  if not asMixin then
    if #deferredData then
      deferredData:forEach(function(dataFn)
        resolveData(instance, dataFn, publicThis)
      end
      )
    end
    if __DEV__ then
      local rawData = toRaw(instance.data)
      for key in pairs(rawData) do
        (OptionTypes.DATA, key)
        if key[0+1] ~= '$' and key[0+1] ~= '_' then
          Object:defineProperty(ctx, key, {configurable=true, enumerable=true, get=function()
            -- [ts2lua]rawData下标访问可能不正确
            rawData[key]
          end
          , set=NOOP})
        end
      end
    end
  end
  if computedOptions then
    for key in pairs(computedOptions) do
      -- [ts2lua]computedOptions下标访问可能不正确
      local opt = computedOptions[key]
      -- [ts2lua]lua中0和空字符串也是true，此处isFunction(opt.get)需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处isFunction(opt)需要确认
      local get = (isFunction(opt) and {opt:bind(publicThis, publicThis)} or {(isFunction(opt.get) and {opt.get:bind(publicThis, publicThis)} or {NOOP})[1]})[1]
      if __DEV__ and get == NOOP then
        warn()
      end
      local set = (not isFunction(opt) and isFunction(opt.set) and {opt.set:bind(publicThis)} or {(__DEV__ and {function()
        warn()
      end
      -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处not isFunction(opt) and isFunction(opt.set)需要确认
      } or {NOOP})[1]})[1]
      local c = computed({get=get, set=set})
      Object:defineProperty(ctx, key, {enumerable=true, configurable=true, get=function()
        c.value
      end
      , set=function(v)
        c.value = v
      end
      })
      if __DEV__ then
        (OptionTypes.COMPUTED, key)
      end
    end
  end
  if watchOptions then
    table.insert(deferredWatch, watchOptions)
  end
  if not asMixin and #deferredWatch then
    deferredWatch:forEach(function(watchOptions)
      for key in pairs(watchOptions) do
        -- [ts2lua]watchOptions下标访问可能不正确
        createWatcher(watchOptions[key], ctx, publicThis, key)
      end
    end
    )
  end
  if provideOptions then
    -- [ts2lua]lua中0和空字符串也是true，此处isFunction(provideOptions)需要确认
    local provides = (isFunction(provideOptions) and {provideOptions:call(publicThis)} or {provideOptions})[1]
    for key in pairs(provides) do
      -- [ts2lua]provides下标访问可能不正确
      provide(key, provides[key])
    end
  end
  if components then
    extend(instance.components, components)
  end
  if directives then
    extend(instance.directives, directives)
  end
  if not asMixin then
    callSyncHook('created', options, publicThis, globalMixins)
  end
  if beforeMount then
    onBeforeMount(beforeMount:bind(publicThis))
  end
  if mounted then
    onMounted(mounted:bind(publicThis))
  end
  if beforeUpdate then
    onBeforeUpdate(beforeUpdate:bind(publicThis))
  end
  if updated then
    onUpdated(updated:bind(publicThis))
  end
  if activated then
    onActivated(activated:bind(publicThis))
  end
  if deactivated then
    onDeactivated(deactivated:bind(publicThis))
  end
  if errorCaptured then
    onErrorCaptured(errorCaptured:bind(publicThis))
  end
  if renderTracked then
    onRenderTracked(renderTracked:bind(publicThis))
  end
  if renderTriggered then
    onRenderTriggered(renderTriggered:bind(publicThis))
  end
  if beforeUnmount then
    onBeforeUnmount(beforeUnmount:bind(publicThis))
  end
  if unmounted then
    onUnmounted(unmounted:bind(publicThis))
  end
end

function callSyncHook(name, options, ctx, globalMixins)
  callHookFromMixins(name, globalMixins, ctx)
  -- [ts2lua]options.extends下标访问可能不正确
  local baseHook = options.extends and options.extends[name]
  if baseHook then
    baseHook:call(ctx)
  end
  local mixins = options.mixins
  if mixins then
    callHookFromMixins(name, mixins, ctx)
  end
  -- [ts2lua]options下标访问可能不正确
  local selfHook = options[name]
  if selfHook then
    selfHook:call(ctx)
  end
end

function callHookFromMixins(name, mixins, ctx)
  local i = 0
  repeat
    -- [ts2lua]mixins[i+1]下标访问可能不正确
    local fn = mixins[i+1][name]
    if fn then
      fn:call(ctx)
    end
    i=i+1
  until not(i < #mixins)
end

function applyMixins(instance, mixins, deferredData, deferredWatch)
  local i = 0
  repeat
    applyOptions(instance, mixins[i+1], deferredData, deferredWatch, true)
    i=i+1
  until not(i < #mixins)
end

function resolveData(instance, dataFn, publicThis)
  local data = dataFn:call(publicThis, publicThis)
  if __DEV__ and isPromise(data) then
    warn( +  + )
  end
  if not isObject(data) then
    __DEV__ and warn()
  elseif instance.data == EMPTY_OBJ then
    instance.data = reactive(data)
  else
    extend(instance.data, data)
  end
end

function createWatcher(raw, ctx, publicThis, key)
  local getter = function()
    -- [ts2lua]publicThis下标访问可能不正确
    publicThis[key]
  end
  
  if isString(raw) then
    -- [ts2lua]ctx下标访问可能不正确
    local handler = ctx[raw]
    if isFunction(handler) then
      watch(getter, handler)
    elseif __DEV__ then
      warn(handler)
    end
  elseif isFunction(raw) then
    watch(getter, raw:bind(publicThis))
  elseif isObject(raw) then
    if isArray(raw) then
      raw:forEach(function(r)
        createWatcher(r, ctx, publicThis, key)
      end
      )
    else
      watch(getter, raw.handler:bind(publicThis), raw)
    end
  elseif __DEV__ then
    warn()
  end
end

function resolveMergedOptions(instance)
  local raw = instance.type
  local  = raw
  if __merged then
    return __merged
  end
  local globalMixins = instance.appContext.mixins
  if (not #globalMixins and not mixins) and not extendsOptions then
    return raw
  end
  local options = {}
  globalMixins:forEach(function(m)
    mergeOptions(options, m, instance)
  end
  )
  extendsOptions and mergeOptions(options, extendsOptions, instance)
  mixins and mixins:forEach(function(m)
    mergeOptions(options, m, instance)
  end
  )
  mergeOptions(options, raw, instance)
  return raw.__merged = options
end

function mergeOptions(to, from, instance)
  local strats = instance.appContext.config.optionMergeStrategies
  for key in pairs(from) do
    if strats and hasOwn(strats, key) then
      -- [ts2lua]to下标访问可能不正确
      -- [ts2lua]strats下标访问可能不正确
      -- [ts2lua]to下标访问可能不正确
      -- [ts2lua]from下标访问可能不正确
      to[key] = strats[key](to[key], from[key], instance.proxy, key)
    elseif not hasOwn(to, key) then
      -- [ts2lua]to下标访问可能不正确
      -- [ts2lua]from下标访问可能不正确
      to[key] = from[key]
    end
  end
end
