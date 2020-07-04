require("server-renderer/src/render")

function ssrRenderSlot(slots, slotName, slotProps, fallbackRenderFn, push, parentComponent)
  push()
  -- [ts2lua]slots下标访问可能不正确
  local slotFn = slots[slotName]
  if slotFn then
    local scopeId = parentComponent and parentComponent.type.__scopeId
    -- [ts2lua]lua中0和空字符串也是true，此处scopeId需要确认
    local ret = slotFn(slotProps, push, parentComponent, (scopeId and {} or {})[1])
    if Array:isArray(ret) then
      renderVNodeChildren(push, ret, parentComponent)
    end
  elseif fallbackRenderFn then
    fallbackRenderFn()
  end
  push()
end
