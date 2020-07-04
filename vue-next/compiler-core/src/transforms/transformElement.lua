require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast/ElementTypes")
require("compiler-core/src/ast")
require("@vue/shared/PatchFlags")
require("@vue/shared")
require("compiler-core/src/errors")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/src/utils")
require("compiler-core/src/transforms/vSlot")
require("compiler-core/src/transforms/hoistStatic")

local directiveImportMap = WeakMap()
local transformElement = function(node, context)
  if not (node.type == NodeTypes.ELEMENT and (node.tagType == ElementTypes.ELEMENT or node.tagType == ElementTypes.COMPONENT)) then
    return
  end
  return function postTransformElement()
    local  = node
    local isComponent = node.tagType == ElementTypes.COMPONENT
    -- [ts2lua]lua中0和空字符串也是true，此处isComponent需要确认
    local vnodeTag = (isComponent and {resolveComponentType(node, context)} or {})[1]
    local isDynamicComponent = isObject(vnodeTag) and vnodeTag.callee == RESOLVE_DYNAMIC_COMPONENT
    local vnodeProps = nil
    local vnodeChildren = nil
    local vnodePatchFlag = nil
    local patchFlag = 0
    local vnodeDynamicProps = nil
    local dynamicPropNames = nil
    local vnodeDirectives = nil
    local shouldUseBlock = isDynamicComponent or not isComponent and ((tag == 'svg' or tag == 'foreignObject') or findProp(node, 'key', true))
    if #props > 0 then
      local propsBuildResult = buildProps(node, context)
      vnodeProps = propsBuildResult.props
      patchFlag = propsBuildResult.patchFlag
      dynamicPropNames = propsBuildResult.dynamicPropNames
      local directives = propsBuildResult.directives
      vnodeDirectives = (directives and #directives and {createArrayExpression(directives:map(function(dir)
        buildDirectiveArgs(dir, context)
      end
      -- [ts2lua]lua中0和空字符串也是true，此处directives and #directives需要确认
      ))} or {undefined})[1]
    end
    if #node.children > 0 then
      if vnodeTag == KEEP_ALIVE then
        shouldUseBlock = true
        patchFlag = patchFlag | PatchFlags.DYNAMIC_SLOTS
        if __DEV__ and #node.children > 1 then
          -- [ts2lua]node.children下标访问可能不正确
          context:onError(createCompilerError(ErrorCodes.X_KEEP_ALIVE_INVALID_CHILDREN, {start=node.children[0+1].loc.start, tsvar_end=node.children[#node.children - 1].loc.tsvar_end, source=''}))
        end
      end
      local shouldBuildAsSlots = (isComponent and vnodeTag ~= TELEPORT) and vnodeTag ~= KEEP_ALIVE
      if shouldBuildAsSlots then
        local  = buildSlots(node, context)
        vnodeChildren = slots
        if hasDynamicSlots then
          patchFlag = patchFlag | PatchFlags.DYNAMIC_SLOTS
        end
      elseif #node.children == 1 and vnodeTag ~= TELEPORT then
        local child = node.children[0+1]
        local type = child.type
        local hasDynamicTextChild = type == NodeTypes.INTERPOLATION or type == NodeTypes.COMPOUND_EXPRESSION
        if hasDynamicTextChild and not getStaticType(child) then
          patchFlag = patchFlag | PatchFlags.TEXT
        end
        if hasDynamicTextChild or type == NodeTypes.TEXT then
          vnodeChildren = child
        else
          vnodeChildren = node.children
        end
      else
        vnodeChildren = node.children
      end
    end
    if patchFlag ~= 0 then
      if __DEV__ then
        if patchFlag < 0 then
          vnodePatchFlag = patchFlag + 
        else
          local flagNames = Object:keys(PatchFlagNames):map(Number):filter(function(n)
            n > 0 and patchFlag & n
          end
          ):map(function(n)
            PatchFlagNames[n+1]
          end
          ):join()
          vnodePatchFlag = patchFlag + 
        end
      else
        vnodePatchFlag = String(patchFlag)
      end
      if dynamicPropNames and #dynamicPropNames then
        vnodeDynamicProps = stringifyDynamicPropNames(dynamicPropNames)
      end
    end
    node.codegenNode = createVNodeCall(context, vnodeTag, vnodeProps, vnodeChildren, vnodePatchFlag, vnodeDynamicProps, vnodeDirectives, not (not shouldUseBlock), false, node.loc)
  end
  

end

function resolveComponentType(node, context, ssr)
  if ssr == nil then
    ssr=false
  end
  local  = node
  -- [ts2lua]lua中0和空字符串也是true，此处node.tag == 'component'需要确认
  local isProp = (node.tag == 'component' and {findProp(node, 'is')} or {findDir(node, 'is')})[1]
  if isProp then
    -- [ts2lua]lua中0和空字符串也是true，此处isProp.type == NodeTypes.ATTRIBUTE需要确认
    local exp = (isProp.type == NodeTypes.ATTRIBUTE and {isProp.value and createSimpleExpression(isProp.value.content, true)} or {isProp.exp})[1]
    if exp then
      return createCallExpression(context:helper(RESOLVE_DYNAMIC_COMPONENT), {exp})
    end
  end
  local builtIn = isCoreComponent(tag) or context:isBuiltInComponent(tag)
  if builtIn then
    if not ssr then
      context:helper(builtIn)
    end
    return builtIn
  end
  context:helper(RESOLVE_COMPONENT)
  context.components:add(tag)
  return toValidAssetId(tag, )
end

function buildProps(node, context, props, ssr)
  if props == nil then
    props=node.props
  end
  if ssr == nil then
    ssr=false
  end
  local  = node
  local isComponent = node.tagType == ElementTypes.COMPONENT
  local properties = {}
  local mergeArgs = {}
  local runtimeDirectives = {}
  local patchFlag = 0
  local hasRef = false
  local hasClassBinding = false
  local hasStyleBinding = false
  local hasHydrationEventBinding = false
  local hasDynamicKeys = false
  local dynamicPropNames = {}
  local analyzePatchFlag = function()
    if key.type == NodeTypes.SIMPLE_EXPRESSION and key.isStatic then
      local name = key.content
      if ((not isComponent and isOn(name)) and name:toLowerCase() ~= 'onclick') and name ~= 'onUpdate:modelValue' then
        hasHydrationEventBinding = true
      end
      if value.type == NodeTypes.JS_CACHE_EXPRESSION or (value.type == NodeTypes.SIMPLE_EXPRESSION or value.type == NodeTypes.COMPOUND_EXPRESSION) and getStaticType(value) > 0 then
        return
      end
      if name == 'ref' then
        hasRef = true
      elseif name == 'class' and not isComponent then
        hasClassBinding = true
      elseif name == 'style' and not isComponent then
        hasStyleBinding = true
      elseif name ~= 'key' and not dynamicPropNames:includes(name) then
        table.insert(dynamicPropNames, name)
      end
    else
      hasDynamicKeys = true
    end
  end
  
  local i = 0
  repeat
    repeat
      local prop = props[i+1]
      if prop.type == NodeTypes.ATTRIBUTE then
        local  = prop
        if name == 'ref' then
          hasRef = true
        end
        if name == 'is' and tag == 'component' then
          break
        end
        -- [ts2lua]lua中0和空字符串也是true，此处value需要确认
        -- [ts2lua]lua中0和空字符串也是true，此处value需要确认
        table.insert(properties, createObjectProperty(createSimpleExpression(name, true, getInnerRange(loc, 0, #name)), createSimpleExpression((value and {value.content} or {''})[1], true, (value and {value.loc} or {loc})[1])))
      else
        local  = prop
        local isBind = name == 'bind'
        local isOn = name == 'on'
        if name == 'slot' then
          if not isComponent then
            context:onError(createCompilerError(ErrorCodes.X_V_SLOT_MISPLACED, loc))
          end
          break
        end
        if name == 'once' then
          break
        end
        if name == 'is' or (isBind and tag == 'component') and isBindKey(arg, 'is') then
          break
        end
        if isOn and ssr then
          break
        end
        if not arg and (isBind or isOn) then
          hasDynamicKeys = true
          if exp then
            if #properties then
              table.insert(mergeArgs, createObjectExpression(dedupeProperties(properties), elementLoc))
              properties = {}
            end
            if isBind then
              table.insert(mergeArgs, exp)
            else
              table.insert(mergeArgs, {type=NodeTypes.JS_CALL_EXPRESSION, loc=loc, callee=context:helper(TO_HANDLERS), arguments={exp}})
            end
          else
            -- [ts2lua]lua中0和空字符串也是true，此处isBind需要确认
            context:onError(createCompilerError((isBind and {ErrorCodes.X_V_BIND_NO_EXPRESSION} or {ErrorCodes.X_V_ON_NO_EXPRESSION})[1], loc))
          end
          break
        end
        -- [ts2lua]context.directiveTransforms下标访问可能不正确
        local directiveTransform = context.directiveTransforms[name]
        if directiveTransform then
          local  = directiveTransform(prop, node, context)
          not ssr and props:forEach(analyzePatchFlag)
          table.insert(properties, ...)
          if needRuntime then
            table.insert(runtimeDirectives, prop)
            if isSymbol(needRuntime) then
              directiveImportMap:set(prop, needRuntime)
            end
          end
        else
          table.insert(runtimeDirectives, prop)
        end
      end
    until true
    i=i+1
  until not(i < #props)
  local propsExpression = undefined
  if #mergeArgs then
    if #properties then
      table.insert(mergeArgs, createObjectExpression(dedupeProperties(properties), elementLoc))
    end
    if #mergeArgs > 1 then
      propsExpression = createCallExpression(context:helper(MERGE_PROPS), mergeArgs, elementLoc)
    else
      propsExpression = mergeArgs[0+1]
    end
  elseif #properties then
    propsExpression = createObjectExpression(dedupeProperties(properties), elementLoc)
  end
  if hasDynamicKeys then
    patchFlag = patchFlag | PatchFlags.FULL_PROPS
  else
    if hasClassBinding then
      patchFlag = patchFlag | PatchFlags.CLASS
    end
    if hasStyleBinding then
      patchFlag = patchFlag | PatchFlags.STYLE
    end
    if #dynamicPropNames then
      patchFlag = patchFlag | PatchFlags.PROPS
    end
    if hasHydrationEventBinding then
      patchFlag = patchFlag | PatchFlags.HYDRATE_EVENTS
    end
  end
  if (patchFlag == 0 or patchFlag == PatchFlags.HYDRATE_EVENTS) and (hasRef or #runtimeDirectives > 0) then
    patchFlag = patchFlag | PatchFlags.NEED_PATCH
  end
  return {props=propsExpression, directives=runtimeDirectives, patchFlag=patchFlag, dynamicPropNames=dynamicPropNames}
end

function dedupeProperties(properties)
  local knownProps = Map()
  local deduped = {}
  local i = 0
  repeat
    repeat
      local prop = properties[i+1]
      if prop.key.type == NodeTypes.COMPOUND_EXPRESSION or not prop.key.isStatic then
        table.insert(deduped, prop)
        break
      end
      local name = prop.key.content
      local existing = knownProps:get(name)
      if existing then
        if (name == 'style' or name == 'class') or name:startsWith('on') then
          mergeAsArray(existing, prop)
        end
      else
        knownProps:set(name, prop)
        table.insert(deduped, prop)
      end
    until true
    i=i+1
  until not(i < #properties)
  return deduped
end

function mergeAsArray(existing, incoming)
  if existing.value.type == NodeTypes.JS_ARRAY_EXPRESSION then
    table.insert(existing.value.elements, incoming.value)
  else
    existing.value = createArrayExpression({existing.value, incoming.value}, existing.loc)
  end
end

function buildDirectiveArgs(dir, context)
  local dirArgs = {}
  local runtime = directiveImportMap:get(dir)
  if runtime then
    table.insert(dirArgs, context:helperString(runtime))
  else
    context:helper(RESOLVE_DIRECTIVE)
    context.directives:add(dir.name)
    table.insert(dirArgs, toValidAssetId(dir.name, ))
  end
  local  = dir
  if dir.exp then
    table.insert(dirArgs, dir.exp)
  end
  if dir.arg then
    if not dir.exp then
      table.insert(dirArgs)
    end
    table.insert(dirArgs, dir.arg)
  end
  if #Object:keys(dir.modifiers) then
    if not dir.arg then
      if not dir.exp then
        table.insert(dirArgs)
      end
      table.insert(dirArgs)
    end
    local trueExpression = createSimpleExpression(false, loc)
    table.insert(dirArgs, createObjectExpression(dir.modifiers:map(function(modifier)
      createObjectProperty(modifier, trueExpression)
    end
    ), loc))
  end
  return createArrayExpression(dirArgs, dir.loc)
end

function stringifyDynamicPropNames(props)
  local propsNamesString = nil
  local i = 0
  local l = #props
  repeat
    propsNamesString = propsNamesString + JSON:stringify(props[i+1])
    if i < l - 1 then
      propsNamesString = propsNamesString .. ', '
    end
    i=i+1
  until not(i < l)
  return propsNamesString + 
end
