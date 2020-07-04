require("shared/src/index")

local toDisplayString = function(val)
  -- [ts2lua]lua中0和空字符串也是true，此处isObject(val)需要确认
  -- [ts2lua]lua中0和空字符串也是true，此处val == nil需要确认
  return (val == nil and {''} or {(isObject(val) and {JSON:stringify(val, replacer, 2)} or {String(val)})[1]})[1]
end

local replacer = function(_key, val)
  if val:instanceof(Map) then
    return {=({...}):reduce(function(entries, )
      
      -- [ts2lua]entries下标访问可能不正确
      entries[] = val
      return entries
    end
    , {})}
  elseif val:instanceof(Set) then
    return {={...}}
  elseif (isObject(val) and not isArray(val)) and not isPlainObject(val) then
    return String(val)
  end
  return val
end
