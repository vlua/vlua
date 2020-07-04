require("vue")
require("server-renderer/src/render")

function ssrRenderTeleport(parentPush, contentRenderFn, target, disabled, parentComponent)
  parentPush('<!--teleport start-->')
  local teleportContent = nil
  if disabled then
    contentRenderFn(parentPush)
    teleportContent = 
  else
    local  = createBuffer()
    contentRenderFn(push)
    push()
    teleportContent = getBuffer()
  end
  -- [ts2lua]parentComponent.appContext.provides下标访问可能不正确
  local context = parentComponent.appContext.provides[ssrContextKey]
  local teleportBuffers = context.__teleportBuffers or (context.__teleportBuffers = {})
  -- [ts2lua]teleportBuffers下标访问可能不正确
  if teleportBuffers[target] then
    -- [ts2lua]teleportBuffers下标访问可能不正确
    table.insert(teleportBuffers[target], teleportContent)
  else
    -- [ts2lua]teleportBuffers下标访问可能不正确
    teleportBuffers[target] = {teleportContent}
  end
  parentPush('<!--teleport end-->')
end
