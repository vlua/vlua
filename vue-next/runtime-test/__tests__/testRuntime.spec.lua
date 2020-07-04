require("runtime-test/src")
require("runtime-test/src/NodeTypes")
require("runtime-test/src/NodeOpTypes")
require("@vue/shared")

describe('test renderer', function()
  mockWarn()
  it('should work', function()
    local root = nodeOps:createElement('div')
    render(h('div', {id='test'}, 'hello'), root)
    expect(#root.children):toBe(1)
    local el = root.children[0+1]
    expect(el.type):toBe(NodeTypes.ELEMENT)
    expect(el.props.id):toBe('test')
    expect(#el.children):toBe(1)
    local text = el.children[0+1]
    expect(text.type):toBe(NodeTypes.TEXT)
    expect(text.text):toBe('hello')
  end
  )
  it('should record ops', function()
    local state = reactive({id='test', text='hello'})
    local App = {render=function()
      return h('div', {id=state.id}, state.text)
    end
    }
    local root = nodeOps:createElement('div')
    resetOps()
    render(h(App), root)
    local ops = dumpOps()
    expect(#ops):toBe(4)
    expect(ops[0+1]):toEqual({type=NodeOpTypes.CREATE, nodeType=NodeTypes.ELEMENT, tag='div', targetNode=root.children[0+1]})
    expect(ops[1+1]):toEqual({type=NodeOpTypes.SET_ELEMENT_TEXT, text='hello', targetNode=root.children[0+1]})
    expect(ops[2+1]):toEqual({type=NodeOpTypes.PATCH, targetNode=root.children[0+1], propKey='id', propPrevValue=nil, propNextValue='test'})
    expect(ops[3+1]):toEqual({type=NodeOpTypes.INSERT, targetNode=root.children[0+1], parentNode=root, refNode=nil})
    state.id = 'foo'
    state.text = 'bar'
    local updateOps = dumpOps()
    expect(#updateOps):toBe(2)
    expect(updateOps[0+1]):toEqual({type=NodeOpTypes.PATCH, targetNode=root.children[0+1], propKey='id', propPrevValue='test', propNextValue='foo'})
    expect(updateOps[1+1]):toEqual({type=NodeOpTypes.SET_ELEMENT_TEXT, targetNode=root.children[0+1], text='bar'})
  end
  )
  it('should be able to serialize nodes', function()
    local App = {render=function()
      return h('div', {id='test', boolean=''}, {h('span', 'foo'), 'hello'})
    end
    }
    local root = nodeOps:createElement('div')
    render(h(App), root)
    expect(serialize(root)):toEqual()
    expect(serialize(root, 2)):toEqual()
  end
  )
  it('should be able to trigger events', function()
    local count = ref(0)
    local App = function()
      return h('span', {onClick=function()
        count.value=count.value+1
      end
      }, count.value)
    end
    
    local root = nodeOps:createElement('div')
    render(h(App), root)
    triggerEvent(root.children[0+1], 'click')
    expect(count.value):toBe(1)
    expect(serialize(root)):toBe()
  end
  )
  it('should be able to trigger events with multiple listeners', function()
    local count = ref(0)
    local count2 = ref(1)
    local App = function()
      return h('span', {onClick={function()
        count.value=count.value+1
      end
      , function()
        count2.value=count2.value+1
      end
      }}, )
    end
    
    local root = nodeOps:createElement('div')
    render(h(App), root)
    triggerEvent(root.children[0+1], 'click')
    expect(count.value):toBe(1)
    expect(count2.value):toBe(2)
    expect(serialize(root)):toBe()
  end
  )
  it('should mock warn', function()
    console:warn('warn!!!')
    expect('warn!!!'):toHaveBeenWarned()
    expect('warn!!!'):toHaveBeenWarnedTimes(1)
    console:warn('warn!!!')
    expect('warn!!!'):toHaveBeenWarnedTimes(2)
    console:warn('warning')
    expect('warn!!!'):toHaveBeenWarnedTimes(2)
    expect('warning'):toHaveBeenWarnedLast()
  end
  )
end
)