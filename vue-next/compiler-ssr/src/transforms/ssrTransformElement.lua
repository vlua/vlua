require("@vue/compiler-dom/NodeTypes")
require("@vue/compiler-dom/ElementTypes")
require("@vue/compiler-dom")
require("@vue/compiler-dom/ErrorCodes")
require("@vue/shared")
require("compiler-ssr/src/errors")
require("compiler-ssr/src/errors/SSRErrorCodes")
require("compiler-ssr/src/runtimeHelpers")
require("compiler-ssr/src/ssrCodegenTransform")

local rawChildrenMap = WeakMap()
local ssrTransformElement = function(node, context)
  if node.type ~= NodeTypes.ELEMENT or node.tagType ~= ElementTypes.ELEMENT then
    return
  end
  return function ssrPostTransformElement()
    local openTag = {}
    local needTagForRuntime = node.tag == 'textarea' or node.tag:find('-') > 0
    local hasDynamicVBind = hasDynamicKeyVBind(node)
    if hasDynamicVBind then
      local  = buildProps(node, context, node.props, true)
      if props then
        local propsExp = createCallExpression(context:helper(SSR_RENDER_ATTRS), {props})
        if node.tag == 'textarea' then
          local existingText = node.children[0+1]
          if not existingText or existingText.type ~= NodeTypes.INTERPOLATION then
            local tempId = nil
            propsExp.arguments = {createAssignmentExpression(createSimpleExpression(tempId, false), props)}
            -- [ts2lua]lua中0和空字符串也是true，此处existingText需要确认
            rawChildrenMap:set(node, createCallExpression(context:helper(SSR_INTERPOLATE), {createConditionalExpression(createSimpleExpression(false), createSimpleExpression(false), createSimpleExpression((existingText and {existingText.content} or {})[1], true), false)}))
          end
        elseif node.tag == 'input' then
          local vModel = findVModel(node)
          if vModel then
            local tempId = nil
            local tempExp = createSimpleExpression(tempId, false)
            propsExp.arguments = {createSequenceExpression({createAssignmentExpression(tempExp, props), createCallExpression(context:helper(MERGE_PROPS), {tempExp, createCallExpression(context:helper(SSR_GET_DYNAMIC_MODEL_PROPS), {tempExp, })})})}
          end
        end
        if needTagForRuntime then
          table.insert(propsExp.arguments)
        end
        table.insert(openTag, propsExp)
      end
    end
    local dynamicClassBinding = undefined
    local staticClassBinding = undefined
    local dynamicStyleBinding = undefined
    local i = 0
    repeat
      local prop = node.props[i+1]
      if prop.type == NodeTypes.DIRECTIVE then
        if prop.name == 'html' and prop.exp then
          rawChildrenMap:set(node, prop.exp)
        elseif prop.name == 'text' and prop.exp then
          node.children = {createInterpolation(prop.exp, prop.loc)}
        elseif prop.name == 'slot' then
          context:onError(createCompilerError(ErrorCodes.X_V_SLOT_MISPLACED, prop.loc))
        elseif isTextareaWithValue(node, prop) and prop.exp then
          if not hasDynamicVBind then
            node.children = {createInterpolation(prop.exp, prop.loc)}
          end
        else
          -- [ts2lua]context.directiveTransforms下标访问可能不正确
          local directiveTransform = context.directiveTransforms[prop.name]
          if not directiveTransform then
            context:onError(createSSRCompilerError(SSRErrorCodes.X_SSR_CUSTOM_DIRECTIVE_NO_TRANSFORM, prop.loc))
          elseif not hasDynamicVBind then
            local  = directiveTransform(prop, node, context)
            if ssrTagParts then
              table.insert(openTag, ...)
            end
            local j = 0
            repeat
              local  = props[j+1]
              if key.type == NodeTypes.SIMPLE_EXPRESSION and key.isStatic then
                local attrName = key.content
                if attrName == 'class' then
                  dynamicClassBinding = createCallExpression(context:helper(SSR_RENDER_CLASS), {value})
                  table.insert(openTag, dynamicClassBinding, )
                elseif attrName == 'style' then
                  if dynamicStyleBinding then
                    mergeCall(dynamicStyleBinding, value)
                  else
                    dynamicStyleBinding = createCallExpression(context:helper(SSR_RENDER_STYLE), {value})
                    table.insert(openTag, dynamicStyleBinding, )
                  end
                else
                  -- [ts2lua]propsToAttrMap下标访问可能不正确
                  -- [ts2lua]lua中0和空字符串也是true，此处node.tag:find('-') > 0需要确认
                  attrName = (node.tag:find('-') > 0 and {attrName} or {propsToAttrMap[attrName] or attrName:toLowerCase()})[1]
                  if isBooleanAttr(attrName) then
                    table.insert(openTag, createConditionalExpression(value, createSimpleExpression(' ' .. attrName, true), createSimpleExpression('', true), false))
                  elseif isSSRSafeAttrName(attrName) then
                    table.insert(openTag, createCallExpression(context:helper(SSR_RENDER_ATTR), {key, value}))
                  else
                    context:onError(createSSRCompilerError(SSRErrorCodes.X_SSR_UNSAFE_ATTR_NAME, key.loc))
                  end
                end
              else
                local args = {key, value}
                if needTagForRuntime then
                  table.insert(args)
                end
                table.insert(openTag, createCallExpression(context:helper(SSR_RENDER_DYNAMIC_ATTR), args))
              end
              j=j+1
            until not(j < #props)
          end
        end
      else
        if (node.tag == 'textarea' and prop.name == 'value') and prop.value then
          rawChildrenMap:set(node, escapeHtml(prop.value.content))
        elseif not hasDynamicVBind then
          if prop.name == 'class' and prop.value then
            staticClassBinding = JSON:stringify(prop.value.content)
          end
          -- [ts2lua]lua中0和空字符串也是true，此处prop.value需要确认
          table.insert(openTag,  + (prop.value and {} or {})[1])
        end
      end
      i=i+1
    until not(i < #node.props)
    if dynamicClassBinding and staticClassBinding then
      mergeCall(dynamicClassBinding, staticClassBinding)
      removeStaticBinding(openTag, 'class')
    end
    if context.scopeId then
      table.insert(openTag)
    end
    node.ssrCodegenNode = createTemplateLiteral(openTag)
  end
  

end

function isTextareaWithValue(node, prop)
  return not (not ((node.tag == 'textarea' and prop.name == 'bind') and isBindKey(prop.arg, 'value')))
end

function mergeCall(call, arg)
  local existing = call.arguments[0+1]
  if existing.type == NodeTypes.JS_ARRAY_EXPRESSION then
    table.insert(existing.elements, arg)
  else
    call.arguments[0+1] = createArrayExpression({existing, arg})
  end
end

function removeStaticBinding(tag, binding)
  local i = tag:findIndex(function(e)
    type(e) == 'string' and e:startsWith()
  end
  )
  if i > -1 then
    tag:splice(i, 1)
  end
end

function findVModel(node)
  return node.props:find(function(p)
    (p.type == NodeTypes.DIRECTIVE and p.name == 'model') and p.exp
  end
  )
end

function ssrProcessElement(node, context)
  local isVoidTag = context.options.isVoidTag or NO
  local elementsToAdd = ().elements
  local j = 0
  repeat
    context:pushStringPart(elementsToAdd[j+1])
    j=j+1
  until not(j < #elementsToAdd)
  if context.withSlotScopeId then
    context:pushStringPart(createSimpleExpression(false))
  end
  context:pushStringPart()
  local rawChildren = rawChildrenMap:get(node)
  if rawChildren then
    context:pushStringPart(rawChildren)
  elseif #node.children then
    processChildren(node.children, context)
  end
  if not isVoidTag(node.tag) then
    context:pushStringPart()
  end
end
