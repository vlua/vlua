require("runtime-core/src/vnode")
require("@vue/shared")
require("@vue/shared/ShapeFlags")
require("runtime-core/src/component")
require("runtime-core/src/renderer/MoveType")
require("runtime-core/src/scheduler")
require("runtime-core/src/componentRenderUtils")
require("runtime-core/src/warning")
require("runtime-core/src/errorHandling")
require("runtime-core/src/errorHandling/ErrorCodes")

local isSuspense = function(type)
  type.__isSuspense
end

local SuspenseImpl = {__isSuspense=true, process=function(n1, n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized, rendererInternals)
  if n1 == nil then
    mountSuspense(n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized, rendererInternals)
  else
    patchSuspense(n1, n2, container, anchor, parentComponent, isSVG, optimized, rendererInternals)
  end
end
, hydrate=hydrateSuspense}
-- [ts2lua]lua中0和空字符串也是true，此处__FEATURE_SUSPENSE__需要确认
local Suspense = (__FEATURE_SUSPENSE__ and {SuspenseImpl} or {nil})[1]
function mountSuspense(n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized, rendererInternals)
  local  = rendererInternals
  local hiddenContainer = createElement('div')
  n2.suspense = createSuspenseBoundary(n2, parentSuspense, parentComponent, container, hiddenContainer, anchor, isSVG, optimized, rendererInternals)
  local suspense = n2.suspense
  patch(nil, suspense.subTree, hiddenContainer, nil, parentComponent, suspense, isSVG, optimized)
  if suspense.deps > 0 then
    patch(nil, suspense.fallbackTree, container, anchor, parentComponent, nil, isSVG, optimized)
    n2.el = suspense.fallbackTree.el
  else
    suspense:resolve()
  end
end

function patchSuspense(n1, n2, container, anchor, parentComponent, isSVG, optimized, )
  local suspense = nil
  suspense.vnode = n2
  local  = normalizeSuspenseChildren(n2)
  local oldSubTree = suspense.subTree
  local oldFallbackTree = suspense.fallbackTree
  if not suspense.isResolved then
    patch(oldSubTree, content, suspense.hiddenContainer, nil, parentComponent, suspense, isSVG, optimized)
    if suspense.deps > 0 then
      patch(oldFallbackTree, fallback, container, anchor, parentComponent, nil, isSVG, optimized)
      n2.el = fallback.el
    end
  else
    patch(oldSubTree, content, container, anchor, parentComponent, suspense, isSVG, optimized)
    n2.el = content.el
  end
  suspense.subTree = content
  suspense.fallbackTree = fallback
end

local hasWarned = false
function createSuspenseBoundary(vnode, parent, parentComponent, container, hiddenContainer, anchor, isSVG, optimized, rendererInternals, isHydrating)
  if isHydrating == nil then
    isHydrating=false
  end
  if (__DEV__ and not __TEST__) and not hasWarned then
    hasWarned = true
    -- [ts2lua]lua中0和空字符串也是true，此处console.info需要确认
    -- [ts2lua]console下标访问可能不正确
    console[(console.info and {'info'} or {'log'})[1]]()
  end
  local  = rendererInternals
  local getCurrentTree = function()
    -- [ts2lua]lua中0和空字符串也是true，此处suspense.isResolved or suspense.isHydrating需要确认
    (suspense.isResolved or suspense.isHydrating and {suspense.subTree} or {suspense.fallbackTree})[1]
  end
  
  local  = normalizeSuspenseChildren(vnode)
  local suspense = {vnode=vnode, parent=parent, parentComponent=parentComponent, isSVG=isSVG, optimized=optimized, container=container, hiddenContainer=hiddenContainer, anchor=anchor, deps=0, subTree=content, fallbackTree=fallback, isHydrating=isHydrating, isResolved=false, isUnmounted=false, effects={}, resolve=function()
    if __DEV__ then
      if suspense.isResolved then
        error(Error())
      end
      if suspense.isUnmounted then
        error(Error())
      end
    end
    local  = suspense
    if suspense.isHydrating then
      suspense.isHydrating = false
    else
      local  = suspense
      if fallbackTree.el then
        anchor = next(fallbackTree)
        unmount(fallbackTree, parentComponent, suspense, true)
      end
      move(subTree, container, anchor, MoveType.ENTER)
    end
    vnode.el = 
    local el = vnode.el
    if parentComponent and parentComponent.subTree == vnode then
      parentComponent.vnode.el = el
      updateHOCHostEl(parentComponent, el)
    end
    local parent = suspense.parent
    local hasUnresolvedAncestor = false
    while(parent)
    do
    if not parent.isResolved then
      table.insert(parent.effects, ...)
      hasUnresolvedAncestor = true
      break
    end
    parent = parent.parent
    end
    if not hasUnresolvedAncestor then
      queuePostFlushCb(effects)
    end
    suspense.isResolved = true
    suspense.effects = {}
    local onResolve = vnode.props and vnode.props.onResolve
    if isFunction(onResolve) then
      onResolve()
    end
  end
  , recede=function()
    suspense.isResolved = false
    local  = suspense
    local anchor = next(subTree)
    move(subTree, hiddenContainer, nil, MoveType.LEAVE)
    patch(nil, fallbackTree, container, anchor, parentComponent, nil, isSVG, optimized)
    vnode.el = 
    local el = vnode.el
    if parentComponent and parentComponent.subTree == vnode then
      parentComponent.vnode.el = el
      updateHOCHostEl(parentComponent, el)
    end
    local onRecede = vnode.props and vnode.props.onRecede
    if isFunction(onRecede) then
      onRecede()
    end
  end
  , move=function(container, anchor, type)
    move(getCurrentTree(), container, anchor, type)
    suspense.container = container
  end
  , next=function()
    return next(getCurrentTree())
  end
  , registerDep=function(instance, setupRenderEffect)
    if suspense.isResolved then
      queueJob(function()
        suspense:recede()
      end
      )
    end
    local hydratedEl = instance.vnode.el
    suspense.deps=suspense.deps+1
    ():catch(function(err)
      handleError(err, instance, ErrorCodes.SETUP_FUNCTION)
    end
    ):tsvar_then(function(asyncSetupResult)
      if instance.isUnmounted or suspense.isUnmounted then
        return
      end
      suspense.deps=suspense.deps-1
      instance.asyncResolved = true
      local  = instance
      if __DEV__ then
        pushWarningContext(vnode)
      end
      handleSetupResult(instance, asyncSetupResult, false)
      if hydratedEl then
        vnode.el = hydratedEl
      end
      -- [ts2lua]lua中0和空字符串也是true，此处hydratedEl需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处hydratedEl需要确认
      setupRenderEffect(instance, vnode, (hydratedEl and {} or {})[1], (hydratedEl and {nil} or {next(instance.subTree)})[1], suspense, isSVG, optimized)
      updateHOCHostEl(instance, vnode.el)
      if __DEV__ then
        popWarningContext()
      end
      if suspense.deps == 0 then
        suspense:resolve()
      end
    end
    )
  end
  , unmount=function(parentSuspense, doRemove)
    suspense.isUnmounted = true
    unmount(suspense.subTree, parentComponent, parentSuspense, doRemove)
    if not suspense.isResolved then
      unmount(suspense.fallbackTree, parentComponent, parentSuspense, doRemove)
    end
  end
  }
  return suspense
end

function hydrateSuspense(node, vnode, parentComponent, parentSuspense, isSVG, optimized, rendererInternals, hydrateNode)
  vnode.suspense = createSuspenseBoundary(vnode, parentSuspense, parentComponent, , document:createElement('div'), nil, isSVG, optimized, rendererInternals, true)
  local suspense = vnode.suspense
  local result = hydrateNode(node, suspense.subTree, parentComponent, suspense, optimized)
  if suspense.deps == 0 then
    suspense:resolve()
  end
  return result
end

function normalizeSuspenseChildren(vnode)
  local  = vnode
  if shapeFlag & ShapeFlags.SLOTS_CHILDREN then
    local  = children
    -- [ts2lua]lua中0和空字符串也是true，此处isFunction(d)需要确认
    -- [ts2lua]lua中0和空字符串也是true，此处isFunction(fallback)需要确认
    return {content=normalizeVNode((isFunction(d) and {d()} or {d})[1]), fallback=normalizeVNode((isFunction(fallback) and {fallback()} or {fallback})[1])}
  else
    return {content=normalizeVNode(children), fallback=normalizeVNode(nil)}
  end
end

function queueEffectWithSuspense(fn, suspense)
  if suspense and not suspense.isResolved then
    if isArray(fn) then
      table.insert(suspense.effects, ...)
    else
      table.insert(suspense.effects, fn)
    end
  else
    queuePostFlushCb(fn)
  end
end
