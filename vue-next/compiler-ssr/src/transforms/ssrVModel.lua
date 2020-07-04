require("@vue/compiler-dom/ElementTypes")
require("@vue/compiler-dom")
require("@vue/compiler-dom/NodeTypes")
require("@vue/compiler-dom/DOMErrorCodes")
require("compiler-ssr/src/runtimeHelpers")

local ssrTransformModel = function(dir, node, context)
  local model = nil
  function checkDuplicatedValue()
    local value = findProp(node, 'value')
    if value then
      context:onError(createDOMCompilerError(DOMErrorCodes.X_V_MODEL_UNNECESSARY_VALUE, value.loc))
    end
  end
  
  if node.tagType == ElementTypes.ELEMENT then
    local res = {props={}}
    local defaultProps = {createObjectProperty(model)}
    if node.tag == 'input' then
      local type = findProp(node, 'type')
      if type then
        local value = findValueBinding(node)
        if type.type == NodeTypes.DIRECTIVE then
          res.ssrTagParts = {createCallExpression(context:helper(SSR_RENDER_DYNAMIC_MODEL), {model, value})}
        elseif type.value then
          local switch = {
            ['radio'] = function()
              res.props = {createObjectProperty(createCallExpression(context:helper(SSR_LOOSE_EQUAL), {model, value}))}
            end,
            ['checkbox'] = function()
              res.props = {createObjectProperty(createConditionalExpression(createCallExpression({model}), createCallExpression(context:helper(SSR_LOOSE_CONTAIN), {model, value}), model))}
            end,
            ['file'] = function()
              context:onError(createDOMCompilerError(DOMErrorCodes.X_V_MODEL_ON_FILE_INPUT_ELEMENT, dir.loc))
            end,
            ["default"] = function()
              checkDuplicatedValue()
              res.props = defaultProps
            end
          }
          local casef = switch[type.value.content]
          if not casef then casef = switch["default"] end
          if casef then casef() end
        end
      elseif hasDynamicKeyVBind(node) then
        
      else
        checkDuplicatedValue()
        res.props = defaultProps
      end
    elseif node.tag == 'textarea' then
      checkDuplicatedValue()
      node.children = {createInterpolation(model, model.loc)}
    elseif node.tag == 'select' then
      
    else
      context:onError(createDOMCompilerError(DOMErrorCodes.X_V_MODEL_ON_INVALID_ELEMENT, dir.loc))
    end
    return res
  else
    return transformModel(dir, node, context)
  end
end

function findValueBinding(node)
  local valueBinding = findProp(node, 'value')
  -- [ts2lua]lua中0和空字符串也是true，此处valueBinding.type == NodeTypes.DIRECTIVE需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处valueBinding需要确认
  return (valueBinding and {(valueBinding.type == NodeTypes.DIRECTIVE and {} or {createSimpleExpression(().content, true)})[1]} or {createSimpleExpression(false)})[1]
end
