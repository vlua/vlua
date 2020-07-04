require("@vue/compiler-core/NodeTypes")
require("@vue/compiler-core/ElementTypes")
require("compiler-dom/src/runtimeHelpers")
require("compiler-dom/src/errors")
require("compiler-dom/src/errors/DOMErrorCodes")

local warnTransitionChildren = function(node, context)
  if node.type == NodeTypes.ELEMENT and node.tagType == ElementTypes.COMPONENT then
    local component = context:isBuiltInComponent(node.tag)
    if component == TRANSITION then
      return function()
        if #node.children and hasMultipleChildren(node) then
          -- [ts2lua]node.children下标访问可能不正确
          context:onError(createDOMCompilerError(DOMErrorCodes.X_TRANSITION_INVALID_CHILDREN, {start=node.children[0+1].loc.start, tsvar_end=node.children[#node.children - 1].loc.tsvar_end, source=''}))
        end
      end
      
    
    end
  end
end

function hasMultipleChildren(node)
  node.children = node.children:filter(function(c)
    c.type ~= NodeTypes.COMMENT
  end
  )
  local children = node.children
  local child = children[0+1]
  return (#children ~= 1 or child.type == NodeTypes.FOR) or child.type == NodeTypes.IF and child.branches:some(hasMultipleChildren)
end
