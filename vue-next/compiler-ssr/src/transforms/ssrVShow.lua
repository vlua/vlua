require("@vue/compiler-dom/DOMErrorCodes")
require("@vue/compiler-dom")

local ssrTransformShow = function(dir, node, context)
  if not dir.exp then
    context:onError(createDOMCompilerError(DOMErrorCodes.X_V_SHOW_NO_EXPRESSION))
  end
  return {props={createObjectProperty(createConditionalExpression(createSimpleExpression(false), createObjectExpression({createObjectProperty(createSimpleExpression(true))}), false))}}
end
