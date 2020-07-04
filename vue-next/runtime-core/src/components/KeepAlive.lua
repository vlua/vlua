require("stringutil")
require("runtime-core/src/component/LifecycleHooks")
require("runtime-core/src/component")
require("runtime-core/src/vnode")
require("runtime-core/src/warning")
require("runtime-core/src/apiLifecycle")
require("@vue/shared")
require("@vue/shared/ShapeFlags")
require("runtime-core/src/apiWatch")
require("runtime-core/src/renderer")
require("runtime-core/src/renderer/MoveType")
require("runtime-core/src/components/BaseTransition")

local isKeepAlive = function(vnode)
  vnode.type.__isKeepAlive
end

local KeepAliveImpl = {name=, __isKeepAlive=true, inheritRef=true, props={include={String, RegExp, Array}, exclude={String, RegExp, Array}, max={String, Number}}, setup=function(props, )
  local cache = Map()
  local keys = Set()
  local current = nil
  local instance = nil
  local parentSuspense = instance.suspense
  local sharedContext = instance.ctx
  local  = sharedContext
  local storageContainer = createElement('div')
  sharedContext.activate = function(vnode, container, anchor, isSVG, optimized)
    local instance = nil
    move(vnode, container, anchor, MoveType.ENTER, parentSuspense)
    patch(instance.vnode, vnode, container, anchor, instance, parentSuspense, isSVG, optimized)
    queuePostRenderEffect(function()
      instance.isDeactivated = false
      if instance.a then
        invokeArrayFns(instance.a)
      end
      local vnodeHook = vnode.props and vnode.props.onVnodeMounted
      if vnodeHook then
        invokeVNodeHook(vnodeHook, instance.parent, vnode)
      end
    end
    , parentSuspense)
  end
  
  sharedContext.deactivate = function(vnode)
    local instance = nil
    move(vnode, storageContainer, nil, MoveType.LEAVE, parentSuspense)
    queuePostRenderEffect(function()
      if instance.da then
        invokeArrayFns(instance.da)
      end
      local vnodeHook = vnode.props and vnode.props.onVnodeUnmounted
      if vnodeHook then
        invokeVNodeHook(vnodeHook, instance.parent, vnode)
      end
      instance.isDeactivated = true
    end
    , parentSuspense)
  end
  
  function unmount(vnode)
    resetShapeFlag(vnode)
    _unmount(vnode, instance, parentSuspense)
  end
  
  function pruneCache(filter)
    cache:forEach(function(vnode, key)
      local name = getName(vnode.type)
      if name and (not filter or not filter(name)) then
        pruneCacheEntry(key)
      end
    end
    )
  end
  
  function pruneCacheEntry(key)
    local cached = cache:get(key)
    if not current or cached.type ~= current.type then
      unmount(cached)
    elseif current then
      resetShapeFlag(current)
    end
    cache:delete(key)
    keys:delete(key)
  end
  
  watch(function()
    {props.include, props.exclude}
  end
  , function()
    include and pruneCache(function(name)
      matches(include, name)
    end
    )
    exclude and pruneCache(function(name)
      matches(exclude, name)
    end
    )
  end
  )
  onBeforeUnmount(function()
    cache:forEach(function(cached)
      local  = instance
      if cached.type == subTree.type then
        resetShapeFlag(subTree)
        local da = ().da
        da and queuePostRenderEffect(da, suspense)
        return
      end
      unmount(cached)
    end
    )
  end
  )
  return function()
    if not slots.default then
      return nil
    end
    local children = slots:default()
    local vnode = children[0+1]
    if #children > 1 then
      if __DEV__ then
        warn()
      end
      current = nil
      return children
    elseif not isVNode(vnode) or not (vnode.shapeFlag & ShapeFlags.STATEFUL_COMPONENT) then
      current = nil
      return vnode
    end
    local comp = vnode.type
    local name = getName(comp)
    local  = props
    if include and (not name or not matches(include, name)) or (exclude and name) and matches(exclude, name) then
      return current = vnode
    end
    -- [ts2lua]lua中0和空字符串也是true，此处vnode.key == nil需要确认
    local key = (vnode.key == nil and {comp} or {vnode.key})[1]
    local cachedVNode = cache:get(key)
    if vnode.el then
      vnode = cloneVNode(vnode)
    end
    cache:set(key, vnode)
    if cachedVNode then
      vnode.el = cachedVNode.el
      vnode.component = cachedVNode.component
      if vnode.transition then
        setTransitionHooks(vnode, )
      end
      vnode.shapeFlag = vnode.shapeFlag | ShapeFlags.COMPONENT_KEPT_ALIVE
      keys:delete(key)
      keys:add(key)
    else
      keys:add(key)
      if max and keys.size > parseInt(max, 10) then
        pruneCacheEntry(keys:values():next().value)
      end
    end
    vnode.shapeFlag = vnode.shapeFlag | ShapeFlags.COMPONENT_SHOULD_KEEP_ALIVE
    current = vnode
    return vnode
  end
  

end
}
local KeepAlive = KeepAliveImpl
function getName(comp)
  return comp.displayName or comp.name
end

function matches(pattern, name)
  if isArray(pattern) then
    return pattern:some(function(p)
      matches(p, name)
    end
    )
  elseif isString(pattern) then
    return pattern:split(','):find(name) > -1
  elseif pattern.test then
    return pattern:test(name)
  end
  return false
end

function onActivated(hook, target)
  registerKeepAliveHook(hook, LifecycleHooks.ACTIVATED, target)
end

function onDeactivated(hook, target)
  registerKeepAliveHook(hook, LifecycleHooks.DEACTIVATED, target)
end

function registerKeepAliveHook(hook, type, target)
  if target == nil then
    target=currentInstance
  end
  local wrappedHook = hook.__wdc or (hook.__wdc = function()
    local current = target
    while(current)
    do
    if current.isDeactivated then
      return
    end
    current = current.parent
    end
    hook()
  end
  )
  injectHook(type, wrappedHook, target)
  if target then
    local current = target.parent
    while(current and current.parent)
    do
    if isKeepAlive(current.parent.vnode) then
      injectToKeepAliveRoot(wrappedHook, type, target, current)
    end
    current = current.parent
    end
  end
end

function injectToKeepAliveRoot(hook, type, target, keepAliveRoot)
  injectHook(type, hook, keepAliveRoot, true)
  onUnmounted(function()
    remove(hook)
  end
  , target)
end

function resetShapeFlag(vnode)
  local shapeFlag = vnode.shapeFlag
  if shapeFlag & ShapeFlags.COMPONENT_SHOULD_KEEP_ALIVE then
    shapeFlag = shapeFlag - ShapeFlags.COMPONENT_SHOULD_KEEP_ALIVE
  end
  if shapeFlag & ShapeFlags.COMPONENT_KEPT_ALIVE then
    shapeFlag = shapeFlag - ShapeFlags.COMPONENT_KEPT_ALIVE
  end
  vnode.shapeFlag = shapeFlag
end
