require("runtime-dom/src")

describe('static vnode handling', function()
  local content = nil
  local content2 = nil
  local s = createStaticVNode(content, 2)
  local s2 = createStaticVNode(content2, 3)
  test('should mount from string', function()
    local root = document:createElement('div')
    render(h('div', {s}), root)
    expect(root.innerHTML):toBe()
  end
  )
  test('should support reusing the same hoisted node', function()
    local root = document:createElement('div')
    render(h('div', {s, s}), root)
    expect(root.innerHTML):toBe()
  end
  )
  test('should update', function()
    local root = document:createElement('div')
    render(h('div', {s}), root)
    expect(root.innerHTML):toBe()
    render(h('div', {s2}), root)
    expect(root.innerHTML):toBe()
  end
  )
  test('should move', function()
    local root = document:createElement('div')
    render(h('div', {h('b'), s, h('b')}), root)
    expect(root.innerHTML):toBe()
    render(h('div', {s, h('b'), h('b')}), root)
    expect(root.innerHTML):toBe()
    render(h('div', {h('b'), h('b'), s}), root)
    expect(root.innerHTML):toBe()
  end
  )
  test('should remove', function()
    local root = document:createElement('div')
    render(h('div', {h('b'), s, h('b')}), root)
    expect(root.innerHTML):toBe()
    render(h('div', {h('b'), h('b')}), root)
    expect(root.innerHTML):toBe()
    render(h('div', {h('b'), h('b'), s}), root)
    expect(root.innerHTML):toBe()
  end
  )
end
)