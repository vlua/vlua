require("@vue/shared")

local systemModifiers = {'ctrl', 'shift', 'alt', 'meta'}
local modifierGuards = {stop=function(e)
  e:stopPropagation()
end
, prevent=function(e)
  e:preventDefault()
end
, self=function(e)
  e.target ~= e.currentTarget
end
, ctrl=function(e)
  not e.ctrlKey
end
, shift=function(e)
  not e.shiftKey
end
, alt=function(e)
  not e.altKey
end
, meta=function(e)
  not e.metaKey
end
, left=function(e)
  e['button'] and e.button ~= 0
end
, middle=function(e)
  e['button'] and e.button ~= 1
end
, right=function(e)
  e['button'] and e.button ~= 2
end
, exact=function(e, modifiers)
  systemModifiers:some(function(m)
    -- [ts2lua]e下标访问可能不正确
    e[] and not modifiers:includes(m)
  end
  )
end
}
local withModifiers = function(fn, modifiers)
  return function(event, ...)
    local i = 0
    repeat
      -- [ts2lua]modifierGuards下标访问可能不正确
      local guard = modifierGuards[modifiers[i+1]]
      if guard and guard(event, modifiers) then
        return
      end
      i=i+1
    until not(i < #modifiers)
    return fn(event, ...)
  end
  

end

local keyNames = {esc='escape', space=' ', up='arrow-up', left='arrow-left', right='arrow-right', down='arrow-down', delete='backspace'}
local withKeys = function(fn, modifiers)
  return function(event)
    if not (event['key']) then
      return
    end
    local eventKey = hyphenate(event.key)
    if not modifiers:some(function(k)
      k == eventKey or keyNames[k+1] == eventKey
    end
    ) then
      return
    end
    return fn(event)
  end
  

end
