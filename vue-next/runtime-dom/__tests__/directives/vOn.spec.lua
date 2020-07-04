require("runtime-dom/src/modules/events")
require("@vue/runtime-dom")

function triggerEvent(target, event, process)
  local e = document:createEvent('HTMLEvents')
  e:initEvent(event, true, true)
  if event == 'click' then
    
    e.button = 0
  end
  if process then
    process(e)
  end
  target:dispatchEvent(e)
  return e
end

describe('runtime-dom: v-on directive', function()
  test('it should support "stop" and "prevent"', function()
    local parent = document:createElement('div')
    local child = document:createElement('input')
    parent:appendChild(child)
    local childNextValue = withModifiers(jest:fn(), {'prevent', 'stop'})
    patchEvent(child, 'onClick', nil, childNextValue, nil)
    local parentNextValue = jest:fn()
    patchEvent(parent, 'onClick', nil, parentNextValue, nil)
    expect(triggerEvent(child, 'click').defaultPrevented):toBe(true)
    expect(parentNextValue).tsvar_not:toBeCalled()
  end
  )
  test('it should support "self"', function()
    local parent = document:createElement('div')
    local child = document:createElement('input')
    parent:appendChild(child)
    local fn = jest:fn()
    local handler = withModifiers(fn, {'self'})
    patchEvent(parent, 'onClick', nil, handler, nil)
    triggerEvent(child, 'click')
    expect(fn).tsvar_not:toBeCalled()
  end
  )
  test('it should support key modifiers and system modifiers', function()
    local el = document:createElement('div')
    local fn = jest:fn()
    local nextValue = withKeys(withModifiers(fn, {'ctrl'}), {'esc', 'arrow-left'})
    patchEvent(el, 'onKeyup', nil, nextValue, nil)
    triggerEvent(el, 'keyup', function(e)
      e.key = 'a'
    end
    )
    expect(fn).tsvar_not:toBeCalled()
    triggerEvent(el, 'keyup', function(e)
      e.ctrlKey = false
      e.key = 'esc'
    end
    )
    expect(fn).tsvar_not:toBeCalled()
    triggerEvent(el, 'keyup', function(e)
      e.ctrlKey = true
      e.key = 'Escape'
    end
    )
    expect(fn):toBeCalledTimes(1)
    triggerEvent(el, 'keyup', function(e)
      e.ctrlKey = true
      e.key = 'ArrowLeft'
    end
    )
    expect(fn):toBeCalledTimes(2)
  end
  )
  test('it should support "exact" modifier', function()
    local el = document:createElement('div')
    local fn1 = jest:fn()
    local next1 = withModifiers(fn1, {'exact'})
    patchEvent(el, 'onKeyup', nil, next1, nil)
    triggerEvent(el, 'keyup')
    expect(#fn1.mock.calls):toBe(1)
    triggerEvent(el, 'keyup', function(e)
      e.ctrlKey = true
    end
    )
    expect(#fn1.mock.calls):toBe(1)
    local fn2 = jest:fn()
    local next2 = withKeys(withModifiers(fn2, {'ctrl', 'exact'}), {'a'})
    patchEvent(el, 'onKeyup', nil, next2, nil)
    triggerEvent(el, 'keyup', function(e)
      e.key = 'a'
    end
    )
    expect(fn2).tsvar_not:toBeCalled()
    triggerEvent(el, 'keyup', function(e)
      e.key = 'a'
      e.ctrlKey = true
    end
    )
    expect(#fn2.mock.calls):toBe(1)
    triggerEvent(el, 'keyup', function(e)
      e.key = 'a'
      e.ctrlKey = true
      e.altKey = true
    end
    )
    expect(#fn2.mock.calls):toBe(1)
  end
  )
  it('should support mouse modifiers', function()
    local buttons = {'left', 'middle', 'right'}
    local buttonCodes = {left=0, middle=1, right=2}
    buttons:forEach(function(button)
      local el = document:createElement('div')
      local fn = jest:fn()
      local handler = withModifiers(fn, {button})
      patchEvent(el, 'onMousedown', nil, handler, nil)
      buttons:filter(function(b)
        b ~= button
      end
      ):forEach(function(button)
        triggerEvent(el, 'mousedown', function(e)
          -- [ts2lua]buttonCodes下标访问可能不正确
          e.button = buttonCodes[button]
        end
        )
      end
      )
      expect(fn).tsvar_not:toBeCalled()
      triggerEvent(el, 'mousedown', function(e)
        -- [ts2lua]buttonCodes下标访问可能不正确
        e.button = buttonCodes[button]
      end
      )
      expect(fn):toBeCalled()
    end
    )
  end
  )
  it('should handle multiple arguments when using modifiers', function()
    local el = document:createElement('div')
    local fn = jest:fn()
    local handler = withModifiers(fn, {'ctrl'})
    local event = triggerEvent(el, 'click', function(e)
      e.ctrlKey = true
    end
    )
    handler(event, 'value', true)
    expect(fn):toBeCalledWith(event, 'value', true)
  end
  )
end
)