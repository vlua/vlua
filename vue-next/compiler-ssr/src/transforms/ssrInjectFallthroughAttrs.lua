require("@vue/compiler-dom/NodeTypes")
require("@vue/compiler-dom/ElementTypes")
require("@vue/compiler-dom")

local hasSingleChild = function(node)
  #node.children:filter(function(n)
    n.type ~= NodeTypes.COMMENT
  end
  ) == 1
end

local ssrInjectFallthroughAttrs = function(node, context)
  if node.type == NodeTypes.ROOT then
    context.identifiers._attrs = 1
  end
  local parent = context.parent
  if not parent or parent.type ~= NodeTypes.ROOT then
    return
  end
  if node.type == NodeTypes.IF_BRANCH and hasSingleChild(node) then
    injectFallthroughAttrs(node.children[0+1])
  elseif hasSingleChild(parent) then
    injectFallthroughAttrs(node)
  end
end

function injectFallthroughAttrs(node)
  if (node.type == NodeTypes.ELEMENT and (node.tagType == ElementTypes.ELEMENT or node.tagType == ElementTypes.COMPONENT)) and not findDir(node, 'for') then
    table.insert(node.props, {type=NodeTypes.DIRECTIVE, name='bind', arg=undefined, exp=createSimpleExpression(false), modifiers={}, loc=locStub})
  end
end
