require("@vue/compiler-dom")
require("compiler-ssr/src/ssrCodegenTransform")
require("compiler-ssr/src/runtimeHelpers")

local wipMap = WeakMap()
function ssrTransformSuspense(node, context)
  return function()
    if #node.children then
      local wipEntry = {slotsExp=nil, wipSlots={}}
      wipMap:set(node, wipEntry)
      wipEntry.slotsExp = buildSlots(node, context, function(_props, children, loc)
        local fn = createFunctionExpression({}, undefined, true, false, loc)
        table.insert(wipEntry.wipSlots, {fn=fn, children=children})
        return fn
      end
      ).slots
    end
  end
  

end

function ssrProcessSuspense(node, context)
  local wipEntry = wipMap:get(node)
  if not wipEntry then
    return
  end
  local  = wipEntry
  local i = 0
  repeat
    local  = wipSlots[i+1]
    fn.body = processChildrenAsStatement(children, context)
    i=i+1
  until not(i < #wipSlots)
  context:pushStatement(createCallExpression(context:helper(SSR_RENDER_SUSPENSE), {slotsExp}))
end
