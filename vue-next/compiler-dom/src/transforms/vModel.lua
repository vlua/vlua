require("@vue/compiler-core")
require("@vue/compiler-core/ElementTypes")
require("@vue/compiler-core/NodeTypes")
require("compiler-dom/src/errors")
require("compiler-dom/src/errors/DOMErrorCodes")
require("compiler-dom/src/runtimeHelpers")
local baseTransform = transformModel

local transformModel = function(dir, node, context)
  local baseResult = baseTransform(dir, node, context)
  if not #baseResult.props or node.tagType == ElementTypes.COMPONENT then
    return baseResult
  end
  if dir.arg then
    context:onError(createDOMCompilerError(DOMErrorCodes.X_V_MODEL_ARG_ON_ELEMENT, dir.arg.loc))
  end
  function checkDuplicatedValue()
    local value = findProp(node, 'value')
    if value then
      context:onError(createDOMCompilerError(DOMErrorCodes.X_V_MODEL_UNNECESSARY_VALUE, value.loc))
    end
  end
  
  local  = node
  if (tag == 'input' or tag == 'textarea') or tag == 'select' then
    local directiveToUse = V_MODEL_TEXT
    local isInvalidType = false
    if tag == 'input' then
      local type = findProp(node, )
      if type then
        if type.type == NodeTypes.DIRECTIVE then
          directiveToUse = V_MODEL_DYNAMIC
        elseif type.value then
          local switch = {
            ['radio'] = function()
              directiveToUse = V_MODEL_RADIO
            end,
            ['checkbox'] = function()
              directiveToUse = V_MODEL_CHECKBOX
            end,
            ['file'] = function()
              isInvalidType = true
              context:onError(createDOMCompilerError(DOMErrorCodes.X_V_MODEL_ON_FILE_INPUT_ELEMENT, dir.loc))
            end,
            ["default"] = function()
              __DEV__ and checkDuplicatedValue()
            end
          }
          local casef = switch[type.value.content]
          if not casef then casef = switch["default"] end
          if casef then casef() end
        end
      elseif hasDynamicKeyVBind(node) then
        directiveToUse = V_MODEL_DYNAMIC
      else
        __DEV__ and checkDuplicatedValue()
      end
    elseif tag == 'select' then
      directiveToUse = V_MODEL_SELECT
    elseif tag == 'textarea' then
      __DEV__ and checkDuplicatedValue()
    end
    if not isInvalidType then
      baseResult.needRuntime = context:helper(directiveToUse)
    end
  else
    context:onError(createDOMCompilerError(DOMErrorCodes.X_V_MODEL_ON_INVALID_ELEMENT, dir.loc))
  end
  baseResult.props = baseResult.props:filter(function(p)
    if p.key.type == NodeTypes.SIMPLE_EXPRESSION and p.key.content == 'modelValue' then
      return false
    end
    return true
  end
  )
  return baseResult
end
