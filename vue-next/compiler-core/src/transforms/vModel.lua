require("compiler-core/src/ast")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast/ElementTypes")
require("compiler-core/src/errors")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src/utils")

local transformModel = function(dir, node, context)
  local  = dir
  if not exp then
    context:onError(createCompilerError(ErrorCodes.X_V_MODEL_NO_EXPRESSION, dir.loc))
    return createTransformProps()
  end
  -- [ts2lua]lua中0和空字符串也是true，此处exp.type == NodeTypes.SIMPLE_EXPRESSION需要确认
  local expString = (exp.type == NodeTypes.SIMPLE_EXPRESSION and {exp.content} or {exp.loc.source})[1]
  if not isMemberExpression(expString) then
    context:onError(createCompilerError(ErrorCodes.X_V_MODEL_MALFORMED_EXPRESSION, exp.loc))
    return createTransformProps()
  end
  -- [ts2lua]context.identifiers下标访问可能不正确
  if ((not __BROWSER__ and context.prefixIdentifiers) and isSimpleIdentifier(expString)) and context.identifiers[expString] then
    context:onError(createCompilerError(ErrorCodes.X_V_MODEL_ON_SCOPE_VARIABLE, exp.loc))
    return createTransformProps()
  end
  -- [ts2lua]lua中0和空字符串也是true，此处arg需要确认
  local propName = (arg and {arg} or {createSimpleExpression('modelValue', true)})[1]
  -- [ts2lua]lua中0和空字符串也是true，此处arg.type == NodeTypes.SIMPLE_EXPRESSION and arg.isStatic需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处arg需要确认
  local eventName = (arg and {(arg.type == NodeTypes.SIMPLE_EXPRESSION and arg.isStatic and {} or {createCompoundExpression({'"onUpdate:" + ', arg})})[1]} or {})[1]
  local props = {createObjectProperty(propName, ), createObjectProperty(eventName, createCompoundExpression({exp, }))}
  if ((not __BROWSER__ and context.prefixIdentifiers) and context.cacheHandlers) and not hasScopeRef(exp, context.identifiers) then
    props[1+1].value = context:cache(props[1+1].value)
  end
  if #dir.modifiers and node.tagType == ElementTypes.COMPONENT then
    local modifiers = dir.modifiers:map(function(m)
      -- [ts2lua]lua中0和空字符串也是true，此处isSimpleIdentifier(m)需要确认
      (isSimpleIdentifier(m) and {m} or {JSON:stringify(m)})[1] + 
    end
    ):join()
    -- [ts2lua]lua中0和空字符串也是true，此处arg.type == NodeTypes.SIMPLE_EXPRESSION and arg.isStatic需要确认
    -- [ts2lua]lua中0和空字符串也是true，此处arg需要确认
    local modifiersKey = (arg and {(arg.type == NodeTypes.SIMPLE_EXPRESSION and arg.isStatic and {} or {createCompoundExpression({arg, ' + "Modifiers"'})})[1]} or {})[1]
    table.insert(props, createObjectProperty(modifiersKey, createSimpleExpression(false, dir.loc, true)))
  end
  return createTransformProps(props)
end

function createTransformProps(props)
  if props == nil then
    props={}
  end
  return {props=props}
end
