require("runtime-core/src/componentRenderUtils")

function withCtx(fn, ctx)
  if ctx == nil then
    ctx=currentRenderingInstance
  end
  if not ctx then
    return fn
  end
  return function renderFnWithContext()
    local owner = currentRenderingInstance
    setCurrentRenderingInstance(ctx)
    local res = fn:apply(nil, arguments)
    setCurrentRenderingInstance(owner)
    return res
  end
  

end
