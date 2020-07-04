require("runtime-core/src/vnode")
require("@vue/shared/ShapeFlags")
require("@vue/shared/PatchFlags")
require("runtime-core/src")
require("@vue/runtime-test")
require("runtime-core/src/componentRenderUtils")

describe('vnode', function()
  test('create with just tag', function()
    local vnode = createVNode('p')
    expect(vnode.type):toBe('p')
    expect(vnode.props):toBe(nil)
  end
  )
  test('create with tag and props', function()
    local vnode = createVNode('p', {})
    expect(vnode.type):toBe('p')
    expect(vnode.props):toMatchObject({})
  end
  )
  test('create with tag, props and children', function()
    local vnode = createVNode('p', {}, {'foo'})
    expect(vnode.type):toBe('p')
    expect(vnode.props):toMatchObject({})
    expect(vnode.children):toMatchObject({'foo'})
  end
  )
  test('create with 0 as props', function()
    local vnode = createVNode('p', nil)
    expect(vnode.type):toBe('p')
    expect(vnode.props):toBe(nil)
  end
  )
  test('create from an existing vnode', function()
    local vnode1 = createVNode('p', {id='foo'})
    local vnode2 = createVNode(vnode1, {class='bar'}, 'baz')
    expect(vnode2):toMatchObject({type='p', props={id='foo', class='bar'}, children='baz', shapeFlag=ShapeFlags.ELEMENT | ShapeFlags.TEXT_CHILDREN})
  end
  )
  test('vnode keys', function()
    for _tmpi, key in pairs({'', 'a', 0, 1, NaN}) do
      expect(createVNode('div', {key=key}).key):toBe(key)
    end
    expect(createVNode('div').key):toBe(nil)
    expect(createVNode('div', {key=undefined}).key):toBe(nil)
  end
  )
  test('create with class component', function()
    local Component = newClass({Class}, {name = 'Component'})
    
    Component.__vccOpts = {template='<div />'};
    local vnode = createVNode(Component)
    expect(vnode.type):toEqual(Component.__vccOpts)
  end
  )
  describe('class normalization', function()
    test('string', function()
      local vnode = createVNode('p', {class='foo baz'})
      expect(vnode.props):toMatchObject({class='foo baz'})
    end
    )
    test('array<string>', function()
      local vnode = createVNode('p', {class={'foo', 'baz'}})
      expect(vnode.props):toMatchObject({class='foo baz'})
    end
    )
    test('array<object>', function()
      local vnode = createVNode('p', {class={{foo='foo'}, {baz='baz'}}})
      expect(vnode.props):toMatchObject({class='foo baz'})
    end
    )
    test('object', function()
      local vnode = createVNode('p', {class={foo='foo', baz='baz'}})
      expect(vnode.props):toMatchObject({class='foo baz'})
    end
    )
  end
  )
  describe('style normalization', function()
    test('array', function()
      local vnode = createVNode('p', {style={{foo='foo'}, {baz='baz'}}})
      expect(vnode.props):toMatchObject({style={foo='foo', baz='baz'}})
    end
    )
    test('object', function()
      local vnode = createVNode('p', {style={foo='foo', baz='baz'}})
      expect(vnode.props):toMatchObject({style={foo='foo', baz='baz'}})
    end
    )
  end
  )
  describe('children normalization', function()
    local nop = jest.fn
    test('null', function()
      local vnode = createVNode('p', nil, nil)
      expect(vnode.children):toBe(nil)
      expect(vnode.shapeFlag):toBe(ShapeFlags.ELEMENT)
    end
    )
    test('array', function()
      local vnode = createVNode('p', nil, {'foo'})
      expect(vnode.children):toMatchObject({'foo'})
      expect(vnode.shapeFlag):toBe(ShapeFlags.ELEMENT | ShapeFlags.ARRAY_CHILDREN)
    end
    )
    test('object', function()
      local vnode = createVNode('p', nil, {foo='foo'})
      expect(vnode.children):toMatchObject({foo='foo'})
      expect(vnode.shapeFlag):toBe(ShapeFlags.ELEMENT | ShapeFlags.SLOTS_CHILDREN)
    end
    )
    test('function', function()
      local vnode = createVNode('p', nil, nop)
      expect(vnode.children):toMatchObject({default=nop})
      expect(vnode.shapeFlag):toBe(ShapeFlags.ELEMENT | ShapeFlags.SLOTS_CHILDREN)
    end
    )
    test('string', function()
      local vnode = createVNode('p', nil, 'foo')
      expect(vnode.children):toBe('foo')
      expect(vnode.shapeFlag):toBe(ShapeFlags.ELEMENT | ShapeFlags.TEXT_CHILDREN)
    end
    )
    test('element with slots', function()
      local children = {createVNode('span', nil, 'hello')}
      local vnode = createVNode('div', nil, {default=function()
        children
      end
      })
      expect(vnode.children):toBe(children)
      expect(vnode.shapeFlag):toBe(ShapeFlags.ELEMENT | ShapeFlags.ARRAY_CHILDREN)
    end
    )
  end
  )
  test('normalizeVNode', function()
    expect(normalizeVNode(nil)):toMatchObject({type=Comment})
    expect(normalizeVNode(undefined)):toMatchObject({type=Comment})
    expect(normalizeVNode(true)):toMatchObject({type=Comment})
    expect(normalizeVNode(false)):toMatchObject({type=Comment})
    expect(normalizeVNode({'foo'})):toMatchObject({type=Fragment})
    local vnode = createVNode('div')
    expect(normalizeVNode(vnode)):toBe(vnode)
    local mounted = createVNode('div')
    mounted.el = {}
    local normalized = normalizeVNode(mounted)
    expect(normalized).tsvar_not:toBe(mounted)
    expect(normalized):toEqual(mounted)
    expect(normalizeVNode('foo')):toMatchObject({type=Text, children=})
    expect(normalizeVNode(1)):toMatchObject({type=Text, children=})
  end
  )
  test('type shapeFlag inference', function()
    expect(createVNode('div').shapeFlag):toBe(ShapeFlags.ELEMENT)
    expect(createVNode({}).shapeFlag):toBe(ShapeFlags.STATEFUL_COMPONENT)
    expect(createVNode(function()
      
    end
    ).shapeFlag):toBe(ShapeFlags.FUNCTIONAL_COMPONENT)
    expect(createVNode(Text).shapeFlag):toBe(0)
  end
  )
  test('cloneVNode', function()
    local node1 = createVNode('div', {foo=1}, nil)
    expect(cloneVNode(node1)):toEqual(node1)
    local node2 = createVNode({}, nil, {node1})
    local cloned2 = cloneVNode(node2)
    expect(cloned2):toEqual(node2)
    expect(cloneVNode(node2)):toEqual(node2)
    expect(cloneVNode(node2)):toEqual(cloned2)
  end
  )
  test('cloneVNode key normalization', function()
    expect(cloneVNode(createVNode('div', {key=1})).key):toBe(1)
    expect(cloneVNode(createVNode('div', {key=1}), {key=2}).key):toBe(2)
    expect(cloneVNode(createVNode('div'), {key=2}).key):toBe(2)
  end
  )
  test('cloneVNode ref normalization', function()
    local mockInstance1 = {}
    local mockInstance2 = {}
    setCurrentRenderingInstance(mockInstance1)
    local original = createVNode('div', {ref='foo'})
    expect(original.ref):toEqual({mockInstance1, 'foo'})
    local cloned1 = cloneVNode(original)
    expect(cloned1.ref):toEqual({mockInstance1, 'foo'})
    local cloned2 = cloneVNode(original, {ref='bar'})
    expect(cloned2.ref):toEqual({mockInstance1, 'bar'})
    local original2 = createVNode('div')
    local cloned3 = cloneVNode(original2, {ref='bar'})
    expect(cloned3.ref):toEqual({mockInstance1, 'bar'})
    setCurrentRenderingInstance(mockInstance2)
    local cloned4 = cloneVNode(original)
    expect(cloned4.ref):toEqual({mockInstance1, 'foo'})
    local cloned5 = cloneVNode(original, {ref='bar'})
    expect(cloned5.ref):toEqual({mockInstance2, 'bar'})
    local cloned6 = cloneVNode(original2, {ref='bar'})
    expect(cloned6.ref):toEqual({mockInstance2, 'bar'})
    setCurrentRenderingInstance(nil)
  end
  )
  describe('mergeProps', function()
    test('class', function()
      local props1 = {class='c'}
      local props2 = {class={'cc'}}
      local props3 = {class={{ccc=true}}}
      local props4 = {class={cccc=true}}
      expect(mergeProps(props1, props2, props3, props4)):toMatchObject({class='c cc ccc cccc'})
    end
    )
    test('style', function()
      local props1 = {style={color='red', fontSize=10}}
      local props2 = {style={{color='blue', width='200px'}, {width='300px', height='300px', fontSize=30}}}
      expect(mergeProps(props1, props2)):toMatchObject({style={color='blue', width='300px', height='300px', fontSize=30}})
    end
    )
    test('style w/ strings', function()
      local props1 = {style='width:100px;right:10;top:10'}
      local props2 = {style={{color='blue', width='200px'}, {width='300px', height='300px', fontSize=30}}}
      expect(mergeProps(props1, props2)):toMatchObject({style={color='blue', width='300px', height='300px', fontSize=30, right='10', top='10'}})
    end
    )
    test('handlers', function()
      local clickHandler1 = function() end
      local clickHandler2 = function() end
      local focusHandler2 = function() end
      local props1 = {onClick=clickHandler1}
      local props2 = {onClick=clickHandler2, onFocus=focusHandler2}
      expect(mergeProps(props1, props2)):toMatchObject({onClick={clickHandler1, clickHandler2}, onFocus=focusHandler2})
    end
    )
    test('default', function()
      local props1 = {foo='c'}
      local props2 = {foo={}, bar={'cc'}}
      local props3 = {baz={ccc=true}}
      expect(mergeProps(props1, props2, props3)):toMatchObject({foo={}, bar={'cc'}, baz={ccc=true}})
    end
    )
  end
  )
  describe('dynamic children', function()
    test('with patchFlags', function()
      local hoist = createVNode('div')
      local vnode1 = nil
      local vnode = openBlock(); createBlock('div', nil, {hoist, vnode1 = createVNode('div', nil, 'text', PatchFlags.TEXT)})
      expect(vnode.dynamicChildren):toStrictEqual({vnode1})
    end
    )
    test('should not track vnodes with only HYDRATE_EVENTS flag', function()
      local hoist = createVNode('div')
      local vnode = openBlock(); createBlock('div', nil, {hoist, createVNode('div', nil, 'text', PatchFlags.HYDRATE_EVENTS)})
      expect(vnode.dynamicChildren):toStrictEqual({})
    end
    )
    test('many times call openBlock', function()
      local hoist = createVNode('div')
      local vnode1 = nil
      local vnode2 = nil
      local vnode3 = nil
      local vnode = openBlock(); createBlock('div', nil, {hoist, vnode1 = createVNode('div', nil, 'text', PatchFlags.TEXT), vnode2 = openBlock(); createBlock('div', nil, {hoist, vnode3 = createVNode('div', nil, 'text', PatchFlags.TEXT)})})
      expect(vnode.dynamicChildren):toStrictEqual({vnode1, vnode2})
      expect(vnode2.dynamicChildren):toStrictEqual({vnode3})
    end
    )
    test('with stateful component', function()
      local hoist = createVNode('div')
      local vnode1 = nil
      local vnode = openBlock(); createBlock('div', nil, {hoist, vnode1 = createVNode({}, nil, 'text')})
      expect(vnode.dynamicChildren):toStrictEqual({vnode1})
    end
    )
    test('with functional component', function()
      local hoist = createVNode('div')
      local vnode1 = nil
      local vnode = openBlock(); createBlock('div', nil, {hoist, vnode1 = createVNode(function()
        
      end
      , nil, 'text')})
      expect(vnode.dynamicChildren):toStrictEqual({vnode1})
    end
    )
    test('with suspense', function()
      local hoist = createVNode('div')
      local vnode1 = nil
      local vnode = openBlock(); createBlock('div', nil, {hoist, vnode1 = createVNode(function()
        
      end
      , nil, 'text')})
      expect(vnode.dynamicChildren):toStrictEqual({vnode1})
    end
    )
    test('element block should track normalized slot children', function()
      local hoist = createVNode('div')
      local vnode1 = nil
      local vnode = openBlock(); createBlock('div', nil, {default=function()
        return {hoist, vnode1 = createVNode('div', nil, 'text', PatchFlags.TEXT)}
      end
      })
      expect(vnode.dynamicChildren):toStrictEqual({vnode1})
    end
    )
    test('openBlock w/ disableTracking: true', function()
      local hoist = createVNode('div')
      local vnode1 = nil
      local vnode = openBlock(); createBlock('div', nil, {vnode1 = openBlock(true); createBlock(Fragment, nil, {hoist, createVNode(function()
        
      end
      , nil, 'text')})})
      expect(vnode.dynamicChildren):toStrictEqual({vnode1})
      expect(vnode1.dynamicChildren):toStrictEqual({})
    end
    )
    test('openBlock without disableTracking: true', function()
      local hoist = createVNode('div')
      local vnode1 = nil
      local vnode2 = nil
      local vnode = openBlock(); createBlock('div', nil, {vnode1 = openBlock(); createBlock(Fragment, nil, {hoist, vnode2 = createVNode(function()
        
      end
      , nil, 'text')})})
      expect(vnode.dynamicChildren):toStrictEqual({vnode1})
      expect(vnode1.dynamicChildren):toStrictEqual({vnode2})
    end
    )
  end
  )
  describe('transformVNodeArgs', function()
    afterEach(function()
      transformVNodeArgs()
    end
    )
    test('no-op pass through', function()
      transformVNodeArgs(function(args)
        args
      end
      )
      local vnode = createVNode('div', {id='foo'}, 'hello')
      expect(vnode):toMatchObject({type='div', props={id='foo'}, children='hello', shapeFlag=ShapeFlags.ELEMENT | ShapeFlags.TEXT_CHILDREN})
    end
    )
    test('direct override', function()
      transformVNodeArgs(function()
        {'div', {id='foo'}, 'hello'}
      end
      )
      local vnode = createVNode('p')
      expect(vnode):toMatchObject({type='div', props={id='foo'}, children='hello', shapeFlag=ShapeFlags.ELEMENT | ShapeFlags.TEXT_CHILDREN})
    end
    )
    test('receive component instance as 2nd arg', function()
      transformVNodeArgs(function(args, instance)
        if instance then
          return {'h1', nil, instance.type.name}
        else
          return args
        end
      end
      )
      local App = {name='Root Component', render=function()
        return h('p')
      end
      }
      local root = nodeOps:createElement('div')
      createApp(App):mount(root)
      expect(serializeInner(root)):toBe('<h1>Root Component</h1>')
    end
    )
    test('should not be observable', function()
      local a = createVNode('div')
      local b = reactive(a)
      expect(b):toBe(a)
      expect(isReactive(b)):toBe(false)
    end
    )
  end
  )
end
)