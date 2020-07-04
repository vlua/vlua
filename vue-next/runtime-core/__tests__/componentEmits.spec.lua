require("@vue/shared")
require("@vue/runtime-test")
require("runtime-core/src/componentEmits")

describe('component: emit', function()
  mockWarn()
  test('trigger handlers', function()
    local Foo = defineComponent({render=function() end, created=function()
      self:tsvar_emit('foo')
      self:tsvar_emit('bar')
      self:tsvar_emit('!baz')
    end
    })
    local onfoo = jest:fn()
    local onBar = jest:fn()
    local onBaz = jest:fn()
    local Comp = function()
      h(Foo, {onfoo=onfoo, onBar=onBar, on!baz=onBaz})
    end
    
    render(h(Comp), nodeOps:createElement('div'))
    expect(onfoo).tsvar_not:toHaveBeenCalled()
    expect(onBar):toHaveBeenCalled()
    expect(onBaz):toHaveBeenCalled()
  end
  )
  test('trigger hyphendated events for update:xxx events', function()
    local Foo = defineComponent({render=function() end, created=function()
      self:tsvar_emit('update:fooProp')
      self:tsvar_emit('update:barProp')
    end
    })
    local fooSpy = jest:fn()
    local barSpy = jest:fn()
    local Comp = function()
      h(Foo, {onUpdate:fooProp=fooSpy, onUpdate:bar-prop=barSpy})
    end
    
    render(h(Comp), nodeOps:createElement('div'))
    expect(fooSpy):toHaveBeenCalled()
    expect(barSpy):toHaveBeenCalled()
  end
  )
  test('should trigger array of listeners', function()
    local Child = defineComponent({setup=function(_, )
      emit('foo', 1)
      return function()
        h('div')
      end
      
    
    end
    })
    local fn1 = jest:fn()
    local fn2 = jest:fn()
    local App = {setup=function()
      return function()
        h(Child, {onFoo={fn1, fn2}})
      end
      
    
    end
    }
    render(h(App), nodeOps:createElement('div'))
    expect(fn1):toHaveBeenCalledTimes(1)
    expect(fn1):toHaveBeenCalledWith(1)
    expect(fn2):toHaveBeenCalledTimes(1)
    expect(fn1):toHaveBeenCalledWith(1)
  end
  )
  test('warning for undeclared event (array)', function()
    local Foo = defineComponent({emits={'foo'}, render=function() end, created=function()
      self:tsvar_emit('bar')
    end
    })
    render(h(Foo), nodeOps:createElement('div'))
    expect():toHaveBeenWarned()
  end
  )
  test('warning for undeclared event (object)', function()
    local Foo = defineComponent({emits={foo=nil}, render=function() end, created=function()
      self:tsvar_emit('bar')
    end
    })
    render(h(Foo), nodeOps:createElement('div'))
    expect():toHaveBeenWarned()
  end
  )
  test('should not warn if has equivalent onXXX prop', function()
    local Foo = defineComponent({props={'onFoo'}, emits={}, render=function() end, created=function()
      self:tsvar_emit('foo')
    end
    })
    render(h(Foo), nodeOps:createElement('div'))
    expect().tsvar_not:toHaveBeenWarned()
  end
  )
  test('validator warning', function()
    local Foo = defineComponent({emits={foo=function(arg)
      arg > 0
    end
    }, render=function() end, created=function()
      self:tsvar_emit('foo', -1)
    end
    })
    render(h(Foo), nodeOps:createElement('div'))
    expect():toHaveBeenWarned()
  end
  )
  test('isEmitListener', function()
    expect(isEmitListener({'click'}, 'onClick')):toBe(true)
    expect(isEmitListener({'click'}, 'onclick')):toBe(false)
    expect(isEmitListener({click=nil}, 'onClick')):toBe(true)
    expect(isEmitListener({click=nil}, 'onclick')):toBe(false)
    expect(isEmitListener({'click'}, 'onBlick')):toBe(false)
    expect(isEmitListener({click=nil}, 'onBlick')):toBe(false)
  end
  )
end
)