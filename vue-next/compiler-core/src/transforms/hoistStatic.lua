require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast/ElementTypes")
require("@vue/shared/PatchFlags")
require("@vue/shared")
require("compiler-core/src/utils")
local StaticType = {
  NOT_STATIC = 0,
  FULL_STATIC = 1,
  HAS_RUNTIME_CONSTANT = 2
}

function hoistStatic(root, context)
  walk(root, context, Map(), isSingleElementRoot(root, root.children[0+1]))
end

function isSingleElementRoot(root, child)
  local  = root
  return (#children == 1 and child.type == NodeTypes.ELEMENT) and not isSlotOutlet(child)
end

function walk(node, context, resultCache, doNotHoistNode)
  if doNotHoistNode == nil then
    doNotHoistNode=false
  end
  local hasHoistedNode = false
  local hasRuntimeConstant = false
  local  = node
  local i = 0
  repeat
    local child = children[i+1]
    if child.type == NodeTypes.ELEMENT and child.tagType == ElementTypes.ELEMENT then
      local staticType = nil
      if not doNotHoistNode and staticType = getStaticType(child, resultCache) > 0 then
        if staticType == StaticType.HAS_RUNTIME_CONSTANT then
          hasRuntimeConstant = true
        end
        -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
        child.codegenNode.patchFlag = PatchFlags.HOISTED + (__DEV__ and {} or {})[1]
        child.codegenNode = context:hoist()
        hasHoistedNode = true
        break
      else
        local codegenNode = nil
        if codegenNode.type == NodeTypes.VNODE_CALL then
          local flag = getPatchFlag(codegenNode)
          if (((not flag or flag == PatchFlags.NEED_PATCH) or flag == PatchFlags.TEXT) and not hasDynamicKeyOrRef(child)) and not hasCachedProps(child) then
            local props = getNodeProps(child)
            if props then
              codegenNode.props = context:hoist(props)
            end
          end
        end
      end
    elseif child.type == NodeTypes.TEXT_CALL then
      local staticType = getStaticType(child.content, resultCache)
      if staticType > 0 then
        if staticType == StaticType.HAS_RUNTIME_CONSTANT then
          hasRuntimeConstant = true
        end
        child.codegenNode = context:hoist(child.codegenNode)
        hasHoistedNode = true
      end
    end
    if child.type == NodeTypes.ELEMENT then
      walk(child, context, resultCache)
    elseif child.type == NodeTypes.FOR then
      walk(child, context, resultCache, #child.children == 1)
    elseif child.type == NodeTypes.IF then
      local i = 0
      repeat
        walk(child.branches[i+1], context, resultCache, #child.branches[i+1].children == 1)
        i=i+1
      until not(i < #child.branches)
    end
    i=i+1
  until not(i < #children)
  if (not hasRuntimeConstant and hasHoistedNode) and context.transformHoist then
    context:transformHoist(children, context, node)
  end
end

function getStaticType(node, resultCache)
  if resultCache == nil then
    resultCache=Map()
  end
  local switch = {
    [NodeTypes.ELEMENT] = function()
      if node.tagType ~= ElementTypes.ELEMENT then
        return StaticType.NOT_STATIC
      end
      local cached = resultCache:get(node)
      if cached ~= undefined then
        return cached
      end
      local codegenNode = nil
      if codegenNode.type ~= NodeTypes.VNODE_CALL then
        return StaticType.NOT_STATIC
      end
      local flag = getPatchFlag(codegenNode)
      if (not flag and not hasDynamicKeyOrRef(node)) and not hasCachedProps(node) then
        local returnType = StaticType.FULL_STATIC
        local i = 0
        repeat
          local childType = getStaticType(node.children[i+1], resultCache)
          if childType == StaticType.NOT_STATIC then
            resultCache:set(node, StaticType.NOT_STATIC)
            return StaticType.NOT_STATIC
          elseif childType == StaticType.HAS_RUNTIME_CONSTANT then
            returnType = StaticType.HAS_RUNTIME_CONSTANT
          end
          i=i+1
        until not(i < #node.children)
        if returnType ~= StaticType.HAS_RUNTIME_CONSTANT then
          local i = 0
          repeat
            local p = node.props[i+1]
            if ((p.type == NodeTypes.DIRECTIVE and p.name == 'bind') and p.exp) and (p.exp.type == NodeTypes.COMPOUND_EXPRESSION or p.exp.isRuntimeConstant) then
              returnType = StaticType.HAS_RUNTIME_CONSTANT
            end
            i=i+1
          until not(i < #node.props)
        end
        if codegenNode.isBlock then
          codegenNode.isBlock = false
        end
        resultCache:set(node, returnType)
        return returnType
      else
        resultCache:set(node, StaticType.NOT_STATIC)
        return StaticType.NOT_STATIC
      end
    end,
    [NodeTypes.TEXT] = function()
     end,
    [NodeTypes.COMMENT] = function()
      return StaticType.FULL_STATIC
    end,
    [NodeTypes.IF] = function()
     end,
    [NodeTypes.FOR] = function()
     end,
    [NodeTypes.IF_BRANCH] = function()
      return StaticType.NOT_STATIC
    end,
    [NodeTypes.INTERPOLATION] = function()
     end,
    [NodeTypes.TEXT_CALL] = function()
      return getStaticType(node.content, resultCache)
    end,
    [NodeTypes.SIMPLE_EXPRESSION] = function()
      -- [ts2lua]lua中0和空字符串也是true，此处node.isRuntimeConstant需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处node.isConstant需要确认
      return (node.isConstant and {(node.isRuntimeConstant and {StaticType.HAS_RUNTIME_CONSTANT} or {StaticType.FULL_STATIC})[1]} or {StaticType.NOT_STATIC})[1]
    end,
    [NodeTypes.COMPOUND_EXPRESSION] = function()
      local returnType = StaticType.FULL_STATIC
      local i = 0
      repeat
        repeat
          local child = node.children[i+1]
          if isString(child) or isSymbol(child) then
            break
          end
          local childType = getStaticType(child, resultCache)
          if childType == StaticType.NOT_STATIC then
            return StaticType.NOT_STATIC
          elseif childType == StaticType.HAS_RUNTIME_CONSTANT then
            returnType = StaticType.HAS_RUNTIME_CONSTANT
          end
        until true
        i=i+1
      until not(i < #node.children)
      return returnType
    end,
    ["default"] = function()
      if __DEV__ then
        local exhaustiveCheck = node
      end
      return StaticType.NOT_STATIC
    end
  }
  local casef = switch[node.type]
  if not casef then casef = switch["default"] end
  if casef then casef() end
end

function hasDynamicKeyOrRef(node)
  return not (not (findProp(node, 'key', true) or findProp(node, 'ref', true)))
end

function hasCachedProps(node)
  if __BROWSER__ then
    return false
  end
  local props = getNodeProps(node)
  if props and props.type == NodeTypes.JS_OBJECT_EXPRESSION then
    local  = props
    local i = 0
    repeat
      local val = properties[i+1].value
      if val.type == NodeTypes.JS_CACHE_EXPRESSION then
        return true
      end
      if val.type == NodeTypes.JS_ARRAY_EXPRESSION and val.elements:some(function(e)
        not isString(e) and e.type == NodeTypes.JS_CACHE_EXPRESSION
      end
      ) then
        return true
      end
      i=i+1
    until not(i < #properties)
  end
  return false
end

function getNodeProps(node)
  local codegenNode = nil
  if codegenNode.type == NodeTypes.VNODE_CALL then
    return codegenNode.props
  end
end

function getPatchFlag(node)
  local flag = node.patchFlag
  -- [ts2lua]lua中0和空字符串也是true，此处flag需要确认
  return (flag and {parseInt(flag, 10)} or {undefined})[1]
end
