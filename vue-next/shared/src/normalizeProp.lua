require("stringutil")
require("shared/src")
require("shared/src/domAttrConfig")

function normalizeStyle(value)
  if isArray(value) then
    local res = {}
    local i = 0
    repeat
      local item = value[i+1]
      -- [ts2lua]lua中0和空字符串也是true，此处isString(item)需要确认
      local normalized = normalizeStyle((isString(item) and {parseStringStyle(item)} or {item})[1])
      if normalized then
        for key in pairs(normalized) do
          -- [ts2lua]res下标访问可能不正确
          -- [ts2lua]normalized下标访问可能不正确
          res[key] = normalized[key]
        end
      end
      i=i+1
    until not(i < #value)
    return res
  elseif isObject(value) then
    return value
  end
end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local listDelimiterRE = /;(?![^(]*\))/g
-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local propertyDelimiterRE = /:(.+)/
function parseStringStyle(cssText)
  local ret = {}
  cssText:split(listDelimiterRE):forEach(function(item)
    if item then
      local tmp = item:split(propertyDelimiterRE)
      -- [ts2lua]ret下标访问可能不正确
      #tmp > 1 and (ret[tmp[0+1]:trim()] = tmp[1+1]:trim())
    end
  end
  )
  return ret
end

function stringifyStyle(styles)
  local ret = ''
  if not styles then
    return ret
  end
  for key in pairs(styles) do
    -- [ts2lua]styles下标访问可能不正确
    local value = styles[key]
    -- [ts2lua]lua中0和空字符串也是true，此处key:startsWith()需要确认
    local normalizedKey = (key:startsWith() and {key} or {hyphenate(key)})[1]
    if isString(value) or type(value) == 'number' and isNoUnitNumericStyleProp(normalizedKey) then
      ret = ret + 
    end
  end
  return ret
end

function normalizeClass(value)
  local res = ''
  if isString(value) then
    res = value
  elseif isArray(value) then
    local i = 0
    repeat
      res = res .. normalizeClass(value[i+1]) .. ' '
      i=i+1
    until not(i < #value)
  elseif isObject(value) then
    for name in pairs(value) do
      -- [ts2lua]value下标访问可能不正确
      if value[name] then
        res = res .. name .. ' '
      end
    end
  end
  return res:trim()
end
