require("runtime-core/src/renderer/MoveType")
require("@vue/shared")
require("@vue/shared/ShapeFlags")
require("runtime-core/src/warning")
require("runtime-core/src/components/Teleport/TeleportMoveTypes")

local isTeleport = function(type)
  type.__isTeleport
end

local isTeleportDisabled = function(props)
  props and (props.disabled or props.disabled == '')
end

local resolveTarget = function(props, select)
  local targetSelector = props and props.to
  if isString(targetSelector) then
    if not select then
      __DEV__ and warn( + )
      return nil
    else
      local target = select(targetSelector)
      if not target then
        __DEV__ and warn()
      end
      return target
    end
  else
    if __DEV__ and not targetSelector then
      warn()
    end
    return targetSelector
  end
end

local TeleportImpl = {__isTeleport=true, process=function(n1, n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized, internals)
  local  = internals
  local disabled = isTeleportDisabled(n2.props)
  local  = n2
  if n1 == nil then
    -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
    n2.el = (__DEV__ and {createComment('teleport start')} or {createText('')})[1]
    local placeholder = n2.el
    -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
    n2.anchor = (__DEV__ and {createComment('teleport end')} or {createText('')})[1]
    local mainAnchor = n2.anchor
    insert(placeholder, container, anchor)
    insert(mainAnchor, container, anchor)
    n2.target = resolveTarget(n2.props, querySelector)
    local target = n2.target
    n2.targetAnchor = createText('')
    local targetAnchor = n2.targetAnchor
    if target then
      insert(targetAnchor, target)
    elseif __DEV__ then
      warn('Invalid Teleport target on mount:', target, )
    end
    local mount = function(container, anchor)
      if shapeFlag & ShapeFlags.ARRAY_CHILDREN then
        mountChildren(children, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
      end
    end
    
    if disabled then
      mount(container, mainAnchor)
    elseif target then
      mount(target, targetAnchor)
    end
  else
    n2.el = n1.el
    local mainAnchor = nil
    local target = nil
    local targetAnchor = nil
    local wasDisabled = isTeleportDisabled(n1.props)
    -- [ts2lua]lua中0和空字符串也是true，此处wasDisabled需要确认
    local currentContainer = (wasDisabled and {container} or {target})[1]
    -- [ts2lua]lua中0和空字符串也是true，此处wasDisabled需要确认
    local currentAnchor = (wasDisabled and {mainAnchor} or {targetAnchor})[1]
    if n2.dynamicChildren then
      patchBlockChildren(n2.dynamicChildren, currentContainer, parentComponent, parentSuspense, isSVG)
    elseif not optimized then
      patchChildren(n1, n2, currentContainer, currentAnchor, parentComponent, parentSuspense, isSVG)
    end
    if disabled then
      if not wasDisabled then
        moveTeleport(n2, container, mainAnchor, internals, TeleportMoveTypes.TOGGLE)
      end
    else
      if n2.props and n2.props.to ~= n1.props and n1.props.to then
        n2.target = resolveTarget(n2.props, querySelector)
        local nextTarget = n2.target
        if nextTarget then
          moveTeleport(n2, nextTarget, nil, internals, TeleportMoveTypes.TARGET_CHANGE)
        elseif __DEV__ then
          warn('Invalid Teleport target on update:', target, )
        end
      elseif wasDisabled then
        moveTeleport(n2, target, targetAnchor, internals, TeleportMoveTypes.TOGGLE)
      end
    end
  end
end
, remove=function(vnode, )
  local  = vnode
  hostRemove()
  if shapeFlag & ShapeFlags.ARRAY_CHILDREN then
    local i = 0
    repeat
      remove(children[i+1])
      i=i+1
    until not(i < #children)
  end
end
, move=moveTeleport, hydrate=hydrateTeleport}
function moveTeleport(vnode, container, parentAnchor, , moveType)
  if moveType == nil then
    moveType=TeleportMoveTypes.REORDER
  end
  if moveType == TeleportMoveTypes.TARGET_CHANGE then
    insert(container, parentAnchor)
  end
  local  = vnode
  local isReorder = moveType == TeleportMoveTypes.REORDER
  if isReorder then
    insert(container, parentAnchor)
  end
  if not isReorder or isTeleportDisabled(props) then
    if shapeFlag & ShapeFlags.ARRAY_CHILDREN then
      local i = 0
      repeat
        move(children[i+1], container, parentAnchor, MoveType.REORDER)
        i=i+1
      until not(i < #children)
    end
  end
  if isReorder then
    insert(container, parentAnchor)
  end
end

function hydrateTeleport(node, vnode, parentComponent, parentSuspense, optimized, , hydrateChildren)
  vnode.target = resolveTarget(vnode.props, querySelector)
  local target = vnode.target
  if target then
    local targetNode = target._lpa or target.firstChild
    if vnode.shapeFlag & ShapeFlags.ARRAY_CHILDREN then
      if isTeleportDisabled(vnode.props) then
        vnode.anchor = hydrateChildren(nextSibling(node), vnode, , parentComponent, parentSuspense, optimized)
        vnode.targetAnchor = targetNode
      else
        vnode.anchor = nextSibling(node)
        vnode.targetAnchor = hydrateChildren(targetNode, vnode, target, parentComponent, parentSuspense, optimized)
      end
      target._lpa = vnode.targetAnchor and nextSibling(vnode.targetAnchor)
    end
  end
  return vnode.anchor and nextSibling(vnode.anchor)
end

local Teleport = TeleportImpl