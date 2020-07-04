require("@vue/compiler-dom")
require("compiler-ssr/src/runtimeHelpers")
require("compiler-ssr/src/ssrCodegenTransform")

local ssrTransformSlotOutlet = function(node, context)
  if isSlotOutlet(node) then
    local  = processSlotOutlet(node, context)
    node.ssrCodegenNode = createCallExpression(context:helper(SSR_RENDER_SLOT), {slotName, slotProps or , , , })
  end
end

function ssrProcessSlotOutlet(node, context)
  local renderCall = nil
  if #node.children then
    local fallbackRenderFn = createFunctionExpression({})
    fallbackRenderFn.body = processChildrenAsStatement(node.children, context)
    renderCall.arguments[3+1] = fallbackRenderFn
  end
  context:pushStatement()
end
