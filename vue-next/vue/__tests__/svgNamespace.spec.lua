require("vue/src")

describe('SVG support', function()
  test('should mount elements with correct namespaces', function()
    local root = document:createElement('div')
    document.body:appendChild(root)
    local App = {template=}
    render(h(App), root)
    local e0 = nil
    expect(e0.namespaceURI):toMatch('xhtml')
    expect(().namespaceURI):toMatch('svg')
    expect(().namespaceURI):toMatch('svg')
    expect(().namespaceURI):toMatch('xhtml')
  end
  )
  test('should patch elements with correct namespaces', function()
    local root = document:createElement('div')
    document.body:appendChild(root)
    local cls = ref('foo')
    local App = {setup=function()
      {cls=cls}
    end
    , template=}
    render(h(App), root)
    local f1 = nil
    local f2 = nil
    expect(f1:getAttribute('class')):toBe('foo')
    expect(f2.className):toBe('foo')
    f2._vtc = {'baz'}
    cls.value = 'bar'
    expect(f1:getAttribute('class')):toBe('bar')
    expect(f2.className):toBe('bar baz')
  end
  )
end
)