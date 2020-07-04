require("@vue/compiler-dom/NodeTypes")
require("@vue/compiler-dom/ElementTypes")
require("@vue/compiler-dom")
require("@vue/compiler-dom/Namespaces")
require("compiler-ssr/src/runtimeHelpers")
require("compiler-ssr/src/ssrCodegenTransform")
require("compiler-ssr/src/transforms/ssrTransformTeleport")
require("compiler-ssr/src/transforms/ssrTransformSuspense")
require("@vue/shared")

local wipMap = WeakMap()
local componentTypeMap = WeakMap()
local ssrTransformComponent = function(node, context)
  if node.type ~= NodeTypes.ELEMENT or node.tagType ~= ElementTypes.COMPONENT then
    return
  end
  local component = resolveComponentType(node, context, true)
  if isSymbol(component) then
    componentTypeMap:set(node, component)
    if component == SUSPENSE then
      return ssrTransformSuspense(node, context)
    end
    return
  end
  local vnodeBranches = {}
  local clonedNode = clone(node)
  return function ssrPostTransformComponent()
    if #clonedNode.children then
      buildSlots(clonedNode, context, function(props, children)
        table.insert(vnodeBranches, createVNodeSlotBranch(props, children, context))
        return createFunctionExpression(undefined)
      end
      )
    end
    -- [ts2lua]lua中0和空字符串也是true，此处#node.props > 0需要确认
    local props = (#node.props > 0 and {buildProps(node, context).props or } or {})[1]
    local wipEntries = {}
    wipMap:set(node, wipEntries)
    local buildSSRSlotFn = function(props, children, loc)
      local fn = createFunctionExpression({props or , , , }, undefined, true, true, loc)
      -- [ts2lua]vnodeBranches下标访问可能不正确
      table.insert(wipEntries, {fn=fn, children=children, vnodeBranch=vnodeBranches[#wipEntries]})
      return fn
    end
    
    -- [ts2lua]lua中0和空字符串也是true，此处#node.children需要确认
    local slots = (#node.children and {buildSlots(node, context, buildSSRSlotFn).slots} or {})[1]
    node.ssrCodegenNode = createCallExpression(context:helper(SSR_RENDER_COMPONENT), {component, props, slots, })
  end
  

end

function ssrProcessComponent(node, context)
  if not node.ssrCodegenNode then
    local component = nil
    if component == TELEPORT then
      return ssrProcessTeleport(node, context)
    elseif component == SUSPENSE then
      return ssrProcessSuspense(node, context)
    else
      processChildren(node.children, context, component == TRANSITION_GROUP)
    end
  else
    local wipEntries = wipMap:get(node) or {}
    local i = 0
    repeat
      local  = wipEntries[i+1]
      fn.body = createIfStatement(createSimpleExpression(false), processChildrenAsStatement(children, context, false, true), vnodeBranch)
      i=i+1
    until not(i < #wipEntries)
    context:pushStatement(createCallExpression({node.ssrCodegenNode}))
  end
end

local rawOptionsMap = WeakMap()
local  = getBaseTransformPreset(true)
local vnodeNodeTransforms = {..., ...}
local vnodeDirectiveTransforms = {..., ...}
function createVNodeSlotBranch(props, children, parentContext)
  local rawOptions = nil
  local subOptions = {..., nodeTransforms={..., ...}, directiveTransforms={..., ...}}
  local wrapperNode = {type=NodeTypes.ELEMENT, ns=Namespaces.HTML, tag='template', tagType=ElementTypes.TEMPLATE, isSelfClosing=false, props={{type=NodeTypes.DIRECTIVE, name='slot', exp=props, arg=undefined, modifiers={}, loc=locStub}}, children=children, loc=locStub, codegenNode=undefined}
  subTransform(wrapperNode, subOptions, parentContext)
  return createReturnStatement(children)
end

function subTransform(node, options, parentContext)
  local childRoot = createRoot({node})
  local childContext = createTransformContext(childRoot, options)
  childContext.ssr = false
  childContext.scopes = {...}
  childContext.identifiers = {...}
  traverseNode(childRoot, childContext)
  {'helpers', 'components', 'directives', 'imports'}:forEach(function(key)
    -- [ts2lua]childContext下标访问可能不正确
    childContext[key]:forEach(function(value)
      
      -- [ts2lua]parentContext下标访问可能不正确
      parentContext[key]:add(value)
    end
    )
  end
  )
end

function clone(v)
  if isArray(v) then
    return v:map(clone)
  elseif isObject(v) then
    local res = {}
    for key in pairs(v) do
      -- [ts2lua]res下标访问可能不正确
      -- [ts2lua]v下标访问可能不正确
      res[key] = clone(v[key])
    end
    return res
  else
    return v
  end
end
