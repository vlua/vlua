require("@vue/compiler-core/TextModes")
require("@vue/compiler-core/Namespaces")
require("@vue/compiler-core/NodeTypes")
require("@vue/compiler-core")
require("@vue/shared")
require("compiler-dom/src/runtimeHelpers")
require("compiler-dom/src/decodeHtml")
require("compiler-dom/src/decodeHtmlBrowser")
require("compiler-dom/src/parserOptions/DOMNamespaces")

local isRawTextContainer = makeMap('style,iframe,script,noscript', true)
local parserOptions = {isVoidTag=isVoidTag, isNativeTag=function(tag)
  isHTMLTag(tag) or isSVGTag(tag)
end
, isPreTag=function(tag)
  tag == 'pre'
end
-- [ts2lua]lua中0和空字符串也是true，此处__BROWSER__需要确认
, decodeEntities=(__BROWSER__ and {decodeHtmlBrowser} or {decodeHtml})[1], isBuiltInComponent=function(tag)
  if isBuiltInType(tag, ) then
    return TRANSITION
  elseif isBuiltInType(tag, ) then
    return TRANSITION_GROUP
  end
end
, getNamespace=function(tag, parent)
  -- [ts2lua]lua中0和空字符串也是true，此处parent需要确认
  local ns = (parent and {parent.ns} or {DOMNamespaces.HTML})[1]
  if parent and ns == DOMNamespaces.MATH_ML then
    if parent.tag == 'annotation-xml' then
      if tag == 'svg' then
        return DOMNamespaces.SVG
      end
      if parent.props:some(function(a)
        ((a.type == NodeTypes.ATTRIBUTE and a.name == 'encoding') and a.value ~= nil) and (a.value.content == 'text/html' or a.value.content == 'application/xhtml+xml')
      end
      ) then
        ns = DOMNamespaces.HTML
      end
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    elseif ((/^m(?:[ions]|text)$/):test(parent.tag) and tag ~= 'mglyph') and tag ~= 'malignmark' then
      ns = DOMNamespaces.HTML
    end
  elseif parent and ns == DOMNamespaces.SVG then
    if (parent.tag == 'foreignObject' or parent.tag == 'desc') or parent.tag == 'title' then
      ns = DOMNamespaces.HTML
    end
  end
  if ns == DOMNamespaces.HTML then
    if tag == 'svg' then
      return DOMNamespaces.SVG
    end
    if tag == 'math' then
      return DOMNamespaces.MATH_ML
    end
  end
  return ns
end
, getTextMode=function()
  if ns == DOMNamespaces.HTML then
    if tag == 'textarea' or tag == 'title' then
      return TextModes.RCDATA
    end
    if isRawTextContainer(tag) then
      return TextModes.RAWTEXT
    end
  end
  return TextModes.DATA
end
}