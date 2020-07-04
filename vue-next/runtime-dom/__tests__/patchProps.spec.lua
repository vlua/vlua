require("runtime-dom/src/patchProp")
require("runtime-dom/src")
require("@vue/shared")

describe('runtime-dom: props patching', function()
  mockWarn()
  test('basic', function()
    local el = document:createElement('div')
    patchProp(el, 'id', nil, 'foo')
    expect(el.id):toBe('foo')
    patchProp(el, 'id', nil, nil)
    expect(el.id):toBe('')
  end
  )
  test('value', function()
    local el = document:createElement('input')
    patchProp(el, 'value', nil, 'foo')
    expect(el.value):toBe('foo')
    patchProp(el, 'value', nil, nil)
    expect(el.value):toBe('')
    local obj = {}
    patchProp(el, 'value', nil, obj)
    expect(el.value):toBe(obj:toString())
    expect(el._value):toBe(obj)
  end
  )
  test('boolean prop', function()
    local el = document:createElement('select')
    patchProp(el, 'multiple', nil, '')
    expect(el.multiple):toBe(true)
    patchProp(el, 'multiple', nil, nil)
    expect(el.multiple):toBe(false)
  end
  )
  test('innerHTML unmount prev children', function()
    local fn = jest:fn()
    local comp = {render=function()
      'foo'
    end
    , unmounted=fn}
    local root = document:createElement('div')
    render(h('div', nil, {h(comp)}), root)
    expect(root.innerHTML):toBe()
    render(h('div', {innerHTML='bar'}), root)
    expect(root.innerHTML):toBe()
    expect(fn):toHaveBeenCalled()
  end
  )
  test('(svg) innerHTML unmount prev children', function()
    local fn = jest:fn()
    local comp = {render=function()
      'foo'
    end
    , unmounted=fn}
    local root = document:createElement('div')
    render(h('div', nil, {h(comp)}), root)
    expect(root.innerHTML):toBe()
    render(h('svg', {innerHTML='<g></g>'}), root)
    expect(root.innerHTML):toBe()
    expect(fn):toHaveBeenCalled()
  end
  )
  test('textContent unmount prev children', function()
    local fn = jest:fn()
    local comp = {render=function()
      'foo'
    end
    , unmounted=fn}
    local root = document:createElement('div')
    render(h('div', nil, {h(comp)}), root)
    expect(root.innerHTML):toBe()
    render(h('div', {textContent='bar'}), root)
    expect(root.innerHTML):toBe()
    expect(fn):toHaveBeenCalled()
  end
  )
  test('set value as-is for non string-value props', function()
    local el = document:createElement('video')
    local intiialValue = el.srcObject
    local fakeObject = {}
    patchProp(el, 'srcObject', nil, fakeObject)
    expect(el.srcObject).tsvar_not:toBe(fakeObject)
    patchProp(el, 'srcObject', nil, nil)
    expect(el.srcObject):toBe(intiialValue)
  end
  )
  test('catch and warn prop set TypeError', function()
    local el = document:createElement('div')
    Object:defineProperty(el, 'someProp', {set=function()
      error(TypeError('Invalid type'))
    end
    })
    patchProp(el, 'someProp', nil, 'foo')
    expect():toHaveBeenWarnedLast()
  end
  )
end
)