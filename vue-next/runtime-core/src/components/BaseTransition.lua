require("tableutil")
require("runtime-core/src/vnode")
require("runtime-core/src/warning")
require("runtime-core/src/components/KeepAlive")
require("@vue/reactivity")
require("runtime-core/src/errorHandling")
require("runtime-core/src/errorHandling/ErrorCodes")
require("@vue/shared/ShapeFlags")
require("@vue/shared/PatchFlags")
require("runtime-core/src/apiLifecycle")

function useTransitionState()
  local state = {isMounted=false, isLeaving=false, isUnmounting=false, leavingVNodes=Map()}
  onMounted(function()
    state.isMounted = true
  end
  )
  onBeforeUnmount(function()
    state.isUnmounting = true
  end
  )
  return state
end

local BaseTransitionImpl = {name=, props={mode=String, appear=Boolean, persisted=Boolean, onBeforeEnter=Function, onEnter=Function, onAfterEnter=Function, onEnterCancelled=Function, onBeforeLeave=Function, onLeave=Function, onAfterLeave=Function, onLeaveCancelled=Function, onBeforeAppear=Function, onAppear=Function, onAfterAppear=Function, onAppearCancelled=Function}, setup=function(props, )
  local instance = nil
  local state = useTransitionState()
  local prevTransitionKey = nil
  return function()
    local children = slots.default and getTransitionRawChildren(slots:default(), true)
    if not children or not #children then
      return
    end
    if __DEV__ and #children > 1 then
      warn('<transition> can only be used on a single element or component. Use ' .. '<transition-group> for lists.')
    end
    local rawProps = toRaw(props)
    local  = rawProps
    if (__DEV__ and mode) and not ({'in-out', 'out-in', 'default'}):includes(mode) then
      warn()
    end
    local child = children[0+1]
    if state.isLeaving then
      return emptyPlaceholder(child)
    end
    local innerChild = getKeepAliveChild(child)
    if not innerChild then
      return emptyPlaceholder(child)
    end
    innerChild.transition = resolveTransitionHooks(innerChild, rawProps, state, instance)
    local enterHooks = innerChild.transition
    local oldChild = instance.subTree
    local oldInnerChild = oldChild and getKeepAliveChild(oldChild)
    local transitionKeyChanged = false
    local  = innerChild.type
    if getTransitionKey then
      local key = getTransitionKey()
      if prevTransitionKey == undefined then
        prevTransitionKey = key
      elseif key ~= prevTransitionKey then
        prevTransitionKey = key
        transitionKeyChanged = true
      end
    end
    if (oldInnerChild and oldInnerChild.type ~= Comment) and (not isSameVNodeType(innerChild, oldInnerChild) or transitionKeyChanged) then
      local leavingHooks = resolveTransitionHooks(oldInnerChild, rawProps, state, instance)
      setTransitionHooks(oldInnerChild, leavingHooks)
      if mode == 'out-in' then
        state.isLeaving = true
        leavingHooks.afterLeave = function()
          state.isLeaving = false
          instance:update()
        end
        
        return emptyPlaceholder(child)
      elseif mode == 'in-out' then
        leavingHooks.delayLeave = function(el, earlyRemove, delayedLeave)
          local leavingVNodesCache = getLeavingNodesForType(state, oldInnerChild)
          -- [ts2lua]leavingVNodesCache下标访问可能不正确
          leavingVNodesCache[String(oldInnerChild.key)] = oldInnerChild
          el._leaveCb = function()
            earlyRemove()
            el._leaveCb = undefined
            enterHooks.delayedLeave = nil
          end
          
          enterHooks.delayedLeave = delayedLeave
        end
        
      
      end
    end
    return child
  end
  

end
}
local BaseTransition = BaseTransitionImpl
function getLeavingNodesForType(state, vnode)
  local  = state
  local leavingVNodesCache = nil
  if not leavingVNodesCache then
    leavingVNodesCache = Object:create(nil)
    leavingVNodes:set(vnode.type, leavingVNodesCache)
  end
  return leavingVNodesCache
end

function resolveTransitionHooks(vnode, , state, instance)
  local key = String(vnode.key)
  local leavingVNodesCache = getLeavingNodesForType(state, vnode)
  local callHook = function(hook, args)
    hook and callWithAsyncErrorHandling(hook, instance, ErrorCodes.TRANSITION_HOOK, args)
  end
  
  local hooks = {persisted=persisted, beforeEnter=function(el)
    local hook = onBeforeEnter
    if not state.isMounted then
      if appear then
        hook = onBeforeAppear or onBeforeEnter
      else
        return
      end
    end
    if el._leaveCb then
      el:_leaveCb(true)
    end
    -- [ts2lua]leavingVNodesCache下标访问可能不正确
    local leavingVNode = leavingVNodesCache[key]
    if (leavingVNode and isSameVNodeType(vnode, leavingVNode)) and ()._leaveCb then
      ():_leaveCb()
    end
    callHook(hook, {el})
  end
  , enter=function(el)
    local hook = onEnter
    local afterHook = onAfterEnter
    local cancelHook = onEnterCancelled
    if not state.isMounted then
      if appear then
        hook = onAppear or onEnter
        afterHook = onAfterAppear or onAfterEnter
        cancelHook = onAppearCancelled or onEnterCancelled
      else
        return
      end
    end
    local called = false
    el._enterCb = function(cancelled)
      if called then
        return
      end
      called = true
      if cancelled then
        callHook(cancelHook, {el})
      else
        callHook(afterHook, {el})
      end
      if hooks.delayedLeave then
        hooks:delayedLeave()
      end
      el._enterCb = undefined
    end
    
    local done = el._enterCb
    if hook then
      hook(el, done)
      if #hook <= 1 then
        done()
      end
    else
      done()
    end
  end
  , leave=function(el, remove)
    local key = String(vnode.key)
    if el._enterCb then
      el:_enterCb(true)
    end
    if state.isUnmounting then
      return remove()
    end
    callHook(onBeforeLeave, {el})
    local called = false
    el._leaveCb = function(cancelled)
      if called then
        return
      end
      called = true
      remove()
      if cancelled then
        callHook(onLeaveCancelled, {el})
      else
        callHook(onAfterLeave, {el})
      end
      el._leaveCb = undefined
      -- [ts2lua]leavingVNodesCache下标访问可能不正确
      if leavingVNodesCache[key] == vnode then
        -- [ts2lua]leavingVNodesCache下标访问可能不正确
        leavingVNodesCache[key] = nil
      end
    end
    
    local done = el._leaveCb
    -- [ts2lua]leavingVNodesCache下标访问可能不正确
    leavingVNodesCache[key] = vnode
    if onLeave then
      onLeave(el, done)
      if #onLeave <= 1 then
        done()
      end
    else
      done()
    end
  end
  }
  return hooks
end

function emptyPlaceholder(vnode)
  if isKeepAlive(vnode) then
    vnode = cloneVNode(vnode)
    vnode.children = nil
    return vnode
  end
end

function getKeepAliveChild(vnode)
  -- [ts2lua]lua中0和空字符串也是true，此处vnode.children需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处isKeepAlive(vnode)需要确认
  return (isKeepAlive(vnode) and {(vnode.children and {vnode.children[0+1]} or {undefined})[1]} or {vnode})[1]
end

function setTransitionHooks(vnode, hooks)
  if vnode.shapeFlag & ShapeFlags.COMPONENT and vnode.component then
    setTransitionHooks(vnode.component.subTree, hooks)
  else
    vnode.transition = hooks
  end
end

function getTransitionRawChildren(children, keepComment)
  if keepComment == nil then
    keepComment=false
  end
  local ret = {}
  local keyedFragmentCount = 0
  local i = 0
  repeat
    local child = children[i+1]
    if child.type == Fragment then
      if child.patchFlag & PatchFlags.KEYED_FRAGMENT then
        keyedFragmentCount=keyedFragmentCount+1
      end
      ret = table.merge(ret, getTransitionRawChildren(child.children, keepComment))
    elseif keepComment or child.type ~= Comment then
      table.insert(ret, child)
    end
    i=i+1
  until not(i < #children)
  if keyedFragmentCount > 1 then
    local i = 0
    repeat
      ret[i+1].patchFlag = PatchFlags.BAIL
      i=i+1
    until not(i < #ret)
  end
  return ret
end
