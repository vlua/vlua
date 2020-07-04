require("@vue/runtime-test")
require("@vue/shared")

describe('api: options', function()
  test('data', function()
    local Comp = defineComponent({data=function()
      return {foo=1}
    end
    , render=function()
      return h('div', {onClick=function()
        self.foo=self.foo+1
      end
      }, self.foo)
    end
    })
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    triggerEvent(root.children[0+1], 'click')
    expect(serializeInner(root)):toBe()
  end
  )
  test('computed', function()
    local Comp = defineComponent({data=function()
      return {foo=1}
    end
    , computed={bar=function()
      return self.foo + 1
    end
    , baz=function(vm)
      vm.bar + 1
    end
    }, render=function()
      return h('div', {onClick=function()
        self.foo=self.foo+1
      end
      }, self.bar + self.baz)
    end
    })
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    triggerEvent(root.children[0+1], 'click')
    expect(serializeInner(root)):toBe()
  end
  )
  test('methods', function()
    local Comp = defineComponent({data=function()
      return {foo=1}
    end
    , methods={inc=function()
      self.foo=self.foo+1
    end
    }, render=function()
      return h('div', {onClick=self.inc}, self.foo)
    end
    })
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    triggerEvent(root.children[0+1], 'click')
    expect(serializeInner(root)):toBe()
  end
  )
  test('watch', function()
    function returnThis(this)
      return self
    end
    
    local spyA = jest:fn(returnThis)
    local spyB = jest:fn(returnThis)
    local spyC = jest:fn(returnThis)
    local ctx = nil
    local Comp = {data=function()
      return {foo=1, bar=2, baz={qux=3}}
    end
    , watch={foo='onFooChange', bar=spyB, baz={handler=spyC, deep=true}}, methods={onFooChange=spyA}, render=function()
      ctx = self
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    function assertCall(spy, callIndex, args)
      -- [ts2lua]spy.mock.calls下标访问可能不正确
      expect(spy.mock.calls[callIndex]:slice(0, 2)):toMatchObject(args)
      expect(spy):toHaveReturnedWith(ctx)
    end
    
    ctx.foo=ctx.foo+1
    expect(spyA):toHaveBeenCalledTimes(1)
    assertCall(spyA, 0, {2, 1})
    ctx.bar=ctx.bar+1
    expect(spyB):toHaveBeenCalledTimes(1)
    assertCall(spyB, 0, {3, 2})
    ctx.baz.qux=ctx.baz.qux+1
    expect(spyC):toHaveBeenCalledTimes(1)
    assertCall(spyC, 0, {{qux=4}, {qux=4}})
  end
  )
  test('watch array', function()
    function returnThis(this)
      return self
    end
    
    local spyA = jest:fn(returnThis)
    local spyB = jest:fn(returnThis)
    local spyC = jest:fn(returnThis)
    local ctx = nil
    local Comp = {data=function()
      return {foo=1, bar=2, baz={qux=3}}
    end
    , watch={foo={'onFooChange'}, bar={spyB}, baz={{handler=spyC, deep=true}}}, methods={onFooChange=spyA}, render=function()
      ctx = self
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    function assertCall(spy, callIndex, args)
      -- [ts2lua]spy.mock.calls下标访问可能不正确
      expect(spy.mock.calls[callIndex]:slice(0, 2)):toMatchObject(args)
      expect(spy):toHaveReturnedWith(ctx)
    end
    
    ctx.foo=ctx.foo+1
    expect(spyA):toHaveBeenCalledTimes(1)
    assertCall(spyA, 0, {2, 1})
    ctx.bar=ctx.bar+1
    expect(spyB):toHaveBeenCalledTimes(1)
    assertCall(spyB, 0, {3, 2})
    ctx.baz.qux=ctx.baz.qux+1
    expect(spyC):toHaveBeenCalledTimes(1)
    assertCall(spyC, 0, {{qux=4}, {qux=4}})
  end
  )
  test('provide/inject', function()
    local Root = {data=function()
      return {a=1}
    end
    , provide=function()
      return {a=self.a}
    end
    , render=function()
      return {h(ChildA), h(ChildB), h(ChildC), h(ChildD)}
    end
    }
    local ChildA = {inject={'a'}, render=function()
      return self.a
    end
    }
    local ChildB = {inject={b='a'}, render=function()
      return self.b
    end
    }
    local ChildC = {inject={b={from='a'}}, render=function()
      return self.b
    end
    }
    local ChildD = {inject={b={from='c', default=2}}, render=function()
      return self.b
    end
    }
    expect(renderToString(h(Root))):toBe()
  end
  )
  test('lifecycle', function()
    local count = ref(0)
    local root = nodeOps:createElement('div')
    local calls = {}
    local Root = {beforeCreate=function()
      table.insert(calls, 'root beforeCreate')
    end
    , created=function()
      table.insert(calls, 'root created')
    end
    , beforeMount=function()
      table.insert(calls, 'root onBeforeMount')
    end
    , mounted=function()
      table.insert(calls, 'root onMounted')
    end
    , beforeUpdate=function()
      table.insert(calls, 'root onBeforeUpdate')
    end
    , updated=function()
      table.insert(calls, 'root onUpdated')
    end
    , beforeUnmount=function()
      table.insert(calls, 'root onBeforeUnmount')
    end
    , unmounted=function()
      table.insert(calls, 'root onUnmounted')
    end
    , render=function()
      return h(Mid, {count=count.value})
    end
    }
    local Mid = {beforeCreate=function()
      table.insert(calls, 'mid beforeCreate')
    end
    , created=function()
      table.insert(calls, 'mid created')
    end
    , beforeMount=function()
      table.insert(calls, 'mid onBeforeMount')
    end
    , mounted=function()
      table.insert(calls, 'mid onMounted')
    end
    , beforeUpdate=function()
      table.insert(calls, 'mid onBeforeUpdate')
    end
    , updated=function()
      table.insert(calls, 'mid onUpdated')
    end
    , beforeUnmount=function()
      table.insert(calls, 'mid onBeforeUnmount')
    end
    , unmounted=function()
      table.insert(calls, 'mid onUnmounted')
    end
    , render=function(this)
      return h(Child, {count=self.tsvar_props.count})
    end
    }
    local Child = {beforeCreate=function()
      table.insert(calls, 'child beforeCreate')
    end
    , created=function()
      table.insert(calls, 'child created')
    end
    , beforeMount=function()
      table.insert(calls, 'child onBeforeMount')
    end
    , mounted=function()
      table.insert(calls, 'child onMounted')
    end
    , beforeUpdate=function()
      table.insert(calls, 'child onBeforeUpdate')
    end
    , updated=function()
      table.insert(calls, 'child onUpdated')
    end
    , beforeUnmount=function()
      table.insert(calls, 'child onBeforeUnmount')
    end
    , unmounted=function()
      table.insert(calls, 'child onUnmounted')
    end
    , render=function(this)
      return h('div', self.tsvar_props.count)
    end
    }
    render(h(Root), root)
    expect(calls):toEqual({'root beforeCreate', 'root created', 'root onBeforeMount', 'mid beforeCreate', 'mid created', 'mid onBeforeMount', 'child beforeCreate', 'child created', 'child onBeforeMount', 'child onMounted', 'mid onMounted', 'root onMounted'})
    -- [ts2lua]修改数组长度需要手动处理。
    calls.length = 0
    count.value=count.value+1
    expect(calls):toEqual({'root onBeforeUpdate', 'mid onBeforeUpdate', 'child onBeforeUpdate', 'child onUpdated', 'mid onUpdated', 'root onUpdated'})
    -- [ts2lua]修改数组长度需要手动处理。
    calls.length = 0
    render(nil, root)
    expect(calls):toEqual({'root onBeforeUnmount', 'mid onBeforeUnmount', 'child onBeforeUnmount', 'child onUnmounted', 'mid onUnmounted', 'root onUnmounted'})
  end
  )
  test('mixins', function()
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
    local mixinB = {props={bP={type=String}}, data=function()
      return {b=2}
    end
    , created=function(this)
      table.insert(calls, 'mixinB created')
      expect(self.a):toBe(1)
      expect(self.b):toBe(2)
      expect(self.bP):toBeUndefined()
      expect(self.c):toBe(3)
      expect(self.cP1):toBeUndefined()
    end
    , mounted=function()
      table.insert(calls, 'mixinB mounted')
    end
    }
    local mixinC = defineComponent({props={'cP1', 'cP2'}, data=function()
      return {c=3}
    end
    , created=function()
      table.insert(calls, 'mixinC created')
      expect(self.c):toBe(3)
      expect(self.cP1):toBeUndefined()
    end
    , mounted=function()
      table.insert(calls, 'mixinC mounted')
    end
    })
    local Comp = defineComponent({props={aaa=String}, mixins={defineComponent(mixinA), defineComponent(mixinB), mixinC}, data=function()
      return {z=4}
    end
    , created=function()
      table.insert(calls, 'comp created')
      expect(self.a):toBe(1)
      expect(self.b):toBe(2)
      expect(self.bP):toBeUndefined()
      expect(self.c):toBe(3)
      expect(self.cP2):toBeUndefined()
      expect(self.z):toBe(4)
    end
    , mounted=function()
      table.insert(calls, 'comp mounted')
    end
    , render=function()
      return 
    end
    })
    expect(renderToString(h(Comp))):toBe()
    expect(calls):toEqual({'mixinA created', 'mixinB created', 'mixinC created', 'comp created', 'mixinA mounted', 'mixinB mounted', 'mixinC mounted', 'comp mounted'})
  end
  )
  test('extends', function()
    local calls = {}
    local Base = {data=function()
      return {a=1}
    end
    , methods={sayA=function() end}, mounted=function(this)
      expect(self.a):toBe(1)
      expect(self.b):toBe(2)
      table.insert(calls, 'base')
    end
    }
    local Comp = defineComponent({extends=defineComponent(Base), data=function()
      return {b=2}
    end
    , mounted=function()
      table.insert(calls, 'comp')
    end
    , render=function()
      return 
    end
    })
    expect(renderToString(h(Comp))):toBe()
    expect(calls):toEqual({'base', 'comp'})
  end
  )
  test('extends with mixins', function()
    local calls = {}
    local Base = {data=function()
      return {a=1}
    end
    , methods={sayA=function() end}, mounted=function(this)
      expect(self.a):toBe(1)
      expect(self.b):toBeTruthy()
      expect(self.c):toBe(2)
      table.insert(calls, 'base')
    end
    }
    local Base2 = {data=function()
      return {b=true}
    end
    , mounted=function(this)
      expect(self.a):toBe(1)
      expect(self.b):toBeTruthy()
      expect(self.c):toBe(2)
      table.insert(calls, 'base2')
    end
    }
    local Comp = defineComponent({extends=defineComponent(Base), mixins={defineComponent(Base2)}, data=function()
      return {c=2}
    end
    , mounted=function()
      table.insert(calls, 'comp')
    end
    , render=function()
      return 
    end
    })
    expect(renderToString(h(Comp))):toBe()
    expect(calls):toEqual({'base', 'base2', 'comp'})
  end
  )
  test('accessing setup() state from options', function()
    local Comp = defineComponent({setup=function()
      return {count=ref(0)}
    end
    , data=function()
      return {plusOne=self.count + 1}
    end
    , computed={plusTwo=function()
      return self.count + 2
    end
    }, methods={inc=function()
      self.count=self.count+1
    end
    }, render=function()
      return h('div', {onClick=self.inc}, )
    end
    })
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    triggerEvent(root.children[0+1], 'click')
    expect(serializeInner(root)):toBe()
  end
  )
  test('watcher initialization should be deferred in mixins', function()
    local mixin1 = {data=function()
      return {mixin1Data='mixin1'}
    end
    , methods={}}
    local watchSpy = jest:fn()
    local mixin2 = {watch={mixin3Data=watchSpy}}
    local mixin3 = {data=function()
      return {mixin3Data='mixin3'}
    end
    , methods={}}
    local vm = nil
    local Comp = {mixins={mixin1, mixin2, mixin3}, render=function() end, created=function()
      vm = self
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    vm.mixin3Data = 'hello'
    expect(watchSpy.mock.calls[0+1]:slice(0, 2)):toEqual({'hello', 'mixin3'})
  end
  )
  describe('warnings', function()
    mockWarn()
    test('Expected a function as watch handler', function()
      local Comp = {watch={foo='notExistingMethod'}, render=function() end}
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect('Invalid watch handler specified by key "notExistingMethod"'):toHaveBeenWarned()
    end
    )
    test('Invalid watch option', function()
      local Comp = {watch={foo=true}, render=function() end}
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect('Invalid watch option: "foo"'):toHaveBeenWarned()
    end
    )
    test('computed with setter and no getter', function()
      local Comp = {computed={foo={set=function() end}}, render=function() end}
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect('Computed property "foo" has no getter.'):toHaveBeenWarned()
    end
    )
    test('assigning to computed with no setter', function()
      local instance = nil
      local Comp = {computed={foo={get=function() end}}, mounted=function()
        instance = self
      end
      , render=function() end}
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      instance.foo = 1
      expect('Write operation failed: computed property "foo" is readonly'):toHaveBeenWarned()
    end
    )
    test('inject property is already declared in props', function()
      local Comp = {data=function()
        return {a=1}
      end
      , provide=function()
        return {a=self.a}
      end
      , render=function()
        return {h(ChildA)}
      end
      }
      local ChildA = {props={a=Number}, inject={'a'}, render=function()
        return self.a
      end
      }
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect():toHaveBeenWarned()
    end
    )
    test('methods property is not a function', function()
      local Comp = {methods={foo=1}, render=function() end}
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect( + ):toHaveBeenWarned()
    end
    )
    test('methods property is already declared in props', function()
      local Comp = {props={foo=Number}, methods={foo=function() end}, render=function() end}
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect():toHaveBeenWarned()
    end
    )
    test('methods property is already declared in inject', function()
      local Comp = {data=function()
        return {a=1}
      end
      , provide=function()
        return {a=self.a}
      end
      , render=function()
        return {h(ChildA)}
      end
      }
      local ChildA = {methods={a=function()
        nil
      end
      }, inject={'a'}, render=function()
        return self.a
      end
      }
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect():toHaveBeenWarned()
    end
    )
    test('data property is already declared in props', function()
      local Comp = {props={foo=Number}, data=function()
        {foo=1}
      end
      , render=function() end}
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect():toHaveBeenWarned()
    end
    )
    test('data property is already declared in inject', function()
      local Comp = {data=function()
        return {a=1}
      end
      , provide=function()
        return {a=self.a}
      end
      , render=function()
        return {h(ChildA)}
      end
      }
      local ChildA = {data=function()
        return {a=1}
      end
      , inject={'a'}, render=function()
        return self.a
      end
      }
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect():toHaveBeenWarned()
    end
    )
    test('data property is already declared in methods', function()
      local Comp = {data=function()
        {foo=1}
      end
      , methods={foo=function() end}, render=function() end}
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect():toHaveBeenWarned()
    end
    )
    test('computed property is already declared in props', function()
      local Comp = {props={foo=Number}, computed={foo=function() end}, render=function() end}
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect():toHaveBeenWarned()
    end
    )
    test('computed property is already declared in inject', function()
      local Comp = {data=function()
        return {a=1}
      end
      , provide=function()
        return {a=self.a}
      end
      , render=function()
        return {h(ChildA)}
      end
      }
      local ChildA = {computed={a={get=function() end, set=function() end}}, inject={'a'}, render=function()
        return self.a
      end
      }
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect():toHaveBeenWarned()
    end
    )
    test('computed property is already declared in methods', function()
      local Comp = {computed={foo=function() end}, methods={foo=function() end}, render=function() end}
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect():toHaveBeenWarned()
    end
    )
    test('computed property is already declared in data', function()
      local Comp = {data=function()
        {foo=1}
      end
      , computed={foo=function() end}, render=function() end}
      local root = nodeOps:createElement('div')
      render(h(Comp), root)
      expect():toHaveBeenWarned()
    end
    )
  end
  )
end
)