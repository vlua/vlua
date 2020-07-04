require("@vue/reactivity")
require("runtime-core/src/component")
local _computed = computed
-- [ts2lua]请手动处理DeclareFunction


-- [ts2lua]请手动处理DeclareFunction

function computed(getterOrOptions)
  local c = _computed(getterOrOptions)
  recordInstanceBoundEffect(c.effect)
  return c
end
