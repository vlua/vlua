require("@vue/runtime-test")
require("@vue/runtime-test/NodeTypes")
require("@vue/runtime-test/NodeOpTypes")
require("@vue/shared/PatchFlags")

describe('renderer: fragment', function()
  it('should allow returning multiple component root nodes', function()
    local App = {render=function()
      return {h('div', 'one'), 'two'}
    end
    }
    local root = nodeOps:createElement('div')
    render(h(App), root)
    expect(serializeInner(root)):toBe()
    expect(#root.children):toBe(4)
    expect(root.children[0+1]):toMatchObject({type=NodeTypes.TEXT, text=''})
    expect(root.children[1+1]):toMatchObject({type=NodeTypes.ELEMENT, tag='div'})
    expect(root.children[1+1].children[0+1]):toMatchObject({type=NodeTypes.TEXT, text='one'})
    expect(root.children[2+1]):toMatchObject({type=NodeTypes.TEXT, text='two'})
    expect(root.children[3+1]):toMatchObject({type=NodeTypes.TEXT, text=''})
  end
  )
  it('explicitly create fragments', function()
    local root = nodeOps:createElement('div')
    render(h('div', {h(Fragment, {h('div', 'one'), 'two'})}), root)
    local parent = root.children[0+1]
    expect(serializeInner(parent)):toBe()
  end
  )
  it('patch fragment children (manual, keyed)', function()
    local root = nodeOps:createElement('div')
    render(h(Fragment, {h('div', {key=1}, 'one'), h('div', {key=2}, 'two')}), root)
    expect(serializeInner(root)):toBe()
    resetOps()
    render(h(Fragment, {h('div', {key=2}, 'two'), h('div', {key=1}, 'one')}), root)
    expect(serializeInner(root)):toBe()
    local ops = dumpOps()
    expect(ops):toMatchObject({{type=NodeOpTypes.INSERT}})
  end
  )
  it('patch fragment children (manual, unkeyed)', function()
    local root = nodeOps:createElement('div')
    render(h(Fragment, {h('div', 'one'), h('div', 'two')}), root)
    expect(serializeInner(root)):toBe()
    resetOps()
    render(h(Fragment, {h('div', 'two'), h('div', 'one')}), root)
    expect(serializeInner(root)):toBe()
    local ops = dumpOps()
    expect(ops):toMatchObject({{type=NodeOpTypes.SET_ELEMENT_TEXT}, {type=NodeOpTypes.SET_ELEMENT_TEXT}})
  end
  )
  it('patch fragment children (compiler generated, unkeyed)', function()
    local root = nodeOps:createElement('div')
    render(createVNode(Fragment, nil, {createVNode('div', nil, 'one', PatchFlags.TEXT), createTextVNode('two')}, PatchFlags.UNKEYED_FRAGMENT), root)
    expect(serializeInner(root)):toBe()
    render(createVNode(Fragment, nil, {createVNode('div', nil, 'foo', PatchFlags.TEXT), createTextVNode('bar'), createTextVNode('baz')}, PatchFlags.KEYED_FRAGMENT), root)
    expect(serializeInner(root)):toBe()
  end
  )
  it('patch fragment children (compiler generated, keyed)', function()
    local root = nodeOps:createElement('div')
    render(createVNode(Fragment, nil, {h('div', {key=1}, 'one'), h('div', {key=2}, 'two')}, PatchFlags.KEYED_FRAGMENT), root)
    expect(serializeInner(root)):toBe()
    resetOps()
    render(createVNode(Fragment, nil, {h('div', {key=2}, 'two'), h('div', {key=1}, 'one')}, PatchFlags.KEYED_FRAGMENT), root)
    expect(serializeInner(root)):toBe()
    local ops = dumpOps()
    expect(ops):toMatchObject({{type=NodeOpTypes.INSERT}})
  end
  )
  it('move fragment', function()
    local root = nodeOps:createElement('div')
    render(h('div', {h('div', {key=1}, 'outer'), h(Fragment, {key=2}, {h('div', {key=1}, 'one'), h('div', {key=2}, 'two')})}), root)
    expect(serializeInner(root)):toBe()
    resetOps()
    render(h('div', {h(Fragment, {key=2}, {h('div', {key=2}, 'two'), h('div', {key=1}, 'one')}), h('div', {key=1}, 'outer')}), root)
    expect(serializeInner(root)):toBe()
    local ops = dumpOps()
    expect(ops):toMatchObject({{type=NodeOpTypes.INSERT, targetNode={type='element'}}, {type=NodeOpTypes.INSERT, targetNode={type='text', text=''}}, {type=NodeOpTypes.INSERT, targetNode={type='element'}}, {type=NodeOpTypes.INSERT, targetNode={type='element'}}, {type=NodeOpTypes.INSERT, targetNode={type='text', text=''}}})
  end
  )
  it('handle nested fragments', function()
    local root = nodeOps:createElement('div')
    render(h(Fragment, {h('div', {key=1}, 'outer'), h(Fragment, {key=2}, {h('div', {key=1}, 'one'), h('div', {key=2}, 'two')})}), root)
    expect(serializeInner(root)):toBe()
    resetOps()
    render(h(Fragment, {h(Fragment, {key=2}, {h('div', {key=2}, 'two'), h('div', {key=1}, 'one')}), h('div', {key=1}, 'outer')}), root)
    expect(serializeInner(root)):toBe()
    local ops = dumpOps()
    expect(ops):toMatchObject({{type=NodeOpTypes.INSERT, targetNode={type='element'}}, {type=NodeOpTypes.INSERT, targetNode={type='text', text=''}}, {type=NodeOpTypes.INSERT, targetNode={type='element'}}, {type=NodeOpTypes.INSERT, targetNode={type='element'}}, {type=NodeOpTypes.INSERT, targetNode={type='text', text=''}}})
    render(nil, root)
    expect(serializeInner(root)):toBe()
  end
  )
end
)