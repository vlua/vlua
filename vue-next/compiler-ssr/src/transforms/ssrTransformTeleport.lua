require("@vue/compiler-dom")
require("@vue/compiler-dom/NodeTypes")
require("compiler-ssr/src/ssrCodegenTransform")
require("compiler-ssr/src/errors")
require("compiler-ssr/src/errors/SSRErrorCodes")
require("compiler-ssr/src/runtimeHelpers")

function ssrProcessTeleport(node, context)
  local targetProp = findProp(node, 'target')
  if not targetProp then
    context:onError(createSSRCompilerError(SSRErrorCodes.X_SSR_NO_TELEPORT_TARGET, node.loc))
    return
  end
  local target = nil
  if targetProp.type == NodeTypes.ATTRIBUTE then
    target = targetProp.value and createSimpleExpression(targetProp.value.content, true)
  else
    target = targetProp.exp
  end
  if not target then
    context:onError(createSSRCompilerError(SSRErrorCodes.X_SSR_NO_TELEPORT_TARGET, targetProp.loc))
    return
  end
  local disabledProp = findProp(node, 'disabled', false, true)
  -- [ts2lua]lua中0和空字符串也是true，此处disabledProp.type == NodeTypes.ATTRIBUTE需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处disabledProp需要确认
  local disabled = (disabledProp and {(disabledProp.type == NodeTypes.ATTRIBUTE and {} or {disabledProp.exp or })[1]} or {})[1]
  local contentRenderFn = createFunctionExpression({}, undefined, true, false, node.loc)
  contentRenderFn.body = processChildrenAsStatement(node.children, context)
  context:pushStatement(createCallExpression(context:helper(SSR_RENDER_TELEPORT), {contentRenderFn, target, disabled, }))
end
