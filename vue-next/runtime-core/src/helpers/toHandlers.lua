require("@vue/shared")
require("runtime-core/src/warning")

function toHandlers(obj)
  local ret = {}
  if __DEV__ and not isObject(obj) then
    warn()
    return ret
  end
  for key in pairs(obj) do
    -- [ts2lua]ret下标访问可能不正确
    -- [ts2lua]obj下标访问可能不正确
    ret[] = obj[key]
  end
  return ret
end
