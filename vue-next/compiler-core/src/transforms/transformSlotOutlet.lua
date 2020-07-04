require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast")
require("compiler-core/src/utils")
require("compiler-core/src/transforms/transformElement")
require("compiler-core/src/errors")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src/runtimeHelpers")

local transformSlotOutlet = function(node, context)
  if isSlotOutlet(node) then
    local  = node
    local  = processSlotOutlet(node, context)
    -- [ts2lua]lua中0和空字符串也是true，此处context.prefixIdentifiers需要确认
    local slotArgs = {(context.prefixIdentifiers and {} or {})[1], slotName}
    if slotProps then
      table.insert(slotArgs, slotProps)
    end
    if #children then
      if not slotProps then
        table.insert(slotArgs)
      end
      table.insert(slotArgs, createFunctionExpression({}, children, false, false, loc))
    end
    node.codegenNode = createCallExpression(context:helper(RENDER_SLOT), slotArgs, loc)
  end
end

function processSlotOutlet(node, context)
  local slotName = nil
  local slotProps = undefined
  local name = findProp(node, 'name')
  if name then
    if name.type == NodeTypes.ATTRIBUTE and name.value then
      slotName = JSON:stringify(name.value.content)
    elseif name.type == NodeTypes.DIRECTIVE and name.exp then
      slotName = name.exp
    end
  end
  local propsWithoutName = (name and {node.props:filter(function(p)
    p ~= name
  end
  -- [ts2lua]lua中0和空字符串也是true，此处name需要确认
  )} or {node.props})[1]
  if #propsWithoutName > 0 then
    local  = buildProps(node, context, propsWithoutName)
    slotProps = props
    if #directives then
      context:onError(createCompilerError(ErrorCodes.X_V_SLOT_UNEXPECTED_DIRECTIVE_ON_SLOT_OUTLET, directives[0+1].loc))
    end
  end
  return {slotName=slotName, slotProps=slotProps}
end
