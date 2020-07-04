require("stringutil")
require("tableutil")
require("@vue/runtime-core")
require("runtime-dom/src/modules/events")
require("@vue/shared")

local getModelAssigner = function(vnode)
  -- [ts2lua]()下标访问可能不正确
  local fn = ()['onUpdate:modelValue']
  return (isArray(fn) and {function(value)
    invokeArrayFns(fn, value)
  end
  -- [ts2lua]lua中0和空字符串也是true，此处isArray(fn)需要确认
  } or {fn})[1]
end

function onCompositionStart(e)
  
  e.target.composing = true
end

function onCompositionEnd(e)
  local target = e.target
  if target.composing then
    target.composing = false
    trigger(target, 'input')
  end
end

function trigger(el, type)
  local e = document:createEvent('HTMLEvents')
  e:initEvent(type, true, true)
  el:dispatchEvent(e)
end

local vModelText = {beforeMount=function(el, , vnode)
  el.value = value
  el._assign = getModelAssigner(vnode)
  local castToNumber = number or el.type == 'number'
  -- [ts2lua]lua中0和空字符串也是true，此处lazy需要确认
  addEventListener(el, (lazy and {'change'} or {'input'})[1], function(e)
    if e.target.composing then
      return
    end
    local domValue = el.value
    if trim then
      domValue = domValue:trim()
    elseif castToNumber then
      domValue = toNumber(domValue)
    end
    el:_assign(domValue)
  end
  )
  if trim then
    addEventListener(el, 'change', function()
      el.value = el.value:trim()
    end
    )
  end
  if not lazy then
    addEventListener(el, 'compositionstart', onCompositionStart)
    addEventListener(el, 'compositionend', onCompositionEnd)
    addEventListener(el, 'change', onCompositionEnd)
  end
end
, beforeUpdate=function(el, , vnode)
  el._assign = getModelAssigner(vnode)
  if document.activeElement == el then
    if trim and el.value:trim() == value then
      return
    end
    if (number or el.type == 'number') and toNumber(el.value) == value then
      return
    end
  end
  el.value = value
end
}
local vModelCheckbox = {beforeMount=function(el, binding, vnode)
  setChecked(el, binding, vnode)
  el._assign = getModelAssigner(vnode)
  addEventListener(el, 'change', function()
    local modelValue = el._modelValue
    local elementValue = getValue(el)
    local checked = el.checked
    local assign = el._assign
    if isArray(modelValue) then
      local index = looseIndexOf(modelValue, elementValue)
      local found = index ~= -1
      if checked and not found then
        assign(table.merge(modelValue, elementValue))
      elseif not checked and found then
        local filtered = {...}
        filtered:splice(index, 1)
        assign(filtered)
      end
    else
      assign(getCheckboxValue(el, checked))
    end
  end
  )
end
, beforeUpdate=function(el, binding, vnode)
  el._assign = getModelAssigner(vnode)
  setChecked(el, binding, vnode)
end
}
function setChecked(el, , vnode)
  
  el._modelValue = value
  if isArray(value) then
    el.checked = looseIndexOf(value, ().value) > -1
  elseif value ~= oldValue then
    el.checked = looseEqual(value, getCheckboxValue(el, true))
  end
end

local vModelRadio = {beforeMount=function(el, , vnode)
  el.checked = looseEqual(value, ().value)
  el._assign = getModelAssigner(vnode)
  addEventListener(el, 'change', function()
    el:_assign(getValue(el))
  end
  )
end
, beforeUpdate=function(el, , vnode)
  el._assign = getModelAssigner(vnode)
  if value ~= oldValue then
    el.checked = looseEqual(value, ().value)
  end
end
}
local vModelSelect = {mounted=function(el, , vnode)
  setSelected(el, value)
  el._assign = getModelAssigner(vnode)
  addEventListener(el, 'change', function()
    local selectedVal = Array.prototype.filter:call(el.options, function(o)
      o.selected
    end
    ):map(getValue)
    -- [ts2lua]lua中0和空字符串也是true，此处el.multiple需要确认
    el:_assign((el.multiple and {selectedVal} or {selectedVal[0+1]})[1])
  end
  )
end
, beforeUpdate=function(el, _binding, vnode)
  el._assign = getModelAssigner(vnode)
end
, updated=function(el, )
  setSelected(el, value)
end
}
function setSelected(el, value)
  local isMultiple = el.multiple
  if isMultiple and not isArray(value) then
    __DEV__ and warn( + )
    return
  end
  local i = 0
  local l = #el.options
  repeat
    local option = el.options[i+1]
    local optionValue = getValue(option)
    if isMultiple then
      option.selected = looseIndexOf(value, optionValue) > -1
    else
      if looseEqual(getValue(option), value) then
        el.selectedIndex = i
        return
      end
    end
    i=i+1
  until not(i < l)
  if not isMultiple then
    el.selectedIndex = -1
  end
end

function getValue(el)
  -- [ts2lua]lua中0和空字符串也是true，此处el['_value']需要确认
  return (el['_value'] and {el._value} or {el.value})[1]
end

function getCheckboxValue(el, checked)
  -- [ts2lua]lua中0和空字符串也是true，此处checked需要确认
  local key = (checked and {'_trueValue'} or {'_falseValue'})[1]
  -- [ts2lua]el下标访问可能不正确
  -- [ts2lua]lua中0和空字符串也是true，此处el[key]需要确认
  return (el[key] and {el[key]} or {checked})[1]
end

local vModelDynamic = {beforeMount=function(el, binding, vnode)
  callModelHook(el, binding, vnode, nil, 'beforeMount')
end
, mounted=function(el, binding, vnode)
  callModelHook(el, binding, vnode, nil, 'mounted')
end
, beforeUpdate=function(el, binding, vnode, prevVNode)
  callModelHook(el, binding, vnode, prevVNode, 'beforeUpdate')
end
, updated=function(el, binding, vnode, prevVNode)
  callModelHook(el, binding, vnode, prevVNode, 'updated')
end
}
function callModelHook(el, binding, vnode, prevVNode, hook)
  local modelToUse = nil
  local switch = {
    ['SELECT'] = function()
      modelToUse = vModelSelect
    end,
    ['TEXTAREA'] = function()
      modelToUse = vModelText
    end,
    ["default"] = function()
      local switch = {
        ['checkbox'] = function()
          modelToUse = vModelCheckbox
        end,
        ['radio'] = function()
          modelToUse = vModelRadio
        end,
        ["default"] = function()
          modelToUse = vModelText
        end
      }
      local casef = switch[el.type]
      if not casef then casef = switch["default"] end
      if casef then casef() end
    end
  }
  local casef = switch[el.tagName]
  if not casef then casef = switch["default"] end
  if casef then casef() end
  -- [ts2lua]modelToUse下标访问可能不正确
  local fn = modelToUse[hook]
  fn and fn(el, binding, vnode, prevVNode)
end

if __NODE_JS__ then
  vModelText.getSSRProps = function()
    {value=value}
  end
  
  vModelRadio.getSSRProps = function(, vnode)
    if vnode.props and looseEqual(vnode.props.value, value) then
      return {checked=true}
    end
  end
  
  vModelCheckbox.getSSRProps = function(, vnode)
    if isArray(value) then
      if vnode.props and looseIndexOf(value, vnode.props.value) > -1 then
        return {checked=true}
      end
    elseif value then
      return {checked=true}
    end
  end
  

end