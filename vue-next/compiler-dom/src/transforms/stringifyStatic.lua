require("@vue/compiler-core/NodeTypes")
require("@vue/compiler-core")
require("@vue/compiler-core/ElementTypes")
require("@vue/shared")
require("compiler-dom/src/transforms/stringifyStatic/StringifyThresholds")

local stringifyStatic = function(children, context, parent)
  if parent.type == NodeTypes.ELEMENT and (parent.tagType == ElementTypes.COMPONENT or parent.tagType == ElementTypes.TEMPLATE) then
    return
  end
  local nc = 0
  local ec = 0
  local currentChunk = {}
  local stringifyCurrentChunk = function(currentIndex)
    if nc >= StringifyThresholds.NODE_COUNT or ec >= StringifyThresholds.ELEMENT_WITH_BINDING_COUNT then
      local staticCall = createCallExpression(context:helper(CREATE_STATIC), {JSON:stringify(currentChunk:map(function(node)
        stringifyNode(node, context)
      end
      ):join('')), String(#currentChunk)})
      replaceHoist(currentChunk[0+1], staticCall, context)
      if #currentChunk > 1 then
        local i = 1
        repeat
          replaceHoist(currentChunk[i+1], nil, context)
          i=i+1
        until not(i < #currentChunk)
        local deleteCount = #currentChunk - 1
        children:splice(currentIndex - #currentChunk + 1, deleteCount)
        return deleteCount
      end
    end
    return 0
  end
  
  local i = 0
  repeat
    repeat
      local child = children[i+1]
      local hoisted = getHoistedNode(child)
      if hoisted then
        local node = child
        local result = analyzeNode(node)
        if result then
          nc = nc + result[0+1]
          ec = ec + result[1+1]
          table.insert(currentChunk, node)
          break
        end
      end
      i = i - stringifyCurrentChunk(i)
      nc = 0
      ec = 0
      -- [ts2lua]修改数组长度需要手动处理。
      currentChunk.length = 0
    until true
    i=i+1
  until not(i < #children)
  stringifyCurrentChunk(i)
end

local getHoistedNode = function(node)
  (((node.type == NodeTypes.ELEMENT and node.tagType == ElementTypes.ELEMENT or node.type == NodeTypes.TEXT_CALL) and node.codegenNode) and node.codegenNode.type == NodeTypes.SIMPLE_EXPRESSION) and node.codegenNode.hoisted
end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local dataAriaRE = /^(data|aria)-/
local isStringifiableAttr = function(name)
  return isKnownAttr(name) or dataAriaRE:test(name)
end

local replaceHoist = function(node, replacement, context)
  local hoistToReplace = nil
  -- [ts2lua]context.hoists下标访问可能不正确
  context.hoists[context.hoists:find(hoistToReplace)] = replacement
end

local isNonStringifiable = makeMap()
function analyzeNode(node)
  if node.type == NodeTypes.ELEMENT and isNonStringifiable(node.tag) then
    return false
  end
  if node.type == NodeTypes.TEXT_CALL then
    return {1, 0}
  end
  local nc = 1
  -- [ts2lua]lua中0和空字符串也是true，此处#node.props > 0需要确认
  local ec = (#node.props > 0 and {1} or {0})[1]
  local bailed = false
  local bail = function()
    bailed = true
    return false
  end
  
  function walk(node)
    local i = 0
    repeat
      local p = node.props[i+1]
      if p.type == NodeTypes.ATTRIBUTE and not isStringifiableAttr(p.name) then
        return bail()
      end
      if p.type == NodeTypes.DIRECTIVE and p.name == 'bind' then
        if p.arg and (p.arg.type == NodeTypes.COMPOUND_EXPRESSION or p.arg.isStatic and not isStringifiableAttr(p.arg.content)) then
          return bail()
        end
      end
      i=i+1
    until not(i < #node.props)
    local i = 0
    repeat
      nc=nc+1
      local child = node.children[i+1]
      if child.type == NodeTypes.ELEMENT then
        if #child.props > 0 then
          ec=ec+1
        end
        walk(child)
        if bailed then
          return false
        end
      end
      i=i+1
    until not(i < #node.children)
    return true
  end
  
  -- [ts2lua]lua中0和空字符串也是true，此处walk(node)需要确认
  return (walk(node) and {{nc, ec}} or {false})[1]
end

function stringifyNode(node, context)
  if isString(node) then
    return node
  end
  if isSymbol(node) then
    return 
  end
  local switch = {
    [NodeTypes.ELEMENT] = function()
      return stringifyElement(node, context)
    end,
    [NodeTypes.TEXT] = function()
      return escapeHtml(node.content)
    end,
    [NodeTypes.COMMENT] = function()
      return 
    end,
    [NodeTypes.INTERPOLATION] = function()
      return escapeHtml(toDisplayString(evaluateConstant(node.content)))
    end,
    [NodeTypes.COMPOUND_EXPRESSION] = function()
      return escapeHtml(evaluateConstant(node))
    end,
    [NodeTypes.TEXT_CALL] = function()
      return stringifyNode(node.content, context)
    end,
    ["default"] = function()
      return ''
    end
  }
  local casef = switch[node.type]
  if not casef then casef = switch["default"] end
  if casef then casef() end
end

function stringifyElement(node, context)
  local res = nil
  local i = 0
  repeat
    local p = node.props[i+1]
    if p.type == NodeTypes.ATTRIBUTE then
      res = res + 
      if p.value then
        res = res + 
      end
    elseif p.type == NodeTypes.DIRECTIVE and p.name == 'bind' then
      local evaluated = evaluateConstant(p.exp)
      local arg = p.arg and p.arg.content
      if arg == 'class' then
        evaluated = normalizeClass(evaluated)
      elseif arg == 'style' then
        evaluated = stringifyStyle(normalizeStyle(evaluated))
      end
      res = res + 
    end
    i=i+1
  until not(i < #node.props)
  if context.scopeId then
    res = res + 
  end
  res = res + 
  local i = 0
  repeat
    res = res + stringifyNode(node.children[i+1], context)
    i=i+1
  until not(i < #node.children)
  if not isVoidTag(node.tag) then
    res = res + 
  end
  return res
end

function evaluateConstant(exp)
  if exp.type == NodeTypes.SIMPLE_EXPRESSION then
    return Function()()
  else
    local res = nil
    exp.children:forEach(function(c)
      if isString(c) or isSymbol(c) then
        return
      end
      if c.type == NodeTypes.TEXT then
        res = res + c.content
      elseif c.type == NodeTypes.INTERPOLATION then
        res = res + toDisplayString(evaluateConstant(c.content))
      else
        res = res + evaluateConstant(c)
      end
    end
    )
    return res
  end
end
