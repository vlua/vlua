require("@vue/runtime-test")
require("vue")
require("@vue/shared")
local domRender = render

describe('component props', function()
  mockWarn()
  test('stateful', function()
    local props = nil
    local attrs = nil
    local proxy = nil
    local Comp = defineComponent({props={'fooBar', 'barBaz'}, render=function()
      props = self.tsvar_props
      attrs = self.tsvar_attrs
      proxy = self
    end
    })
    local root = nodeOps:createElement('div')
    render(h(Comp, {fooBar=1, bar=2}), root)
    expect(proxy.fooBar):toBe(1)
    expect(props):toEqual({fooBar=1})
    expect(attrs):toEqual({bar=2})
    render(h(Comp, {foo-bar=2, bar=3, baz=4}), root)
    expect(proxy.fooBar):toBe(2)
    expect(props):toEqual({fooBar=2})
    expect(attrs):toEqual({bar=3, baz=4})
    render(h(Comp, {foo-bar=3, bar=3, baz=4, barBaz=5}), root)
    expect(proxy.fooBar):toBe(3)
    expect(proxy.barBaz):toBe(5)
    expect(props):toEqual({fooBar=3, barBaz=5})
    expect(attrs):toEqual({bar=3, baz=4})
    render(h(Comp, {qux=5}), root)
    expect(proxy.fooBar):toBeUndefined()
    expect(proxy.barBaz):toBeUndefined()
    expect(props):toEqual({})
    expect(attrs):toEqual({qux=5})
  end
  )
  test('stateful with setup', function()
    local props = nil
    local attrs = nil
    local Comp = defineComponent({props={'foo'}, setup=function(_props, )
      return function()
        props = _props
        attrs = _attrs
      end
      
    
    end
    })
    local root = nodeOps:createElement('div')
    render(h(Comp, {foo=1, bar=2}), root)
    expect(props):toEqual({foo=1})
    expect(attrs):toEqual({bar=2})
    render(h(Comp, {foo=2, bar=3, baz=4}), root)
    expect(props):toEqual({foo=2})
    expect(attrs):toEqual({bar=3, baz=4})
    render(h(Comp, {qux=5}), root)
    expect(props):toEqual({})
    expect(attrs):toEqual({qux=5})
  end
  )
  test('functional with declaration', function()
    local props = nil
    local attrs = nil
    local Comp = function(_props, )
      props = _props
      attrs = _attrs
    end
    
    Comp.props = {'foo'}
    local root = nodeOps:createElement('div')
    render(h(Comp, {foo=1, bar=2}), root)
    expect(props):toEqual({foo=1})
    expect(attrs):toEqual({bar=2})
    render(h(Comp, {foo=2, bar=3, baz=4}), root)
    expect(props):toEqual({foo=2})
    expect(attrs):toEqual({bar=3, baz=4})
    render(h(Comp, {qux=5}), root)
    expect(props):toEqual({})
    expect(attrs):toEqual({qux=5})
  end
  )
  test('functional without declaration', function()
    local props = nil
    local attrs = nil
    local Comp = function(_props, )
      props = _props
      attrs = _attrs
    end
    
    local root = nodeOps:createElement('div')
    render(h(Comp, {foo=1}), root)
    expect(props):toEqual({foo=1})
    expect(attrs):toEqual({foo=1})
    expect(props):toBe(attrs)
    render(h(Comp, {bar=2}), root)
    expect(props):toEqual({bar=2})
    expect(attrs):toEqual({bar=2})
    expect(props):toBe(attrs)
  end
  )
  test('boolean casting', function()
    local proxy = nil
    local Comp = {props={foo=Boolean, bar=Boolean, baz=Boolean, qux=Boolean}, render=function()
      proxy = self
    end
    }
    render(h(Comp, {bar='', baz='baz', qux='ok'}), nodeOps:createElement('div'))
    expect(proxy.foo):toBe(false)
    expect(proxy.bar):toBe(true)
    expect(proxy.baz):toBe(true)
    expect(proxy.qux):toBe('ok')
    expect('type check failed for prop "qux"'):toHaveBeenWarned()
  end
  )
  test('default value', function()
    local proxy = nil
    local defaultFn = jest:fn(function()
      {a=1}
    end
    )
    local defaultBaz = jest:fn(function()
      {b=1}
    end
    )
    local Comp = {props={foo={default=1}, bar={default=defaultFn}, baz={type=Function, default=defaultBaz}}, render=function()
      proxy = self
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp, {foo=2}), root)
    expect(proxy.foo):toBe(2)
    local prevBar = proxy.bar
    expect(proxy.bar):toEqual({a=1})
    expect(proxy.baz):toEqual(defaultBaz)
    expect(defaultFn):toHaveBeenCalledTimes(1)
    expect(defaultBaz):toHaveBeenCalledTimes(0)
    render(h(Comp, {foo=3}), root)
    expect(proxy.foo):toBe(3)
    expect(proxy.bar):toEqual({a=1})
    expect(proxy.bar):toBe(prevBar)
    expect(defaultFn):toHaveBeenCalledTimes(1)
    render(h(Comp, {bar={b=2}}), root)
    expect(proxy.foo):toBe(1)
    expect(proxy.bar):toEqual({b=2})
    expect(defaultFn):toHaveBeenCalledTimes(1)
    render(h(Comp, {foo=3, bar={b=3}}), root)
    expect(proxy.foo):toBe(3)
    expect(proxy.bar):toEqual({b=3})
    expect(defaultFn):toHaveBeenCalledTimes(1)
    render(h(Comp, {bar={b=4}}), root)
    expect(proxy.foo):toBe(1)
    expect(proxy.bar):toEqual({b=4})
    expect(defaultFn):toHaveBeenCalledTimes(1)
  end
  )
  test('optimized props updates', function()
    local Child = defineComponent({props={'foo'}, template=})
    local foo = ref(1)
    local id = ref('a')
    local Comp = defineComponent({setup=function()
      return {foo=foo, id=id}
    end
    , components={Child=Child}, template=})
    local root = document:createElement('div')
    domRender(h(Comp), root)
    expect(root.innerHTML):toBe('<div id="a">1</div>')
    foo.value=foo.value+1
    expect(root.innerHTML):toBe('<div id="a">2</div>')
    id.value = 'b'
    expect(root.innerHTML):toBe('<div id="b">2</div>')
  end
  )
  test('warn props mutation', function()
    local instance = nil
    local setupProps = nil
    local Comp = {props={'foo'}, setup=function(props)
      instance = 
      setupProps = props
      return function()
        nil
      end
      
    
    end
    }
    render(h(Comp, {foo=1}), nodeOps:createElement('div'))
    expect(setupProps.foo):toBe(1)
    expect(().props.foo):toBe(1)
    setupProps.foo = 2
    expect():toHaveBeenWarned()
    expect(function()
      
      ().proxy.foo = 2
    end
    ):toThrow(TypeError)
    expect():toHaveBeenWarned()
  end
  )
  test('merging props from mixins and extends', function()
    local setupProps = nil
    local renderProxy = nil
    local E = {props={'base'}}
    local M1 = {props={'m1'}}
    local M2 = {props={m2=nil}}
    local Comp = {props={'self'}, mixins={M1, M2}, extends=E, setup=function(props)
      setupProps = props
    end
    , render=function(this)
      renderProxy = self
      return h('div', {self.self, self.base, self.m1, self.m2})
    end
    }
    local root = nodeOps:createElement('div')
    local props = {self='from self, ', base='from base, ', m1='from mixin 1, ', m2='from mixin 2'}
    render(h(Comp, props), root)
    expect(serializeInner(root)):toMatch()
    expect(setupProps):toMatchObject(props)
    expect(renderProxy.tsvar_props):toMatchObject(props)
  end
  )
end
)