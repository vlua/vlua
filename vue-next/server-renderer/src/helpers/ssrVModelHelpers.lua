require("@vue/shared")
require("server-renderer/src/helpers/ssrRenderAttrs")

local ssrLooseEqual = looseEqual
function ssrLooseContain(arr, value)
  return looseIndexOf(arr, value) > -1
end

function ssrRenderDynamicModel(type, model, value)
  local switch = {
    ['radio'] = function()
      -- [ts2lua]lua中0和空字符串也是true，此处looseEqual(model, value)需要确认
      return (looseEqual(model, value) and {' checked'} or {''})[1]
    end,
    ['checkbox'] = function()
      -- [ts2lua]lua中0和空字符串也是true，此处Array:isArray(model)需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处(Array:isArray(model) and {ssrLooseContain(model, value)} or {model})[1]需要确认
      return ((Array:isArray(model) and {ssrLooseContain(model, value)} or {model})[1] and {' checked'} or {''})[1]
    end,
    ["default"] = function()
      return ssrRenderAttr('value', model)
    end
  }
  local casef = switch[type]
  if not casef then casef = switch["default"] end
  if casef then casef() end
end

function ssrGetDynamicModelProps(existingProps, model)
  if existingProps == nil then
    existingProps={}
  end
  local  = existingProps
  local switch = {
    ['radio'] = function()
      -- [ts2lua]lua中0和空字符串也是true，此处looseEqual(model, value)需要确认
      return (looseEqual(model, value) and {{checked=true}} or {nil})[1]
    end,
    ['checkbox'] = function()
      -- [ts2lua]lua中0和空字符串也是true，此处Array:isArray(model)需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处(Array:isArray(model) and {ssrLooseContain(model, value)} or {model})[1]需要确认
      return ((Array:isArray(model) and {ssrLooseContain(model, value)} or {model})[1] and {{checked=true}} or {nil})[1]
    end,
    ["default"] = function()
      return {value=model}
    end
  }
  local casef = switch[type]
  if not casef then casef = switch["default"] end
  if casef then casef() end
end
