require("@vue/shared")

function triggerEvent(el, event, payload)
  if payload == nil then
    payload={}
  end
  local  = el
  if eventListeners then
    -- [ts2lua]eventListeners下标访问可能不正确
    local listener = eventListeners[event]
    if listener then
      if isArray(listener) then
        local i = 0
        repeat
          listener[i+1](...)
          i=i+1
        until not(i < #listener)
      else
        listener(...)
      end
    end
  end
end
