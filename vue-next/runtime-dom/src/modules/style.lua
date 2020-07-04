require("@vue/shared")
require("@vue/runtime-core")

function patchStyle(el, prev, next)
  local style = el.style
  if not next then
    el:removeAttribute('style')
  elseif isString(next) then
    if prev ~= next then
      style.cssText = next
    end
  else
    for key in pairs(next) do
      -- [ts2lua]next下标访问可能不正确
      setStyle(style, key, next[key])
    end
    if prev and not isString(prev) then
      for key in pairs(prev) do
        -- [ts2lua]next下标访问可能不正确
        if not next[key] then
          setStyle(style, key, '')
        end
      end
    end
  end
end

-- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
local importantRE = /\s*!important$/
function setStyle(style, name, val)
  if name:startsWith('--') then
    style:setProperty(name, val)
  else
    local prefixed = autoPrefix(style, name)
    if importantRE:test(val) then
      style:setProperty(hyphenate(prefixed), val:gsub(importantRE, ''), 'important')
    else
      -- [ts2lua]style下标访问可能不正确
      style[prefixed] = val
    end
  end
end

local prefixes = {'Webkit', 'Moz', 'ms'}
local prefixCache = {}
function autoPrefix(style, rawName)
  -- [ts2lua]prefixCache下标访问可能不正确
  local cached = prefixCache[rawName]
  if cached then
    return cached
  end
  local name = camelize(rawName)
  if name ~= 'filter' and style[name] then
    -- [ts2lua]prefixCache下标访问可能不正确
    return prefixCache[rawName] = name
  end
  name = capitalize(name)
  local i = 0
  repeat
    local prefixed = prefixes[i+1] + name
    if style[prefixed] then
      -- [ts2lua]prefixCache下标访问可能不正确
      return prefixCache[rawName] = prefixed
    end
    i=i+1
  until not(i < #prefixes)
  return rawName
end
