require("@vue/compiler-dom")
require("@vue/compiler-dom/NodeTypes")
require("@vue/compiler-dom/ElementTypes")
require("@vue/shared")
require("compiler-ssr/src/runtimeHelpers")
require("compiler-ssr/src/transforms/ssrVIf")
require("compiler-ssr/src/transforms/ssrVFor")
require("compiler-ssr/src/transforms/ssrTransformSlotOutlet")
require("compiler-ssr/src/transforms/ssrTransformComponent")
require("compiler-ssr/src/transforms/ssrTransformElement")
require("compiler-ssr/src/errors")
require("compiler-ssr/src/errors/SSRErrorCodes")

function ssrCodegenTransform(ast, options)
  local context = createSSRTransformContext(ast, options)
  local isFragment = #ast.children > 1 and ast.children:some(function(c)
    not isText(c)
  end
  )
  processChildren(ast.children, context, isFragment)
  ast.codegenNode = createBlockStatement(context.body)
  ast.ssrHelpers = {..., ...}
  ast.helpers = ast.helpers:filter(function(h)
    not (ssrHelpers[h])
  end
  )
end

function createSSRTransformContext(root, options, helpers, withSlotScopeId)
  if helpers == nil then
    helpers=Set()
  end
  if withSlotScopeId == nil then
    withSlotScopeId=false
  end
  local body = {}
  local currentString = nil
  return {root=root, options=options, body=body, helpers=helpers, withSlotScopeId=withSlotScopeId, onError=options.onError or function(e)
    error(e)
  end
  , helper=function(name)
    helpers:add(name)
    return name
  end
  , pushStringPart=function(part)
    if not currentString then
      local currentCall = createCallExpression()
      table.insert(body, currentCall)
      currentString = createTemplateLiteral({})
      table.insert(currentCall.arguments, currentString)
    end
    local bufferedElements = currentString.elements
    -- [ts2lua]bufferedElements下标访问可能不正确
    local lastItem = bufferedElements[#bufferedElements - 1]
    if isString(part) and isString(lastItem) then
      -- [ts2lua]bufferedElements下标访问可能不正确
      -- [ts2lua]bufferedElements下标访问可能不正确
      bufferedElements[#bufferedElements - 1] = bufferedElements[#bufferedElements - 1] + part
    else
      table.insert(bufferedElements, part)
    end
  end
  , pushStatement=function(statement)
    currentString = nil
    table.insert(body, statement)
  end
  }
end

function createChildContext(parent, withSlotScopeId)
  if withSlotScopeId == nil then
    withSlotScopeId=parent.withSlotScopeId
  end
  return createSSRTransformContext(parent.root, parent.options, parent.helpers, withSlotScopeId)
end

function processChildren(children, context, asFragment)
  if asFragment == nil then
    asFragment=false
  end
  if asFragment then
    context:pushStringPart()
  end
  local i = 0
  repeat
    local child = children[i+1]
    local switch = {
      [NodeTypes.ELEMENT] = function()
        local switch = {
          [ElementTypes.ELEMENT] = function()
            ssrProcessElement(child, context)
          end,
          [ElementTypes.COMPONENT] = function()
            ssrProcessComponent(child, context)
          end,
          [ElementTypes.SLOT] = function()
            ssrProcessSlotOutlet(child, context)
          end,
          [ElementTypes.TEMPLATE] = function()
           end,
          ["default"] = function()
            context:onError(createSSRCompilerError(SSRErrorCodes.X_SSR_INVALID_AST_NODE, child.loc))
            local exhaustiveCheck = child
            return exhaustiveCheck
          end
        }
        local casef = switch[child.tagType]
        if not casef then casef = switch["default"] end
        if casef then casef() end
      end,
      [NodeTypes.TEXT] = function()
        context:pushStringPart(escapeHtml(child.content))
      end,
      [NodeTypes.COMMENT] = function()
        context:pushStringPart()
      end,
      [NodeTypes.INTERPOLATION] = function()
        context:pushStringPart(createCallExpression(context:helper(SSR_INTERPOLATE), {child.content}))
      end,
      [NodeTypes.IF] = function()
        ssrProcessIf(child, context)
      end,
      [NodeTypes.FOR] = function()
        ssrProcessFor(child, context)
      end,
      [NodeTypes.IF_BRANCH] = function()
       end,
      [NodeTypes.TEXT_CALL] = function()
       end,
      [NodeTypes.COMPOUND_EXPRESSION] = function()
       end,
      ["default"] = function()
        context:onError(createSSRCompilerError(SSRErrorCodes.X_SSR_INVALID_AST_NODE, child.loc))
        local exhaustiveCheck = child
        return exhaustiveCheck
      end
    }
    local casef = switch[child.type]
    if not casef then casef = switch["default"] end
    if casef then casef() end
    i=i+1
  until not(i < #children)
  if asFragment then
    context:pushStringPart()
  end
end

function processChildrenAsStatement(children, parentContext, asFragment, withSlotScopeId)
  if asFragment == nil then
    asFragment=false
  end
  if withSlotScopeId == nil then
    withSlotScopeId=parentContext.withSlotScopeId
  end
  local childContext = createChildContext(parentContext, withSlotScopeId)
  processChildren(children, childContext, asFragment)
  return createBlockStatement(childContext.body)
end
