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
    expect(isReactive(observed)):toBe(true)
    expect(isReactive(original)):toBe(false)
    expect(observed.foo):toBe(1)
    expect(observed['foo']):toBe(true)
    expect(Object:keys(observed)):toEqual({'foo'})
  end
  )
  test('proto', function()
    local obj = {}
    local reactiveObj = reactive(obj)
    expect(isReactive(reactiveObj)):toBe(true)
    -- [ts2lua]reactiveObj下标访问可能不正确
    local prototype = reactiveObj['__proto__']
    local otherObj = {data={'a'}}
    expect(isReactive(otherObj)):toBe(false)
    local reactiveOther = reactive(otherObj)
    expect(isReactive(reactiveOther)):toBe(true)
    expect(reactiveOther.data[0+1]):toBe('a')
  end
  )
  test('nested reactives', function()
    local original = {nested={foo=1}, array={{bar=2}}}
    local observed = reactive(original)
    expect(isReactive(observed.nested)):toBe(true)
    expect(isReactive(observed.array)):toBe(true)
    expect(isReactive(observed.array[0+1])):toBe(true)
  end
  )
  test('observed value should proxy mutations to original (Object)', function()
    local original = {foo=1}
    local observed = reactive(original)
    observed.bar = 1
    expect(observed.bar):toBe(1)
    expect(original.bar):toBe(1)
    observed.foo = nil
    expect(observed['foo']):toBe(false)
    expect(original['foo']):toBe(false)
  end
  )
  test('setting a property with an unobserved value should wrap with reactive', function()
    local observed = reactive({})
    local raw = {}
    observed.foo = raw
    expect(observed.foo).tsvar_not:toBe(raw)
    expect(isReactive(observed.foo)):toBe(true)
  end
  )
  test('observing already observed value should return same Proxy', function()
    local original = {foo=1}
    local observed = reactive(original)
    local observed2 = reactive(observed)
    expect(observed2):toBe(observed)
  end
  )
  test('observing the same value multiple times should return same Proxy', function()
    local original = {foo=1}
    local observed = reactive(original)
    local observed2 = reactive(original)
    expect(observed2):toBe(observed)
  end
  )
  test('should not pollute original object with Proxies', function()
    local original = {foo=1}
    local original2 = {bar=2}
    local observed = reactive(original)
    local observed2 = reactive(original2)
    observed.bar = observed2
    expect(observed.bar):toBe(observed2)
    expect(original.bar):toBe(original2)
  end
  )
  test('toRaw', function()
    local original = {foo=1}
    local observed = reactive(original)
    expect(toRaw(observed)):toBe(original)
    expect(toRaw(original)):toBe(original)
  end
  )
  test('toRaw on object using reactive as prototype', function()
    local original = reactive({})
    local obj = Object:create(original)
    local raw = toRaw(obj)
    expect(raw):toBe(obj)
    expect(raw).tsvar_not:toBe(toRaw(original))
  end
  )
  test('should not unwrap Ref<T>', function()
    local observedNumberRef = reactive(ref(1))
    local observedObjectRef = reactive(ref({foo=1}))
    expect(isRef(observedNumberRef)):toBe(true)
    expect(isRef(observedObjectRef)):toBe(true)
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
    expect(type(obj.a)):toBe()
    expect(type(obj.b)):toBe()
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
    expect(dummy.value):toBe(0)
    observed.a = bar
    expect(dummy.value):toBe(1)
    bar.value=bar.value+1
    expect(dummy.value):toBe(2)
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
    expect(reactive(p)):toBe(p)
    local r = ''
    expect(reactive(r)):toBe(r)
    local d = Date()
    expect(reactive(d)):toBe(d)
  end
  )
  test('markRaw', function()
    local obj = reactive({foo={a=1}, bar=markRaw({b=2})})
    expect(isReactive(obj.foo)):toBe(true)
    expect(isReactive(obj.bar)):toBe(false)
  end
  )
  test('should not observe frozen objects', function()
    local obj = reactive({foo=Object:freeze({a=1})})
    expect(isReactive(obj.foo)):toBe(false)
  end
  )
  test('should not observe objects with __v_skip', function()
    local original = {foo=1, __v_skip=true}
    local observed = reactive(original)
    expect(isReactive(observed)):toBe(false)
  end
  )
end
)