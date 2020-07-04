local _computed = require("reactivity.computed").computed
local function computed(getterOrOptions)
  local c = _computed(getterOrOptions)
  -- recordInstanceBoundEffect(c.effect)
  return c
end

return {
  computed = computed
}