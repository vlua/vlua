require("runtime-core/src/h")
require("runtime-core/src/vnode")

describe('renderer: h', function()
  test('type only', function()
    expect(h('div')):toMatchObject(createVNode('div'))
  end
  )
  test('type + props', function()
    expect(h('div', {id='foo'})):toMatchObject(createVNode('div', {id='foo'}))
  end
  )
  test('type + omit props', function()
    expect(h('div', {'foo'})):toMatchObject(createVNode('div', nil, {'foo'}))
    local Component = {template='<br />'}
    local slot = function()
      
    end
    
    expect(h(Component, slot)):toMatchObject(createVNode(Component, nil, slot))
    local vnode = h('div')
    expect(h('div', vnode)):toMatchObject(createVNode('div', nil, {vnode}))
    expect(h('div', 'foo')):toMatchObject(createVNode('div', nil, 'foo'))
  end
  )
  test('type + props + children', function()
    expect(h('div', {}, {'foo'})):toMatchObject(createVNode('div', {}, {'foo'}))
    local slots = {}
    expect(h('div', {}, slots)):toMatchObject(createVNode('div', {}, slots))
    local Component = {template='<br />'}
    expect(h(Component, {}, slots)):toMatchObject(createVNode(Component, {}, slots))
    local slot = function()
      
    end
    
    expect(h(Component, {}, slot)):toMatchObject(createVNode(Component, {}, slot))
    local vnode = h('div')
    expect(h('div', {}, vnode)):toMatchObject(createVNode('div', {}, {vnode}))
    expect(h('div', {}, 'foo')):toMatchObject(createVNode('div', {}, 'foo'))
  end
  )
  test('named slots with null props', function()
    local Component = {template='<br />'}
    local slot = function()
      
    end
    
    expect(h(Component, nil, {foo=slot})):toMatchObject(createVNode(Component, nil, {foo=slot}))
  end
  )
end
)