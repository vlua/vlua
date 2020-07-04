require("@vue/shared")
require("@vue/runtime-core")
require("packages/runtime-core/src/errorHandling/ErrorCodes")

local _getNow = Date.now
if type(document) ~= 'undefined' and _getNow() > document:createEvent('Event').timeStamp then
  _getNow = function()
    performance:now()
  end
  

end
local cachedNow = 0
local p = Promise:resolve()
local reset = function()
  cachedNow = 0
end

local getNow = function()
  cachedNow or (p:tsvar_then(reset); cachedNow = _getNow())
end

function addEventListener(el, event, handler, options)
  el:addEventListener(event, handler, options)
end

function removeEventListener(el, event, handler, options)
  el:removeEventListener(event, handler, options)
end

function patchEvent(el, rawName, prevValue, nextValue, instance)
  if instance == nil then
    instance=nil
  end
  local name = rawName:slice(2):toLowerCase()
  local prevOptions = (prevValue and prevValue['options']) and prevValue.options
  local nextOptions = (nextValue and nextValue['options']) and nextValue.options
  local invoker = prevValue and prevValue.invoker
  -- [ts2lua]lua中0和空字符串也是true，此处nextValue and nextValue['handler']需要确认
  local value = (nextValue and nextValue['handler'] and {nextValue.handler} or {nextValue})[1]
  if prevOptions or nextOptions then
    local prev = prevOptions or EMPTY_OBJ
    local next = nextOptions or EMPTY_OBJ
    if (prev.capture ~= next.capture or prev.passive ~= next.passive) or prev.once ~= next.once then
      if invoker then
        removeEventListener(el, name, invoker, prev)
      end
      if nextValue and value then
        local invoker = createInvoker(value, instance)
        nextValue.invoker = invoker
        addEventListener(el, name, invoker, next)
      end
      return
    end
  end
  if nextValue and value then
    if invoker then
      
      prevValue.invoker = nil
      invoker.value = value
      nextValue.invoker = invoker
      invoker.lastUpdated = getNow()
    else
      addEventListener(el, name, createInvoker(value, instance), nextOptions or undefined)
    end
  elseif invoker then
    removeEventListener(el, name, invoker, prevOptions or undefined)
  end
end

function createInvoker(initialValue, instance)
  local invoker = function(e)
    local timeStamp = e.timeStamp or _getNow()
    if timeStamp >= invoker.lastUpdated - 1 then
      callWithAsyncErrorHandling(patchStopImmediatePropagation(e, invoker.value), instance, ErrorCodes.NATIVE_EVENT_HANDLER, {e})
    end
  end
  
  invoker.value = initialValue
  initialValue.invoker = invoker
  invoker.lastUpdated = getNow()
  return invoker
end

function patchStopImmediatePropagation(e, value)
  if isArray(value) then
    local originalStop = e.stopImmediatePropagation
    e.stopImmediatePropagation = function()
      originalStop:call(e)
      e._stopped = true
    end
    
    return value:map(function(fn)
      function(e)
        not e._stopped and fn(e)
      end
      
    
    end
    )
  else
    return value
  end
end
