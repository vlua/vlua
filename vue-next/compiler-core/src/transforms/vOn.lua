require("stringutil")
require("compiler-core/src/ast")
require("compiler-core/src/ast/NodeTypes")
require("@vue/shared")
require("compiler-core/src/errors")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src/transforms/transformExpression")
require("compiler-core/src/validateExpression")
require("compiler-core/src/utils")
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。

local fnExpRE = /^([\w$_]+|\([^)]*?\))\s*=>|^function(?:\s+[\w$]+)?\s*\(/
local transformOn = function(dir, node, context, augmentor)
  local  = dir
  if not dir.exp and not #modifiers then
    context:onError(createCompilerError(ErrorCodes.X_V_ON_NO_EXPRESSION, loc))
  end
  local eventName = nil
  if arg.type == NodeTypes.SIMPLE_EXPRESSION then
    if arg.isStatic then
      local rawName = arg.content
      -- [ts2lua]lua中0和空字符串也是true，此处rawName:startsWith()需要确认
      local normalizedName = (rawName:startsWith() and {capitalize(camelize(rawName))} or {capitalize(rawName)})[1]
      eventName = createSimpleExpression(true, arg.loc)
    else
      eventName = createCompoundExpression({arg, })
    end
  else
    eventName = arg
    eventName.children:unshift()
    table.insert(eventName.children)
  end
  local exp = dir.exp
  if exp and not exp.content:trim() then
    exp = undefined
  end
  local isCacheable = not exp
  if exp then
    local isMemberExp = isMemberExpression(exp.content)
    local isInlineStatement = not (isMemberExp or fnExpRE:test(exp.content))
    local hasMultipleStatements = exp.content:includes()
    if not __BROWSER__ and context.prefixIdentifiers then
      context:addIdentifiers()
      exp = processExpression(exp, context, false, hasMultipleStatements)
      context:removeIdentifiers()
      isCacheable = context.cacheHandlers and not hasScopeRef(exp, context.identifiers)
      if isCacheable and isMemberExp then
        if exp.type == NodeTypes.SIMPLE_EXPRESSION then
          exp.content = exp.content + 
        else
          table.insert(exp.children)
        end
      end
    end
    if __DEV__ and __BROWSER__ then
      validateBrowserExpression(exp, context, false, hasMultipleStatements)
    end
    if isInlineStatement or isCacheable and isMemberExp then
      -- [ts2lua]lua中0和空字符串也是true，此处hasMultipleStatements需要确认
      exp = createCompoundExpression({exp, (hasMultipleStatements and {} or {})[1]})
    end
  end
  local ret = {props={createObjectProperty(eventName, exp or createSimpleExpression(false, loc))}}
  if augmentor then
    ret = augmentor(ret)
  end
  if isCacheable then
    ret.props[0+1].value = context:cache(ret.props[0+1].value)
  end
  return ret
end
