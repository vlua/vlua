require("vue")
require("@vue/shared")
require("server-renderer/src/render")
require("stream")

local  = ssrUtils
function unrollBuffer(buffer, stream)
  if buffer.hasAsync then
    local i = 0
    repeat
      local item = buffer[i+1]
      if isPromise(item) then
        item = 
      end
      if isString(item) then
        table.insert(stream, item)
      else
        
      end
      i=i+1
    until not(i < #buffer)
  else
    unrollBufferSync(buffer, stream)
  end
end

function unrollBufferSync(buffer, stream)
  local i = 0
  repeat
    local item = buffer[i+1]
    if isString(item) then
      table.insert(stream, item)
    else
      unrollBufferSync(item, stream)
    end
    i=i+1
  until not(i < #buffer)
end

function renderToStream(input, context)
  if context == nil then
    context={}
  end
  if isVNode(input) then
    return renderToStream(createApp({render=function()
      input
    end
    }), context)
  end
  local vnode = createVNode(input._component, input._props)
  vnode.appContext = input._context
  input:provide(ssrContextKey, context)
  local stream = Readable()
  Promise:resolve(renderComponentVNode(vnode)):tsvar_then(function(buffer)
    unrollBuffer(buffer, stream)
  end
  ):tsvar_then(function()
    table.insert(stream, nil)
  end
  ):catch(function(error)
    stream:destroy(error)
  end
  )
  return stream
end
