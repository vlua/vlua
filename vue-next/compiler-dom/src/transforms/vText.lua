require("@vue/compiler-core")
require("compiler-dom/src/errors")
require("compiler-dom/src/errors/DOMErrorCodes")

local transformVText = function(dir, node, context)
  local  = dir
  if not exp then
    context:onError(createDOMCompilerError(DOMErrorCodes.X_V_TEXT_NO_EXPRESSION, loc))
  end
  if #node.children then
    context:onError(createDOMCompilerError(DOMErrorCodes.X_V_TEXT_WITH_CHILDREN, loc))
    
    node.children.length = 0
  end
  return {props={createObjectProperty(createSimpleExpression(true, loc), exp or createSimpleExpression('', true))}}
end
