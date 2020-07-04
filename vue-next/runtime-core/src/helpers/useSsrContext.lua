require("runtime-core/src/apiInject")
require("runtime-core/src/warning")
-- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认

local ssrContextKey = Symbol((__DEV__ and {} or {})[1])
local useSSRContext = function()
  if not __GLOBAL__ then
    local ctx = inject(ssrContextKey)
    if not ctx then
      warn( + )
    end
    return ctx
  elseif __DEV__ then
    warn()
  end
end
