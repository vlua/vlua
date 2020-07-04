require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast")
require("compiler-core/src/ast/ElementTypes")
require("@vue/shared")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/src/utils")
require("compiler-core/src/transforms/hoistStatic")

function createTransformContext(root, )
  local context = {prefixIdentifiers=prefixIdentifiers, hoistStatic=hoistStatic, cacheHandlers=cacheHandlers, nodeTransforms=nodeTransforms, directiveTransforms=directiveTransforms, transformHoist=transformHoist, isBuiltInComponent=isBuiltInComponent, expressionPlugins=expressionPlugins, scopeId=scopeId, ssr=ssr, onError=onError, root=root, helpers=Set(), components=Set(), directives=Set(), hoists={}, imports=Set(), temps=0, cached=0, identifiers={}, scopes={vFor=0, vSlot=0, vPre=0, vOnce=0}, parent=nil, currentNode=root, childIndex=0, helper=function(name)
    context.helpers:add(name)
    return name
  end
  , helperString=function(name)
    return 
  end
  , replaceNode=function(node)
    if __DEV__ then
      if not context.currentNode then
        error(Error())
      end
      if not context.parent then
        error(Error())
      end
    end
    context.currentNode = node
    -- [ts2lua]().children下标访问可能不正确
    ().children[context.childIndex] = context.currentNode
  end
  , removeNode=function(node)
    if __DEV__ and not context.parent then
      error(Error())
    end
    local list = ().children
    -- [ts2lua]lua中0和空字符串也是true，此处context.currentNode需要确认
    -- [ts2lua]lua中0和空字符串也是true，此处node需要确认
    local removalIndex = (node and {list:find(node)} or {(context.currentNode and {context.childIndex} or {-1})[1]})[1]
    if __DEV__ and removalIndex < 0 then
      error(Error())
    end
    if not node or node == context.currentNode then
      context.currentNode = nil
      context:onNodeRemoved()
    else
      if context.childIndex > removalIndex then
        context.childIndex=context.childIndex-1
        context:onNodeRemoved()
      end
    end
    ().children:splice(removalIndex, 1)
  end
  , onNodeRemoved=function()
    
  end
  , addIdentifiers=function(exp)
    if not __BROWSER__ then
      if isString(exp) then
        addId(exp)
      elseif exp.identifiers then
        exp.identifiers:forEach(addId)
      elseif exp.type == NodeTypes.SIMPLE_EXPRESSION then
        addId(exp.content)
      end
    end
  end
  , removeIdentifiers=function(exp)
    if not __BROWSER__ then
      if isString(exp) then
        removeId(exp)
      elseif exp.identifiers then
        exp.identifiers:forEach(removeId)
      elseif exp.type == NodeTypes.SIMPLE_EXPRESSION then
        removeId(exp.content)
      end
    end
  end
  , hoist=function(exp)
    table.insert(context.hoists, exp)
    local identifier = createSimpleExpression(false, exp.loc, true)
    identifier.hoisted = exp
    return identifier
  end
  , cache=function(exp, isVNode)
    if isVNode == nil then
      isVNode=false
    end
    return createCacheExpression(context.cached, exp, isVNode)
  end
  }
  function addId(id)
    local  = context
    -- [ts2lua]identifiers下标访问可能不正确
    if identifiers[id] == undefined then
      -- [ts2lua]identifiers下标访问可能不正确
      identifiers[id] = 0
    end
    =+1
  end
  
  function removeId(id)
    =-1
  end
  
  return context
end

function transform(root, options)
  local context = createTransformContext(root, options)
  traverseNode(root, context)
  if options.hoistStatic then
    hoistStatic(root, context)
  end
  if not options.ssr then
    createRootCodegen(root, context)
  end
  root.helpers = {...}
  root.components = {...}
  root.directives = {...}
  root.imports = {...}
  root.hoists = context.hoists
  root.temps = context.temps
  root.cached = context.cached
end

function createRootCodegen(root, context)
  local  = context
  local  = root
  local child = children[0+1]
  if #children == 1 then
    if isSingleElementRoot(root, child) and child.codegenNode then
      local codegenNode = child.codegenNode
      if codegenNode.type == NodeTypes.VNODE_CALL then
        codegenNode.isBlock = true
        helper(OPEN_BLOCK)
        helper(CREATE_BLOCK)
      end
      root.codegenNode = codegenNode
    else
      root.codegenNode = child
    end
  elseif #children > 1 then
    root.codegenNode = createVNodeCall(context, helper(FRAGMENT), undefined, root.children, , undefined, undefined, true)
  end
end

function traverseChildren(parent, context)
  local i = 0
  local nodeRemoved = function()
    i=i-1
  end
  
  repeat
    repeat
      local child = parent.children[i+1]
      if isString(child) then
        break
      end
      context.parent = parent
      context.childIndex = i
      context.onNodeRemoved = nodeRemoved
      traverseNode(child, context)
    until true
    i=i+1
  until not(i < #parent.children)
end

function traverseNode(node, context)
  context.currentNode = node
  local  = context
  local exitFns = {}
  local i = 0
  repeat
    local onExit = nodeTransforms[i+1](node, context)
    if onExit then
      if isArray(onExit) then
        table.insert(exitFns, ...)
      else
        table.insert(exitFns, onExit)
      end
    end
    if not context.currentNode then
      return
    else
      node = context.currentNode
    end
    i=i+1
  until not(i < #nodeTransforms)
  local switch = {
    [NodeTypes.COMMENT] = function()
      if not context.ssr then
        context:helper(CREATE_COMMENT)
      end
    end,
    [NodeTypes.INTERPOLATION] = function()
      if not context.ssr then
        context:helper(TO_DISPLAY_STRING)
      end
    end,
    [NodeTypes.IF] = function()
      local i = 0
      repeat
        traverseNode(node.branches[i+1], context)
        i=i+1
      until not(i < #node.branches)
    end,
    [NodeTypes.IF_BRANCH] = function()
     end,
    [NodeTypes.FOR] = function()
     end,
    [NodeTypes.ELEMENT] = function()
     end,
    [NodeTypes.ROOT] = function()
      traverseChildren(node, context)
    end
  }
  local casef = switch[node.type]
  if not casef then casef = switch["default"] end
  if casef then casef() end
  local i = #exitFns
  while(i=i-1)
  do
  exitFns[i+1]()
  end
end

function createStructuralDirectiveTransform(name, fn)
  local matches = (isString(name) and {function(n)
    n == name
  end
  } or {function(n)
    name:test(n)
  end
  -- [ts2lua]lua中0和空字符串也是true，此处isString(name)需要确认
  })[1]
  return function(node, context)
    if node.type == NodeTypes.ELEMENT then
      local  = node
      if node.tagType == ElementTypes.TEMPLATE and props:some(isVSlot) then
        return
      end
      local exitFns = {}
      local i = 0
      repeat
        local prop = props[i+1]
        if prop.type == NodeTypes.DIRECTIVE and matches(prop.name) then
          props:splice(i, 1)
          i=i-1
          local onExit = fn(node, prop, context)
          if onExit then
            table.insert(exitFns, onExit)
          end
        end
        i=i+1
      until not(i < #props)
      return exitFns
    end
  end
  

end
