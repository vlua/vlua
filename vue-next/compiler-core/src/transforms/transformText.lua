require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast")
require("compiler-core/src/ast/ElementTypes")
require("compiler-core/src/utils")
require("compiler-core/src/runtimeHelpers")

local transformText = function(node, context)
  if ((node.type == NodeTypes.ROOT or node.type == NodeTypes.ELEMENT) or node.type == NodeTypes.FOR) or node.type == NodeTypes.IF_BRANCH then
    return function()
      local children = node.children
      local currentContainer = undefined
      local hasText = false
      local i = 0
      repeat
        local child = children[i+1]
        if isText(child) then
          hasText = true
          local j = i + 1
          repeat
            local next = children[j+1]
            if isText(next) then
              if not currentContainer then
                children[i+1] = {type=NodeTypes.COMPOUND_EXPRESSION, loc=child.loc, children={child}}
                currentContainer = children[i+1]
              end
              table.insert(currentContainer.children, next)
              children:splice(j, 1)
              j=j-1
            else
              currentContainer = undefined
              break
            end
            j=j+1
          until not(j < #children)
        end
        i=i+1
      until not(i < #children)
      if not hasText or #children == 1 and (node.type == NodeTypes.ROOT or node.type == NodeTypes.ELEMENT and node.tagType == ElementTypes.ELEMENT) then
        return
      end
      local i = 0
      repeat
        local child = children[i+1]
        if isText(child) or child.type == NodeTypes.COMPOUND_EXPRESSION then
          local callArgs = {}
          if child.type ~= NodeTypes.TEXT or child.content ~= ' ' then
            table.insert(callArgs, child)
          end
          if not context.ssr and child.type ~= NodeTypes.TEXT then
            table.insert(callArgs)
          end
          children[i+1] = {type=NodeTypes.TEXT_CALL, content=child, loc=child.loc, codegenNode=createCallExpression(context:helper(CREATE_TEXT), callArgs)}
        end
        i=i+1
      until not(i < #children)
    end
    
  
  end
end
