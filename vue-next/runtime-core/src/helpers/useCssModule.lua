require("@vue/shared")
require("runtime-core/src/warning")

local useCSSModule = function(name = '$style')
  if name == nil then
    name='$style'
  end
  if not __GLOBAL__ then
    local instance = nil
    if not instance then
      __DEV__ and warn()
      return EMPTY_OBJ
    end
    local modules = instance.type.__cssModules
    if not modules then
      __DEV__ and warn()
      return EMPTY_OBJ
    end
    -- [ts2lua]modules下标访问可能不正确
    local mod = modules[name]
    if not mod then
      __DEV__ and warn()
      return EMPTY_OBJ
    end
    return mod
  else
    if __DEV__ then
      warn()
    end
    return EMPTY_OBJ
  end
end
