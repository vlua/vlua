require("@vue/shared")

function ssrRenderList(source, renderItem)
  if isArray(source) or isString(source) then
    local i = 0
    local l = #source
    repeat
      renderItem(source[i+1], i)
      i=i+1
    until not(i < l)
  elseif type(source) == 'number' then
    local i = 0
    repeat
      renderItem(i + 1, i)
      i=i+1
    until not(i < source)
  elseif isObject(source) then
    -- [ts2lua]source下标访问可能不正确
    if source[Symbol.iterator] then
      local arr = Array:from(source)
      local i = 0
      local l = #arr
      repeat
        renderItem(arr[i+1], i)
        i=i+1
      until not(i < l)
    else
      local keys = Object:keys(source)
      local i = 0
      local l = #keys
      repeat
        local key = keys[i+1]
        -- [ts2lua]source下标访问可能不正确
        renderItem(source[key], key, i)
        i=i+1
      until not(i < l)
    end
  end
end
