require("compiler-core/src/utils")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/runtimeHelpers")

local transformOnce = function(node, context)
  if node.type == NodeTypes.ELEMENT and findDir(node, 'once', true) then
    context:helper(SET_BLOCK_TRACKING)
    return function()
      if node.codegenNode then
        node.codegenNode = context:cache(node.codegenNode, true)
      end
    end
    
  
  end
end
