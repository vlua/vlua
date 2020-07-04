require("tableutil")
require("reactivity/src/reactive")
require("reactivity/src/ref")
require("reactivity/src/effect")

describe('reactivity/reactive/Array', function()
  test('should make Array reactive', function()
    local original = {{foo=1}}
    local observed = reactive(original)
    expect(observed).tsvar_not:toBe(original)
    lu.assertEquals(isReactive(observed), true)
    lu.assertEquals(isReactive(original), false)
    lu.assertEquals(isReactive(observed[0+1]), true)
    lu.assertEquals(observed[0+1].foo, 1)
    lu.assertEquals(observed[0], true)
    lu.assertEquals(Object:keys(observed), {'0'})
  end
  )
  test('cloned reactive Array should point to observed values', function()
    local original = {{foo=1}}
    local observed = reactive(original)
    local clone = observed:slice()
    lu.assertEquals(isReactive(clone[0+1]), true)
    expect(clone[0+1]).tsvar_not:toBe(original[0+1])
    lu.assertEquals(clone[0+1], observed[0+1])
  end
  )
  test('observed value should proxy mutations to original (Array)', function()
    local original = {{foo=1}, {bar=2}}
    local observed = reactive(original)
    local value = {baz=3}
    local reactiveValue = reactive(value)
    observed[0+1] = value
    lu.assertEquals(observed[0+1], reactiveValue)
    lu.assertEquals(original[0+1], value)
    observed[0+1] = nil
    expect(observed[0+1]):toBeUndefined()
    expect(original[0+1]):toBeUndefined()
    table.insert(observed, value)
    lu.assertEquals(observed[2+1], reactiveValue)
    lu.assertEquals(original[2+1], value)
  end
  )
  test('Array identity methods should work with raw values', function()
    local raw = {}
    local arr = reactive({{}, {}})
    table.insert(arr, raw)
    lu.assertEquals(arr:find(raw), 2)
    lu.assertEquals(arr:find(raw, 3), -1)
    lu.assertEquals(arr:includes(raw), true)
    lu.assertEquals(arr:includes(raw, 3), false)
    lu.assertEquals(arr:lastIndexOf(raw), 2)
    lu.assertEquals(arr:lastIndexOf(raw, 1), -1)
    local observed = arr[2+1]
    lu.assertEquals(arr:find(observed), 2)
    lu.assertEquals(arr:find(observed, 3), -1)
    lu.assertEquals(arr:includes(observed), true)
    lu.assertEquals(arr:includes(observed, 3), false)
    lu.assertEquals(arr:lastIndexOf(observed), 2)
    lu.assertEquals(arr:lastIndexOf(observed, 1), -1)
  end
  )
  test('Array identity methods should work if raw value contains reactive objects', function()
    local raw = {}
    local obj = reactive({})
    table.insert(raw, obj)
    local arr = reactive(raw)
    lu.assertEquals(arr:includes(obj), true)
  end
  )
  test('Array identity methods should be reactive', function()
    local obj = {}
    local arr = reactive({obj, {}})
    local index = -1
    effect(function()
      index = arr:find(obj)
    end
    )
    lu.assertEquals(index, 0)
    arr:reverse()
    lu.assertEquals(index, 1)
  end
  )
  test('delete on Array should not trigger length dependency', function()
    local arr = reactive({1, 2, 3})
    local fn = jest:fn()
    effect(function()
      fn(#arr)
    end
    )
    fn.toHaveBeenCalledTimes(1)
    arr[1+1] = nil
    fn.toHaveBeenCalledTimes(1)
  end
  )
  describe('Array methods w/ refs', function()
    local original = nil
    beforeEach(function()
      original = reactive({1, ref(2)})
    end
    )
    test('read only copy methods', function()
      local res = table.merge(original, {3, ref(4)})
      local raw = toRaw(res)
      lu.assertEquals(isRef(raw[1+1]), true)
      lu.assertEquals(isRef(raw[3+1]), true)
    end
    )
    test('read + write mutating methods', function()
      local res = original:copyWithin(0, 1, 2)
      local raw = toRaw(res)
      lu.assertEquals(isRef(raw[0+1]), true)
      lu.assertEquals(isRef(raw[1+1]), true)
    end
    )
    test('read + identity', function()
      local ref = original[1+1]
      lu.assertEquals(ref, toRaw(original)[1+1])
      lu.assertEquals(original:find(ref), 1)
    end
    )
  end
  )
end
)