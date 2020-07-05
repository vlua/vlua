require("runtime-core/src/vnode")
require("runtime-core/src/component")
require("runtime-core/src/componentRenderUtils")
require("@vue/shared")
require("@vue/shared/PatchFlags")
require("@vue/shared/ShapeFlags")
require("runtime-core/src/scheduler")
require("@vue/reactivity")
require("runtime-core/src/componentProps")
require("runtime-core/src/componentSlots")
require("runtime-core/src/warning")
require("runtime-core/src/apiCreateApp")
require("runtime-core/src/components/Suspense")
require("runtime-core/src/components/KeepAlive")
require("runtime-core/src/hmr")
require("runtime-core/src/errorHandling/ErrorCodes")
require("runtime-core/src/errorHandling")
require("runtime-core/src/hydration")
require("runtime-core/src/directives")
require("runtime-core/src/profiling")
require("runtime-core/src/renderer/MoveType")

local prodEffectOptions = {scheduler=queueJob}
function createDevEffectOptions(instance)
  return {scheduler=queueJob, onTrack=(instance.rtc and {function(e)
    invokeArrayFns(e)
  end
  -- [ts2lua]lua中0和空字符串也是true，此处instance.rtc需要确认
  } or {undefined})[1], onTrigger=(instance.rtg and {function(e)
    invokeArrayFns(e)
  end
  -- [ts2lua]lua中0和空字符串也是true，此处instance.rtg需要确认
  } or {undefined})[1]}
end

-- [ts2lua]lua中0和空字符串也是true，此处__FEATURE_SUSPENSE__需要确认
local queuePostRenderEffect = (__FEATURE_SUSPENSE__ and {queueEffectWithSuspense} or {queuePostFlushCb})[1]
local setRef = function(rawRef, oldRawRef, parent, vnode)
  local value = nil
  if not vnode then
    value = nil
  else
    if vnode.shapeFlag & ShapeFlags.STATEFUL_COMPONENT then
      value = ().proxy
    else
      value = vnode.el
    end
  end
  local  = rawRef
  if __DEV__ and not owner then
    warn( + )
    return
  end
  local oldRef = oldRawRef and oldRawRef[1+1]
  -- [ts2lua]lua中0和空字符串也是true，此处owner.refs == EMPTY_OBJ需要确认
  local refs = (owner.refs == EMPTY_OBJ and {owner.refs = {}} or {owner.refs})[1]
  local setupState = owner.setupState
  if oldRef ~= nil and oldRef ~= ref then
    if isString(oldRef) then
      -- [ts2lua]refs下标访问可能不正确
      refs[oldRef] = nil
      if hasOwn(setupState, oldRef) then
        -- [ts2lua]setupState下标访问可能不正确
        setupState[oldRef] = nil
      end
    elseif isRef(oldRef) then
      oldRef.value = nil
    end
  end
  if isString(ref) then
    -- [ts2lua]refs下标访问可能不正确
    refs[ref] = value
    if hasOwn(setupState, ref) then
      -- [ts2lua]setupState下标访问可能不正确
      setupState[ref] = value
    end
  elseif isRef(ref) then
    ref.value = value
  elseif isFunction(ref) then
    callWithErrorHandling(ref, parent, ErrorCodes.FUNCTION_REF, {value, refs})
  elseif __DEV__ then
    warn('Invalid template ref type:', value, )
  end
end

function createRenderer(options)
  return baseCreateRenderer(options)
end

function createHydrationRenderer(options)
  return baseCreateRenderer(options, createHydrationFunctions)
end

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

function baseCreateRenderer(options, createHydrationFns)
  local  = options
  local patch = function(n1, n2, container, anchor = nil, parentComponent = nil, parentSuspense = nil, isSVG = false, optimized = false)
    if anchor == nil then
      anchor=nil
    end
    if parentComponent == nil then
      parentComponent=nil
    end
    if parentSuspense == nil then
      parentSuspense=nil
    end
    if isSVG == nil then
      isSVG=false
    end
    if optimized == nil then
      optimized=false
    end
    if n1 and not isSameVNodeType(n1, n2) then
      anchor = getNextHostNode(n1)
      unmount(n1, parentComponent, parentSuspense, true)
      n1 = nil
    end
    if n2.patchFlag == PatchFlags.BAIL then
      optimized = false
      n2.dynamicChildren = nil
    end
    local  = n2
    local switch = {
      [Text] = function()
        processText(n1, n2, container, anchor)
      end,
      [Comment] = function()
        processCommentNode(n1, n2, container, anchor)
      end,
      [Static] = function()
        if n1 == nil then
          mountStaticNode(n2, container, anchor, isSVG)
        elseif __DEV__ then
          patchStaticNode(n1, n2, container, isSVG)
        end
      end,
      [Fragment] = function()
        processFragment(n1, n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
      end,
      ["default"] = function()
        if shapeFlag & ShapeFlags.ELEMENT then
          processElement(n1, n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
        elseif shapeFlag & ShapeFlags.COMPONENT then
          processComponent(n1, n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
        elseif shapeFlag & ShapeFlags.TELEPORT then
          
          type:process(n1, n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized, internals)
        elseif __FEATURE_SUSPENSE__ and shapeFlag & ShapeFlags.SUSPENSE then
          
          type:process(n1, n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized, internals)
        elseif __DEV__ then
          warn('Invalid VNode type:', type, )
        end
      end
    }
    local casef = switch[type]
    if not casef then casef = switch["default"] end
    if casef then casef() end
    if ref ~= nil and parentComponent then
      setRef(ref, n1 and n1.ref, parentComponent, n2)
    end
  end
  
  local processText = function(n1, n2, container, anchor)
    if n1 == nil then
      hostInsert(n2.el, container, anchor)
    else
      n2.el = 
      local el = n2.el
      if n2.children ~= n1.children then
        hostSetText(el, n2.children)
      end
    end
  end
  
  local processCommentNode = function(n1, n2, container, anchor)
    if n1 == nil then
      hostInsert(n2.el, container, anchor)
    else
      n2.el = n1.el
    end
  end
  
  local mountStaticNode = function(n2, container, anchor, isSVG)
    
     = (n2.children, container, anchor, isSVG)
  end
  
  local patchStaticNode = function(n1, n2, container, isSVG)
    if n2.children ~= n1.children then
      local anchor = hostNextSibling()
      removeStaticNode(n1)
       = (n2.children, container, anchor, isSVG)
    else
      n2.el = n1.el
      n2.anchor = n1.anchor
    end
  end
  
  local moveStaticNode = function(vnode, container, anchor)
    local cur = vnode.el
    local tsvar_end = nil
    while(cur and cur ~= tsvar_end)
    do
    local next = hostNextSibling(cur)
    hostInsert(cur, container, anchor)
    cur = next
    end
    hostInsert(tsvar_end, container, anchor)
  end
  
  local removeStaticNode = function(vnode)
    local cur = vnode.el
    while(cur and cur ~= vnode.anchor)
    do
    local next = hostNextSibling(cur)
    hostRemove(cur)
    cur = next
    end
    hostRemove()
  end
  
  local processElement = function(n1, n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
    isSVG = isSVG or n2.type == 'svg'
    if n1 == nil then
      mountElement(n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
    else
      patchElement(n1, n2, parentComponent, parentSuspense, isSVG, optimized)
    end
  end
  
  local mountElement = function(vnode, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
    local el = nil
    local vnodeHook = nil
    local  = vnode
    if (vnode.el and hostCloneNode ~= undefined) and patchFlag == PatchFlags.HOISTED then
      vnode.el = hostCloneNode(vnode.el)
      el = vnode.el
    else
      vnode.el = hostCreateElement(vnode.type, isSVG, props and props.is)
      el = vnode.el
      if shapeFlag & ShapeFlags.TEXT_CHILDREN then
        hostSetElementText(el, vnode.children)
      elseif shapeFlag & ShapeFlags.ARRAY_CHILDREN then
        mountChildren(vnode.children, el, nil, parentComponent, parentSuspense, isSVG and type ~= 'foreignObject', optimized or not (not vnode.dynamicChildren))
      end
      if props then
        for key in pairs(props) do
          if not isReservedProp(key) then
            -- [ts2lua]props下标访问可能不正确
            hostPatchProp(el, key, nil, props[key], isSVG, vnode.children, parentComponent, parentSuspense, unmountChildren)
          end
        end
        if vnodeHook = props.onVnodeBeforeMount then
          invokeVNodeHook(vnodeHook, parentComponent, vnode)
        end
      end
      if dirs then
        invokeDirectiveHook(vnode, nil, parentComponent, 'beforeMount')
      end
      if scopeId then
        hostSetScopeId(el, scopeId)
      end
      local treeOwnerId = parentComponent and parentComponent.type.__scopeId
      if treeOwnerId and treeOwnerId ~= scopeId then
        hostSetScopeId(el, treeOwnerId .. '-s')
      end
      if transition and not transition.persisted then
        transition:beforeEnter(el)
      end
    end
    hostInsert(el, container, anchor)
    if ((vnodeHook = props and props.onVnodeMounted) or transition and not transition.persisted) or dirs then
      queuePostRenderEffect(function()
        vnodeHook and invokeVNodeHook(vnodeHook, parentComponent, vnode)
        (transition and not transition.persisted) and transition:enter(el)
        dirs and invokeDirectiveHook(vnode, nil, parentComponent, 'mounted')
      end
      , parentSuspense)
    end
  end
  
  local mountChildren = function(children, container, anchor, parentComponent, parentSuspense, isSVG, optimized, start = 0)
    if start == nil then
      start=0
    end
    local i = start
    repeat
      -- [ts2lua]lua中0和空字符串也是true，此处optimized需要确认
      children[i+1] = (optimized and {cloneIfMounted(children[i+1])} or {normalizeVNode(children[i+1])})[1]
      local child = children[i+1]
      patch(nil, child, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
      i=i+1
    until not(i < #children)
  end
  
  local patchElement = function(n1, n2, parentComponent, parentSuspense, isSVG, optimized)
    n2.el = 
    local el = n2.el
    local  = n2
    patchFlag = patchFlag | n1.patchFlag & PatchFlags.FULL_PROPS
    local oldProps = n1.props or EMPTY_OBJ
    local newProps = n2.props or EMPTY_OBJ
    local vnodeHook = nil
    if vnodeHook = newProps.onVnodeBeforeUpdate then
      invokeVNodeHook(vnodeHook, parentComponent, n2, n1)
    end
    if dirs then
      invokeDirectiveHook(n2, n1, parentComponent, 'beforeUpdate')
    end
    if __DEV__ and isHmrUpdating then
      patchFlag = 0
      optimized = false
      dynamicChildren = nil
    end
    if patchFlag > 0 then
      if patchFlag & PatchFlags.FULL_PROPS then
        patchProps(el, n2, oldProps, newProps, parentComponent, parentSuspense, isSVG)
      else
        if patchFlag & PatchFlags.CLASS then
          if oldProps.class ~= newProps.class then
            hostPatchProp(el, 'class', nil, newProps.class, isSVG)
          end
        end
        if patchFlag & PatchFlags.STYLE then
          hostPatchProp(el, 'style', oldProps.style, newProps.style, isSVG)
        end
        if patchFlag & PatchFlags.PROPS then
          local propsToUpdate = nil
          local i = 0
          repeat
            local key = propsToUpdate[i+1]
            -- [ts2lua]oldProps下标访问可能不正确
            local prev = oldProps[key]
            -- [ts2lua]newProps下标访问可能不正确
            local next = newProps[key]
            if next ~= prev or hostForcePatchProp and hostForcePatchProp(el, key) then
              hostPatchProp(el, key, prev, next, isSVG, n1.children, parentComponent, parentSuspense, unmountChildren)
            end
            i=i+1
          until not(i < #propsToUpdate)
        end
      end
      if patchFlag & PatchFlags.TEXT then
        if n1.children ~= n2.children then
          hostSetElementText(el, n2.children)
        end
      end
    elseif not optimized and dynamicChildren == nil then
      patchProps(el, n2, oldProps, newProps, parentComponent, parentSuspense, isSVG)
    end
    local areChildrenSVG = isSVG and n2.type ~= 'foreignObject'
    if dynamicChildren then
      patchBlockChildren(dynamicChildren, el, parentComponent, parentSuspense, areChildrenSVG)
      if (__DEV__ and parentComponent) and parentComponent.type.__hmrId then
        traverseStaticChildren(n1, n2)
      end
    elseif not optimized then
      patchChildren(n1, n2, el, nil, parentComponent, parentSuspense, areChildrenSVG)
    end
    if (vnodeHook = newProps.onVnodeUpdated) or dirs then
      queuePostRenderEffect(function()
        vnodeHook and invokeVNodeHook(vnodeHook, parentComponent, n2, n1)
        dirs and invokeDirectiveHook(n2, n1, parentComponent, 'updated')
      end
      , parentSuspense)
    end
  end
  
  local patchBlockChildren = function(oldChildren, newChildren, fallbackContainer, parentComponent, parentSuspense, isSVG)
    local i = 0
    repeat
      local oldVNode = oldChildren[i+1]
      local newVNode = newChildren[i+1]
      -- [ts2lua]lua中0和空字符串也是true，此处(oldVNode.type == Fragment or not isSameVNodeType(oldVNode, newVNode)) or oldVNode.shapeFlag & ShapeFlags.COMPONENT需要确认
      local container = ((oldVNode.type == Fragment or not isSameVNodeType(oldVNode, newVNode)) or oldVNode.shapeFlag & ShapeFlags.COMPONENT and {} or {fallbackContainer})[1]
      patch(oldVNode, newVNode, container, nil, parentComponent, parentSuspense, isSVG, true)
      i=i+1
    until not(i < #newChildren)
  end
  
  local patchProps = function(el, vnode, oldProps, newProps, parentComponent, parentSuspense, isSVG)
    if oldProps ~= newProps then
      for key in pairs(newProps) do
        if isReservedProp(key) then
          break
        end
        -- [ts2lua]newProps下标访问可能不正确
        local next = newProps[key]
        -- [ts2lua]oldProps下标访问可能不正确
        local prev = oldProps[key]
        if next ~= prev or hostForcePatchProp and hostForcePatchProp(el, key) then
          hostPatchProp(el, key, prev, next, isSVG, vnode.children, parentComponent, parentSuspense, unmountChildren)
        end
      end
      if oldProps ~= EMPTY_OBJ then
        for key in pairs(oldProps) do
          if not isReservedProp(key) and not (newProps[key]) then
            -- [ts2lua]oldProps下标访问可能不正确
            hostPatchProp(el, key, oldProps[key], nil, isSVG, vnode.children, parentComponent, parentSuspense, unmountChildren)
          end
        end
      end
    end
  end
  
  local processFragment = function(n1, n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
    local fragmentStartAnchor = nil
    local fragmentEndAnchor = nil
    local  = n2
    if patchFlag > 0 then
      optimized = true
    end
    if __DEV__ and isHmrUpdating then
      patchFlag = 0
      optimized = false
      dynamicChildren = nil
    end
    if n1 == nil then
      hostInsert(fragmentStartAnchor, container, anchor)
      hostInsert(fragmentEndAnchor, container, anchor)
      mountChildren(n2.children, container, fragmentEndAnchor, parentComponent, parentSuspense, isSVG, optimized)
    else
      if (patchFlag > 0 and patchFlag & PatchFlags.STABLE_FRAGMENT) and dynamicChildren then
        patchBlockChildren(dynamicChildren, container, parentComponent, parentSuspense, isSVG)
        if (__DEV__ and parentComponent) and parentComponent.type.__hmrId then
          traverseStaticChildren(n1, n2)
        end
      else
        patchChildren(n1, n2, container, fragmentEndAnchor, parentComponent, parentSuspense, isSVG, optimized)
      end
    end
  end
  
  local processComponent = function(n1, n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
    if n1 == nil then
      if n2.shapeFlag & ShapeFlags.COMPONENT_KEPT_ALIVE then
        
        ().ctx:activate(n2, container, anchor, isSVG, optimized)
      else
        mountComponent(n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
      end
    else
      updateComponent(n1, n2, optimized)
    end
  end
  
  local mountComponent = function(initialVNode, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
    initialVNode.component = createComponentInstance(initialVNode, parentComponent, parentSuspense)
    local instance = initialVNode.component
    if __DEV__ and instance.type.__hmrId then
      registerHMR(instance)
    end
    if __DEV__ then
      pushWarningContext(initialVNode)
      startMeasure(instance, )
    end
    if isKeepAlive(initialVNode) then
      
      instance.ctx.renderer = internals
    end
    if __DEV__ then
      startMeasure(instance, )
    end
    setupComponent(instance)
    if __DEV__ then
      endMeasure(instance, )
    end
    if __FEATURE_SUSPENSE__ and instance.asyncDep then
      if not parentSuspense then
        if __DEV__ then
          warn('async setup() is used without a suspense boundary!')
        end
        return
      end
      parentSuspense:registerDep(instance, setupRenderEffect)
      if not initialVNode.el then
        instance.subTree = createVNode(Comment)
        local placeholder = instance.subTree
        processCommentNode(nil, placeholder, , anchor)
      end
      return
    end
    setupRenderEffect(instance, initialVNode, container, anchor, parentSuspense, isSVG, optimized)
    if __DEV__ then
      popWarningContext()
      endMeasure(instance, )
    end
  end
  
  local updateComponent = function(n1, n2, optimized)
    local instance = nil
    if shouldUpdateComponent(n1, n2, optimized) then
      if (__FEATURE_SUSPENSE__ and instance.asyncDep) and not instance.asyncResolved then
        if __DEV__ then
          pushWarningContext(n2)
        end
        updateComponentPreRender(instance, n2, optimized)
        if __DEV__ then
          popWarningContext()
        end
        return
      else
        instance.next = n2
        invalidateJob(instance.update)
        instance:update()
      end
    else
      n2.component = n1.component
      n2.el = n1.el
      instance.vnode = n2
    end
  end
  
  local setupRenderEffect = function(instance, initialVNode, container, anchor, parentSuspense, isSVG, optimized)
    instance.update = effect(function componentEffect()
      if not instance.isMounted then
        local vnodeHook = nil
        local  = initialVNode
        local  = instance
        if __DEV__ then
          startMeasure(instance, )
        end
        instance.subTree = renderComponentRoot(instance)
        local subTree = instance.subTree
        if __DEV__ then
          endMeasure(instance, )
        end
        if bm then
          invokeArrayFns(bm)
        end
        if vnodeHook = props and props.onVnodeBeforeMount then
          invokeVNodeHook(vnodeHook, parent, initialVNode)
        end
        if el and hydrateNode then
          if __DEV__ then
            startMeasure(instance, )
          end
          hydrateNode(initialVNode.el, subTree, instance, parentSuspense)
          if __DEV__ then
            endMeasure(instance, )
          end
        else
          if __DEV__ then
            startMeasure(instance, )
          end
          patch(nil, subTree, container, anchor, instance, parentSuspense, isSVG)
          if __DEV__ then
            endMeasure(instance, )
          end
          initialVNode.el = subTree.el
        end
        if m then
          queuePostRenderEffect(m, parentSuspense)
        end
        if vnodeHook = props and props.onVnodeMounted then
          queuePostRenderEffect(function()
            invokeVNodeHook(parent, initialVNode)
          end
          , parentSuspense)
        end
        if a and initialVNode.shapeFlag & ShapeFlags.COMPONENT_SHOULD_KEEP_ALIVE then
          queuePostRenderEffect(a, parentSuspense)
        end
        instance.isMounted = true
      else
        local  = instance
        local originNext = next
        local vnodeHook = nil
        if __DEV__ then
          pushWarningContext(next or instance.vnode)
        end
        if next then
          updateComponentPreRender(instance, next, optimized)
        else
          next = vnode
        end
        if __DEV__ then
          startMeasure(instance, )
        end
        local nextTree = renderComponentRoot(instance)
        if __DEV__ then
          endMeasure(instance, )
        end
        local prevTree = instance.subTree
        instance.subTree = nextTree
        next.el = vnode.el
        if bu then
          invokeArrayFns(bu)
        end
        if vnodeHook = next.props and next.props.onVnodeBeforeUpdate then
          invokeVNodeHook(vnodeHook, parent, next, vnode)
        end
        if instance.refs ~= EMPTY_OBJ then
          instance.refs = {}
        end
        if __DEV__ then
          startMeasure(instance, )
        end
        patch(prevTree, nextTree, , getNextHostNode(prevTree), instance, parentSuspense, isSVG)
        if __DEV__ then
          endMeasure(instance, )
        end
        next.el = nextTree.el
        if originNext == nil then
          updateHOCHostEl(instance, nextTree.el)
        end
        if u then
          queuePostRenderEffect(u, parentSuspense)
        end
        if vnodeHook = next.props and next.props.onVnodeUpdated then
          queuePostRenderEffect(function()
            invokeVNodeHook(parent, , vnode)
          end
          , parentSuspense)
        end
        if __DEV__ then
          popWarningContext()
        end
      end
    end
    -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
    , (__DEV__ and {createDevEffectOptions(instance)} or {prodEffectOptions})[1])
  end
  
  local updateComponentPreRender = function(instance, nextVNode, optimized)
    if __DEV__ and instance.type.__hmrId then
      optimized = false
    end
    nextVNode.component = instance
    local prevProps = instance.vnode.props
    instance.vnode = nextVNode
    instance.next = nil
    updateProps(instance, nextVNode.props, prevProps, optimized)
    updateSlots(instance, nextVNode.children)
  end
  
  local patchChildren = function(n1, n2, container, anchor, parentComponent, parentSuspense, isSVG, optimized = false)
    if optimized == nil then
      optimized=false
    end
    local c1 = n1 and n1.children
    -- [ts2lua]lua中0和空字符串也是true，此处n1需要确认
    local prevShapeFlag = (n1 and {n1.shapeFlag} or {0})[1]
    local c2 = n2.children
    local  = n2
    if patchFlag > 0 then
      if patchFlag & PatchFlags.KEYED_FRAGMENT then
        patchKeyedChildren(c1, c2, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
        return
      elseif patchFlag & PatchFlags.UNKEYED_FRAGMENT then
        patchUnkeyedChildren(c1, c2, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
        return
      end
    end
    if shapeFlag & ShapeFlags.TEXT_CHILDREN then
      if prevShapeFlag & ShapeFlags.ARRAY_CHILDREN then
        unmountChildren(c1, parentComponent, parentSuspense)
      end
      if c2 ~= c1 then
        hostSetElementText(container, c2)
      end
    else
      if prevShapeFlag & ShapeFlags.ARRAY_CHILDREN then
        if shapeFlag & ShapeFlags.ARRAY_CHILDREN then
          patchKeyedChildren(c1, c2, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
        else
          unmountChildren(c1, parentComponent, parentSuspense, true)
        end
      else
        if prevShapeFlag & ShapeFlags.TEXT_CHILDREN then
          hostSetElementText(container, '')
        end
        if shapeFlag & ShapeFlags.ARRAY_CHILDREN then
          mountChildren(c2, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
        end
      end
    end
  end
  
  local patchUnkeyedChildren = function(c1, c2, container, anchor, parentComponent, parentSuspense, isSVG, optimized)
    c1 = c1 or EMPTY_ARR
    c2 = c2 or EMPTY_ARR
    local oldLength = #c1
    local newLength = #c2
    local commonLength = Math:min(oldLength, newLength)
    local i = nil
    i = 0
    repeat
      -- [ts2lua]lua中0和空字符串也是true，此处optimized需要确认
      c2[i+1] = (optimized and {cloneIfMounted(c2[i+1])} or {normalizeVNode(c2[i+1])})[1]
      local nextChild = c2[i+1]
      patch(c1[i+1], nextChild, container, nil, parentComponent, parentSuspense, isSVG, optimized)
      i=i+1
    until not(i < commonLength)
    if oldLength > newLength then
      unmountChildren(c1, parentComponent, parentSuspense, true, commonLength)
    else
      mountChildren(c2, container, anchor, parentComponent, parentSuspense, isSVG, optimized, commonLength)
    end
  end
  
  local patchKeyedChildren = function(c1, c2, container, parentAnchor, parentComponent, parentSuspense, isSVG, optimized)
    local i = 0
    local l2 = #c2
    local e1 = #c1 - 1
    local e2 = l2 - 1
    while(i <= e1 and i <= e2)
    do
    local n1 = c1[i+1]
    -- [ts2lua]lua中0和空字符串也是true，此处optimized需要确认
    c2[i+1] = (optimized and {cloneIfMounted(c2[i+1])} or {normalizeVNode(c2[i+1])})[1]
    local n2 = c2[i+1]
    if isSameVNodeType(n1, n2) then
      patch(n1, n2, container, nil, parentComponent, parentSuspense, isSVG, optimized)
    else
      break
    end
    i=i+1
    end
    while(i <= e1 and i <= e2)
    do
    -- [ts2lua]c1下标访问可能不正确
    local n1 = c1[e1]
    -- [ts2lua]c2下标访问可能不正确
    -- [ts2lua]c2下标访问可能不正确
    -- [ts2lua]c2下标访问可能不正确
    -- [ts2lua]lua中0和空字符串也是true，此处optimized需要确认
    c2[e2] = (optimized and {cloneIfMounted(c2[e2])} or {normalizeVNode(c2[e2])})[1]
    -- [ts2lua]c2下标访问可能不正确
    local n2 = c2[e2]
    if isSameVNodeType(n1, n2) then
      patch(n1, n2, container, nil, parentComponent, parentSuspense, isSVG, optimized)
    else
      break
    end
    e1=e1-1
    e2=e2-1
    end
    if i > e1 then
      if i <= e2 then
        local nextPos = e2 + 1
        -- [ts2lua]c2下标访问可能不正确
        -- [ts2lua]lua中0和空字符串也是true，此处nextPos < l2需要确认
        local anchor = (nextPos < l2 and {c2[nextPos].el} or {parentAnchor})[1]
        while(i <= e2)
        do
        patch(nil, c2[i+1], container, anchor, parentComponent, parentSuspense, isSVG)
        i=i+1
        end
      end
    elseif i > e2 then
      while(i <= e1)
      do
      unmount(c1[i+1], parentComponent, parentSuspense, true)
      i=i+1
      end
    else
      local s1 = i
      local s2 = i
      local keyToNewIndexMap = Map()
      i = s2
      repeat
        -- [ts2lua]lua中0和空字符串也是true，此处optimized需要确认
        c2[i+1] = (optimized and {cloneIfMounted(c2[i+1])} or {normalizeVNode(c2[i+1])})[1]
        local nextChild = c2[i+1]
        if nextChild.key ~= nil then
          if __DEV__ and keyToNewIndexMap:has(nextChild.key) then
            warn(JSON:stringify(nextChild.key), )
          end
          keyToNewIndexMap:set(nextChild.key, i)
        end
        i=i+1
      until not(i <= e2)
      local j = nil
      local patched = 0
      local toBePatched = e2 - s2 + 1
      local moved = false
      local maxNewIndexSoFar = 0
      local newIndexToOldIndexMap = {}
      i = 0
      repeat
        newIndexToOldIndexMap[i+1] = 0
        i=i+1
      until not(i < toBePatched)
      i = s1
      repeat
        local prevChild = c1[i+1]
        if patched >= toBePatched then
          unmount(prevChild, parentComponent, parentSuspense, true)
          break
        end
        local newIndex = nil
        if prevChild.key ~= nil then
          newIndex = keyToNewIndexMap:get(prevChild.key)
        else
          j = s2
          repeat
            -- [ts2lua]newIndexToOldIndexMap下标访问可能不正确
            if newIndexToOldIndexMap[j - s2] == 0 and isSameVNodeType(prevChild, c2[j+1]) then
              newIndex = j
              break
            end
            j=j+1
          until not(j <= e2)
        end
        if newIndex == undefined then
          unmount(prevChild, parentComponent, parentSuspense, true)
        else
          -- [ts2lua]newIndexToOldIndexMap下标访问可能不正确
          newIndexToOldIndexMap[newIndex - s2] = i + 1
          if newIndex >= maxNewIndexSoFar then
            maxNewIndexSoFar = newIndex
          else
            moved = true
          end
          -- [ts2lua]c2下标访问可能不正确
          patch(prevChild, c2[newIndex], container, nil, parentComponent, parentSuspense, isSVG, optimized)
          patched=patched+1
        end
        i=i+1
      until not(i <= e1)
      -- [ts2lua]lua中0和空字符串也是true，此处moved需要确认
      local increasingNewIndexSequence = (moved and {getSequence(newIndexToOldIndexMap)} or {EMPTY_ARR})[1]
      j = #increasingNewIndexSequence - 1
      i = toBePatched - 1
      repeat
        local nextIndex = s2 + i
        -- [ts2lua]c2下标访问可能不正确
        local nextChild = c2[nextIndex]
        -- [ts2lua]c2下标访问可能不正确
        -- [ts2lua]lua中0和空字符串也是true，此处nextIndex + 1 < l2需要确认
        local anchor = (nextIndex + 1 < l2 and {c2[nextIndex + 1].el} or {parentAnchor})[1]
        if newIndexToOldIndexMap[i+1] == 0 then
          patch(nil, nextChild, container, anchor, parentComponent, parentSuspense, isSVG)
        elseif moved then
          if j < 0 or i ~= increasingNewIndexSequence[j+1] then
            move(nextChild, container, anchor, MoveType.REORDER)
          else
            j=j-1
          end
        end
        i=i-1
      until not(i >= 0)
    end
  end
  
  local move = function(vnode, container, anchor, moveType, parentSuspense = nil)
    if parentSuspense == nil then
      parentSuspense=nil
    end
    local  = vnode
    if shapeFlag & ShapeFlags.COMPONENT then
      move(().subTree, container, anchor, moveType)
      return
    end
    if __FEATURE_SUSPENSE__ and shapeFlag & ShapeFlags.SUSPENSE then
      ():move(container, anchor, moveType)
      return
    end
    if shapeFlag & ShapeFlags.TELEPORT then
      
      type:move(vnode, container, anchor, internals)
      return
    end
    if type == Fragment then
      hostInsert(container, anchor)
      local i = 0
      repeat
        move(children[i+1], container, anchor, moveType)
        i=i+1
      until not(i < #children)
      hostInsert(container, anchor)
      return
    end
    if __DEV__ and type == Static then
      moveStaticNode(vnode, container, anchor)
      return
    end
    local needTransition = (moveType ~= MoveType.REORDER and shapeFlag & ShapeFlags.ELEMENT) and transition
    if needTransition then
      if moveType == MoveType.ENTER then
        ():beforeEnter()
        hostInsert(container, anchor)
        queuePostRenderEffect(function()
          ():enter()
        end
        , parentSuspense)
      else
        local  = nil
        local remove = function()
          hostInsert(container, anchor)
        end
        
        local performLeave = function()
          leave(function()
            remove()
            afterLeave and afterLeave()
          end
          )
        end
        
        if delayLeave then
          delayLeave(remove, performLeave)
        else
          performLeave()
        end
      end
    else
      hostInsert(container, anchor)
    end
  end
  
  local unmount = function(vnode, parentComponent, parentSuspense, doRemove = false)
    if doRemove == nil then
      doRemove=false
    end
    local  = vnode
    if ref ~= nil and parentComponent then
      setRef(ref, nil, parentComponent, nil)
    end
    if shapeFlag & ShapeFlags.COMPONENT_SHOULD_KEEP_ALIVE then
      
      ().ctx:deactivate(vnode)
      return
    end
    local shouldInvokeDirs = shapeFlag & ShapeFlags.ELEMENT and dirs
    local vnodeHook = nil
    if vnodeHook = props and props.onVnodeBeforeUnmount then
      invokeVNodeHook(vnodeHook, parentComponent, vnode)
    end
    if shapeFlag & ShapeFlags.COMPONENT then
      unmountComponent(parentSuspense, doRemove)
    else
      if __FEATURE_SUSPENSE__ and shapeFlag & ShapeFlags.SUSPENSE then
        ():unmount(parentSuspense, doRemove)
        return
      end
      if shouldInvokeDirs then
        invokeDirectiveHook(vnode, nil, parentComponent, 'beforeUnmount')
      end
      if dynamicChildren and (type ~= Fragment or patchFlag > 0 and patchFlag & PatchFlags.STABLE_FRAGMENT) then
        unmountChildren(dynamicChildren, parentComponent, parentSuspense)
      elseif shapeFlag & ShapeFlags.ARRAY_CHILDREN then
        unmountChildren(children, parentComponent, parentSuspense)
      end
      if shapeFlag & ShapeFlags.TELEPORT then
        
        vnode.type:remove(vnode, internals)
      end
      if doRemove then
        remove(vnode)
      end
    end
    if (vnodeHook = props and props.onVnodeUnmounted) or shouldInvokeDirs then
      queuePostRenderEffect(function()
        vnodeHook and invokeVNodeHook(vnodeHook, parentComponent, vnode)
        shouldInvokeDirs and invokeDirectiveHook(vnode, nil, parentComponent, 'unmounted')
      end
      , parentSuspense)
    end
  end
  
  local remove = function(vnode)
    local  = vnode
    if type == Fragment then
      removeFragment()
      return
    end
    if __DEV__ and type == Static then
      removeStaticNode(vnode)
      return
    end
    local performRemove = function()
      hostRemove()
      if (transition and not transition.persisted) and transition.afterLeave then
        transition:afterLeave()
      end
    end
    
    if (vnode.shapeFlag & ShapeFlags.ELEMENT and transition) and not transition.persisted then
      local  = transition
      local performLeave = function()
        leave(performRemove)
      end
      
      if delayLeave then
        delayLeave(performRemove, performLeave)
      else
        performLeave()
      end
    else
      performRemove()
    end
  end
  
  local removeFragment = function(cur, tsvar_end)
    local next = nil
    while(cur ~= tsvar_end)
    do
    next = 
    hostRemove(cur)
    cur = next
    end
    hostRemove(tsvar_end)
  end
  
  local unmountComponent = function(instance, parentSuspense, doRemove)
    if __DEV__ and instance.type.__hmrId then
      unregisterHMR(instance)
    end
    local  = instance
    if bum then
      invokeArrayFns(bum)
    end
    if effects then
      local i = 0
      repeat
        stop(effects[i+1])
        i=i+1
      until not(i < #effects)
    end
    if update then
      stop(update)
      unmount(subTree, instance, parentSuspense, doRemove)
    end
    if um then
      queuePostRenderEffect(um, parentSuspense)
    end
    if (da and not isDeactivated) and instance.vnode.shapeFlag & ShapeFlags.COMPONENT_SHOULD_KEEP_ALIVE then
      queuePostRenderEffect(da, parentSuspense)
    end
    queuePostRenderEffect(function()
      instance.isUnmounted = true
    end
    , parentSuspense)
    if ((((__FEATURE_SUSPENSE__ and parentSuspense) and not parentSuspense.isResolved) and not parentSuspense.isUnmounted) and instance.asyncDep) and not instance.asyncResolved then
      parentSuspense.deps=parentSuspense.deps-1
      if parentSuspense.deps == 0 then
        parentSuspense:resolve()
      end
    end
  end
  
  local unmountChildren = function(children, parentComponent, parentSuspense, doRemove = false, start = 0)
    if doRemove == nil then
      doRemove=false
    end
    if start == nil then
      start=0
    end
    local i = start
    repeat
      unmount(children[i+1], parentComponent, parentSuspense, doRemove)
      i=i+1
    until not(i < #children)
  end
  
  local getNextHostNode = function(vnode)
    if vnode.shapeFlag & ShapeFlags.COMPONENT then
      return getNextHostNode(().subTree)
    end
    if __FEATURE_SUSPENSE__ and vnode.shapeFlag & ShapeFlags.SUSPENSE then
      return ():next()
    end
    return hostNextSibling()
  end
  
  local traverseStaticChildren = function(n1, n2)
    local ch1 = n1.children
    local ch2 = n2.children
    if isArray(ch1) and isArray(ch2) then
      local i = 0
      repeat
        local c1 = ch1[i+1]
        local c2 = ch2[i+1]
        if ((isVNode(c1) and isVNode(c2)) and c2.shapeFlag & ShapeFlags.ELEMENT) and not c2.dynamicChildren then
          if c2.patchFlag <= 0 then
            c2.el = c1.el
          end
          traverseStaticChildren(c1, c2)
        end
        i=i+1
      until not(i < #ch1)
    end
  end
  
  local render = function(vnode, container)
    if vnode == nil then
      if container._vnode then
        unmount(container._vnode, nil, nil, true)
      end
    else
      patch(container._vnode or nil, vnode, container)
    end
    flushPostFlushCbs()
    container._vnode = vnode
  end
  
  local internals = {p=patch, um=unmount, m=move, r=remove, mt=mountComponent, mc=mountChildren, pc=patchChildren, pbc=patchBlockChildren, n=getNextHostNode, o=options}
  local hydrate = nil
  local hydrateNode = nil
  if createHydrationFns then
    
     = createHydrationFns(internals)
  end
  return {render=render, hydrate=hydrate, createApp=createAppAPI(render, hydrate)}
end

function invokeVNodeHook(hook, instance, vnode, prevVNode)
  if prevVNode == nil then
    prevVNode=nil
  end
  callWithAsyncErrorHandling(hook, instance, ErrorCodes.VNODE_HOOK, {vnode, prevVNode})
end

function getSequence(arr)
  local p = arr:slice()
  local result = {0}
  local i = nil
  local j = nil
  local u = nil
  local v = nil
  local c = nil
  local len = #arr
  i = 0
  repeat
    repeat
      local arrI = arr[i+1]
      if arrI ~= 0 then
        -- [ts2lua]result下标访问可能不正确
        j = result[#result - 1]
        if arr[j+1] < arrI then
          p[i+1] = j
          table.insert(result, i)
          break
        end
        u = 0
        v = #result - 1
        while(u < v)
        do
        c = u + v / 2 | 0
        -- [ts2lua]arr下标访问可能不正确
        if arr[result[c+1]] < arrI then
          u = c + 1
        else
          v = c
        end
        end
        -- [ts2lua]arr下标访问可能不正确
        if arrI < arr[result[u+1]] then
          if u > 0 then
            -- [ts2lua]result下标访问可能不正确
            p[i+1] = result[u - 1]
          end
          result[u+1] = i
        end
      end
    until true
    i=i+1
  until not(i < len)
  
  u = result.length
  -- [ts2lua]result下标访问可能不正确
  v = result[u - 1]
  local uBefore = u
  u=u-1
  while(uBefore > 0)
  do
  result[u+1] = v
  v = p[v+1]
  end
  return result
end
