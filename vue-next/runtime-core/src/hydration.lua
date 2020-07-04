require("runtime-core/src/vnode")
require("runtime-core/src/scheduler")
require("runtime-core/src/directives")
require("runtime-core/src/warning")
require("@vue/shared/PatchFlags")
require("@vue/shared/ShapeFlags")
require("@vue/shared")
require("runtime-core/src/renderer")
require("runtime-core/src/components/Suspense")
local DOMNodeTypes = {
  ELEMENT = 1,
  TEXT = 3,
  COMMENT = 8
}

local hasMismatch = false
local isSVGContainer = function(container)
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  (/svg/):test() and container.tagName ~= 'foreignObject'
end

local isComment = function(node)
  node.nodeType == DOMNodeTypes.COMMENT
end

function createHydrationFunctions(rendererInternals)
  local  = rendererInternals
  local hydrate = function(vnode, container)
    if __DEV__ and not container:hasChildNodes() then
      warn( + )
      patch(nil, vnode, container)
      return
    end
    hasMismatch = false
    hydrateNode(vnode, nil, nil)
    flushPostFlushCbs()
    if hasMismatch and not __TEST__ then
      console:error()
    end
  end
  
  local hydrateNode = function(node, vnode, parentComponent, parentSuspense, optimized = false)
    if optimized == nil then
      optimized=false
    end
    local isFragmentStart = isComment(node) and node.data == '['
    local onMismatch = function()
      handleMismtach(node, vnode, parentComponent, parentSuspense, isFragmentStart)
    end
    
    local  = vnode
    local domType = node.nodeType
    vnode.el = node
    local nextNode = nil
    local switch = {
      [Text] = function()
        if domType ~= DOMNodeTypes.TEXT then
          nextNode = onMismatch()
        else
          if node.data ~= vnode.children then
            hasMismatch = true
            __DEV__ and warn( +  + )
            node.data = vnode.children
          end
          nextNode = nextSibling(node)
        end
      end,
      [Comment] = function()
        if domType ~= DOMNodeTypes.COMMENT or isFragmentStart then
          nextNode = onMismatch()
        else
          nextNode = nextSibling(node)
        end
      end,
      [Static] = function()
        if domType ~= DOMNodeTypes.ELEMENT then
          nextNode = onMismatch()
        else
          nextNode = node
          local needToAdoptContent = not #vnode.children
          local i = 0
          repeat
            if needToAdoptContent then
              vnode.children = vnode.children + nextNode.outerHTML
            end
            if i == vnode.staticCount - 1 then
              vnode.anchor = nextNode
            end
            nextNode = 
            i=i+1
          until not(i < vnode.staticCount)
          return nextNode
        end
      end,
      [Fragment] = function()
        if not isFragmentStart then
          nextNode = onMismatch()
        else
          nextNode = hydrateFragment(node, vnode, parentComponent, parentSuspense, optimized)
        end
      end,
      ["default"] = function()
        if shapeFlag & ShapeFlags.ELEMENT then
          if domType ~= DOMNodeTypes.ELEMENT or vnode.type ~= node.tagName:toLowerCase() then
            nextNode = onMismatch()
          else
            nextNode = hydrateElement(node, vnode, parentComponent, parentSuspense, optimized)
          end
        elseif shapeFlag & ShapeFlags.COMPONENT then
          local container = nil
          local hydrateComponent = function()
            mountComponent(vnode, container, nil, parentComponent, parentSuspense, isSVGContainer(container), optimized)
          end
          
          local loadAsync = vnode.type.__asyncLoader
          if loadAsync then
            loadAsync():tsvar_then(hydrateComponent)
          else
            hydrateComponent()
          end
          -- [ts2lua]lua中0和空字符串也是true，此处isFragmentStart需要确认
          nextNode = (isFragmentStart and {locateClosingAsyncAnchor(node)} or {nextSibling(node)})[1]
        elseif shapeFlag & ShapeFlags.TELEPORT then
          if domType ~= DOMNodeTypes.COMMENT then
            nextNode = onMismatch()
          else
            nextNode = vnode.type:hydrate(node, vnode, parentComponent, parentSuspense, optimized, rendererInternals, hydrateChildren)
          end
        elseif __FEATURE_SUSPENSE__ and shapeFlag & ShapeFlags.SUSPENSE then
          nextNode = vnode.type:hydrate(node, vnode, parentComponent, parentSuspense, isSVGContainer(), optimized, rendererInternals, hydrateNode)
        elseif __DEV__ then
          warn('Invalid HostVNode type:', type, )
        end
      end
    }
    local casef = switch[type]
    if not casef then casef = switch["default"] end
    if casef then casef() end
    if ref ~= nil and parentComponent then
      setRef(ref, nil, parentComponent, vnode)
    end
    return nextNode
  end
  
  local hydrateElement = function(el, vnode, parentComponent, parentSuspense, optimized)
    optimized = optimized or not (not vnode.dynamicChildren)
    local  = vnode
    if patchFlag ~= PatchFlags.HOISTED then
      if props then
        if not optimized or (patchFlag & PatchFlags.FULL_PROPS or patchFlag & PatchFlags.HYDRATE_EVENTS) then
          for key in pairs(props) do
            if not isReservedProp(key) and isOn(key) then
              -- [ts2lua]props下标访问可能不正确
              patchProp(el, key, nil, props[key])
            end
          end
        elseif props.onClick then
          patchProp(el, 'onClick', nil, props.onClick)
        end
      end
      local vnodeHooks = nil
      if vnodeHooks = props and props.onVnodeBeforeMount then
        invokeVNodeHook(vnodeHooks, parentComponent, vnode)
      end
      if dirs then
        invokeDirectiveHook(vnode, nil, parentComponent, 'beforeMount')
      end
      if (vnodeHooks = props and props.onVnodeMounted) or dirs then
        queueEffectWithSuspense(function()
          vnodeHooks and invokeVNodeHook(vnodeHooks, parentComponent, vnode)
          dirs and invokeDirectiveHook(vnode, nil, parentComponent, 'mounted')
        end
        , parentSuspense)
      end
      if shapeFlag & ShapeFlags.ARRAY_CHILDREN and not (props and (props.innerHTML or props.textContent)) then
        local next = hydrateChildren(el.firstChild, vnode, el, parentComponent, parentSuspense, optimized)
        local hasWarned = false
        while(next)
        do
        hasMismatch = true
        if __DEV__ and not hasWarned then
          warn( + )
          hasWarned = true
        end
        local cur = next
        next = next.nextSibling
        remove(cur)
        end
      elseif shapeFlag & ShapeFlags.TEXT_CHILDREN then
        if el.textContent ~= vnode.children then
          hasMismatch = true
          __DEV__ and warn( +  + )
          el.textContent = vnode.children
        end
      end
    end
    return el.nextSibling
  end
  
  local hydrateChildren = function(node, vnode, container, parentComponent, parentSuspense, optimized)
    optimized = optimized or not (not vnode.dynamicChildren)
    local children = vnode.children
    local l = #children
    local hasWarned = false
    local i = 0
    repeat
      -- [ts2lua]lua中0和空字符串也是true，此处optimized需要确认
      local vnode = (optimized and {children[i+1]} or {children[i+1] = normalizeVNode(children[i+1])})[1]
      if node then
        node = hydrateNode(node, vnode, parentComponent, parentSuspense, optimized)
      else
        hasMismatch = true
        if __DEV__ and not hasWarned then
          warn( + )
          hasWarned = true
        end
        patch(nil, vnode, container, nil, parentComponent, parentSuspense, isSVGContainer(container))
      end
      i=i+1
    until not(i < l)
    return node
  end
  
  local hydrateFragment = function(node, vnode, parentComponent, parentSuspense, optimized)
    local container = nil
    local next = hydrateChildren(vnode, container, parentComponent, parentSuspense, optimized)
    if (next and isComment(next)) and next.data == ']' then
      return nextSibling(vnode.anchor)
    else
      hasMismatch = true
      insert(vnode.anchor, container, next)
      return next
    end
  end
  
  local handleMismtach = function(node, vnode, parentComponent, parentSuspense, isFragment)
    hasMismatch = true
    -- [ts2lua]lua中0和空字符串也是true，此处isComment(node) and node.data == '['需要确认
    -- [ts2lua]lua中0和空字符串也是true，此处node.nodeType == DOMNodeTypes.TEXT需要确认
    __DEV__ and warn(vnode.type, , node, (node.nodeType == DOMNodeTypes.TEXT and {} or {(isComment(node) and node.data == '[' and {} or {})[1]})[1])
    vnode.el = nil
    if isFragment then
      local tsvar_end = locateClosingAsyncAnchor(node)
      while(true)
      do
      local next = nextSibling(node)
      if next and next ~= tsvar_end then
        remove(next)
      else
        break
      end
      end
    end
    local next = nextSibling(node)
    local container = nil
    remove(node)
    patch(nil, vnode, container, next, parentComponent, parentSuspense, isSVGContainer(container))
    return next
  end
  
  local locateClosingAsyncAnchor = function(node)
    local match = 0
    while(node)
    do
    node = nextSibling(node)
    if node and isComment(node) then
      if node.data == '[' then
        match=match+1
      end
      if node.data == ']' then
        if match == 0 then
          return nextSibling(node)
        else
          match=match-1
        end
      end
    end
    end
    return node
  end
  
  return {hydrate, hydrateNode}
end
