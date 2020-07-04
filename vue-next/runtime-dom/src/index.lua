require("@vue/runtime-core")
require("runtime-dom/src/nodeOps")
require("runtime-dom/src/patchProp")
require("@vue/shared")

'@vue/reactivity' = {}

local rendererOptions = extend({patchProp=patchProp, forcePatchProp=forcePatchProp}, nodeOps)
local renderer = nil
local enabledHydration = false
function ensureRenderer()
  return renderer or (renderer = createRenderer(rendererOptions))
end

function ensureHydrationRenderer()
  -- [ts2lua]lua中0和空字符串也是true，此处enabledHydration需要确认
  renderer = (enabledHydration and {renderer} or {createHydrationRenderer(rendererOptions)})[1]
  enabledHydration = true
  return renderer
end

local render = function(...)
  ensureRenderer():render(...)
end

local hydrate = function(...)
  ensureHydrationRenderer():hydrate(...)
end

local createApp = function(...)
  local app = ensureRenderer():createApp(...)
  if __DEV__ then
    injectNativeTagCheck(app)
  end
  local  = app
  app.mount = function(containerOrSelector)
    local container = normalizeContainer(containerOrSelector)
    if not container then
      return
    end
    local component = app._component
    if (not isFunction(component) and not component.render) and not component.template then
      component.template = container.innerHTML
    end
    container.innerHTML = ''
    local proxy = mount(container)
    container:removeAttribute('v-cloak')
    return proxy
  end
  
  return app
end

local createSSRApp = function(...)
  local app = ensureHydrationRenderer():createApp(...)
  if __DEV__ then
    injectNativeTagCheck(app)
  end
  local  = app
  app.mount = function(containerOrSelector)
    local container = normalizeContainer(containerOrSelector)
    if container then
      return mount(container, true)
    end
  end
  
  return app
end

function injectNativeTagCheck(app)
  Object:defineProperty(app.config, 'isNativeTag', {value=function(tag)
    isHTMLTag(tag) or isSVGTag(tag)
  end
  , writable=false})
end

function normalizeContainer(container)
  if isString(container) then
    local res = document:querySelector(container)
    if __DEV__ and not res then
      warn()
    end
    return res
  end
  return container
end

undefined
undefined
undefined
undefined
undefined