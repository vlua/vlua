require("runtime-dom/src/patchProp")
require("runtime-dom/src/nodeOps")

describe('runtime-dom: class patching', function()
  test('basics', function()
    local el = document:createElement('div')
    patchProp(el, 'class', nil, 'foo')
    expect(el.className):toBe('foo')
    patchProp(el, 'class', nil, nil)
    expect(el.className):toBe('')
  end
  )
  test('transition class', function()
    local el = document:createElement('div')
    el._vtc = Set({'bar', 'baz'})
    patchProp(el, 'class', nil, 'foo')
    expect(el.className):toBe('foo bar baz')
    patchProp(el, 'class', nil, nil)
    expect(el.className):toBe('bar baz')
    el._vtc = nil
    patchProp(el, 'class', nil, 'foo')
    expect(el.className):toBe('foo')
  end
  )
  test('svg', function()
    local el = document:createElementNS(svgNS, 'svg')
    patchProp(el, 'class', nil, 'foo', true)
    expect(el:getAttribute('class')):toBe('foo')
  end
  )
end
)