require("runtime-core/src/index")
require("@vue/runtime-test")
require("@vue/shared")

describe('api: provide/inject', function()
  mockWarn()
  it('string keys', function()
    local Provider = {setup=function()
      provide('foo', 1)
      return function()
        h(Middle)
      end
      
    
    end
    }
    local Middle = {render=function()
      h(Consumer)
    end
    }
    local Consumer = {setup=function()
      local foo = inject('foo')
      return function()
        foo
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Provider), root)
    expect(serialize(root)):toBe()
  end
  )
  it('symbol keys', function()
    local key = Symbol()
    local Provider = {setup=function()
      provide(key, 1)
      return function()
        h(Middle)
      end
      
    
    end
    }
    local Middle = {render=function()
      h(Consumer)
    end
    }
    local Consumer = {setup=function()
      local foo = inject(key) or 1
      return function()
        foo + 1
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Provider), root)
    expect(serialize(root)):toBe()
  end
  )
  it('default values', function()
    local Provider = {setup=function()
      provide('foo', 'foo')
      return function()
        h(Middle)
      end
      
    
    end
    }
    local Middle = {render=function()
      h(Consumer)
    end
    }
    local Consumer = {setup=function()
      local foo = inject('foo', 'fooDefault')
      local bar = inject('bar', 'bar')
      return function()
        foo + bar
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Provider), root)
    expect(serialize(root)):toBe()
  end
  )
  it('nested providers', function()
    local ProviderOne = {setup=function()
      provide('foo', 'foo')
      provide('bar', 'bar')
      return function()
        h(ProviderTwo)
      end
      
    
    end
    }
    local ProviderTwo = {setup=function()
      provide('foo', 'fooOverride')
      provide('baz', 'baz')
      return function()
        h(Consumer)
      end
      
    
    end
    }
    local Consumer = {setup=function()
      local foo = inject('foo')
      local bar = inject('bar')
      local baz = inject('baz')
      return function()
        ({foo, bar, baz}):join(',')
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(ProviderOne), root)
    expect(serialize(root)):toBe()
  end
  )
  it('reactivity with refs', function()
    local count = ref(1)
    local Provider = {setup=function()
      provide('count', count)
      return function()
        h(Middle)
      end
      
    
    end
    }
    local Middle = {render=function()
      h(Consumer)
    end
    }
    local Consumer = {setup=function()
      local count = inject('count')
      return function()
        count.value
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Provider), root)
    expect(serialize(root)):toBe()
    count.value=count.value+1
    expect(serialize(root)):toBe()
  end
  )
  it('reactivity with readonly refs', function()
    local count = ref(1)
    local Provider = {setup=function()
      provide('count', readonly(count))
      return function()
        h(Middle)
      end
      
    
    end
    }
    local Middle = {render=function()
      h(Consumer)
    end
    }
    local Consumer = {setup=function()
      local count = inject('count')
      count.value=count.value+1
      return function()
        count.value
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Provider), root)
    expect(serialize(root)):toBe()
    expect():toHaveBeenWarned()
    count.value=count.value+1
    expect(serialize(root)):toBe()
  end
  )
  it('reactivity with objects', function()
    local rootState = reactive({count=1})
    local Provider = {setup=function()
      provide('state', rootState)
      return function()
        h(Middle)
      end
      
    
    end
    }
    local Middle = {render=function()
      h(Consumer)
    end
    }
    local Consumer = {setup=function()
      local state = inject('state')
      return function()
        state.count
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Provider), root)
    expect(serialize(root)):toBe()
    rootState.count=rootState.count+1
    expect(serialize(root)):toBe()
  end
  )
  it('reactivity with readonly objects', function()
    local rootState = reactive({count=1})
    local Provider = {setup=function()
      provide('state', readonly(rootState))
      return function()
        h(Middle)
      end
      
    
    end
    }
    local Middle = {render=function()
      h(Consumer)
    end
    }
    local Consumer = {setup=function()
      local state = inject('state')
      state.count=state.count+1
      return function()
        state.count
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Provider), root)
    expect(serialize(root)):toBe()
    expect():toHaveBeenWarned()
    rootState.count=rootState.count+1
    expect(serialize(root)):toBe()
  end
  )
  it('should warn unfound', function()
    local Provider = {setup=function()
      return function()
        h(Middle)
      end
      
    
    end
    }
    local Middle = {render=function()
      h(Consumer)
    end
    }
    local Consumer = {setup=function()
      local foo = inject('foo')
      expect(foo):toBeUndefined()
      return function()
        foo
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Provider), root)
    expect(serialize(root)):toBe()
    expect():toHaveBeenWarned()
  end
  )
  it('should not warn when default value is undefined', function()
    local Provider = {setup=function()
      return function()
        h(Middle)
      end
      
    
    end
    }
    local Middle = {render=function()
      h(Consumer)
    end
    }
    local Consumer = {setup=function()
      local foo = inject('foo', undefined)
      return function()
        foo
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Provider), root)
    expect().tsvar_not:toHaveBeenWarned()
  end
  )
end
)