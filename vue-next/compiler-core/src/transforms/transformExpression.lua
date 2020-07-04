require("stringutil")
require("trycatch")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast")
require("compiler-core/src/utils")
require("@vue/shared")
require("compiler-core/src/errors")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src/validateExpression")

local isLiteralWhitelisted = makeMap('true,false,null,this')
local transformExpression = function(node, context)
  if node.type == NodeTypes.INTERPOLATION then
    node.content = processExpression(node.content, context)
  elseif node.type == NodeTypes.ELEMENT then
    local i = 0
    repeat
      local dir = node.props[i+1]
      if dir.type == NodeTypes.DIRECTIVE and dir.name ~= 'for' then
        local exp = dir.exp
        local arg = dir.arg
        if (exp and exp.type == NodeTypes.SIMPLE_EXPRESSION) and not (dir.name == 'on' and arg) then
          dir.exp = processExpression(exp, context, dir.name == 'slot')
        end
        if (arg and arg.type == NodeTypes.SIMPLE_EXPRESSION) and not arg.isStatic then
          dir.arg = processExpression(arg, context)
        end
      end
      i=i+1
    until not(i < #node.props)
  end
end

function processExpression(node, context, asParams, asRawStatements)
  if asParams == nil then
    asParams=false
  end
  if asRawStatements == nil then
    asRawStatements=false
  end
  if __DEV__ and __BROWSER__ then
    validateBrowserExpression(node, context, asParams, asRawStatements)
    return node
  end
  if not context.prefixIdentifiers or not node.content:trim() then
    return node
  end
  local rawExp = node.content
  local bailConstant = rawExp:find() > -1
  if isSimpleIdentifier(rawExp) then
    -- [ts2lua]context.identifiers下标访问可能不正确
    if ((not asParams and not context.identifiers[rawExp]) and not isGloballyWhitelisted(rawExp)) and not isLiteralWhitelisted(rawExp) then
      node.content = 
    -- [ts2lua]context.identifiers下标访问可能不正确
    elseif not context.identifiers[rawExp] and not bailConstant then
      node.isConstant = true
    end
    return node
  end
  local ast = nil
  -- [ts2lua]lua中0和空字符串也是true，此处asRawStatements需要确认
  local source = (asRawStatements and {} or {})[1]
  try_catch{
    main = function()
      ast = parseJS(source, {plugins={..., 'bigInt', 'optionalChaining', 'nullishCoalescingOperator'}}).program
    end,
    catch = function(e)
      context:onError(createCompilerError(ErrorCodes.X_INVALID_EXPRESSION, node.loc, undefined, e.message))
      return node
    end
  }
  local ids = {}
  local knownIds = Object:create(context.identifiers)
  local isDuplicate = function(node)
    ids:some(function(id)
      id.start == node.start
    end
    )
  end
  
  walkJS(ast, {enter=function(node, parent)
    if node.type == 'Identifier' then
      if not isDuplicate(node) then
        local needPrefix = shouldPrefix(node, parent)
        -- [ts2lua]knownIds下标访问可能不正确
        if not knownIds[node.name] and needPrefix then
          if isPropertyShorthand(node, parent) then
            node.prefix = 
          end
          node.name = 
          table.insert(ids, node)
        elseif not isStaticPropertyKey(node, parent) then
          -- [ts2lua]knownIds下标访问可能不正确
          if not (needPrefix and knownIds[node.name]) and not bailConstant then
            node.isConstant = true
          end
          table.insert(ids, node)
        end
      end
    elseif isFunction(node) then
      node.params:forEach(function(p)
        walkJS(p, {enter=function(child, parent)
          if (child.type == 'Identifier' and not isStaticPropertyKey(child, parent)) and not ((parent and parent.type == 'AssignmentPattern') and parent.right == child) then
            local  = child
            if node.scopeIds and node.scopeIds:has(name) then
              return
            end
            if knownIds[name] then
              -- [ts2lua]knownIds下标访问可能不正确
              -- [ts2lua]knownIds下标访问可能不正确
              knownIds[name]=knownIds[name]+1
            else
              -- [ts2lua]knownIds下标访问可能不正确
              knownIds[name] = 1
            end
            (node.scopeIds or (node.scopeIds = Set())):add(name)
          end
        end
        })
      end
      )
    end
  end
  , leave=function(node)
    if node ~= ast.body[0+1].expression and node.scopeIds then
      node.scopeIds:forEach(function(id)
        -- [ts2lua]knownIds下标访问可能不正确
        -- [ts2lua]knownIds下标访问可能不正确
        knownIds[id]=knownIds[id]-1
        -- [ts2lua]knownIds下标访问可能不正确
        if knownIds[id] == 0 then
          -- [ts2lua]knownIds下标访问可能不正确
          knownIds[id] = nil
        end
      end
      )
    end
  end
  })
  local children = {}
  ids:sort(function(a, b)
    a.start - b.start
  end
  )
  ids:forEach(function(id, i)
    local start = id.start - 1
    local tsvar_end = id.tsvar_end - 1
    -- [ts2lua]ids下标访问可能不正确
    local last = ids[i - 1]
    -- [ts2lua]lua中0和空字符串也是true，此处last需要确认
    local leadingText = rawExp:slice((last and {last.tsvar_end - 1} or {0})[1], start)
    if #leadingText or id.prefix then
      table.insert(children, leadingText + id.prefix or )
    end
    local source = rawExp:slice(start, tsvar_end)
    table.insert(children, createSimpleExpression(id.name, false, {source=source, start=advancePositionWithClone(node.loc.start, source, start), tsvar_end=advancePositionWithClone(node.loc.start, source, tsvar_end)}, id.isConstant))
    if i == #ids - 1 and tsvar_end < #rawExp then
      table.insert(children, rawExp:slice(tsvar_end))
    end
  end
  )
  local ret = nil
  if #children then
    ret = createCompoundExpression(children, node.loc)
  else
    ret = node
    ret.isConstant = not bailConstant
  end
  ret.identifiers = Object:keys(knownIds)
  return ret
end

local isFunction = function(node)
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  (/Function(Expression|Declaration)$/):test(node.type)
end

local isStaticProperty = function(node)
  (node and (node.type == 'ObjectProperty' or node.type == 'ObjectMethod')) and not node.computed
end

local isPropertyShorthand = function(node, parent)
  return (((isStaticProperty(parent) and parent.value == node) and parent.key.type == 'Identifier') and parent.key.name == node.name) and parent.key.start == node.start
end

local isStaticPropertyKey = function(node, parent)
  isStaticProperty(parent) and parent.key == node
end

function shouldPrefix(identifier, parent)
  if (((((not (isFunction(parent) and (parent.id == identifier or parent.params:includes(identifier))) and not isStaticPropertyKey(identifier, parent)) and not (((parent.type == 'MemberExpression' or parent.type == 'OptionalMemberExpression') and parent.property == identifier) and not parent.computed)) and not (parent.type == 'ArrayPattern')) and not isGloballyWhitelisted(identifier.name)) and identifier.name ~= ) and identifier.name ~=  then
    return true
  end
end
