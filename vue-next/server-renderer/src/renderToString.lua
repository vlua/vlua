require("vue")
require("@vue/shared")

local  = ssrUtils
function unrollBuffer(buffer)
  if buffer.hasAsync then
    local ret = ''
    local i = 0
    repeat
      local item = buffer[i+1]
      if isPromise(item) then
        item = 
      end
      if isString(item) then
        ret = ret + item
      else
        ret = ret + 
      end
      i=i+1
    until not(i < #buffer)
    return ret
  else
    return unrollBufferSync(buffer)
  end
end

function unrollBufferSync(buffer)
  local ret = ''
  local i = 0
  repeat
    local item = buffer[i+1]
    if isString(item) then
      ret = ret + item
    else
      ret = ret + unrollBufferSync(item)
    end
    i=i+1
  until not(i < #buffer)
  return ret
end

function renderToString(input, context)
  if context == nil then
    context={}
  end
  if isVNode(input) then
    return renderToString(createApp({render=function()
      input
    end
    }), context)
  end
  local vnode = createVNode(input._component, input._props)
  vnode.appContext = input._context
  input:provide(ssrContextKey, context)
  local buffer = nil
  return unrollBuffer(buffer)
end

function resolveTeleports(context)
  if context.__teleportBuffers then
    context.teleports = context.teleports or {}
    for key in pairs(context.__teleportBuffers) do
      -- [ts2lua]context.teleports下标访问可能不正确
      context.teleports[key] = 
    end
  end
end
