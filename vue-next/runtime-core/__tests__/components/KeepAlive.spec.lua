require("@vue/runtime-test")

describe('KeepAlive', function()
  local one = nil
  local two = nil
  local views = nil
  local root = nil
  beforeEach(function()
    root = nodeOps:createElement('div')
    one = {name='one', data=function()
      {msg='one'}
    end
    , render=function(this)
      return h('div', self.msg)
    end
    , created=jest:fn(), mounted=jest:fn(), activated=jest:fn(), deactivated=jest:fn(), unmounted=jest:fn()}
    two = {name='two', data=function()
      {msg='two'}
    end
    , render=function(this)
      return h('div', self.msg)
    end
    , created=jest:fn(), mounted=jest:fn(), activated=jest:fn(), deactivated=jest:fn(), unmounted=jest:fn()}
    views = {one=one, two=two}
  end
  )
  function assertHookCalls(component, callCounts)
    expect({#component.created.mock.calls, #component.mounted.mock.calls, #component.activated.mock.calls, #component.deactivated.mock.calls, #component.unmounted.mock.calls}):toEqual(callCounts)
  end
  
  test('should preserve state', function()
    local viewRef = ref('one')
    local instanceRef = ref(nil)
    local App = {render=function()
      return h(KeepAlive, nil, {default=function()
        -- [ts2lua]views下标访问可能不正确
        h(views[viewRef.value], {ref=instanceRef})
      end
      })
    end
    }
    render(h(App), root)
    expect(serializeInner(root)):toBe()
    instanceRef.value.msg = 'changed'
    expect(serializeInner(root)):toBe()
    viewRef.value = 'two'
    expect(serializeInner(root)):toBe()
    viewRef.value = 'one'
    expect(serializeInner(root)):toBe()
  end
  )
  test('should call correct lifecycle hooks', function()
    local toggle = ref(true)
    local viewRef = ref('one')
    local App = {render=function()
      return (toggle.value and {h(KeepAlive, function()
        -- [ts2lua]views下标访问可能不正确
        h(views[viewRef.value])
      end
      -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
      )} or {nil})[1]
    end
    }
    render(h(App), root)
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 1, 0, 0})
    assertHookCalls(two, {0, 0, 0, 0, 0})
    viewRef.value = 'two'
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 1, 1, 0})
    assertHookCalls(two, {1, 1, 1, 0, 0})
    viewRef.value = 'one'
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 1, 0})
    assertHookCalls(two, {1, 1, 1, 1, 0})
    viewRef.value = 'two'
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 2, 0})
    assertHookCalls(two, {1, 1, 2, 1, 0})
    toggle.value = false
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 2, 1})
    assertHookCalls(two, {1, 1, 2, 2, 1})
  end
  )
  test('should call lifecycle hooks on nested components', function()
    one.render = function()
      h(two)
    end
    
    local toggle = ref(true)
    local App = {render=function()
      return h(KeepAlive, function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {h(one)} or {nil})[1]
      end
      )
    end
    }
    render(h(App), root)
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 1, 0, 0})
    assertHookCalls(two, {1, 1, 1, 0, 0})
    toggle.value = false
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 1, 1, 0})
    assertHookCalls(two, {1, 1, 1, 1, 0})
    toggle.value = true
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 1, 0})
    assertHookCalls(two, {1, 1, 2, 1, 0})
    toggle.value = false
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 2, 0})
    assertHookCalls(two, {1, 1, 2, 2, 0})
  end
  )
  test('should call correct hooks for nested keep-alive', function()
    local toggle2 = ref(true)
    one.render = function()
      h(KeepAlive, function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle2.value需要确认
        (toggle2.value and {h(two)} or {nil})[1]
      end
      )
    end
    
    local toggle1 = ref(true)
    local App = {render=function()
      return h(KeepAlive, function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle1.value需要确认
        (toggle1.value and {h(one)} or {nil})[1]
      end
      )
    end
    }
    render(h(App), root)
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 1, 0, 0})
    assertHookCalls(two, {1, 1, 1, 0, 0})
    toggle1.value = false
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 1, 1, 0})
    assertHookCalls(two, {1, 1, 1, 1, 0})
    toggle1.value = true
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 1, 0})
    assertHookCalls(two, {1, 1, 2, 1, 0})
    toggle2.value = false
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 1, 0})
    assertHookCalls(two, {1, 1, 2, 2, 0})
    toggle2.value = true
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 1, 0})
    assertHookCalls(two, {1, 1, 3, 2, 0})
    toggle1.value = false
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 2, 0})
    assertHookCalls(two, {1, 1, 3, 3, 0})
    toggle2.value = false
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 2, 0})
    assertHookCalls(two, {1, 1, 3, 3, 0})
    toggle2.value = true
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 2, 0})
    assertHookCalls(two, {1, 1, 3, 3, 0})
    toggle1.value = true
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 3, 2, 0})
    assertHookCalls(two, {1, 1, 4, 3, 0})
    toggle1.value = false
    toggle2.value = false
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 3, 3, 0})
    assertHookCalls(two, {1, 1, 4, 4, 0})
    toggle1.value = true
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 4, 3, 0})
    assertHookCalls(two, {1, 1, 4, 4, 0})
  end
  )
  function assertNameMatch(props)
    local outerRef = ref(true)
    local viewRef = ref('one')
    local App = {render=function()
      return (outerRef.value and {h(KeepAlive, props, function()
        -- [ts2lua]views下标访问可能不正确
        h(views[viewRef.value])
      end
      -- [ts2lua]lua中0和空字符串也是true，此处outerRef.value需要确认
      )} or {nil})[1]
    end
    }
    render(h(App), root)
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 1, 0, 0})
    assertHookCalls(two, {0, 0, 0, 0, 0})
    viewRef.value = 'two'
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 1, 1, 0})
    assertHookCalls(two, {1, 1, 0, 0, 0})
    viewRef.value = 'one'
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 1, 0})
    assertHookCalls(two, {1, 1, 0, 0, 1})
    viewRef.value = 'two'
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 2, 0})
    assertHookCalls(two, {2, 2, 0, 0, 1})
    outerRef.value = false
    expect(serializeInner(root)):toBe()
    assertHookCalls(one, {1, 1, 2, 2, 1})
    assertHookCalls(two, {2, 2, 0, 0, 2})
  end
  
  describe('props', function()
    test('include (string)', function()
      
    end
    )
    test('include (regex)', function()
      
    end
    )
    test('include (array)', function()
      
    end
    )
    test('exclude (string)', function()
      
    end
    )
    test('exclude (regex)', function()
      
    end
    )
    test('exclude (array)', function()
      
    end
    )
    test('include + exclude', function()
      
    end
    )
    test('max', function()
      local spyA = jest:fn()
      local spyB = jest:fn()
      local spyC = jest:fn()
      local spyAD = jest:fn()
      local spyBD = jest:fn()
      local spyCD = jest:fn()
      function assertCount(calls)
        expect({#spyA.mock.calls, #spyAD.mock.calls, #spyB.mock.calls, #spyBD.mock.calls, #spyC.mock.calls, #spyCD.mock.calls}):toEqual(calls)
      end
      
      local viewRef = ref('a')
      local views = {a={render=function()
        
      end
      , created=spyA, unmounted=spyAD}, b={render=function()
        
      end
      , created=spyB, unmounted=spyBD}, c={render=function()
        
      end
      , created=spyC, unmounted=spyCD}}
      local App = {render=function()
        return h(KeepAlive, {max=2}, function()
          -- [ts2lua]views下标访问可能不正确
          return h(views[viewRef.value])
        end
        )
      end
      }
      render(h(App), root)
      assertCount({1, 0, 0, 0, 0, 0})
      viewRef.value = 'b'
      assertCount({1, 0, 1, 0, 0, 0})
      viewRef.value = 'c'
      assertCount({1, 1, 1, 0, 1, 0})
      viewRef.value = 'b'
      assertCount({1, 1, 1, 0, 1, 0})
      viewRef.value = 'a'
      assertCount({2, 1, 1, 0, 1, 1})
    end
    )
  end
  )
  describe('cache invalidation', function()
    function setup()
      local viewRef = ref('one')
      local includeRef = ref('one,two')
      local App = {render=function()
        return h(KeepAlive, {include=includeRef.value}, function()
          -- [ts2lua]views下标访问可能不正确
          h(views[viewRef.value])
        end
        )
      end
      }
      render(h(App), root)
      return {viewRef=viewRef, includeRef=includeRef}
    end
    
    test('on include/exclude change', function()
      local  = setup()
      viewRef.value = 'two'
      assertHookCalls(one, {1, 1, 1, 1, 0})
      assertHookCalls(two, {1, 1, 1, 0, 0})
      includeRef.value = 'two'
      assertHookCalls(one, {1, 1, 1, 1, 1})
      assertHookCalls(two, {1, 1, 1, 0, 0})
      viewRef.value = 'one'
      assertHookCalls(one, {2, 2, 1, 1, 1})
      assertHookCalls(two, {1, 1, 1, 1, 0})
    end
    )
    test('on include/exclude change + view switch', function()
      local  = setup()
      viewRef.value = 'two'
      assertHookCalls(one, {1, 1, 1, 1, 0})
      assertHookCalls(two, {1, 1, 1, 0, 0})
      includeRef.value = 'one'
      viewRef.value = 'one'
      assertHookCalls(one, {1, 1, 2, 1, 0})
      assertHookCalls(two, {1, 1, 1, 1, 1})
    end
    )
    test('should not prune current active instance', function()
      local  = setup()
      includeRef.value = 'two'
      assertHookCalls(one, {1, 1, 1, 0, 0})
      assertHookCalls(two, {0, 0, 0, 0, 0})
      viewRef.value = 'two'
      assertHookCalls(one, {1, 1, 1, 0, 1})
      assertHookCalls(two, {1, 1, 1, 0, 0})
    end
    )
    function assertAnonymous(include)
      local one = {name='one', created=jest:fn(), render=function()
        'one'
      end
      }
      local two = {created=jest:fn(), render=function()
        'two'
      end
      }
      local views = {one=one, two=two}
      local viewRef = ref('one')
      local App = {render=function()
        -- [ts2lua]lua中0和空字符串也是true，此处include需要确认
        return h(KeepAlive, {include=(include and {'one'} or {undefined})[1]}, function()
          -- [ts2lua]views下标访问可能不正确
          h(views[viewRef.value])
        end
        )
      end
      }
      render(h(App), root)
      function assert(oneCreateCount, twoCreateCount)
        expect(#one.created.mock.calls):toBe(oneCreateCount)
        expect(#two.created.mock.calls):toBe(twoCreateCount)
      end
      
      assert(1, 0)
      viewRef.value = 'two'
      assert(1, 1)
      viewRef.value = 'one'
      assert(1, 1)
      viewRef.value = 'two'
      -- [ts2lua]lua中0和空字符串也是true，此处include需要确认
      assert(1, (include and {2} or {1})[1])
    end
    
    test('should not cache anonymous component when include is specified', function()
      
    end
    )
    test('should cache anonymous components if include is not specified', function()
      
    end
    )
    test('should not destroy active instance when pruning cache', function()
      local Foo = {render=function()
        'foo'
      end
      , unmounted=jest:fn()}
      local includeRef = ref({'foo'})
      local App = {render=function()
        return h(KeepAlive, {include=includeRef.value}, function()
          h(Foo)
        end
        )
      end
      }
      render(h(App), root)
      includeRef.value = {'foo', 'bar'}
      includeRef.value = {}
      expect(Foo.unmounted).tsvar_not:toHaveBeenCalled()
    end
    )
    test('should update re-activated component if props have changed', function()
      local Foo = function(props)
        props.n
      end
      
      local toggle = ref(true)
      local n = ref(0)
      local App = {setup=function()
        return function()
          h(KeepAlive, function()
            -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
            (toggle.value and {h(Foo, {n=n.value})} or {nil})[1]
          end
          )
        end
        
      
      end
      }
      render(h(App), root)
      expect(serializeInner(root)):toBe()
      toggle.value = false
      expect(serializeInner(root)):toBe()
      n.value=n.value+1
      toggle.value = true
      expect(serializeInner(root)):toBe()
    end
    )
  end
  )
  it('should call correct vnode hooks', function()
    local Foo = markRaw({name='Foo', render=function()
      return h('Foo')
    end
    })
    local Bar = markRaw({name='Bar', render=function()
      return h('Bar')
    end
    })
    local spyMounted = jest:fn()
    local spyUnmounted = jest:fn()
    local RouterView = defineComponent({setup=function(_, )
      local Component = inject('component')
      local refView = ref()
      local componentProps = {ref=refView, onVnodeMounted=function()
        spyMounted()
      end
      , onVnodeUnmounted=function()
        spyUnmounted()
      end
      }
      return function()
        local child = ({Component=().value})[0+1]
        local innerChild = child.children[0+1]
        child.children[0+1] = cloneVNode(innerChild, componentProps)
        return child
      end
      
    
    end
    })
    local toggle = function()
      
    end
    
    local App = defineComponent({setup=function()
      local component = ref(Foo)
      provide('component', component)
      toggle = function()
        -- [ts2lua]lua中0和空字符串也是true，此处component.value == Foo需要确认
        component.value = (component.value == Foo and {Bar} or {Foo})[1]
      end
      
      return {component=component, toggle=toggle}
    end
    , render=function()
      return h(RouterView, nil, {default=function()
        h(KeepAlive, nil, {h(Component)})
      end
      })
    end
    })
    render(h(App), root)
    expect(spyMounted):toHaveBeenCalledTimes(1)
    expect(spyUnmounted):toHaveBeenCalledTimes(0)
    toggle()
    expect(spyMounted):toHaveBeenCalledTimes(2)
    expect(spyUnmounted):toHaveBeenCalledTimes(1)
    toggle()
    expect(spyMounted):toHaveBeenCalledTimes(3)
    expect(spyUnmounted):toHaveBeenCalledTimes(2)
    render(nil, root)
    expect(spyMounted):toHaveBeenCalledTimes(3)
    expect(spyUnmounted):toHaveBeenCalledTimes(4)
  end
  )
end
)