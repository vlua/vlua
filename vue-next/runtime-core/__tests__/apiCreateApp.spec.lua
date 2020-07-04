require("trycatch")
require("@vue/runtime-test")
require("@vue/shared")

describe('api: createApp', function()
  mockWarn()
  test('mount', function()
    local Comp = defineComponent({props={count={default=0}}, setup=function(props)
      return function()
        props.count
      end
      
    
    end
    })
    local root1 = nodeOps:createElement('div')
    createApp(Comp):mount(root1)
    expect(serializeInner(root1)):toBe()
    local root2 = nodeOps:createElement('div')
    local app2 = createApp(Comp, {count=1})
    app2:mount(root2)
    expect(serializeInner(root2)):toBe()
    local root3 = nodeOps:createElement('div')
    app2:mount(root3)
    expect(serializeInner(root3)):toBe()
    expect():toHaveBeenWarned()
  end
  )
  test('unmount', function()
    local Comp = defineComponent({props={count={default=0}}, setup=function(props)
      return function()
        props.count
      end
      
    
    end
    })
    local root = nodeOps:createElement('div')
    local app = createApp(Comp)
    app:mount(root)
    app:unmount(root)
    expect(serializeInner(root)):toBe()
  end
  )
  test('provide', function()
    local Root = {setup=function()
      provide('foo', 3)
      return function()
        h(Child)
      end
      
    
    end
    }
    local Child = {setup=function()
      local foo = inject('foo')
      local bar = inject('bar')
      try_catch{
        main = function()
          inject('__proto__')
        end,
        catch = function(e)
          
        
        end
      }
      return function()
        
      end
      
    
    end
    }
    local app = createApp(Root)
    app:provide('foo', 1)
    app:provide('bar', 2)
    local root = nodeOps:createElement('div')
    app:mount(root)
    expect(serializeInner(root)):toBe()
    expect('[Vue warn]: injection "__proto__" not found.'):toHaveBeenWarned()
  end
  )
  test('component', function()
    local Root = {components={BarBaz=function()
      'barbaz-local!'
    end
    }, setup=function()
      local FooBar = resolveComponent('foo-bar')
      return function()
        local BarBaz = resolveComponent('bar-baz')
        return h('div', {h(FooBar), h(BarBaz)})
      end
      
    
    end
    }
    local app = createApp(Root)
    local FooBar = function()
      'foobar!'
    end
    
    app:component('FooBar', FooBar)
    expect(app:component('FooBar')):toBe(FooBar)
    app:component('BarBaz', function()
      'barbaz!'
    end
    )
    app:component('BarBaz', function()
      'barbaz!'
    end
    )
    expect('Component "BarBaz" has already been registered in target app.'):toHaveBeenWarnedTimes(1)
    local root = nodeOps:createElement('div')
    app:mount(root)
    expect(serializeInner(root)):toBe()
  end
  )
  test('directive', function()
    local spy1 = jest:fn()
    local spy2 = jest:fn()
    local spy3 = jest:fn()
    local Root = {directives={BarBaz={mounted=spy3}}, setup=function()
      local FooBar = nil
      return function()
        local BarBaz = nil
        return withDirectives(h('div'), {{FooBar}, {BarBaz}})
      end
      
    
    end
    }
    local app = createApp(Root)
    local FooBar = {mounted=spy1}
    app:directive('FooBar', FooBar)
    expect(app:directive('FooBar')):toBe(FooBar)
    app:directive('BarBaz', {mounted=spy2})
    app:directive('BarBaz', {mounted=spy2})
    expect('Directive "BarBaz" has already been registered in target app.'):toHaveBeenWarnedTimes(1)
    local root = nodeOps:createElement('div')
    app:mount(root)
    expect(spy1):toHaveBeenCalled()
    expect(spy2).tsvar_not:toHaveBeenCalled()
    expect(spy3):toHaveBeenCalled()
    app:directive('bind', FooBar)
    expect():toHaveBeenWarned()
  end
  )
  test('mixin', function()
    local calls = {}
    local mixinA = {data=function()
      return {a=1}
    end
    , created=function(this)
      table.insert(calls, 'mixinA created')
      expect(self.a):toBe(1)
      expect(self.b):toBe(2)
      expect(self.c):toBe(3)
    end
    , mounted=function()
      table.insert(calls, 'mixinA mounted')
    end
    }
    local mixinB = {name='mixinB', data=function()
      return {b=2}
    end
    , created=function(this)
      table.insert(calls, 'mixinB created')
      expect(self.a):toBe(1)
      expect(self.b):toBe(2)
      expect(self.c):toBe(3)
    end
    , mounted=function()
      table.insert(calls, 'mixinB mounted')
    end
    }
    local Comp = {data=function()
      return {c=3}
    end
    , created=function(this)
      table.insert(calls, 'comp created')
      expect(self.a):toBe(1)
      expect(self.b):toBe(2)
      expect(self.c):toBe(3)
    end
    , mounted=function()
      table.insert(calls, 'comp mounted')
    end
    , render=function(this)
      return 
    end
    }
    local app = createApp(Comp)
    app:mixin(mixinA)
    app:mixin(mixinB)
    app:mixin(mixinA)
    app:mixin(mixinB)
    expect('Mixin has already been applied to target app'):toHaveBeenWarnedTimes(2)
    expect('Mixin has already been applied to target app: mixinB'):toHaveBeenWarnedTimes(1)
    local root = nodeOps:createElement('div')
    app:mount(root)
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({'mixinA created', 'mixinB created', 'comp created', 'mixinA mounted', 'mixinB mounted', 'comp mounted'})
  end
  )
  test('use', function()
    local PluginA = function(app)
      app:provide('foo', 1)
    end
    
    local PluginB = {install=function(app, arg1, arg2)
      app:provide('bar', arg1 + arg2)
    end
    }
    local PluginC = newClass({Class}, {name = 'PluginC'})
    function PluginC:__new__(...)
      self:superCall('__new__', unpack({...}))
      self.someProperty = {};
    end
    
    function PluginC.install()
      app:provide('baz', 2)
    end
    
    local PluginD = undefined
    local Root = {setup=function()
      local foo = inject('foo')
      local bar = inject('bar')
      return function()
        
      end
      
    
    end
    }
    local app = createApp(Root)
    app:use(PluginA)
    app:use(PluginB, 1, 1)
    app:use(PluginC)
    local root = nodeOps:createElement('div')
    app:mount(root)
    expect(serializeInner(root)):toBe()
    app:use(PluginA)
    expect():toHaveBeenWarnedTimes(1)
    app:use(PluginD)
    expect( + ):toHaveBeenWarnedTimes(1)
  end
  )
  test('config.errorHandler', function()
    local error = Error()
    local count = ref(0)
    local handler = jest:fn(function(err, instance, info)
      expect(err):toBe(error)
      expect(instance.count):toBe(count.value)
      expect(info):toBe()
    end
    )
    local Root = {setup=function()
      local count = ref(0)
      return {count=count}
    end
    , render=function()
      error(error)
    end
    }
    local app = createApp(Root)
    app.config.errorHandler = handler
    app:mount(nodeOps:createElement('div'))
    expect(handler):toHaveBeenCalled()
  end
  )
  test('config.warnHandler', function()
    local ctx = nil
    local handler = jest:fn(function(msg, instance, trace)
      expect(msg):toMatch()
      expect(instance):toBe(ctx.proxy)
      expect(trace):toMatch()
    end
    )
    local Root = {name='Hello', setup=function()
      ctx = getCurrentInstance()
    end
    }
    local app = createApp(Root)
    app.config.warnHandler = handler
    app:mount(nodeOps:createElement('div'))
    expect(handler):toHaveBeenCalledTimes(1)
  end
  )
  describe('config.isNativeTag', function()
    local isNativeTag = jest:fn(function(tag)
      tag == 'div'
    end
    )
    test('Component.name', function()
      local Root = {name='div', render=function()
        return nil
      end
      }
      local app = createApp(Root)
      Object:defineProperty(app.config, 'isNativeTag', {value=isNativeTag, writable=false})
      app:mount(nodeOps:createElement('div'))
      expect():toHaveBeenWarned()
    end
    )
    test('Component.components', function()
      local Root = {components={div=function()
        'div'
      end
      }, render=function()
        return nil
      end
      }
      local app = createApp(Root)
      Object:defineProperty(app.config, 'isNativeTag', {value=isNativeTag, writable=false})
      app:mount(nodeOps:createElement('div'))
      expect():toHaveBeenWarned()
    end
    )
    test('Component.directives', function()
      local Root = {directives={bind=function()
        
      end
      }, render=function()
        return nil
      end
      }
      local app = createApp(Root)
      Object:defineProperty(app.config, 'isNativeTag', {value=isNativeTag, writable=false})
      app:mount(nodeOps:createElement('div'))
      expect():toHaveBeenWarned()
    end
    )
    test('register using app.component', function()
      local app = createApp({render=function() end})
      Object:defineProperty(app.config, 'isNativeTag', {value=isNativeTag, writable=false})
      app:component('div', function()
        'div'
      end
      )
      app:mount(nodeOps:createElement('div'))
      expect():toHaveBeenWarned()
    end
    )
  end
  )
  test('config.optionMergeStrategies', function()
    local merged = nil
    local App = defineComponent({render=function() end, mixins={{foo='mixin'}}, extends={foo='extends'}, foo='local', beforeCreate=function()
      merged = self.tsvar_options.foo
    end
    })
    local app = createApp(App)
    app:mixin({foo='global'})
    app.config.optionMergeStrategies.foo = function(a, b)
      -- [ts2lua]lua中0和空字符串也是true，此处a需要确认
      (a and {} or {})[1] + b
    end
    
    app:mount(nodeOps:createElement('div'))
    expect():toBe('global,extends,mixin,local')
  end
  )
  test('config.globalProperties', function()
    local app = createApp({render=function()
      return self.foo
    end
    })
    app.config.globalProperties.foo = 'hello'
    local root = nodeOps:createElement('div')
    app:mount(root)
    expect(serializeInner(root)):toBe('hello')
  end
  )
end
)