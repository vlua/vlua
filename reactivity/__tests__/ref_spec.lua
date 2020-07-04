require("reactivity/src/index")
require("@vue/runtime-dom")
require("reactivity/src/ref")

describe('reactivity/ref', function()
  it('should hold a value', function()
    local a = ref(1)
    lu.assertEquals(a.value, 1)
    a.value = 2
    lu.assertEquals(a.value, 2)
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
    lu.assertEquals(calls, 1)
    lu.assertEquals(dummy, 1)
    a.value = 2
    lu.assertEquals(calls, 2)
    lu.assertEquals(dummy, 2)
    a.value = 2
    lu.assertEquals(calls, 2)
    lu.assertEquals(dummy, 2)
  end
  )
  it('should make nested properties reactive', function()
    local a = ref({count=1})
    local dummy = nil
    effect(function()
      dummy = a.value.count
    end
    )
    lu.assertEquals(dummy, 1)
    a.value.count = 2
    lu.assertEquals(dummy, 2)
  end
  )
  it('should work without initial value', function()
    local a = ref()
    local dummy = nil
    effect(function()
      dummy = a.value
    end
    )
    lu.assertEquals(dummy, undefined)
    a.value = 2
    lu.assertEquals(dummy, 2)
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
        lu.assertEquals(dummy, val)
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
    lu.assertEquals(type((b.value + 1)), 'number')
  end
  )
  it('should unwrap nested values in types', function()
    local a = {b=ref(0)}
    local c = ref(a)
    lu.assertEquals(type((c.value.b + 1)), 'number')
  end
  )
  it('should NOT unwrap ref types nested inside arrays', function()
    local arr = ref({1, ref(3)}).value
    lu.assertEquals(isRef(arr[0+1]), false)
    lu.assertEquals(isRef(arr[1+1]), true)
    lu.assertEquals(arr[1+1].value, 3)
  end
  )
  it('should keep tuple types', function()
    local tuple = {0, '1', {a=1}, function()
      0
    end
    , ref(0)}
    local tupleRef = ref(tuple)
    tupleRef.value[0+1]=tupleRef.value[0+1]+1
    lu.assertEquals(tupleRef.value[0+1], 1)
    tupleRef.value[1+1] = tupleRef.value[1+1] .. '1'
    lu.assertEquals(tupleRef.value[1+1], '11')
    tupleRef.value[2+1].a=tupleRef.value[2+1].a+1
    lu.assertEquals(tupleRef.value[2+1].a, 2)
    lu.assertEquals(tupleRef.value[3+1](), 0)
    tupleRef.value[4+1].value=tupleRef.value[4+1].value+1
    lu.assertEquals(tupleRef.value[4+1].value, 1)
  end
  )
  it('should keep symbols', function()
    local customSymbol = Symbol()
    local obj = {Symbol.asyncIterator={a=1}, Symbol.unscopables={b='1'}, customSymbol={c={1, 2, 3}}}
    local objRef = ref(obj)
    -- [ts2lua]objRef.value下标访问可能不正确
    -- [ts2lua]obj下标访问可能不正确
    lu.assertEquals(objRef.value[Symbol.asyncIterator], obj[Symbol.asyncIterator])
    -- [ts2lua]objRef.value下标访问可能不正确
    -- [ts2lua]obj下标访问可能不正确
    lu.assertEquals(objRef.value[Symbol.unscopables], obj[Symbol.unscopables])
    -- [ts2lua]objRef.value下标访问可能不正确
    -- [ts2lua]obj下标访问可能不正确
    expect(objRef.value[customSymbol]):toStrictEqual(obj[customSymbol])
  end
  )
  test('unref', function()
    lu.assertEquals(unref(1), 1)
    lu.assertEquals(unref(ref(1)), 1)
  end
  )
  test('shallowRef', function()
    local sref = shallowRef({a=1})
    lu.assertEquals(isReactive(sref.value), false)
    local dummy = nil
    effect(function()
      dummy = sref.value.a
    end
    )
    lu.assertEquals(dummy, 1)
    sref.value = {a=2}
    lu.assertEquals(isReactive(sref.value), false)
    lu.assertEquals(dummy, 2)
  end
  )
  test('shallowRef force trigger', function()
    local sref = shallowRef({a=1})
    local dummy = nil
    effect(function()
      dummy = sref.value.a
    end
    )
    lu.assertEquals(dummy, 1)
    sref.value.a = 2
    lu.assertEquals(dummy, 1)
    triggerRef(sref)
    lu.assertEquals(dummy, 2)
  end
  )
  test('isRef', function()
    lu.assertEquals(isRef(ref(1)), true)
    expect(isRef(computed(function()
      1
    end
    ))):toBe(true)
    lu.assertEquals(isRef(0), false)
    lu.assertEquals(isRef(1), false)
    lu.assertEquals(isRef({value=0}), false)
  end
  )
  test('toRef', function()
    local a = reactive({x=1})
    local x = toRef(a, 'x')
    lu.assertEquals(isRef(x), true)
    lu.assertEquals(x.value, 1)
    a.x = 2
    lu.assertEquals(x.value, 2)
    x.value = 3
    lu.assertEquals(a.x, 3)
    local dummyX = nil
    effect(function()
      dummyX = x.value
    end
    )
    lu.assertEquals(dummyX, x.value)
    a.x = 4
    lu.assertEquals(dummyX, 4)
  end
  )
  test('toRefs', function()
    local a = reactive({x=1, y=2})
    local  = toRefs(a)
    lu.assertEquals(isRef(x), true)
    lu.assertEquals(isRef(y), true)
    lu.assertEquals(x.value, 1)
    lu.assertEquals(y.value, 2)
    a.x = 2
    a.y = 3
    lu.assertEquals(x.value, 2)
    lu.assertEquals(y.value, 3)
    x.value = 3
    y.value = 4
    lu.assertEquals(a.x, 3)
    lu.assertEquals(a.y, 4)
    local dummyX = nil
    local dummyY = nil
    effect(function()
      dummyX = x.value
      dummyY = y.value
    end
    )
    lu.assertEquals(dummyX, x.value)
    lu.assertEquals(dummyY, y.value)
    a.x = 4
    a.y = 5
    lu.assertEquals(dummyX, 4)
    lu.assertEquals(dummyY, 5)
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
    lu.assertEquals(isRef(custom), true)
    local dummy = nil
    effect(function()
      dummy = custom.value
    end
    )
    lu.assertEquals(dummy, 1)
    custom.value = 2
    lu.assertEquals(dummy, 1)
    ()
    lu.assertEquals(dummy, 2)
  end
  )
end
)