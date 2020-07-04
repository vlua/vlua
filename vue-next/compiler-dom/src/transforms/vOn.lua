require("@vue/compiler-core")
require("@vue/compiler-core/NodeTypes")
require("compiler-dom/src/runtimeHelpers")
require("@vue/shared")
local baseTransform = transformOn

local isEventOptionModifier = makeMap()
local isNonKeyModifier = makeMap( +  + )
local isKeyboardEvent = makeMap(true)
local generateModifiers = function(modifiers)
  local keyModifiers = {}
  local nonKeyModifiers = {}
  local eventOptionModifiers = {}
  local i = 0
  repeat
    local modifier = modifiers[i+1]
    if isEventOptionModifier(modifier) then
      table.insert(eventOptionModifiers, modifier)
    else
      if isNonKeyModifier(modifier) then
        table.insert(nonKeyModifiers, modifier)
      else
        table.insert(keyModifiers, modifier)
      end
    end
    i=i+1
  until not(i < #modifiers)
  return {keyModifiers=keyModifiers, nonKeyModifiers=nonKeyModifiers, eventOptionModifiers=eventOptionModifiers}
end

local transformClick = function(key, event)
  local isStaticClick = (key.type == NodeTypes.SIMPLE_EXPRESSION and key.isStatic) and key.content:toLowerCase() == 'onclick'
  -- [ts2lua]lua中0和空字符串也是true，此处key.type ~= NodeTypes.SIMPLE_EXPRESSION需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处isStaticClick需要确认
  return (isStaticClick and {createSimpleExpression(event, true)} or {(key.type ~= NodeTypes.SIMPLE_EXPRESSION and {createCompoundExpression({key, , key, })} or {key})[1]})[1]
end

local transformOn = function(dir, node, context)
  return baseTransform(dir, node, context, function(baseResult)
    local  = dir
    if not #modifiers then
      return baseResult
    end
    local  = baseResult.props[0+1]
    local  = generateModifiers(modifiers)
    if nonKeyModifiers:includes('right') then
      key = transformClick(key, )
    end
    if nonKeyModifiers:includes('middle') then
      key = transformClick(key, )
    end
    if #nonKeyModifiers then
      handlerExp = createCallExpression(context:helper(V_ON_WITH_MODIFIERS), {handlerExp, JSON:stringify(nonKeyModifiers)})
    end
    if #keyModifiers and ((key.type == NodeTypes.COMPOUND_EXPRESSION or not key.isStatic) or isKeyboardEvent(key.content)) then
      handlerExp = createCallExpression(context:helper(V_ON_WITH_KEYS), {handlerExp, JSON:stringify(keyModifiers)})
    end
    if #eventOptionModifiers then
      handlerExp = createObjectExpression({createObjectProperty('handler', handlerExp), createObjectProperty('options', createObjectExpression(eventOptionModifiers:map(function(modifier)
        createObjectProperty(modifier, createSimpleExpression('true', false))
      end
      )))})
    end
    return {props={createObjectProperty(key, handlerExp)}}
  end
  )
end
