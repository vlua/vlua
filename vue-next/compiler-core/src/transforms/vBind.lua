require("compiler-core/src/ast")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/errors")
require("compiler-core/src/errors/ErrorCodes")
require("@vue/shared")

local transformBind = function(dir, node, context)
  local  = dir
  local arg = nil
  if not exp or exp.type == NodeTypes.SIMPLE_EXPRESSION and not exp.content then
    context:onError(createCompilerError(ErrorCodes.X_V_BIND_NO_EXPRESSION, loc))
  end
  if modifiers:includes('camel') then
    if arg.type == NodeTypes.SIMPLE_EXPRESSION then
      if arg.isStatic then
        arg.content = camelize(arg.content)
      else
        arg.content = 
      end
    else
      arg.children:unshift()
      table.insert(arg.children)
    end
  end
  return {props={createObjectProperty(exp or createSimpleExpression('', true, loc))}}
end
