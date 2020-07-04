require("reactivity/src/index")
require("@vue/runtime-dom")
require("reactivity/src/ref")

describe('reactivity/ref', function()
  it('should hold a value', function()
    local a = ref(1)
    expect(a.value):toBe(1)
    a.value = 2
    expect(a.value):toBe(2)
  end
  )
  it('should be reactive', function()
    local a = ref(1)
    local dummy = nil
    local calls = 0
    effect(function()
      calls=calls+1
      dummy = a.value
    end
    )
    expect(calls):toBe(1)
    expect(dummy):toBe(1)
    a.value = 2
    expect(calls):toBe(2)
    expect(dummy):toBe(2)
    a.value = 2
    expect(calls):toBe(2)
    expect(dummy):toBe(2)
  end
  )
  it('should make nested properties reactive', function()
    local a = ref({count=1})
    local dummy = nil
    effect(function()
      dummy = a.value.count
    end
    )
    expect(dummy):toBe(1)
    a.value.count = 2
    expect(dummy):toBe(2)
  end
  )
  it('should work without initial value', function()
    local a = ref()
    local dummy = nil
    effect(function()
      dummy = a.value
    end
    )
    expect(dummy):toBe(undefined)
    a.value = 2
    expect(dummy):toBe(2)
  end
  )
  it('should work like a normal property when nested in a reactive object', function()
    local a = ref(1)
    local obj = reactive({a=a, b={c=a}})
    local dummy1 = nil
    local dummy2 = nil
    effect(function()
      dummy1 = obj.a
      dummy2 = obj.b.c
    end
    )
    local assertDummiesEqualTo = function(val)
      ({dummy1, dummy2}):forEach(function(dummy)
        expect(dummy):toBe(val)
      end
      )
    end
    
    assertDummiesEqualTo(1)
    a.value=a.value+1
    assertDummiesEqualTo(2)
    obj.a=obj.a+1
    assertDummiesEqualTo(3)
    obj.b.c=obj.b.c+1
    assertDummiesEqualTo(4)
  end
  )
  it('should unwrap nested ref in types', function()
    local a = ref(0)
    local b = ref(a)
    expect(type((b.value + 1))):toBe('number')
  end
  )
  it('should unwrap nested values in types', function()
    local a = {b=ref(0)}
    local c = ref(a)
    expect(type((c.value.b + 1))):toBe('number')
  end
  )
  it('should NOT unwrap ref types nested inside arrays', function()
    local arr = ref({1, ref(3)}).value
    expect(isRef(arr[0+1])):toBe(false)
    expect(isRef(arr[1+1])):toBe(true)
    expect(arr[1+1].value):toBe(3)
  end
  )
  it('should keep tuple types', function()
    local tuple = {0, '1', {a=1}, function()
      0
    end
    , ref(0)}
    local tupleRef = ref(tuple)
    tupleRef.value[0+1]=tupleRef.value[0+1]+1
    expect(tupleRef.value[0+1]):toBe(1)
    tupleRef.value[1+1] = tupleRef.value[1+1] .. '1'
    expect(tupleRef.value[1+1]):toBe('11')
    tupleRef.value[2+1].a=tupleRef.value[2+1].a+1
    expect(tupleRef.value[2+1].a):toBe(2)
    expect(tupleRef.value[3+1]()):toBe(0)
    tupleRef.value[4+1].value=tupleRef.value[4+1].value+1
    expect(tupleRef.value[4+1].value):toBe(1)
  end
  )
  it('should keep symbols', function()
    local customSymbol = Symbol()
    local obj = {Symbol.asyncIterator={a=1}, Symbol.unscopables={b='1'}, customSymbol={c={1, 2, 3}}}
    local objRef = ref(obj)
    -- [ts2lua]objRef.value下标访问可能不正确
    -- [ts2lua]obj下标访问可能不正确
    expect(objRef.value[Symbol.asyncIterator]):toBe(obj[Symbol.asyncIterator])
    -- [ts2lua]objRef.value下标访问可能不正确
    -- [ts2lua]obj下标访问可能不正确
    expect(objRef.value[Symbol.unscopables]):toBe(obj[Symbol.unscopables])
    -- [ts2lua]objRef.value下标访问可能不正确
    -- [ts2lua]obj下标访问可能不正确
    expect(objRef.value[customSymbol]):toStrictEqual(obj[customSymbol])
  end
  )
  test('unref', function()
    expect(unref(1)):toBe(1)
    expect(unref(ref(1))):toBe(1)
  end
  )
  test('shallowRef', function()
    local sref = shallowRef({a=1})
    expect(isReactive(sref.value)):toBe(false)
    local dummy = nil
    effect(function()
      dummy = sref.value.a
    end
    )
    expect(dummy):toBe(1)
    sref.value = {a=2}
    expect(isReactive(sref.value)):toBe(false)
    expect(dummy):toBe(2)
  end
  )
  test('shallowRef force trigger', function()
    local sref = shallowRef({a=1})
    local dummy = nil
    effect(function()
      dummy = sref.value.a
    end
    )
    expect(dummy):toBe(1)
    sref.value.a = 2
    expect(dummy):toBe(1)
    triggerRef(sref)
    expect(dummy):toBe(2)
  end
  )
  test('isRef', function()
    expect(isRef(ref(1))):toBe(true)
    expect(isRef(computed(function()
      1
    end
    ))):toBe(true)
    expect(isRef(0)):toBe(false)
    expect(isRef(1)):toBe(false)
    expect(isRef({value=0})):toBe(false)
  end
  )
  test('toRef', function()
    local a = reactive({x=1})
    local x = toRef(a, 'x')
    expect(isRef(x)):toBe(true)
    expect(x.value):toBe(1)
    a.x = 2
    expect(x.value):toBe(2)
    x.value = 3
    expect(a.x):toBe(3)
    local dummyX = nil
    effect(function()
      dummyX = x.value
    end
    )
    expect(dummyX):toBe(x.value)
    a.x = 4
    expect(dummyX):toBe(4)
  end
  )
  test('toRefs', function()
    local a = reactive({x=1, y=2})
    local  = toRefs(a)
    expect(isRef(x)):toBe(true)
    expect(isRef(y)):toBe(true)
    expect(x.value):toBe(1)
    expect(y.value):toBe(2)
    a.x = 2
    a.y = 3
    expect(x.value):toBe(2)
    expect(y.value):toBe(3)
    x.value = 3
    y.value = 4
    expect(a.x):toBe(3)
    expect(a.y):toBe(4)
    local dummyX = nil
    local dummyY = nil
    effect(function()
      dummyX = x.value
      dummyY = y.value
    end
    )
    expect(dummyX):toBe(x.value)
    expect(dummyY):toBe(y.value)
    a.x = 4
    a.y = 5
    expect(dummyX):toBe(4)
    expect(dummyY):toBe(5)
  end
  )
  test('toRefs pass a reactivity object', function()
    console.warn = jest:fn()
    local obj = {x=1}
    toRefs(obj)
    expect(console.warn):toBeCalled()
  end
  )
  test('customRef', function()
    local value = 1
    local _trigger = nil
    local custom = customRef(function(track, trigger)
      {get=function()
        track()
        return value
      end
      , set=function(newValue)
        value = newValue
        _trigger = trigger
      end
      }
    end
    )
    expect(isRef(custom)):toBe(true)
    local dummy = nil
    effect(function()
      dummy = custom.value
    end
    )
    expect(dummy):toBe(1)
    custom.value = 2
    expect(dummy):toBe(1)
    ()
    expect(dummy):toBe(2)
  end
  )
end
)