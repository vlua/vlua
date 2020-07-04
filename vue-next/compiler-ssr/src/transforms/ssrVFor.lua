require("@vue/compiler-dom")
require("@vue/compiler-dom/NodeTypes")
require("compiler-ssr/src/ssrCodegenTransform")
require("compiler-ssr/src/runtimeHelpers")

local ssrTransformFor = createStructuralDirectiveTransform('for', processFor)
function ssrProcessFor(node, context)
  local needFragmentWrapper = #node.children ~= 1 or node.children[0+1].type ~= NodeTypes.ELEMENT
  local renderLoop = createFunctionExpression(createForLoopParams(node.parseResult))
  renderLoop.body = processChildrenAsStatement(node.children, context, needFragmentWrapper)
  context:pushStringPart()
  context:pushStatement(createCallExpression(context:helper(SSR_RENDER_LIST), {node.source, renderLoop}))
  context:pushStringPart()
end
