require("compiler-dom/src/errors")
require("compiler-dom/src/errors/DOMErrorCodes")
require("compiler-dom/src/runtimeHelpers")

local transformShow = function(dir, node, context)
  local  = dir
  if not exp then
    context:onError(createDOMCompilerError(DOMErrorCodes.X_V_SHOW_NO_EXPRESSION, loc))
  end
  return {props={}, needRuntime=context:helper(V_SHOW)}
end
