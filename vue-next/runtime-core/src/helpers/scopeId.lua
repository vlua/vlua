require("runtime-core/src/helpers/withRenderContext")

local currentScopeId = nil
local scopeIdStack = {}
function pushScopeId(id)
  currentScopeId = id
  table.insert(scopeIdStack, currentScopeId)
end

function popScopeId()
  scopeIdStack:pop()
  -- [ts2lua]scopeIdStack下标访问可能不正确
  currentScopeId = scopeIdStack[#scopeIdStack - 1] or nil
end

function withScopeId(id)
  return function(fn)
    withCtx(function(this)
      pushScopeId(id)
      local res = fn:apply(self, arguments)
      popScopeId()
      return res
    end
    )
  end
  

end
