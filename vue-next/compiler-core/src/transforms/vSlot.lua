require("tableutil")
require("compiler-core/src/ast")
require("compiler-core/src/ast/NodeTypes")
require("compiler-core/src/ast/ElementTypes")
require("compiler-core/src/errors")
require("compiler-core/src/errors/ErrorCodes")
require("compiler-core/src/utils")
require("compiler-core/src/runtimeHelpers")
require("compiler-core/src/transforms/vFor")

local isStaticExp = function(p)
  p.type == NodeTypes.SIMPLE_EXPRESSION and p.isStatic
end

local defaultFallback = createSimpleExpression(false)
local trackSlotScopes = function(node, context)
  if node.type == NodeTypes.ELEMENT and (node.tagType == ElementTypes.COMPONENT or node.tagType == ElementTypes.TEMPLATE) then
    local vSlot = findDir(node, 'slot')
    if vSlot then
      local slotProps = vSlot.exp
      if not __BROWSER__ and context.prefixIdentifiers then
        slotProps and context:addIdentifiers(slotProps)
      end
      context.scopes.vSlot=context.scopes.vSlot+1
      return function()
        if not __BROWSER__ and context.prefixIdentifiers then
          slotProps and context:removeIdentifiers(slotProps)
        end
        context.scopes.vSlot=context.scopes.vSlot-1
      end
      
    
    end
  end
end

local trackVForSlotScopes = function(node, context)
  local vFor = nil
  if (isTemplateNode(node) and node.props:some(isVSlot)) and (vFor = findDir(node, 'for')) then
    vFor.parseResult = parseForExpression(vFor.exp, context)
    local result = vFor.parseResult
    if result then
      local  = result
      local  = context
      value and addIdentifiers(value)
      key and addIdentifiers(key)
      index and addIdentifiers(index)
      return function()
        value and removeIdentifiers(value)
        key and removeIdentifiers(key)
        index and removeIdentifiers(index)
      end
      
    
    end
  end
end

local buildClientSlotFn = function(props, children, loc)
  -- [ts2lua]lua中0和空字符串也是true，此处#children需要确认
  createFunctionExpression(props, children, false, true, (#children and {children[0+1].loc} or {loc})[1])
end

function buildSlots(node, context, buildSlotFn)
  if buildSlotFn == nil then
    buildSlotFn=buildClientSlotFn
  end
  context:helper(WITH_CTX)
  local  = node
  local slotsProperties = {}
  local dynamicSlots = {}
  local buildDefaultSlotProperty = function(props, children)
    createObjectProperty(buildSlotFn(props, children, loc))
  end
  
  local hasDynamicSlots = context.scopes.vSlot > 0 or context.scopes.vFor > 0
  if not __BROWSER__ and context.prefixIdentifiers then
    hasDynamicSlots = hasScopeRef(node, context.identifiers)
  end
  local onComponentSlot = findDir(node, 'slot', true)
  if onComponentSlot then
    local  = onComponentSlot
    table.insert(slotsProperties, createObjectProperty(arg or createSimpleExpression('default', true), buildSlotFn(exp, children, loc)))
  end
  local hasTemplateSlots = false
  local hasNamedDefaultSlot = false
  local implicitDefaultChildren = {}
  local seenSlotNames = Set()
  local i = 0
  repeat
    repeat
      local slotElement = children[i+1]
      local slotDir = nil
      if not isTemplateNode(slotElement) or not (slotDir = findDir(slotElement, 'slot', true)) then
        if slotElement.type ~= NodeTypes.COMMENT then
          table.insert(implicitDefaultChildren, slotElement)
        end
        break
      end
      if onComponentSlot then
        context:onError(createCompilerError(ErrorCodes.X_V_SLOT_MIXED_SLOT_USAGE, slotDir.loc))
        break
      end
      hasTemplateSlots = true
      local  = slotElement
      local  = slotDir
      local staticSlotName = nil
      if isStaticExp(slotName) then
        -- [ts2lua]lua中0和空字符串也是true，此处slotName需要确认
        staticSlotName = (slotName and {slotName.content} or {})[1]
      else
        hasDynamicSlots = true
      end
      local slotFunction = buildSlotFn(slotProps, slotChildren, slotLoc)
      local vIf = nil
      local vElse = nil
      local vFor = nil
      if vIf = findDir(slotElement, 'if') then
        hasDynamicSlots = true
        table.insert(dynamicSlots, createConditionalExpression(buildDynamicSlot(slotName, slotFunction), defaultFallback))
      -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
      elseif vElse = findDir(slotElement, /^else(-if)?$/, true) then
        local j = i
        local prev = nil
        while(j=j-1)
        do
        prev = children[j+1]
        if prev.type ~= NodeTypes.COMMENT then
          break
        end
        end
        if (prev and isTemplateNode(prev)) and findDir(prev, 'if') then
          children:splice(i, 1)
          i=i-1
          __TEST__ and assert(#dynamicSlots > 0)
          -- [ts2lua]dynamicSlots下标访问可能不正确
          local conditional = dynamicSlots[#dynamicSlots - 1]
          while(conditional.alternate.type == NodeTypes.JS_CONDITIONAL_EXPRESSION)
          do
          conditional = conditional.alternate
          end
          -- [ts2lua]lua中0和空字符串也是true，此处vElse.exp需要确认
          conditional.alternate = (vElse.exp and {createConditionalExpression(vElse.exp, buildDynamicSlot(slotName, slotFunction), defaultFallback)} or {buildDynamicSlot(slotName, slotFunction)})[1]
        else
          context:onError(createCompilerError(ErrorCodes.X_V_ELSE_NO_ADJACENT_IF, vElse.loc))
        end
      elseif vFor = findDir(slotElement, 'for') then
        hasDynamicSlots = true
        local parseResult = vFor.parseResult or parseForExpression(vFor.exp, context)
        if parseResult then
          table.insert(dynamicSlots, createCallExpression(context:helper(RENDER_LIST), {parseResult.source, createFunctionExpression(createForLoopParams(parseResult), buildDynamicSlot(slotName, slotFunction), true)}))
        else
          context:onError(createCompilerError(ErrorCodes.X_V_FOR_MALFORMED_EXPRESSION, vFor.loc))
        end
      else
        if staticSlotName then
          if seenSlotNames:has(staticSlotName) then
            context:onError(createCompilerError(ErrorCodes.X_V_SLOT_DUPLICATE_SLOT_NAMES, dirLoc))
            break
          end
          seenSlotNames:add(staticSlotName)
          if staticSlotName == 'default' then
            hasNamedDefaultSlot = true
          end
        end
        table.insert(slotsProperties, createObjectProperty(slotName, slotFunction))
      end
    until true
    i=i+1
  until not(i < #children)
  if not onComponentSlot then
    if not hasTemplateSlots then
      table.insert(slotsProperties, buildDefaultSlotProperty(undefined, children))
    elseif #implicitDefaultChildren then
      if hasNamedDefaultSlot then
        context:onError(createCompilerError(ErrorCodes.X_V_SLOT_EXTRANEOUS_DEFAULT_SLOT_CHILDREN, implicitDefaultChildren[0+1].loc))
      else
        table.insert(slotsProperties, buildDefaultSlotProperty(undefined, implicitDefaultChildren))
      end
    end
  end
  local slots = createObjectExpression(table.merge(slotsProperties, createObjectProperty(createSimpleExpression(false))), loc)
  if #dynamicSlots then
    slots = createCallExpression(context:helper(CREATE_SLOTS), {slots, createArrayExpression(dynamicSlots)})
  end
  return {slots=slots, hasDynamicSlots=hasDynamicSlots}
end

function buildDynamicSlot(name, fn)
  return createObjectExpression({createObjectProperty(name), createObjectProperty(fn)})
end
