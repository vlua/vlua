require("@vue/compiler-core/NodeTypes")
require("@vue/compiler-core")
require("@vue/shared")

local transformStyle = function(node)
  if node.type == NodeTypes.ELEMENT then
    node.props:forEach(function(p, i)
      if (p.type == NodeTypes.ATTRIBUTE and p.name == 'style') and p.value then
        node.props[i+1] = {type=NodeTypes.DIRECTIVE, name=, arg=createSimpleExpression(true, p.loc), exp=parseInlineCSS(p.value.content, p.loc), modifiers={}, loc=p.loc}
      end
    end
    )
  end
end

local parseInlineCSS = function(cssText, loc)
  local normalized = parseStringStyle(cssText)
  return createSimpleExpression(JSON:stringify(normalized), false, loc, true)
end
