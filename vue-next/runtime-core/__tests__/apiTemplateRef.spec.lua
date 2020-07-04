require("@vue/runtime-test")

describe('api: template refs', function()
  it('string ref mount', function()
    local root = nodeOps:createElement('div')
    local el = ref(nil)
    local Comp = {setup=function()
      return {refKey=el}
    end
    , render=function()
      return h('div', {ref='refKey'})
    end
    }
    render(h(Comp), root)
    expect(el.value):toBe(root.children[0+1])
  end
  )
  it('string ref update', function()
    local root = nodeOps:createElement('div')
    local fooEl = ref(nil)
    local barEl = ref(nil)
    local refKey = ref('foo')
    local Comp = {setup=function()
      return {foo=fooEl, bar=barEl}
    end
    , render=function()
      return h('div', {ref=refKey.value})
    end
    }
    render(h(Comp), root)
    expect(fooEl.value):toBe(root.children[0+1])
    expect(barEl.value):toBe(nil)
    refKey.value = 'bar'
    expect(fooEl.value):toBe(nil)
    expect(barEl.value):toBe(root.children[0+1])
  end
  )
  it('string ref unmount', function()
    local root = nodeOps:createElement('div')
    local el = ref(nil)
    local toggle = ref(true)
    local Comp = {setup=function()
      return {refKey=el}
    end
    , render=function()
      -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
      return (toggle.value and {h('div', {ref='refKey'})} or {nil})[1]
    end
    }
    render(h(Comp), root)
    expect(el.value):toBe(root.children[0+1])
    toggle.value = false
    expect(el.value):toBe(nil)
  end
  )
  it('function ref mount', function()
    local root = nodeOps:createElement('div')
    local fn = jest:fn()
    local Comp = defineComponent(function()
      function()
        h('div', {ref=fn})
      end
      
    
    end
    )
    render(h(Comp), root)
    expect(fn.mock.calls[0+1][0+1]):toBe(root.children[0+1])
  end
  )
  it('function ref update', function()
    local root = nodeOps:createElement('div')
    local fn1 = jest:fn()
    local fn2 = jest:fn()
    local fn = ref(fn1)
    local Comp = defineComponent(function()
      function()
        h('div', {ref=fn.value})
      end
      
    
    end
    )
    render(h(Comp), root)
    expect(fn1.mock.calls):toHaveLength(1)
    expect(fn1.mock.calls[0+1][0+1]):toBe(root.children[0+1])
    expect(fn2.mock.calls):toHaveLength(0)
    fn.value = fn2
    expect(fn1.mock.calls):toHaveLength(1)
    expect(fn2.mock.calls):toHaveLength(1)
    expect(fn2.mock.calls[0+1][0+1]):toBe(root.children[0+1])
  end
  )
  it('function ref unmount', function()
    local root = nodeOps:createElement('div')
    local fn = jest:fn()
    local toggle = ref(true)
    local Comp = defineComponent(function()
      function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {h('div', {ref=fn})} or {nil})[1]
      end
      
    
    end
    )
    render(h(Comp), root)
    expect(fn.mock.calls[0+1][0+1]):toBe(root.children[0+1])
    toggle.value = false
    expect(fn.mock.calls[1+1][0+1]):toBe(nil)
  end
  )
  it('render function ref mount', function()
    local root = nodeOps:createElement('div')
    local el = ref(nil)
    local Comp = {setup=function()
      return function()
        h('div', {ref=el})
      end
      
    
    end
    }
    render(h(Comp), root)
    expect(el.value):toBe(root.children[0+1])
  end
  )
  it('render function ref update', function()
    local root = nodeOps:createElement('div')
    local refs = {foo=ref(nil), bar=ref(nil)}
    local refKey = ref('foo')
    local Comp = {setup=function()
      return function()
        -- [ts2lua]refs下标访问可能不正确
        h('div', {ref=refs[refKey.value]})
      end
      
    
    end
    }
    render(h(Comp), root)
    expect(refs.foo.value):toBe(root.children[0+1])
    expect(refs.bar.value):toBe(nil)
    refKey.value = 'bar'
    expect(refs.foo.value):toBe(nil)
    expect(refs.bar.value):toBe(root.children[0+1])
  end
  )
  it('render function ref unmount', function()
    local root = nodeOps:createElement('div')
    local el = ref(nil)
    local toggle = ref(true)
    local Comp = {setup=function()
      return function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {h('div', {ref=el})} or {nil})[1]
      end
      
    
    end
    }
    render(h(Comp), root)
    expect(el.value):toBe(root.children[0+1])
    toggle.value = false
    expect(el.value):toBe(nil)
  end
  )
  test('string ref inside slots', function()
    local root = nodeOps:createElement('div')
    local spy = jest:fn()
    local Child = {render=function(this)
      return self.tsvar_slots:default()
    end
    }
    local Comp = {render=function()
      return h(Child, function()
        return h('div', {ref='foo'})
      end
      )
    end
    , mounted=function(this)
      spy(self.tsvar_refs.foo.tag)
    end
    }
    render(h(Comp), root)
    expect(spy):toHaveBeenCalledWith('div')
  end
  )
  it('should work with direct reactive property', function()
    local root = nodeOps:createElement('div')
    local state = reactive({refKey=nil})
    local Comp = {setup=function()
      return state
    end
    , render=function()
      return h('div', {ref='refKey'})
    end
    }
    render(h(Comp), root)
    expect(state.refKey):toBe(root.children[0+1])
  end
  )
  test('multiple root refs', function()
    local root = nodeOps:createElement('div')
    local refKey1 = ref(nil)
    local refKey2 = ref(nil)
    local refKey3 = ref(nil)
    local Comp = {setup=function()
      return {refKey1=refKey1, refKey2=refKey2, refKey3=refKey3}
    end
    , render=function()
      return {h('div', {ref='refKey1'}), h('div', {ref='refKey2'}), h('div', {ref='refKey3'})}
    end
    }
    render(h(Comp), root)
    expect(refKey1.value):toBe(root.children[1+1])
    expect(refKey2.value):toBe(root.children[2+1])
    expect(refKey3.value):toBe(root.children[3+1])
  end
  )
end
)