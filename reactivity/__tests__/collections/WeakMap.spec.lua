require("reactivity/src")

describe('reactivity/collections', function()
  describe('WeakMap', function()
    test('instanceof', function()
      local original = WeakMap()
      local observed = reactive(original)
      lu.assertEquals(isReactive(observed), true)
      lu.assertEquals(original:instanceof(WeakMap), true)
      lu.assertEquals(observed:instanceof(WeakMap), true)
    end
    )
    it('should observe mutations', function()
      local dummy = nil
      local key = {}
      local map = reactive(WeakMap())
      effect(function()
        dummy = map:get(key)
      end
      )
      lu.assertEquals(dummy, undefined)
      map:set(key, 'value')
      lu.assertEquals(dummy, 'value')
      map:set(key, 'value2')
      lu.assertEquals(dummy, 'value2')
      map:delete(key)
      lu.assertEquals(dummy, undefined)
    end
    )
    it('should observe mutations with observed value as key', function()
      local dummy = nil
      local key = reactive({})
      local value = reactive({})
      local map = reactive(WeakMap())
      effect(function()
        dummy = map:get(key)
      end
      )
      lu.assertEquals(dummy, undefined)
      map:set(key, value)
      lu.assertEquals(dummy, value)
      map:delete(key)
      lu.assertEquals(dummy, undefined)
    end
    )
    it('should not observe custom property mutations', function()
      local dummy = nil
      local map = reactive(WeakMap())
      effect(function()
        dummy = map.customProp
      end
      )
      lu.assertEquals(dummy, undefined)
      map.customProp = 'Hello World'
      lu.assertEquals(dummy, undefined)
    end
    )
    it('should not observe non value changing mutations', function()
      local dummy = nil
      local key = {}
      local map = reactive(WeakMap())
      local mapSpy = jest:fn(function()
        dummy = map:get(key)
      end
      )
      effect(mapSpy)
      lu.assertEquals(dummy, undefined)
      expect(mapSpy):toHaveBeenCalledTimes(1)
      map:set(key, undefined)
      lu.assertEquals(dummy, undefined)
      expect(mapSpy):toHaveBeenCalledTimes(2)
      map:set(key, 'value')
      lu.assertEquals(dummy, 'value')
      expect(mapSpy):toHaveBeenCalledTimes(3)
      map:set(key, 'value')
      lu.assertEquals(dummy, 'value')
      expect(mapSpy):toHaveBeenCalledTimes(3)
      map:delete(key)
      lu.assertEquals(dummy, undefined)
      expect(mapSpy):toHaveBeenCalledTimes(4)
      map:delete(key)
      lu.assertEquals(dummy, undefined)
      expect(mapSpy):toHaveBeenCalledTimes(4)
    end
    )
    it('should not observe raw data', function()
      local dummy = nil
      local key = {}
      local map = reactive(WeakMap())
      effect(function()
        dummy = toRaw(map):get(key)
      end
      )
      lu.assertEquals(dummy, undefined)
      map:set(key, 'Hello')
      lu.assertEquals(dummy, undefined)
      map:delete(key)
      lu.assertEquals(dummy, undefined)
    end
    )
    it('should not pollute original Map with Proxies', function()
      local map = WeakMap()
      local observed = reactive(map)
      local key = {}
      local value = reactive({})
      observed:set(key, value)
      expect(map:get(key)).tsvar_not:toBe(value)
      lu.assertEquals(map:get(key), toRaw(value))
    end
    )
    it('should return observable versions of contained values', function()
      local observed = reactive(WeakMap())
      local key = {}
      local value = {}
      observed:set(key, value)
      local wrapped = observed:get(key)
      lu.assertEquals(isReactive(wrapped), true)
      lu.assertEquals(toRaw(wrapped), value)
    end
    )
    it('should observed nested data', function()
      local observed = reactive(WeakMap())
      local key = {}
      observed:set(key, {a=1})
      local dummy = nil
      effect(function()
        dummy = observed:get(key).a
      end
      )
      observed:get(key).a = 2
      lu.assertEquals(dummy, 2)
    end
    )
    it('should not be trigger when the value and the old value both are NaN', function()
      local map = WeakMap()
      local key = {}
      map:set(key, NaN)
      local mapSpy = jest:fn(function()
        map:get(key)
      end
      )
      effect(mapSpy)
      map:set(key, NaN)
      expect(mapSpy):toHaveBeenCalledTimes(1)
    end
    )
  end
  )
end
)