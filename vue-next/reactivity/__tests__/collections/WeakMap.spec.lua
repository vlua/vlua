require("reactivity/src")

describe('reactivity/collections', function()
  describe('WeakMap', function()
    test('instanceof', function()
      local original = WeakMap()
      local observed = reactive(original)
      expect(isReactive(observed)):toBe(true)
      expect(original:instanceof(WeakMap)):toBe(true)
      expect(observed:instanceof(WeakMap)):toBe(true)
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
      expect(dummy):toBe(undefined)
      map:set(key, 'value')
      expect(dummy):toBe('value')
      map:set(key, 'value2')
      expect(dummy):toBe('value2')
      map:delete(key)
      expect(dummy):toBe(undefined)
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
      expect(dummy):toBe(undefined)
      map:set(key, value)
      expect(dummy):toBe(value)
      map:delete(key)
      expect(dummy):toBe(undefined)
    end
    )
    it('should not observe custom property mutations', function()
      local dummy = nil
      local map = reactive(WeakMap())
      effect(function()
        dummy = map.customProp
      end
      )
      expect(dummy):toBe(undefined)
      map.customProp = 'Hello World'
      expect(dummy):toBe(undefined)
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
      expect(dummy):toBe(undefined)
      expect(mapSpy):toHaveBeenCalledTimes(1)
      map:set(key, undefined)
      expect(dummy):toBe(undefined)
      expect(mapSpy):toHaveBeenCalledTimes(2)
      map:set(key, 'value')
      expect(dummy):toBe('value')
      expect(mapSpy):toHaveBeenCalledTimes(3)
      map:set(key, 'value')
      expect(dummy):toBe('value')
      expect(mapSpy):toHaveBeenCalledTimes(3)
      map:delete(key)
      expect(dummy):toBe(undefined)
      expect(mapSpy):toHaveBeenCalledTimes(4)
      map:delete(key)
      expect(dummy):toBe(undefined)
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
      expect(dummy):toBe(undefined)
      map:set(key, 'Hello')
      expect(dummy):toBe(undefined)
      map:delete(key)
      expect(dummy):toBe(undefined)
    end
    )
    it('should not pollute original Map with Proxies', function()
      local map = WeakMap()
      local observed = reactive(map)
      local key = {}
      local value = reactive({})
      observed:set(key, value)
      expect(map:get(key)).tsvar_not:toBe(value)
      expect(map:get(key)):toBe(toRaw(value))
    end
    )
    it('should return observable versions of contained values', function()
      local observed = reactive(WeakMap())
      local key = {}
      local value = {}
      observed:set(key, value)
      local wrapped = observed:get(key)
      expect(isReactive(wrapped)):toBe(true)
      expect(toRaw(wrapped)):toBe(value)
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
      expect(dummy):toBe(2)
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