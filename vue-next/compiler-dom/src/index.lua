require("@vue/compiler-core")
require("compiler-dom/src/parserOptions")
require("compiler-dom/src/transforms/transformStyle")
require("compiler-dom/src/transforms/vHtml")
require("compiler-dom/src/transforms/vText")
require("compiler-dom/src/transforms/vModel")
require("compiler-dom/src/transforms/vOn")
require("compiler-dom/src/transforms/vShow")
require("compiler-dom/src/transforms/stringifyStatic")
require("@vue/shared")

undefined
local DOMNodeTransforms = {transformStyle, ...}
local DOMDirectiveTransforms = {cloak=noopDirectiveTransform, html=transformVHtml, text=transformVText, model=transformModel, on=transformOn, show=transformShow}
function compile(template, options)
  if options == nil then
    options={}
  end
  -- [ts2lua]lua中0和空字符串也是true，此处__BROWSER__需要确认
  return baseCompile(template, extend({}, parserOptions, options, {nodeTransforms={..., ...}, directiveTransforms=extend({}, DOMDirectiveTransforms, options.directiveTransforms or {}), transformHoist=(__BROWSER__ and {nil} or {stringifyStatic})[1]}))
end

function parse(template, options)
  if options == nil then
    options={}
  end
  return baseParse(template, extend({}, parserOptions, options))
end

undefined
undefined