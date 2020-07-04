require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast")
require("source-map")
require("compiler-core/src/utils")
require("@vue/shared")
require("compiler-core/src/runtimeHelpers")

local PURE_ANNOTATION = nil
function createCodegenContext(ast, )
  local context = {mode=mode, prefixIdentifiers=prefixIdentifiers, sourceMap=sourceMap, filename=filename, scopeId=scopeId, optimizeBindings=optimizeBindings, runtimeGlobalName=runtimeGlobalName, runtimeModuleName=runtimeModuleName, ssr=ssr, source=ast.loc.source, code=, column=1, line=1, offset=0, indentLevel=0, pure=false, map=undefined, helper=function(key)
    return 
  end
  , push=function(code, node)
    context.code = context.code + code
    if not __BROWSER__ and context.map then
      if node then
        local name = nil
        if node.type == NodeTypes.SIMPLE_EXPRESSION and not node.isStatic then
          -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
          local content = node.content:gsub(/^_ctx\./, '')
          if content ~= node.content and isSimpleIdentifier(content) then
            name = content
          end
        end
        addMapping(node.loc.start, name)
      end
      advancePositionWithMutation(context, code)
      if node and node.loc ~= locStub then
        addMapping(node.loc.tsvar_end)
      end
    end
  end
  , indent=function()
    newline(context.indentLevel)
  end
  , deindent=function(withoutNewLine)
    if withoutNewLine == nil then
      withoutNewLine=false
    end
    if withoutNewLine then
      context.indentLevel=context.indentLevel-1
    else
      newline(context.indentLevel)
    end
  end
  , newline=function()
    newline(context.indentLevel)
  end
  }
  function newline(n)
    table.insert(context, '\n' .. ():tsvar_repeat(n))
  end
  
  function addMapping(loc, name)
    ():addMapping({name=name, source=context.filename, original={line=loc.line, column=loc.column - 1}, generated={line=context.line, column=context.column - 1}})
  end
  
  if not __BROWSER__ and sourceMap then
    context.map = SourceMapGenerator()
    ():setSourceContent(filename, context.source)
  end
  return context
end

function generate(ast, options)
  if options == nil then
    options={}
  end
  local context = createCodegenContext(ast, options)
  local  = context
  local hasHelpers = #ast.helpers > 0
  local useWithBlock = not prefixIdentifiers and mode ~= 'module'
  local genScopeId = (not __BROWSER__ and scopeId ~= nil) and mode == 'module'
  if not __BROWSER__ and mode == 'module' then
    genModulePreamble(ast, context, genScopeId)
  else
    genFunctionPreamble(ast, context)
  end
  if not ssr then
    if genScopeId then
      push()
    end
    push()
  else
    if genScopeId then
      push()
    end
    push()
  end
  indent()
  if useWithBlock then
    push()
    indent()
    if hasHelpers then
      push()
      push()
      newline()
    end
  end
  if #ast.components then
    genAssets(ast.components, 'component', context)
    if #ast.directives or ast.temps > 0 then
      newline()
    end
  end
  if #ast.directives then
    genAssets(ast.directives, 'directive', context)
    if ast.temps > 0 then
      newline()
    end
  end
  if ast.temps > 0 then
    push()
    local i = 0
    repeat
      push()
      i=i+1
    until not(i < ast.temps)
  end
  if (#ast.components or #ast.directives) or ast.temps then
    push()
    newline()
  end
  if not ssr then
    push()
  end
  if ast.codegenNode then
    genNode(ast.codegenNode, context)
  else
    push()
  end
  if useWithBlock then
    deindent()
    push()
  end
  deindent()
  push()
  if genScopeId then
    push()
  end
  -- [ts2lua]lua中0和空字符串也是true，此处context.map需要确认
  return {ast=ast, code=context.code, map=(context.map and {context.map:toJSON()} or {undefined})[1]}
end

function genFunctionPreamble(ast, context)
  local  = context
  -- [ts2lua]lua中0和空字符串也是true，此处not __BROWSER__ and ssr需要确认
  local VueBinding = (not __BROWSER__ and ssr and {} or {runtimeGlobalName})[1]
  local aliasHelper = function(s)
    
  end
  
  if #ast.helpers > 0 then
    if not __BROWSER__ and prefixIdentifiers then
      push()
    else
      push()
      if #ast.hoists then
        local staticHelpers = ({CREATE_VNODE, CREATE_COMMENT, CREATE_TEXT, CREATE_STATIC}):filter(function(helper)
          ast.helpers:includes(helper)
        end
        ):map(aliasHelper):join(', ')
        push()
      end
    end
  end
  if (not __BROWSER__ and ast.ssrHelpers) and #ast.ssrHelpers then
    push()
  end
  genHoists(ast.hoists, context)
  newline()
  push()
end

function genModulePreamble(ast, context, genScopeId)
  local  = context
  if genScopeId then
    table.insert(ast.helpers, WITH_SCOPE_ID)
    if #ast.hoists then
      table.insert(ast.helpers, PUSH_SCOPE_ID, POP_SCOPE_ID)
    end
  end
  if #ast.helpers then
    if optimizeBindings then
      push()
      push()
    else
      push()
    end
  end
  if ast.ssrHelpers and #ast.ssrHelpers then
    push()
  end
  if #ast.imports then
    genImports(ast.imports, context)
    newline()
  end
  if genScopeId then
    push()
    newline()
  end
  genHoists(ast.hoists, context)
  newline()
  push()
end

function genAssets(assets, type, )
  -- [ts2lua]lua中0和空字符串也是true，此处type == 'component'需要确认
  local resolver = helper((type == 'component' and {RESOLVE_COMPONENT} or {RESOLVE_DIRECTIVE})[1])
  local i = 0
  repeat
    local id = assets[i+1]
    push()
    if i < #assets - 1 then
      newline()
    end
    i=i+1
  until not(i < #assets)
end

function genHoists(hoists, context)
  if not #hoists then
    return
  end
  context.pure = true
  local  = context
  local genScopeId = (not __BROWSER__ and scopeId ~= nil) and mode ~= 'function'
  newline()
  if genScopeId then
    push()
    newline()
  end
  hoists:forEach(function(exp, i)
    if exp then
      push()
      genNode(exp, context)
      newline()
    end
  end
  )
  if genScopeId then
    push()
    newline()
  end
  context.pure = false
end

function genImports(importsOptions, context)
  if not #importsOptions then
    return
  end
  importsOptions:forEach(function(imports)
    table.insert(context)
    genNode(imports.exp, context)
    table.insert(context)
    context:newline()
  end
  )
end

function isText(n)
  return (((isString(n) or n.type == NodeTypes.SIMPLE_EXPRESSION) or n.type == NodeTypes.TEXT) or n.type == NodeTypes.INTERPOLATION) or n.type == NodeTypes.COMPOUND_EXPRESSION
end

function genNodeListAsArray(nodes, context)
  local multilines = #nodes > 3 or (not __BROWSER__ or __DEV__) and nodes:some(function(n)
    isArray(n) or not isText(n)
  end
  )
  table.insert(context)
  multilines and context:indent()
  genNodeList(nodes, context, multilines)
  multilines and context:deindent()
  table.insert(context)
end

function genNodeList(nodes, context, multilines, comma)
  if multilines == nil then
    multilines=false
  end
  if comma == nil then
    comma=true
  end
  local  = context
  local i = 0
  repeat
    local node = nodes[i+1]
    if isString(node) then
      push(node)
    elseif isArray(node) then
      genNodeListAsArray(node, context)
    else
      genNode(node, context)
    end
    if i < #nodes - 1 then
      if multilines then
        comma and push(',')
        newline()
      else
        comma and push(', ')
      end
    end
    i=i+1
  until not(i < #nodes)
end

function genNode(node, context)
  if isString(node) then
    table.insert(context, node)
    return
  end
  if isSymbol(node) then
    table.insert(context, context:helper(node))
    return
  end
  local switch = {
    [NodeTypes.ELEMENT] = function()
     end,
    [NodeTypes.IF] = function()
     end,
    [NodeTypes.FOR] = function()
      __DEV__ and assert(node.codegenNode ~= nil,  + )
      genNode(context)
    end,
    [NodeTypes.TEXT] = function()
      genText(node, context)
    end,
    [NodeTypes.SIMPLE_EXPRESSION] = function()
      genExpression(node, context)
    end,
    [NodeTypes.INTERPOLATION] = function()
      genInterpolation(node, context)
    end,
    [NodeTypes.TEXT_CALL] = function()
      genNode(node.codegenNode, context)
    end,
    [NodeTypes.COMPOUND_EXPRESSION] = function()
      genCompoundExpression(node, context)
    end,
    [NodeTypes.COMMENT] = function()
      genComment(node, context)
    end,
    [NodeTypes.VNODE_CALL] = function()
      genVNodeCall(node, context)
    end,
    [NodeTypes.JS_CALL_EXPRESSION] = function()
      genCallExpression(node, context)
    end,
    [NodeTypes.JS_OBJECT_EXPRESSION] = function()
      genObjectExpression(node, context)
    end,
    [NodeTypes.JS_ARRAY_EXPRESSION] = function()
      genArrayExpression(node, context)
    end,
    [NodeTypes.JS_FUNCTION_EXPRESSION] = function()
      genFunctionExpression(node, context)
    end,
    [NodeTypes.JS_CONDITIONAL_EXPRESSION] = function()
      genConditionalExpression(node, context)
    end,
    [NodeTypes.JS_CACHE_EXPRESSION] = function()
      genCacheExpression(node, context)
    end,
    [NodeTypes.JS_BLOCK_STATEMENT] = function()
      not __BROWSER__ and genNodeList(node.body, context, true, false)
    end,
    [NodeTypes.JS_TEMPLATE_LITERAL] = function()
      not __BROWSER__ and genTemplateLiteral(node, context)
    end,
    [NodeTypes.JS_IF_STATEMENT] = function()
      not __BROWSER__ and genIfStatement(node, context)
    end,
    [NodeTypes.JS_ASSIGNMENT_EXPRESSION] = function()
      not __BROWSER__ and genAssignmentExpression(node, context)
    end,
    [NodeTypes.JS_SEQUENCE_EXPRESSION] = function()
      not __BROWSER__ and genSequenceExpression(node, context)
    end,
    [NodeTypes.JS_RETURN_STATEMENT] = function()
      not __BROWSER__ and genReturnStatement(node, context)
    end,
    [NodeTypes.IF_BRANCH] = function()
     end,
    ["default"] = function()
      if __DEV__ then
        assert(false, )
        local exhaustiveCheck = node
        return exhaustiveCheck
      end
    end
  }
  local casef = switch[node.type]
  if not casef then casef = switch["default"] end
  if casef then casef() end
end

function genText(node, context)
  table.insert(context, JSON:stringify(node.content), node)
end

function genExpression(node, context)
  local  = node
  -- [ts2lua]lua中0和空字符串也是true，此处isStatic需要确认
  table.insert(context, (isStatic and {JSON:stringify(content)} or {content})[1], node)
end

function genInterpolation(node, context)
  local  = context
  if pure then
    push(PURE_ANNOTATION)
  end
  push()
  genNode(node.content, context)
  push()
end

function genCompoundExpression(node, context)
  local i = 0
  repeat
    local child = ()[i+1]
    if isString(child) then
      table.insert(context, child)
    else
      genNode(child, context)
    end
    i=i+1
  until not(i < #())
end

function genExpressionAsPropertyKey(node, context)
  local  = context
  if node.type == NodeTypes.COMPOUND_EXPRESSION then
    push()
    genCompoundExpression(node, context)
    push()
  elseif node.isStatic then
    -- [ts2lua]lua中0和空字符串也是true，此处isSimpleIdentifier(node.content)需要确认
    local text = (isSimpleIdentifier(node.content) and {node.content} or {JSON:stringify(node.content)})[1]
    push(text, node)
  else
    push(node)
  end
end

function genComment(node, context)
  if __DEV__ then
    local  = context
    if pure then
      push(PURE_ANNOTATION)
    end
    push(node)
  end
end

function genVNodeCall(node, context)
  local  = context
  local  = node
  if directives then
    push(helper(WITH_DIRECTIVES) + )
  end
  if isBlock then
    push()
  end
  if pure then
    push(PURE_ANNOTATION)
  end
  -- [ts2lua]lua中0和空字符串也是true，此处isBlock需要确认
  push(helper((isBlock and {CREATE_BLOCK} or {CREATE_VNODE})[1]) + , node)
  genNodeList(genNullableArgs({tag, props, children, patchFlag, dynamicProps}), context)
  push()
  if isBlock then
    push()
  end
  if directives then
    push()
    genNode(directives, context)
    push()
  end
end

function genNullableArgs(args)
  local i = #args
  while(i=i-1)
  do
  if args[i+1] ~= nil then
    break
  end
  end
  return args:slice(0, i + 1):map(function(arg)
    arg or 
  end
  )
end

function genCallExpression(node, context)
  local  = context
  -- [ts2lua]lua中0和空字符串也是true，此处isString(node.callee)需要确认
  local callee = (isString(node.callee) and {node.callee} or {helper(node.callee)})[1]
  if pure then
    push(PURE_ANNOTATION)
  end
  push(callee + , node)
  genNodeList(node.arguments, context)
  push()
end

function genObjectExpression(node, context)
  local  = context
  local  = node
  if not #properties then
    push(node)
    return
  end
  local multilines = #properties > 1 or (not __BROWSER__ or __DEV__) and properties:some(function(p)
    p.value.type ~= NodeTypes.SIMPLE_EXPRESSION
  end
  )
  -- [ts2lua]lua中0和空字符串也是true，此处multilines需要确认
  push((multilines and {} or {})[1])
  multilines and indent()
  local i = 0
  repeat
    local  = properties[i+1]
    genExpressionAsPropertyKey(key, context)
    push()
    genNode(value, context)
    if i < #properties - 1 then
      push()
      newline()
    end
    i=i+1
  until not(i < #properties)
  multilines and deindent()
  -- [ts2lua]lua中0和空字符串也是true，此处multilines需要确认
  push((multilines and {} or {})[1])
end

function genArrayExpression(node, context)
  genNodeListAsArray(node.elements, context)
end

function genFunctionExpression(node, context)
  local  = context
  local  = node
  local genScopeId = ((not __BROWSER__ and isSlot) and scopeId ~= nil) and mode ~= 'function'
  if genScopeId then
    push()
  elseif isSlot then
    push()
  end
  push(node)
  if isArray(params) then
    genNodeList(params, context)
  elseif params then
    genNode(params, context)
  end
  push()
  if newline or body then
    push()
    indent()
  end
  if returns then
    if newline then
      push()
    end
    if isArray(returns) then
      genNodeListAsArray(returns, context)
    else
      genNode(returns, context)
    end
  elseif body then
    genNode(body, context)
  end
  if newline or body then
    deindent()
    push()
  end
  if genScopeId or isSlot then
    push()
  end
end

function genConditionalExpression(node, context)
  local  = node
  local  = context
  if test.type == NodeTypes.SIMPLE_EXPRESSION then
    local needsParens = not isSimpleIdentifier(test.content)
    needsParens and push()
    genExpression(test, context)
    needsParens and push()
  else
    push()
    genNode(test, context)
    push()
  end
  needNewline and indent()
  context.indentLevel=context.indentLevel+1
  needNewline or push()
  push()
  genNode(consequent, context)
  context.indentLevel=context.indentLevel-1
  needNewline and newline()
  needNewline or push()
  push()
  local isNested = alternate.type == NodeTypes.JS_CONDITIONAL_EXPRESSION
  if not isNested then
    context.indentLevel=context.indentLevel+1
  end
  genNode(alternate, context)
  if not isNested then
    context.indentLevel=context.indentLevel-1
  end
  needNewline and deindent(true)
end

function genCacheExpression(node, context)
  local  = context
  push()
  if node.isVNode then
    indent()
    push()
    newline()
  end
  push()
  genNode(node.value, context)
  if node.isVNode then
    push()
    newline()
    push()
    newline()
    push()
    deindent()
  end
  push()
end

function genTemplateLiteral(node, context)
  local  = context
  push('`')
  local l = #node.elements
  local multilines = l > 3
  local i = 0
  repeat
    local e = node.elements[i+1]
    if isString(e) then
      -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
      push(e:gsub(/(`|\$|\\)/g, '\\$1'))
    else
      push('${')
      if multilines then
        indent()
      end
      genNode(e, context)
      if multilines then
        deindent()
      end
      push('}')
    end
    i=i+1
  until not(i < l)
  push('`')
end

function genIfStatement(node, context)
  local  = context
  local  = node
  push()
  genNode(test, context)
  push()
  indent()
  genNode(consequent, context)
  deindent()
  push()
  if alternate then
    push()
    if alternate.type == NodeTypes.JS_IF_STATEMENT then
      genIfStatement(alternate, context)
    else
      push()
      indent()
      genNode(alternate, context)
      deindent()
      push()
    end
  end
end

function genAssignmentExpression(node, context)
  genNode(node.left, context)
  table.insert(context)
  genNode(node.right, context)
end

function genSequenceExpression(node, context)
  table.insert(context)
  genNodeList(node.expressions, context)
  table.insert(context)
end

function genReturnStatement(, context)
  table.insert(context)
  if isArray(returns) then
    genNodeListAsArray(returns, context)
  else
    genNode(returns, context)
  end
end
