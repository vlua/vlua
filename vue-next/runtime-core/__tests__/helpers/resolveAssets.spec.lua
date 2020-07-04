require("@vue/runtime-test")
require("@vue/shared")

describe('resolveAssets', function()
  mockWarn()
  test('should work', function()
    local FooBar = function()
      nil
    end
    
    local BarBaz = {mounted=function()
      nil
    end
    }
    local component1 = nil
    local component2 = nil
    local component3 = nil
    local component4 = nil
    local directive1 = nil
    local directive2 = nil
    local directive3 = nil
    local directive4 = nil
    local Root = {components={FooBar=FooBar}, directives={BarBaz=BarBaz}, setup=function()
      return function()
        component1 = 
        directive1 = 
        component2 = 
        directive2 = 
        component3 = 
        directive3 = 
        component4 = 
        directive4 = 
      end
      
    
    end
    }
    local app = createApp(Root)
    local root = nodeOps:createElement('div')
    app:mount(root)
    expect():toBe(FooBar)
    expect():toBe(FooBar)
    expect():toBe(FooBar)
    expect():toBe(FooBar)
    expect():toBe(BarBaz)
    expect():toBe(BarBaz)
    expect():toBe(BarBaz)
    expect():toBe(BarBaz)
  end
  )
  describe('warning', function()
    test('used outside render() or setup()', function()
      resolveComponent('foo')
      expect('resolveComponent can only be used in render() or setup().'):toHaveBeenWarned()
      resolveDirective('foo')
      expect('resolveDirective can only be used in render() or setup().'):toHaveBeenWarned()
    end
    )
    test('not exist', function()
      local Root = {setup=function()
        resolveComponent('foo')
        resolveDirective('bar')
        return function()
          nil
        end
        
      
      end
      }
      local app = createApp(Root)
      local root = nodeOps:createElement('div')
      app:mount(root)
      expect('Failed to resolve component: foo'):toHaveBeenWarned()
      expect('Failed to resolve directive: bar'):toHaveBeenWarned()
    end
    )
    test('resolve dynamic component', function()
      local dynamicComponents = {foo=function()
        'foo'
      end
      , bar=function()
        'bar'
      end
      , baz={render=function()
        'baz'
      end
      }}
      local foo = nil
      local bar = nil
      local baz = nil
      local dynamicVNode = nil
      local Child = {render=function(this)
        return self.tsvar_slots:default()
      end
      }
      local Root = {components={foo=dynamicComponents.foo}, setup=function()
        return function()
          foo = resolveDynamicComponent('foo')
          bar = resolveDynamicComponent(dynamicComponents.bar)
          dynamicVNode = createVNode(resolveDynamicComponent(nil))
          return h(Child, function()
            baz = resolveDynamicComponent(dynamicComponents.baz)
          end
          )
        end
        
      
      end
      }
      local app = createApp(Root)
      local root = nodeOps:createElement('div')
      app:mount(root)
      expect(foo):toBe(dynamicComponents.foo)
      expect(bar):toBe(dynamicComponents.bar)
      expect(baz):toBe(dynamicComponents.baz)
      expect(().type):toBe(Comment)
    end
    )
    test('resolve dynamic component should fallback to plain element without warning', function()
      local Root = {setup=function()
        return function()
          return createVNode(resolveDynamicComponent('div'), nil, {default=function()
            'hello'
          end
          })
        end
        
      
      end
      }
      local app = createApp(Root)
      local root = nodeOps:createElement('div')
      app:mount(root)
      expect(serializeInner(root)):toBe('<div>hello</div>')
    end
    )
  end
  )
end
)