require("runtime-dom/src/modules/class")
require("runtime-dom/src/modules/style")
require("runtime-dom/src/modules/attrs")
require("runtime-dom/src/modules/props")
require("runtime-dom/src/modules/events")
require("@vue/shared")
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。

local nativeOnRE = /^on[a-z]/
local forcePatchProp = function(_, key)
  key == 'value'
end

local patchProp = function(el, key, prevValue, nextValue, isSVG = false, prevChildren, parentComponent, parentSuspense, unmountChildren)
  if isSVG == nil then
    isSVG=false
  end
  local switch = {
    ['class'] = function()
      patchClass(el, nextValue, isSVG)
    end,
    ['style'] = function()
      patchStyle(el, prevValue, nextValue)
    end,
    ["default"] = function()
      if isOn(key) then
        if not key:startsWith('onUpdate:') then
          patchEvent(el, key, prevValue, nextValue, parentComponent)
        end
      -- [ts2lua]lua中0和空字符串也是true，此处isSVG需要确认
      elseif (key ~= 'spellcheck' and key ~= 'draggable') and ((isSVG and {key == 'innerHTML' or (el[key] and nativeOnRE:test(key)) and isFunction(nextValue)} or {el[key] and not (nativeOnRE:test(key) and isString(nextValue))})[1]) then
        patchDOMProp(el, key, nextValue, prevChildren, parentComponent, parentSuspense, unmountChildren)
      else
        if key == 'true-value' then
          
          el._trueValue = nextValue
        elseif key == 'false-value' then
          
          el._falseValue = nextValue
        end
        patchAttr(el, key, nextValue, isSVG)
      end
    end
  }
  local casef = switch[key]
  if not casef then casef = switch["default"] end
  if casef then casef() end
end
