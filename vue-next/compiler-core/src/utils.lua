require("stringutil")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast")
require("compiler-core/src/ast/ElementTypes")
require("compiler-core/src/runtimeHelpers")
require("@vue/shared")
require("@babel/parser")
require("estree-walker")

local isBuiltInType = function(tag, expected)
  tag == expected or tag == hyphenate(expected)
end

function isCoreComponent(tag)
  if isBuiltInType(tag, 'Teleport') then
    return TELEPORT
  elseif isBuiltInType(tag, 'Suspense') then
    return SUSPENSE
  elseif isBuiltInType(tag, 'KeepAlive') then
    return KEEP_ALIVE
  elseif isBuiltInType(tag, 'BaseTransition') then
    return BASE_TRANSITION
  end
end

local parseJS = function(code, options)
  if __BROWSER__ then
    assert(not __BROWSER__, )
    return nil
  else
    return parse(code, options)
  end
end

local walkJS = function(ast, walker)
  if __BROWSER__ then
    assert(not __BROWSER__, )
    return nil
  else
    return walk(ast, walker)
  end
end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local nonIdentifierRE = /^\d|[^\$\w]/
local isSimpleIdentifier = function(name)
  not nonIdentifierRE:test(name)
end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local memberExpRE = /^[A-Za-z_$][\w$]*(?:\.[A-Za-z_$][\w$]*|\[[^\]]+\])*$/
local isMemberExpression = function(path)
  if not path then
    return false
  end
  return memberExpRE:test(path:trim())
end

function getInnerRange(loc, offset, length)
  __TEST__ and assert(offset <= #loc.source)
  local source = loc.source:substr(offset, length)
  local newLoc = {source=source, start=advancePositionWithClone(loc.start, loc.source, offset), tsvar_end=loc.tsvar_end}
  if length ~= nil then
    __TEST__ and assert(offset + length <= #loc.source)
    newLoc.tsvar_end = advancePositionWithClone(loc.start, loc.source, offset + length)
  end
  return newLoc
end

function advancePositionWithClone(pos, source, numberOfCharacters)
  if numberOfCharacters == nil then
    numberOfCharacters=#source
  end
  return advancePositionWithMutation(extend({}, pos), source, numberOfCharacters)
end

function advancePositionWithMutation(pos, source, numberOfCharacters)
  if numberOfCharacters == nil then
    numberOfCharacters=#source
  end
  local linesCount = 0
  local lastNewLinePos = -1
  local i = 0
  repeat
    if source:charCodeAt(i) == 10 then
      linesCount=linesCount+1
      lastNewLinePos = i
    end
    i=i+1
  until not(i < numberOfCharacters)
  pos.offset = pos.offset + numberOfCharacters
  pos.line = pos.line + linesCount
  -- [ts2lua]lua中0和空字符串也是true，此处lastNewLinePos == -1需要确认
  pos.column = (lastNewLinePos == -1 and {pos.column + numberOfCharacters} or {numberOfCharacters - lastNewLinePos})[1]
  return pos
end

function assert(condition, msg)
  if not condition then
    error(Error(msg or ))
  end
end

function findDir(node, name, allowEmpty)
  if allowEmpty == nil then
    allowEmpty=false
  end
  local i = 0
  repeat
    local p = node.props[i+1]
    -- [ts2lua]lua中0和空字符串也是true，此处isString(name)需要确认
    if (p.type == NodeTypes.DIRECTIVE and (allowEmpty or p.exp)) and ((isString(name) and {p.name == name} or {name:test(p.name)})[1]) then
      return p
    end
    i=i+1
  until not(i < #node.props)
end

function findProp(node, name, dynamicOnly, allowEmpty)
  if dynamicOnly == nil then
    dynamicOnly=false
  end
  if allowEmpty == nil then
    allowEmpty=false
  end
  local i = 0
  repeat
    repeat
      local p = node.props[i+1]
      if p.type == NodeTypes.ATTRIBUTE then
        if dynamicOnly then
          break
        end
        if p.name == name and (p.value or allowEmpty) then
          return p
        end
      elseif (p.name == 'bind' and p.exp) and isBindKey(p.arg, name) then
        return p
      end
    until true
    i=i+1
  until not(i < #node.props)
end

function isBindKey(arg, name)
  return not (not (((arg and arg.type == NodeTypes.SIMPLE_EXPRESSION) and arg.isStatic) and arg.content == name))
end

function hasDynamicKeyVBind(node)
  return node.props:some(function(p)
    (p.type == NodeTypes.DIRECTIVE and p.name == 'bind') and ((not p.arg or p.arg.type ~= NodeTypes.SIMPLE_EXPRESSION) or not p.arg.isStatic)
  end
  )
end

function isText(node)
  return node.type == NodeTypes.INTERPOLATION or node.type == NodeTypes.TEXT
end

function isVSlot(p)
  return p.type == NodeTypes.DIRECTIVE and p.name == 'slot'
end

function isTemplateNode(node)
  return node.type == NodeTypes.ELEMENT and node.tagType == ElementTypes.TEMPLATE
end

function isSlotOutlet(node)
  return node.type == NodeTypes.ELEMENT and node.tagType == ElementTypes.SLOT
end

function injectProp(node, prop, context)
  local propsWithInjection = nil
  -- [ts2lua]lua中0和空字符串也是true，此处node.type == NodeTypes.VNODE_CALL需要确认
  local props = (node.type == NodeTypes.VNODE_CALL and {node.props} or {node.arguments[2+1]})[1]
  if props == nil or isString(props) then
    propsWithInjection = createObjectExpression({prop})
  elseif props.type == NodeTypes.JS_CALL_EXPRESSION then
    local first = props.arguments[0+1]
    if not isString(first) and first.type == NodeTypes.JS_OBJECT_EXPRESSION then
      first.properties:unshift(prop)
    else
      props.arguments:unshift(createObjectExpression({prop}))
    end
    propsWithInjection = props
  elseif props.type == NodeTypes.JS_OBJECT_EXPRESSION then
    local alreadyExists = false
    if prop.key.type == NodeTypes.SIMPLE_EXPRESSION then
      local propKeyName = prop.key.content
      alreadyExists = props.properties:some(function(p)
        p.key.type == NodeTypes.SIMPLE_EXPRESSION and p.key.content == propKeyName
      end
      )
    end
    if not alreadyExists then
      props.properties:unshift(prop)
    end
    propsWithInjection = props
  else
    propsWithInjection = createCallExpression(context:helper(MERGE_PROPS), {createObjectExpression({prop}), props})
  end
  if node.type == NodeTypes.VNODE_CALL then
    node.props = propsWithInjection
  else
    node.arguments[2+1] = propsWithInjection
  end
end

function toValidAssetId(name, type)
  return 
end

function hasScopeRef(node, ids)
  if not node or #Object:keys(ids) == 0 then
    return false
  end
  local switch = {
    [NodeTypes.ELEMENT] = function()
      local i = 0
      repeat
        local p = node.props[i+1]
        if p.type == NodeTypes.DIRECTIVE and (hasScopeRef(p.arg, ids) or hasScopeRef(p.exp, ids)) then
          return true
        end
        i=i+1
      until not(i < #node.props)
      return node.children:some(function(c)
        hasScopeRef(c, ids)
      end
      )
    end,
    [NodeTypes.FOR] = function()
      if hasScopeRef(node.source, ids) then
        return true
      end
      return node.children:some(function(c)
        hasScopeRef(c, ids)
      end
      )
    end,
    [NodeTypes.IF] = function()
      return node.branches:some(function(b)
        hasScopeRef(b, ids)
      end
      )
    end,
    [NodeTypes.IF_BRANCH] = function()
      if hasScopeRef(node.condition, ids) then
        return true
      end
      return node.children:some(function(c)
        hasScopeRef(c, ids)
      end
      )
    end,
    [NodeTypes.SIMPLE_EXPRESSION] = function()
      -- [ts2lua]ids下标访问可能不正确
      return (not node.isStatic and isSimpleIdentifier(node.content)) and not (not ids[node.content])
    end,
    [NodeTypes.COMPOUND_EXPRESSION] = function()
      return node.children:some(function(c)
        isObject(c) and hasScopeRef(c, ids)
      end
      )
    end,
    [NodeTypes.INTERPOLATION] = function()
     end,
    [NodeTypes.TEXT_CALL] = function()
      return hasScopeRef(node.content, ids)
    end,
    [NodeTypes.TEXT] = function()
     end,
    [NodeTypes.COMMENT] = function()
      return false
    end,
    ["default"] = function()
      if __DEV__ then
        local exhaustiveCheck = node
      end
      return false
    end
  }
  local casef = switch[node.type]
  if not casef then casef = switch["default"] end
  if casef then casef() end
end
