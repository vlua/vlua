require("tableutil")
require("reactivity/src/reactive")
require("reactivity/src/ref")
require("reactivity/src/effect")

describe('reactivity/reactive/Array', function()
  test('should make Array reactive', function()
    local original = {{foo=1}}
    local observed = reactive(original)
    expect(observed).tsvar_not:toBe(original)
    expect(isReactive(observed)):toBe(true)
    expect(isReactive(original)):toBe(false)
    expect(isReactive(observed[0+1])):toBe(true)
    expect(observed[0+1].foo):toBe(1)
    expect(observed[0]):toBe(true)
    expect(Object:keys(observed)):toEqual({'0'})
  end
  )
  test('cloned reactive Array should point to observed values', function()
    local original = {{foo=1}}
    local observed = reactive(original)
    local clone = observed:slice()
    expect(isReactive(clone[0+1])):toBe(true)
    expect(clone[0+1]).tsvar_not:toBe(original[0+1])
    expect(clone[0+1]):toBe(observed[0+1])
  end
  )
  test('observed value should proxy mutations to original (Array)', function()
    local original = {{foo=1}, {bar=2}}
    local observed = reactive(original)
    local value = {baz=3}
    local reactiveValue = reactive(value)
    observed[0+1] = value
    expect(observed[0+1]):toBe(reactiveValue)
    expect(original[0+1]):toBe(value)
    observed[0+1] = nil
    expect(observed[0+1]):toBeUndefined()
    expect(original[0+1]):toBeUndefined()
    table.insert(observed, value)
    expect(observed[2+1]):toBe(reactiveValue)
    expect(original[2+1]):toBe(value)
  end
  )
  test('Array identity methods should work with raw values', function()
    local raw = {}
    local arr = reactive({{}, {}})
    table.insert(arr, raw)
    expect(arr:find(raw)):toBe(2)
    expect(arr:find(raw, 3)):toBe(-1)
    expect(arr:includes(raw)):toBe(true)
    expect(arr:includes(raw, 3)):toBe(false)
    expect(arr:lastIndexOf(raw)):toBe(2)
    expect(arr:lastIndexOf(raw, 1)):toBe(-1)
    local observed = arr[2+1]
    expect(arr:find(observed)):toBe(2)
    expect(arr:find(observed, 3)):toBe(-1)
    expect(arr:includes(observed)):toBe(true)
    expect(arr:includes(observed, 3)):toBe(false)
    expect(arr:lastIndexOf(observed)):toBe(2)
    expect(arr:lastIndexOf(observed, 1)):toBe(-1)
  end
  )
  test('Array identity methods should work if raw value contains reactive objects', function()
    local raw = {}
    local obj = reactive({})
    table.insert(raw, obj)
    local arr = reactive(raw)
    expect(arr:includes(obj)):toBe(true)
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
    expect(index):toBe(0)
    arr:reverse()
    expect(index):toBe(1)
  end
  )
  test('delete on Array should not trigger length dependency', function()
    local arr = reactive({1, 2, 3})
    local fn = jest:fn()
    effect(function()
      fn(#arr)
    end
    )
    expect(fn):toHaveBeenCalledTimes(1)
    arr[1+1] = nil
    expect(fn):toHaveBeenCalledTimes(1)
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
      expect(isRef(raw[1+1])):toBe(true)
      expect(isRef(raw[3+1])):toBe(true)
    end
    )
    test('read + write mutating methods', function()
      local res = original:copyWithin(0, 1, 2)
      local raw = toRaw(res)
      expect(isRef(raw[0+1])):toBe(true)
      expect(isRef(raw[1+1])):toBe(true)
    end
    )
    test('read + identity', function()
      local ref = original[1+1]
      expect(ref):toBe(toRaw(original)[1+1])
      expect(original:find(ref)):toBe(1)
    end
    )
  end
  )
end
)