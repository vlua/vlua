require("compiler-core/src/NodeTypes")
require("compiler-core/src")
require("compiler-core/src/Namespaces")
require("compiler-core/src/ElementTypes")
require("@vue/shared")
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。

local leadingBracketRE = /^\[/
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local bracketsRE = /^\[|\]$/g
function createObjectMatcher(obj)
  return {type=NodeTypes.JS_OBJECT_EXPRESSION, properties=Object:keys(obj):map(function(key)
    -- [ts2lua]obj下标访问可能不正确
    -- [ts2lua]obj下标访问可能不正确
    -- [ts2lua]obj下标访问可能不正确
    -- [ts2lua]obj下标访问可能不正确
    -- [ts2lua]lua中0和空字符串也是true，此处isString(obj[key])需要确认
    {type=NodeTypes.JS_PROPERTY, key={type=NodeTypes.SIMPLE_EXPRESSION, content=key:gsub(bracketsRE, ''), isStatic=not leadingBracketRE:test(key)}, value=(isString(obj[key]) and {{type=NodeTypes.SIMPLE_EXPRESSION, content=obj[key]:gsub(bracketsRE, ''), isStatic=not leadingBracketRE:test(obj[key])}} or {obj[key]})[1]}
  end
  )}
end

function createElementWithCodegen(tag, props, children, patchFlag, dynamicProps)
  return {type=NodeTypes.ELEMENT, loc=locStub, ns=Namespaces.HTML, tag='div', tagType=ElementTypes.ELEMENT, isSelfClosing=false, props={}, children={}, codegenNode={type=NodeTypes.VNODE_CALL, tag=tag, props=props, children=children, patchFlag=patchFlag, dynamicProps=dynamicProps, directives=undefined, isBlock=false, disableTracking=false, loc=locStub}}
end

function genFlagText(flag)
  if isArray(flag) then
    local f = 0
    flag:forEach(function(ff)
      f = f | ff
    end
    )
    return 
  else
    return 
  end
end
