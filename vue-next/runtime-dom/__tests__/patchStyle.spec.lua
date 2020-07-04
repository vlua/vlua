require("runtime-dom/src/patchProp")

describe(function()
  it('string', function()
    local el = document:createElement('div')
    patchProp(el, 'style', {}, 'color:red')
    expect(el.style.cssText:gsub('%s', '')):toBe('color:red;')
  end
  )
  it('should not patch same string style', function()
    local el = document:createElement('div')
    local fn = jest:fn()
    el.style.cssText = 'color:red;'
    local value = el.style.cssText
    Object:defineProperty(el.style, 'cssText', {get=function()
      return value
    end
    , set=fn})
    patchProp(el, 'style', value, value)
    expect(el.style.cssText:gsub('%s', '')):toBe('color:red;')
    expect(fn).tsvar_not:toBeCalled()
  end
  )
  it('plain object', function()
    local el = document:createElement('div')
    patchProp(el, 'style', {}, {color='red'})
    expect(el.style.cssText:gsub('%s', '')):toBe('color:red;')
  end
  )
  it('camelCase', function()
    local el = document:createElement('div')
    patchProp(el, 'style', {}, {marginRight='10px'})
    expect(el.style.cssText:gsub('%s', '')):toBe('margin-right:10px;')
  end
  )
  it('remove if falsy value', function()
    local el = document:createElement('div')
    patchProp(el, 'style', {color='red'}, {color=undefined})
    expect(el.style.cssText:gsub('%s', '')):toBe('')
  end
  )
  it('!important', function()
    local el = document:createElement('div')
    patchProp(el, 'style', {}, {color='red !important'})
    expect(el.style.cssText:gsub('%s', '')):toBe('color:red!important;')
  end
  )
  it('camelCase with !important', function()
    local el = document:createElement('div')
    patchProp(el, 'style', {}, {marginRight='10px !important'})
    expect(el.style.cssText:gsub('%s', '')):toBe('margin-right:10px!important;')
  end
  )
  it('object with multiple entries', function()
    local el = document:createElement('div')
    patchProp(el, 'style', {}, {color='red', marginRight='10px'})
    expect(el.style:getPropertyValue('color')):toBe('red')
    expect(el.style:getPropertyValue('margin-right')):toBe('10px')
  end
  )
  function mockElementWithStyle()
    local store = {}
    return {style={WebkitTransition='', setProperty=function(key, val)
      -- [ts2lua]store下标访问可能不正确
      store[key] = val
    end
    , getPropertyValue=function(key)
      -- [ts2lua]store下标访问可能不正确
      return store[key]
    end
    }}
  end
  
  it('CSS custom properties', function()
    local el = mockElementWithStyle()
    patchProp(el, 'style', {}, {--theme='red'})
    expect(el.style:getPropertyValue('--theme')):toBe('red')
  end
  )
  it('auto vendor prefixing', function()
    local el = mockElementWithStyle()
    patchProp(el, 'style', {}, {transition='all 1s'})
    expect(el.style.WebkitTransition):toBe('all 1s')
  end
  )
end
)