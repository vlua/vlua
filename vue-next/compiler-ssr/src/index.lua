require("@vue/compiler-dom")
require("compiler-ssr/src/ssrCodegenTransform")
require("compiler-ssr/src/transforms/ssrTransformElement")
require("compiler-ssr/src/transforms/ssrTransformComponent")
require("compiler-ssr/src/transforms/ssrTransformSlotOutlet")
require("compiler-ssr/src/transforms/ssrVIf")
require("compiler-ssr/src/transforms/ssrVFor")
require("compiler-ssr/src/transforms/ssrVModel")
require("compiler-ssr/src/transforms/ssrVShow")
require("compiler-ssr/src/transforms/ssrInjectFallthroughAttrs")

function compile(template, options)
  if options == nil then
    options={}
  end
  -- [ts2lua]lua中0和空字符串也是true，此处options.mode == 'function'需要确认
  options = {..., ..., ssr=true, scopeId=(options.mode == 'function' and {nil} or {options.scopeId})[1], prefixIdentifiers=true, cacheHandlers=false, hoistStatic=false}
  local ast = baseParse(template, options)
  rawOptionsMap:set(ast, options)
  transform(ast, {..., nodeTransforms={ssrTransformIf, ssrTransformFor, trackVForSlotScopes, transformExpression, ssrTransformSlotOutlet, ssrInjectFallthroughAttrs, ssrTransformElement, ssrTransformComponent, trackSlotScopes, transformStyle, ...}, directiveTransforms={bind=transformBind, model=ssrTransformModel, show=ssrTransformShow, on=noopDirectiveTransform, cloak=noopDirectiveTransform, once=noopDirectiveTransform, ...}})
  ssrCodegenTransform(ast, options)
  return generate(ast, options)
end
