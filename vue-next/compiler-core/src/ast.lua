require("@vue/shared")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/src/ast/Namespaces")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast/ElementTypes")

local locStub = {source='', start={line=1, column=1, offset=0}, tsvar_end={line=1, column=1, offset=0}}
function createRoot(children, loc)
  if loc == nil then
    loc=locStub
  end
  return {type=NodeTypes.ROOT, children=children, helpers={}, components={}, directives={}, hoists={}, imports={}, cached=0, temps=0, codegenNode=undefined, loc=loc}
end

function createVNodeCall(context, tag, props, children, patchFlag, dynamicProps, directives, isBlock, disableTracking, loc)
  if isBlock == nil then
    isBlock=false
  end
  if disableTracking == nil then
    disableTracking=false
  end
  if loc == nil then
    loc=locStub
  end
  if context then
    if isBlock then
      context:helper(OPEN_BLOCK)
      context:helper(CREATE_BLOCK)
    else
      context:helper(CREATE_VNODE)
    end
    if directives then
      context:helper(WITH_DIRECTIVES)
    end
  end
  return {type=NodeTypes.VNODE_CALL, tag=tag, props=props, children=children, patchFlag=patchFlag, dynamicProps=dynamicProps, directives=directives, isBlock=isBlock, disableTracking=disableTracking, loc=loc}
end

function createArrayExpression(elements, loc)
  if loc == nil then
    loc=locStub
  end
  return {type=NodeTypes.JS_ARRAY_EXPRESSION, loc=loc, elements=elements}
end

function createObjectExpression(properties, loc)
  if loc == nil then
    loc=locStub
  end
  return {type=NodeTypes.JS_OBJECT_EXPRESSION, loc=loc, properties=properties}
end

function createObjectProperty(key, value)
  -- [ts2lua]lua中0和空字符串也是true，此处isString(key)需要确认
  return {type=NodeTypes.JS_PROPERTY, loc=locStub, key=(isString(key) and {createSimpleExpression(key, true)} or {key})[1], value=value}
end

function createSimpleExpression(content, isStatic, loc, isConstant)
  if loc == nil then
    loc=locStub
  end
  if isConstant == nil then
    isConstant=false
  end
  return {type=NodeTypes.SIMPLE_EXPRESSION, loc=loc, isConstant=isConstant, content=content, isStatic=isStatic}
end

function createInterpolation(content, loc)
  -- [ts2lua]lua中0和空字符串也是true，此处isString(content)需要确认
  return {type=NodeTypes.INTERPOLATION, loc=loc, content=(isString(content) and {createSimpleExpression(content, false, loc)} or {content})[1]}
end

function createCompoundExpression(children, loc)
  if loc == nil then
    loc=locStub
  end
  return {type=NodeTypes.COMPOUND_EXPRESSION, loc=loc, children=children}
end

function createCallExpression(callee, args, loc)
  if args == nil then
    args={}
  end
  if loc == nil then
    loc=locStub
  end
  return {type=NodeTypes.JS_CALL_EXPRESSION, loc=loc, callee=callee, arguments=args}
end

function createFunctionExpression(params, returns, newline, isSlot, loc)
  if returns == nil then
    returns=undefined
  end
  if newline == nil then
    newline=false
  end
  if isSlot == nil then
    isSlot=false
  end
  if loc == nil then
    loc=locStub
  end
  return {type=NodeTypes.JS_FUNCTION_EXPRESSION, params=params, returns=returns, newline=newline, isSlot=isSlot, loc=loc}
end

function createConditionalExpression(test, consequent, alternate, newline)
  if newline == nil then
    newline=true
  end
  return {type=NodeTypes.JS_CONDITIONAL_EXPRESSION, test=test, consequent=consequent, alternate=alternate, newline=newline, loc=locStub}
end

function createCacheExpression(index, value, isVNode)
  if isVNode == nil then
    isVNode=false
  end
  return {type=NodeTypes.JS_CACHE_EXPRESSION, index=index, value=value, isVNode=isVNode, loc=locStub}
end

function createBlockStatement(body)
  return {type=NodeTypes.JS_BLOCK_STATEMENT, body=body, loc=locStub}
end

function createTemplateLiteral(elements)
  return {type=NodeTypes.JS_TEMPLATE_LITERAL, elements=elements, loc=locStub}
end

function createIfStatement(test, consequent, alternate)
  return {type=NodeTypes.JS_IF_STATEMENT, test=test, consequent=consequent, alternate=alternate, loc=locStub}
end

function createAssignmentExpression(left, right)
  return {type=NodeTypes.JS_ASSIGNMENT_EXPRESSION, left=left, right=right, loc=locStub}
end

function createSequenceExpression(expressions)
  return {type=NodeTypes.JS_SEQUENCE_EXPRESSION, expressions=expressions, loc=locStub}
end

function createReturnStatement(returns)
  return {type=NodeTypes.JS_RETURN_STATEMENT, returns=returns, loc=locStub}
end
