require("date")
require("reactivity/src/ref")
require("reactivity/src/reactive")
require("@vue/shared")
require("reactivity/src/computed")

describe('reactivity/reactive', function()
  mockWarn()
  test('Object', function()
    local original = {foo=1}
    local observed = reactive(original)
    expect(observed).tsvar_not:toBe(original)
    lu.assertEquals(isReactive(observed), true)
    lu.assertEquals(isReactive(original), false)
    lu.assertEquals(observed.foo, 1)
    lu.assertEquals(observed['foo'], true)
    expect(Object:keys(observed)):toEqual({'foo'})
  end
  )
  test('proto', function()
    local obj = {}
    local reactiveObj = reactive(obj)
    lu.assertEquals(isReactive(reactiveObj), true)
    -- [ts2lua]reactiveObj下标访问可能不正确
    local prototype = reactiveObj['__proto__']
    local otherObj = {data={'a'}}
    lu.assertEquals(isReactive(otherObj), false)
    local reactiveOther = reactive(otherObj)
    lu.assertEquals(isReactive(reactiveOther), true)
    lu.assertEquals(reactiveOther.data[0+1], 'a')
  end
  )
  test('nested reactives', function()
    local original = {nested={foo=1}, array={{bar=2}}}
    local observed = reactive(original)
    lu.assertEquals(isReactive(observed.nested), true)
    lu.assertEquals(isReactive(observed.array), true)
    lu.assertEquals(isReactive(observed.array[0+1]), true)
  end
  )
  test('observed value should proxy mutations to original (Object)', function()
    local original = {foo=1}
    local observed = reactive(original)
    observed.bar = 1
    lu.assertEquals(observed.bar, 1)
    lu.assertEquals(original.bar, 1)
    observed.foo = nil
    lu.assertEquals(observed['foo'], false)
    lu.assertEquals(original['foo'], false)
  end
  )
  test('setting a property with an unobserved value should wrap with reactive', function()
    local observed = reactive({})
    local raw = {}
    observed.foo = raw
    expect(observed.foo).tsvar_not:toBe(raw)
    lu.assertEquals(isReactive(observed.foo), true)
  end
  )
  test('observing already observed value should return same Proxy', function()
    local original = {foo=1}
    local observed = reactive(original)
    local observed2 = reactive(observed)
    lu.assertEquals(observed2, observed)
  end
  )
  test('observing the same value multiple times should return same Proxy', function()
    local original = {foo=1}
    local observed = reactive(original)
    local observed2 = reactive(original)
    lu.assertEquals(observed2, observed)
  end
  )
  test('should not pollute original object with Proxies', function()
    local original = {foo=1}
    local original2 = {bar=2}
    local observed = reactive(original)
    local observed2 = reactive(original2)
    observed.bar = observed2
    lu.assertEquals(observed.bar, observed2)
    lu.assertEquals(original.bar, original2)
  end
  )
  test('toRaw', function()
    local original = {foo=1}
    local observed = reactive(original)
    lu.assertEquals(toRaw(observed), original)
    lu.assertEquals(toRaw(original), original)
  end
  )
  test('toRaw on object using reactive as prototype', function()
    local original = reactive({})
    local obj = Object:create(original)
    local raw = toRaw(obj)
    lu.assertEquals(raw, obj)
    expect(raw).tsvar_not:toBe(toRaw(original))
  end
  )
  test('should not unwrap Ref<T>', function()
    local observedNumberRef = reactive(ref(1))
    local observedObjectRef = reactive(ref({foo=1}))
    lu.assertEquals(isRef(observedNumberRef), true)
    lu.assertEquals(isRef(observedObjectRef), true)
  end
  )
  test('should unwrap computed refs', function()
    local a = computed(function()
      1
    end
    )
    local b = computed({get=function()
      1
    end
    , set=function()
      
    end
    })
    local obj = reactive({a=a, b=b})
    obj.a + 1
    obj.b + 1
    lu.assertEquals(type(obj.a), )
    lu.assertEquals(type(obj.b), )
  end
  )
  test('should allow setting property from a ref to another ref', function()
    local foo = ref(0)
    local bar = ref(1)
    local observed = reactive({a=foo})
    local dummy = computed(function()
      observed.a
    end
    )
    lu.assertEquals(dummy.value, 0)
    observed.a = bar
    lu.assertEquals(dummy.value, 1)
    bar.value=bar.value+1
    lu.assertEquals(dummy.value, 2)
  end
  )
  test('non-observable values', function()
    local assertValue = function(value)
      reactive(value)
      expect():toHaveBeenWarnedLast()
    end
    
    assertValue(1)
    assertValue('foo')
    assertValue(false)
    assertValue(nil)
    assertValue(undefined)
    local s = Symbol()
    assertValue(s)
    local p = Promise:resolve()
    lu.assertEquals(reactive(p), p)
    local r = ''
    lu.assertEquals(reactive(r), r)
    local d = Date()
    lu.assertEquals(reactive(d), d)
  end
  )
  test('markRaw', function()
    local obj = reactive({foo={a=1}, bar=markRaw({b=2})})
    lu.assertEquals(isReactive(obj.foo), true)
    lu.assertEquals(isReactive(obj.bar), false)
  end
  )
  test('should not observe frozen objects', function()
    local obj = reactive({foo=Object:freeze({a=1})})
    lu.assertEquals(isReactive(obj.foo), false)
  end
  )
  test('should not observe objects with __v_skip', function()
    local original = {foo=1, __v_skip=true}
    local observed = reactive(original)
    lu.assertEquals(isReactive(observed), false)
  end
  )
end
)