require("@vue/shared")
-- [ts2lua]请手动处理DeclareFunction


-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

function renderList(source, renderItem)
  local ret = nil
  if isArray(source) or isString(source) then
    ret = {}
    local i = 0
    local l = #source
    repeat
      ret[i+1] = renderItem(source[i+1], i)
      i=i+1
    until not(i < l)
  elseif type(source) == 'number' then
    ret = {}
    local i = 0
    repeat
      ret[i+1] = renderItem(i + 1, i)
      i=i+1
    until not(i < source)
  elseif isObject(source) then
    -- [ts2lua]source下标访问可能不正确
    if source[Symbol.iterator] then
      ret = Array:from(source, renderItem)
    else
      local keys = Object:keys(source)
      ret = {}
      local i = 0
      local l = #keys
      repeat
        local key = keys[i+1]
        -- [ts2lua]source下标访问可能不正确
        ret[i+1] = renderItem(source[key], key, i)
        i=i+1
      until not(i < l)
    end
  else
    ret = {}
  end
  return ret
end
