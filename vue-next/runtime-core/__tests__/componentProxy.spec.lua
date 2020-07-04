require("@vue/runtime-test")
require("@vue/shared")

describe('component: proxy', function()
  mockWarn()
  test('data', function()
    local instance = nil
    local instanceProxy = nil
    local Comp = {data=function()
      return {foo=1}
    end
    , mounted=function()
      instance = 
      instanceProxy = self
    end
    , render=function()
      return nil
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect(instanceProxy.foo):toBe(1)
    instanceProxy.foo = 2
    expect(().data.foo):toBe(2)
  end
  )
  test('setupState', function()
    local instance = nil
    local instanceProxy = nil
    local Comp = {setup=function()
      return {foo=1}
    end
    , mounted=function()
      instance = 
      instanceProxy = self
    end
    , render=function()
      return nil
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect(instanceProxy.foo):toBe(1)
    instanceProxy.foo = 2
    expect(().setupState.foo):toBe(2)
  end
  )
  test('should not expose non-declared props', function()
    local instanceProxy = nil
    local Comp = {setup=function()
      return function()
        nil
      end
      
    
    end
    , mounted=function()
      instanceProxy = self
    end
    }
    render(h(Comp, {count=1}), nodeOps:createElement('div'))
    expect(instanceProxy['count']):toBe(false)
  end
  )
  test('public properties', function()
    local instance = nil
    local instanceProxy = nil
    local Comp = {setup=function()
      return function()
        nil
      end
      
    
    end
    , mounted=function()
      instance = 
      instanceProxy = self
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect(instanceProxy.tsvar_data):toBe(().data)
    expect(instanceProxy.tsvar_props):toBe(shallowReadonly(().props))
    expect(instanceProxy.tsvar_attrs):toBe(shallowReadonly(().attrs))
    expect(instanceProxy.tsvar_slots):toBe(shallowReadonly(().slots))
    expect(instanceProxy.tsvar_refs):toBe(shallowReadonly(().refs))
    expect(instanceProxy.tsvar_parent):toBe(().parent and ().parent.proxy)
    expect(instanceProxy.tsvar_root):toBe(().root.proxy)
    expect(instanceProxy.tsvar_emit):toBe(().emit)
    expect(instanceProxy.tsvar_el):toBe(().vnode.el)
    expect(instanceProxy.tsvar_options):toBe(().type)
    expect(function()
      instanceProxy.tsvar_data = {}
    end
    ):toThrow(TypeError)
    expect():toHaveBeenWarned()
  end
  )
  test('user attached properties', function()
    local instance = nil
    local instanceProxy = nil
    local Comp = {setup=function()
      return function()
        nil
      end
      
    
    end
    , mounted=function()
      instance = 
      instanceProxy = self
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    instanceProxy.foo = 1
    expect(instanceProxy.foo):toBe(1)
    expect(().ctx.foo):toBe(1)
    instanceProxy.tsvar_store = {}
    local obj = instanceProxy.tsvar_store
    expect(instanceProxy.tsvar_store):toBe(obj)
    expect(().ctx.tsvar_store):toBe(obj)
  end
  )
  test('globalProperties', function()
    local instance = nil
    local instanceProxy = nil
    local Comp = {setup=function()
      return function()
        nil
      end
      
    
    end
    , mounted=function()
      instance = 
      instanceProxy = self
    end
    }
    local app = createApp(Comp)
    app.config.globalProperties.foo = 1
    app:mount(nodeOps:createElement('div'))
    expect(instanceProxy.foo):toBe(1)
    instanceProxy.foo = 2
    expect(().ctx.foo):toBe(2)
    expect(app.config.globalProperties.foo):toBe(1)
  end
  )
  test('has check', function()
    local instanceProxy = nil
    local Comp = {render=function() end, props={msg=String}, data=function()
      return {foo=0}
    end
    , setup=function()
      return {bar=1}
    end
    , mounted=function()
      instanceProxy = self
    end
    }
    local app = createApp(Comp, {msg='hello'})
    app.config.globalProperties.global = 1
    app:mount(nodeOps:createElement('div'))
    expect(instanceProxy['msg']):toBe(true)
    expect(instanceProxy['foo']):toBe(true)
    expect(instanceProxy['bar']):toBe(true)
    expect(instanceProxy['$el']):toBe(true)
    expect(instanceProxy['global']):toBe(true)
    expect(instanceProxy['$foobar']):toBe(false)
    expect(instanceProxy['baz']):toBe(false)
    instanceProxy.baz = 1
    expect(instanceProxy['baz']):toBe(true)
    expect(Object:keys(instanceProxy)):toMatchObject({'msg', 'bar', 'foo', 'baz'})
  end
  )
  test('should not warn declared but absent props', function()
    local Comp = {props={'test'}, render=function(this)
      return self.test
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect().tsvar_not:toHaveBeenWarned()
  end
  )
end
)