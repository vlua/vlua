require("runtime-core/src/componentRenderUtils")
require("runtime-core/src/component")
require("@vue/shared")
require("runtime-core/src/warning")

local COMPONENTS = 'components'
local DIRECTIVES = 'directives'
function resolveComponent(name)
  return resolveAsset(COMPONENTS, name) or name
end

local NULL_DYNAMIC_COMPONENT = Symbol()
function resolveDynamicComponent(component)
  if isString(component) then
    return resolveAsset(COMPONENTS, component, false) or component
  else
    return component or NULL_DYNAMIC_COMPONENT
  end
end

function resolveDirective(name)
  return resolveAsset(DIRECTIVES, name)
end

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

function resolveAsset(type, name, warnMissing)
  if warnMissing == nil then
    warnMissing=true
  end
  local instance = currentRenderingInstance or currentInstance
  if instance then
    local camelized = nil
    local capitalized = nil
    -- [ts2lua]instance下标访问可能不正确
    local registry = instance[type]
    -- [ts2lua]registry下标访问可能不正确
    -- [ts2lua]registry下标访问可能不正确
    -- [ts2lua]registry下标访问可能不正确
    local res = (registry[name] or registry[camelized = camelize(name)]) or registry[capitalized = capitalize(camelized)]
    if not res and type == COMPONENTS then
      local self = instance.type
      local selfName = self.displayName or self.name
      if selfName and ((selfName == name or selfName == camelized) or selfName == capitalized) then
        res = self
      end
    end
    if (__DEV__ and warnMissing) and not res then
      warn()
    end
    return res
  elseif __DEV__ then
    warn( + )
  end
end
