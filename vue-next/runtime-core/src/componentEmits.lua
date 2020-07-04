require("@vue/shared")
require("runtime-core/src/errorHandling")
require("runtime-core/src/errorHandling/ErrorCodes")
require("runtime-core/src/warning")
require("runtime-core/src/componentProps")

function emit(instance, event, ...)
  local props = instance.vnode.props or EMPTY_OBJ
  if __DEV__ then
    local options = normalizeEmitsOptions(instance.type.emits)
    if options then
      if not (options[event]) then
        local propsOptions = normalizePropsOptions(instance.type)[0+1]
        if not propsOptions or not (propsOptions[ + capitalize(event)]) then
          warn( + )
        end
      else
        -- [ts2lua]options下标访问可能不正确
        local validator = options[event]
        if isFunction(validator) then
          local isValid = validator(...)
          if not isValid then
            warn()
          end
        end
      end
    end
  end
  -- [ts2lua]props下标访问可能不正确
  local handler = props[]
  if not handler and event:startsWith('update:') then
    event = hyphenate(event)
    -- [ts2lua]props下标访问可能不正确
    handler = props[]
  end
  if handler then
    callWithAsyncErrorHandling(handler, instance, ErrorCodes.COMPONENT_EVENT_HANDLER, args)
  end
end

function normalizeEmitsOptions(options)
  if not options then
    return
  elseif isArray(options) then
    if options._n then
      return options._n
    end
    local normalized = {}
    options:forEach(function(key)
      -- [ts2lua]normalized下标访问可能不正确
      normalized[key] = nil
    end
    )
    def(options, '_n', normalized)
    return normalized
  else
    return options
  end
end

function isEmitListener(emits, key)
  return isOn(key) and (hasOwn(emits, key[2+1]:toLowerCase() + key:slice(3)) or hasOwn(emits, key:slice(2)))
end
