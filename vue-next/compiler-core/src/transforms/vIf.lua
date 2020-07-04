require("stringutil")
require("compiler-core/src/transform")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast/ElementTypes")
require("compiler-core/src/ast")
require("compiler-core/src/errors")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src/transforms/transformExpression")
require("compiler-core/src/validateExpression")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/src/utils")
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。

local transformIf = createStructuralDirectiveTransform(/^(if|else|else-if)$/, function(node, dir, context)
  return processIf(node, dir, context, function(ifNode, branch, isRoot)
    return function()
      if isRoot then
        ifNode.codegenNode = createCodegenNodeForBranch(branch, 0, context)
      else
        local parentCondition = nil
        while(parentCondition.alternate.type == NodeTypes.JS_CONDITIONAL_EXPRESSION)
        do
        parentCondition = parentCondition.alternate
        end
        parentCondition.alternate = createCodegenNodeForBranch(branch, #ifNode.branches - 1, context)
      end
    end
    
  
  end
  )
end
)
function processIf(node, dir, context, processCodegen)
  if dir.name ~= 'else' and (not dir.exp or not dir.exp.content:trim()) then
    -- [ts2lua]lua中0和空字符串也是true，此处dir.exp需要确认
    local loc = (dir.exp and {dir.exp.loc} or {node.loc})[1]
    context:onError(createCompilerError(ErrorCodes.X_V_IF_NO_EXPRESSION, dir.loc))
    dir.exp = createSimpleExpression(false, loc)
  end
  if (not __BROWSER__ and context.prefixIdentifiers) and dir.exp then
    dir.exp = processExpression(dir.exp, context)
  end
  if (__DEV__ and __BROWSER__) and dir.exp then
    validateBrowserExpression(dir.exp, context)
  end
  if dir.name == 'if' then
    local branch = createIfBranch(node, dir)
    local ifNode = {type=NodeTypes.IF, loc=node.loc, branches={branch}}
    context:replaceNode(ifNode)
    if processCodegen then
      return processCodegen(ifNode, branch, true)
    end
  else
    local siblings = ().children
    local comments = {}
    local i = siblings:find(node)
    local iBefore = i
    i=i-1
    while(iBefore >= -1)
    do
    local sibling = siblings[i+1]
    if (__DEV__ and sibling) and sibling.type == NodeTypes.COMMENT then
      context:removeNode(sibling)
      comments:unshift(sibling)
      break
    end
    if sibling and sibling.type == NodeTypes.IF then
      context:removeNode()
      local branch = createIfBranch(node, dir)
      if __DEV__ and #comments then
        branch.children = {..., ...}
      end
      table.insert(sibling.branches, branch)
      local onExit = processCodegen and processCodegen(sibling, branch, false)
      traverseNode(branch, context)
      if onExit then
        onExit()
      end
      context.currentNode = nil
    else
      context:onError(createCompilerError(ErrorCodes.X_V_ELSE_NO_ADJACENT_IF, node.loc))
    end
    break
    end
  end
end

function createIfBranch(node, dir)
  -- [ts2lua]lua中0和空字符串也是true，此处dir.name == 'else'需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处node.tagType == ElementTypes.TEMPLATE需要确认
  return {type=NodeTypes.IF_BRANCH, loc=node.loc, condition=(dir.name == 'else' and {undefined} or {dir.exp})[1], children=(node.tagType == ElementTypes.TEMPLATE and {node.children} or {{node}})[1]}
end

function createCodegenNodeForBranch(branch, index, context)
  if branch.condition then
    -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
    return createConditionalExpression(branch.condition, createChildrenCodegenNode(branch, index, context), createCallExpression(context:helper(CREATE_COMMENT), {(__DEV__ and {'"v-if"'} or {'""'})[1], 'true'}))
  else
    return createChildrenCodegenNode(branch, index, context)
  end
end

function createChildrenCodegenNode(branch, index, context)
  local  = context
  local keyProperty = createObjectProperty(createSimpleExpression(index .. '', false))
  local  = branch
  local firstChild = children[0+1]
  local needFragmentWrapper = #children ~= 1 or firstChild.type ~= NodeTypes.ELEMENT
  if needFragmentWrapper then
    if #children == 1 and firstChild.type == NodeTypes.FOR then
      local vnodeCall = nil
      injectProp(vnodeCall, keyProperty, context)
      return vnodeCall
    else
      return createVNodeCall(context, helper(FRAGMENT), createObjectExpression({keyProperty}), children, , undefined, undefined, true, false, branch.loc)
    end
  else
    local vnodeCall = firstChild.codegenNode
    if vnodeCall.type == NodeTypes.VNODE_CALL and (firstChild.tagType ~= ElementTypes.COMPONENT or vnodeCall.tag == TELEPORT) then
      vnodeCall.isBlock = true
      helper(OPEN_BLOCK)
      helper(CREATE_BLOCK)
    end
    injectProp(vnodeCall, keyProperty, context)
    return vnodeCall
  end
end
