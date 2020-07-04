require("@vue/shared")

local shouldIgnoreProp = makeMap()
function ssrRenderAttrs(props, tag)
  local ret = ''
  for key in pairs(props) do
    if (shouldIgnoreProp(key) or isOn(key)) or tag == 'textarea' and key == 'value' then
      break
    end
    -- [ts2lua]props下标访问可能不正确
    local value = props[key]
    if key == 'class' then
      ret = ret + 
    elseif key == 'style' then
      ret = ret + 
    else
      ret = ret + ssrRenderDynamicAttr(key, value, tag)
    end
  end
  return ret
end

function ssrRenderDynamicAttr(key, value, tag)
  if not isRenderableValue(value) then
    return 
  end
  -- [ts2lua]propsToAttrMap下标访问可能不正确
  -- [ts2lua]lua中0和空字符串也是true，此处tag and tag:find('-') > 0需要确认
  local attrKey = (tag and tag:find('-') > 0 and {key} or {propsToAttrMap[key] or key:toLowerCase()})[1]
  if isBooleanAttr(attrKey) then
    -- [ts2lua]lua中0和空字符串也是true，此处value == false需要确认
    return (value == false and {} or {})[1]
  elseif isSSRSafeAttrName(attrKey) then
    -- [ts2lua]lua中0和空字符串也是true，此处value == ''需要确认
    return (value == '' and {} or {})[1]
  else
    console:warn()
    return 
  end
end

function ssrRenderAttr(key, value)
  if not isRenderableValue(value) then
    return 
  end
  return 
end

function isRenderableValue(value)
  if value == nil then
    return false
  end
  local type = type(value)
  return (type == 'string' or type == 'number') or type == 'boolean'
end

function ssrRenderClass(raw)
  return escapeHtml(normalizeClass(raw))
end

function ssrRenderStyle(raw)
  if not raw then
    return ''
  end
  if isString(raw) then
    return escapeHtml(raw)
  end
  local styles = normalizeStyle(raw)
  return escapeHtml(stringifyStyle(styles))
end
