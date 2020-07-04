require("runtime-core/src/component")
require("runtime-core/src/componentRenderUtils")
require("runtime-core/src/warning")

function provide(key, value)
  if not currentInstance then
    if __DEV__ then
      warn()
    end
  else
    local provides = currentInstance.provides
    local parentProvides = currentInstance.parent and currentInstance.parent.provides
    if parentProvides == provides then
      currentInstance.provides = Object:create(parentProvides)
      provides = currentInstance.provides
    end
    -- [ts2lua]provides下标访问可能不正确
    provides[key] = value
  end
end

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

function inject(key, defaultValue)
  local instance = currentInstance or currentRenderingInstance
  if instance then
    local provides = instance.provides
    if provides[key] then
      -- [ts2lua]provides下标访问可能不正确
      return provides[key]
    elseif #arguments > 1 then
      return defaultValue
    elseif __DEV__ then
      warn()
    end
  elseif __DEV__ then
    warn()
  end
end
