require("stringutil")
require("compiler-core/src/transform")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast")
require("compiler-core/src/ast/ElementTypes")
require("compiler-core/src/errors")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src/utils")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/src/transforms/transformExpression")
require("compiler-core/src/validateExpression")
require("@vue/shared/PatchFlags")

local transformFor = createStructuralDirectiveTransform('for', function(node, dir, context)
  local  = context
  return processFor(node, dir, context, function(forNode)
    local renderExp = createCallExpression(helper(RENDER_LIST), {forNode.source})
    local keyProp = findProp(node, )
    local isStableFragment = forNode.source.type == NodeTypes.SIMPLE_EXPRESSION and forNode.source.isConstant
    -- [ts2lua]lua中0和空字符串也是true，此处keyProp需要确认
    -- [ts2lua]lua中0和空字符串也是true，此处isStableFragment需要确认
    local fragmentFlag = (isStableFragment and {PatchFlags.STABLE_FRAGMENT} or {(keyProp and {PatchFlags.KEYED_FRAGMENT} or {PatchFlags.UNKEYED_FRAGMENT})[1]})[1]
    forNode.codegenNode = createVNodeCall(context, helper(FRAGMENT), undefined, renderExp, , undefined, undefined, true, not isStableFragment, node.loc)
    return function()
      local childBlock = nil
      local isTemplate = isTemplateNode(node)
      local  = forNode
      local needFragmentWrapper = #children > 1 or children[0+1].type ~= NodeTypes.ELEMENT
      -- [ts2lua]lua中0和空字符串也是true，此处(isTemplate and #node.children == 1) and isSlotOutlet(node.children[0+1])需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处isSlotOutlet(node)需要确认
      local slotOutlet = (isSlotOutlet(node) and {node} or {((isTemplate and #node.children == 1) and isSlotOutlet(node.children[0+1]) and {node.children[0+1]} or {nil})[1]})[1]
      -- [ts2lua]lua中0和空字符串也是true，此处keyProp.type == NodeTypes.ATTRIBUTE需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处keyProp需要确认
      local keyProperty = (keyProp and {createObjectProperty((keyProp.type == NodeTypes.ATTRIBUTE and {createSimpleExpression(().content, true)} or {})[1])} or {nil})[1]
      if slotOutlet then
        childBlock = slotOutlet.codegenNode
        if isTemplate and keyProperty then
          injectProp(childBlock, keyProperty, context)
        end
      elseif needFragmentWrapper then
        -- [ts2lua]lua中0和空字符串也是true，此处keyProperty需要确认
        childBlock = createVNodeCall(context, helper(FRAGMENT), (keyProperty and {createObjectExpression({keyProperty})} or {undefined})[1], node.children, , undefined, undefined, true)
      else
        childBlock = children[0+1].codegenNode
        childBlock.isBlock = not isStableFragment
        if childBlock.isBlock then
          helper(OPEN_BLOCK)
          helper(CREATE_BLOCK)
        end
      end
      table.insert(renderExp.arguments, createFunctionExpression(createForLoopParams(forNode.parseResult), childBlock, true))
    end
    
  
  end
  )
end
)
function processFor(node, dir, context, processCodegen)
  if not dir.exp then
    context:onError(createCompilerError(ErrorCodes.X_V_FOR_NO_EXPRESSION, dir.loc))
    return
  end
  local parseResult = parseForExpression(dir.exp, context)
  if not parseResult then
    context:onError(createCompilerError(ErrorCodes.X_V_FOR_MALFORMED_EXPRESSION, dir.loc))
    return
  end
  local  = context
  local  = parseResult
  -- [ts2lua]lua中0和空字符串也是true，此处node.tagType == ElementTypes.TEMPLATE需要确认
  local forNode = {type=NodeTypes.FOR, loc=dir.loc, source=source, valueAlias=value, keyAlias=key, objectIndexAlias=index, parseResult=parseResult, children=(node.tagType == ElementTypes.TEMPLATE and {node.children} or {{node}})[1]}
  context:replaceNode(forNode)
  scopes.vFor=scopes.vFor+1
  if not __BROWSER__ and context.prefixIdentifiers then
    value and addIdentifiers(value)
    key and addIdentifiers(key)
    index and addIdentifiers(index)
  end
  local onExit = processCodegen and processCodegen(forNode)
  return function()
    scopes.vFor=scopes.vFor-1
    if not __BROWSER__ and context.prefixIdentifiers then
      value and removeIdentifiers(value)
      key and removeIdentifiers(key)
      index and removeIdentifiers(index)
    end
    if onExit then
      onExit()
    end
  end
  

end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local forAliasRE = /([\s\S]*?)\s+(?:in|of)\s+([\s\S]*)/
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local forIteratorRE = /,([^,\}\]]*)(?:,([^,\}\]]*))?$/
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local stripParensRE = /^\(|\)$/g
function parseForExpression(input, context)
  local loc = input.loc
  local exp = input.content
  local inMatch = exp:match(forAliasRE)
  if not inMatch then
    return
  end
  local  = inMatch
  local result = {source=createAliasExpression(loc, RHS:trim(), exp:find(RHS, #LHS)), value=undefined, key=undefined, index=undefined}
  if not __BROWSER__ and context.prefixIdentifiers then
    result.source = processExpression(result.source, context)
  end
  if __DEV__ and __BROWSER__ then
    validateBrowserExpression(result.source, context)
  end
  local valueContent = LHS:trim():gsub(stripParensRE, ''):trim()
  local trimmedOffset = LHS:find(valueContent)
  local iteratorMatch = valueContent:match(forIteratorRE)
  if iteratorMatch then
    valueContent = valueContent:gsub(forIteratorRE, ''):trim()
    local keyContent = iteratorMatch[1+1]:trim()
    local keyOffset = nil
    if keyContent then
      keyOffset = exp:find(keyContent, trimmedOffset + #valueContent)
      result.key = createAliasExpression(loc, keyContent, keyOffset)
      if not __BROWSER__ and context.prefixIdentifiers then
        result.key = processExpression(result.key, context, true)
      end
      if __DEV__ and __BROWSER__ then
        validateBrowserExpression(result.key, context, true)
      end
    end
    if iteratorMatch[2+1] then
      local indexContent = iteratorMatch[2+1]:trim()
      if indexContent then
        -- [ts2lua]lua中0和空字符串也是true，此处result.key需要确认
        result.index = createAliasExpression(loc, indexContent, exp:find(indexContent, (result.key and { + #keyContent} or {trimmedOffset + #valueContent})[1]))
        if not __BROWSER__ and context.prefixIdentifiers then
          result.index = processExpression(result.index, context, true)
        end
        if __DEV__ and __BROWSER__ then
          validateBrowserExpression(result.index, context, true)
        end
      end
    end
  end
  if valueContent then
    result.value = createAliasExpression(loc, valueContent, trimmedOffset)
    if not __BROWSER__ and context.prefixIdentifiers then
      result.value = processExpression(result.value, context, true)
    end
    if __DEV__ and __BROWSER__ then
      validateBrowserExpression(result.value, context, true)
    end
  end
  return result
end

function createAliasExpression(range, content, offset)
  return createSimpleExpression(content, false, getInnerRange(range, offset, #content))
end

function createForLoopParams()
  local params = {}
  if value then
    table.insert(params, value)
  end
  if key then
    if not value then
      table.insert(params, createSimpleExpression(false))
    end
    table.insert(params, key)
  end
  if index then
    if not key then
      if not value then
        table.insert(params, createSimpleExpression(false))
      end
      table.insert(params, createSimpleExpression(false))
    end
    table.insert(params, index)
  end
  return params
end
