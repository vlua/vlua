require("reactivity/src")
require("@vue/shared")

describe('reactivity/collections', function()
  describe('Map', function()
    mockWarn()
    test('instanceof', function()
      local original = Map()
      local observed = reactive(original)
      lu.assertEquals(isReactive(observed), true)
      lu.assertEquals(original:instanceof(Map), true)
      lu.assertEquals(observed:instanceof(Map), true)
    end
    )
    it('should observe mutations', function()
      local dummy = nil
      local map = reactive(Map())
      effect(function()
        dummy = map:get('key')
      end
      )
      lu.assertEquals(dummy, undefined)
      map:set('key', 'value')
      lu.assertEquals(dummy, 'value')
      map:set('key', 'value2')
      lu.assertEquals(dummy, 'value2')
      map:delete('key')
      lu.assertEquals(dummy, undefined)
    end
    )
    it('should observe mutations with observed value as key', function()
      local dummy = nil
      local key = reactive({})
      local value = reactive({})
      local map = reactive(Map())
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
    it('should observe size mutations', function()
      local dummy = nil
      local map = reactive(Map())
      effect(function()
        dummy = map.size
      end
      )
      lu.assertEquals(dummy, 0)
      map:set('key1', 'value')
      map:set('key2', 'value2')
      lu.assertEquals(dummy, 2)
      map:delete('key1')
      lu.assertEquals(dummy, 1)
      map:clear()
      lu.assertEquals(dummy, 0)
    end
    )
    it('should observe for of iteration', function()
      local dummy = nil
      local map = reactive(Map())
      effect(function()
        dummy = 0
        for _tmpi,  in pairs(map) do
          
          dummy = dummy + num
        end
      end
      )
      lu.assertEquals(dummy, 0)
      map:set('key1', 3)
      lu.assertEquals(dummy, 3)
      map:set('key2', 2)
      lu.assertEquals(dummy, 5)
      map:set('key1', 4)
      lu.assertEquals(dummy, 6)
      map:delete('key1')
      lu.assertEquals(dummy, 2)
      map:clear()
      lu.assertEquals(dummy, 0)
    end
    )
    it('should observe forEach iteration', function()
      local dummy = nil
      local map = reactive(Map())
      effect(function()
        dummy = 0
        map:forEach(function(num)
          dummy = dummy + num
        end
        )
      end
      )
      lu.assertEquals(dummy, 0)
      map:set('key1', 3)
      lu.assertEquals(dummy, 3)
      map:set('key2', 2)
      lu.assertEquals(dummy, 5)
      map:set('key1', 4)
      lu.assertEquals(dummy, 6)
      map:delete('key1')
      lu.assertEquals(dummy, 2)
      map:clear()
      lu.assertEquals(dummy, 0)
    end
    )
    it('should observe keys iteration', function()
      local dummy = nil
      local map = reactive(Map())
      effect(function()
        dummy = 0
        for _tmpi, key in pairs(map:keys()) do
          dummy = dummy + key
        end
      end
      )
      lu.assertEquals(dummy, 0)
      map:set(3, 3)
      lu.assertEquals(dummy, 3)
      map:set(2, 2)
      lu.assertEquals(dummy, 5)
      map:delete(3)
      lu.assertEquals(dummy, 2)
      map:clear()
      lu.assertEquals(dummy, 0)
    end
    )
    it('should observe values iteration', function()
      local dummy = nil
      local map = reactive(Map())
      effect(function()
        dummy = 0
        for _tmpi, num in pairs(map:values()) do
          dummy = dummy + num
        end
      end
      )
      lu.assertEquals(dummy, 0)
      map:set('key1', 3)
      lu.assertEquals(dummy, 3)
      map:set('key2', 2)
      lu.assertEquals(dummy, 5)
      map:set('key1', 4)
      lu.assertEquals(dummy, 6)
      map:delete('key1')
      lu.assertEquals(dummy, 2)
      map:clear()
      lu.assertEquals(dummy, 0)
    end
    )
    it('should observe entries iteration', function()
      local dummy = nil
      local dummy2 = nil
      local map = reactive(Map())
      effect(function()
        dummy = ''
        dummy2 = 0
        for _tmpi,  in pairs(map:entries()) do
          dummy = dummy + key
          dummy2 = dummy2 + num
        end
      end
      )
      lu.assertEquals(dummy, '')
      lu.assertEquals(dummy2, 0)
      map:set('key1', 3)
      lu.assertEquals(dummy, 'key1')
      lu.assertEquals(dummy2, 3)
      map:set('key2', 2)
      lu.assertEquals(dummy, 'key1key2')
      lu.assertEquals(dummy2, 5)
      map:set('key1', 4)
      lu.assertEquals(dummy, 'key1key2')
      lu.assertEquals(dummy2, 6)
      map:delete('key1')
      lu.assertEquals(dummy, 'key2')
      lu.assertEquals(dummy2, 2)
      map:clear()
      lu.assertEquals(dummy, '')
      lu.assertEquals(dummy2, 0)
    end
    )
    it('should be triggered by clearing', function()
      local dummy = nil
      local map = reactive(Map())
      effect(function()
        dummy = map:get('key')
      end
      )
      lu.assertEquals(dummy, undefined)
      map:set('key', 3)
      lu.assertEquals(dummy, 3)
      map:clear()
      lu.assertEquals(dummy, undefined)
    end
    )
    it('should not observe custom property mutations', function()
      local dummy = nil
      local map = reactive(Map())
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
      local map = reactive(Map())
      local mapSpy = jest:fn(function()
        dummy = map:get('key')
      end
      )
      effect(mapSpy)
      lu.assertEquals(dummy, undefined)
      mapSpy.toHaveBeenCalledTimes(1)
      map:set('key', undefined)
      lu.assertEquals(dummy, undefined)
      mapSpy.toHaveBeenCalledTimes(2)
      map:set('key', 'value')
      lu.assertEquals(dummy, 'value')
      mapSpy.toHaveBeenCalledTimes(3)
      map:set('key', 'value')
      lu.assertEquals(dummy, 'value')
      mapSpy.toHaveBeenCalledTimes(3)
      map:delete('key')
      lu.assertEquals(dummy, undefined)
      mapSpy.toHaveBeenCalledTimes(4)
      map:delete('key')
      lu.assertEquals(dummy, undefined)
      mapSpy.toHaveBeenCalledTimes(4)
      map:clear()
      lu.assertEquals(dummy, undefined)
      mapSpy.toHaveBeenCalledTimes(4)
    end
    )
    it('should not observe raw data', function()
      local dummy = nil
      local map = reactive(Map())
      effect(function()
        dummy = toRaw(map):get('key')
      end
      )
      lu.assertEquals(dummy, undefined)
      map:set('key', 'Hello')
      lu.assertEquals(dummy, undefined)
      map:delete('key')
      lu.assertEquals(dummy, undefined)
    end
    )
    it('should not pollute original Map with Proxies', function()
      local map = Map()
      local observed = reactive(map)
      local value = reactive({})
      observed:set('key', value)
      expect(map:get('key')).tsvar_not:toBe(value)
      lu.assertEquals(map:get('key'), toRaw(value))
    end
    )
    it('should return observable versions of contained values', function()
      local observed = reactive(Map())
      local value = {}
      observed:set('key', value)
      local wrapped = observed:get('key')
      lu.assertEquals(isReactive(wrapped), true)
      lu.assertEquals(toRaw(wrapped), value)
    end
    )
    it('should observed nested data', function()
      local observed = reactive(Map())
      observed:set('key', {a=1})
      local dummy = nil
      effect(function()
        dummy = observed:get('key').a
      end
      )
      observed:get('key').a = 2
      lu.assertEquals(dummy, 2)
    end
    )
    it('should observe nested values in iterations (forEach)', function()
      local map = reactive(Map({{1, {foo=1}}}))
      local dummy = nil
      effect(function()
        dummy = 0
        map:forEach(function(value)
          lu.assertEquals(isReactive(value), true)
          dummy = dummy + value.foo
        end
        )
      end
      )
      lu.assertEquals(dummy, 1)
      ().foo=().foo+1
      lu.assertEquals(dummy, 2)
    end
    )
    it('should observe nested values in iterations (values)', function()
      local map = reactive(Map({{1, {foo=1}}}))
      local dummy = nil
      effect(function()
        dummy = 0
        for _tmpi, value in pairs(map:values()) do
          lu.assertEquals(isReactive(value), true)
          dummy = dummy + value.foo
        end
      end
      )
      lu.assertEquals(dummy, 1)
      ().foo=().foo+1
      lu.assertEquals(dummy, 2)
    end
    )
    it('should observe nested values in iterations (entries)', function()
      local key = {}
      local map = reactive(Map({{key, {foo=1}}}))
      local dummy = nil
      effect(function()
        dummy = 0
        for _tmpi,  in pairs(map:entries()) do
          
          lu.assertEquals(isReactive(key), true)
          lu.assertEquals(isReactive(value), true)
          dummy = dummy + value.foo
        end
      end
      )
      lu.assertEquals(dummy, 1)
      ().foo=().foo+1
      lu.assertEquals(dummy, 2)
    end
    )
    it('should observe nested values in iterations (for...of)', function()
      local key = {}
      local map = reactive(Map({{key, {foo=1}}}))
      local dummy = nil
      effect(function()
        dummy = 0
        for _tmpi,  in pairs(map) do
          
          lu.assertEquals(isReactive(key), true)
          lu.assertEquals(isReactive(value), true)
          dummy = dummy + value.foo
        end
      end
      )
      lu.assertEquals(dummy, 1)
      ().foo=().foo+1
      lu.assertEquals(dummy, 2)
    end
    )
    it('should not be trigger when the value and the old value both are NaN', function()
      local map = reactive(Map({{'foo', NaN}}))
      local mapSpy = jest:fn(function()
        map:get('foo')
      end
      )
      effect(mapSpy)
      map:set('foo', NaN)
      mapSpy.toHaveBeenCalledTimes(1)
    end
    )
    it('should work with reactive keys in raw map', function()
      local raw = Map()
      local key = reactive({})
      raw:set(key, 1)
      local map = reactive(raw)
      lu.assertEquals(map:has(key), true)
      lu.assertEquals(map:get(key), 1)
      lu.assertEquals(map:delete(key), true)
      lu.assertEquals(map:has(key), false)
      expect(map:get(key)):toBeUndefined()
    end
    )
    it('should track set of reactive keys in raw map', function()
      local raw = Map()
      local key = reactive({})
      raw:set(key, 1)
      local map = reactive(raw)
      local dummy = nil
      effect(function()
        dummy = map:get(key)
      end
      )
      lu.assertEquals(dummy, 1)
      map:set(key, 2)
      lu.assertEquals(dummy, 2)
    end
    )
    it('should track deletion of reactive keys in raw map', function()
      local raw = Map()
      local key = reactive({})
      raw:set(key, 1)
      local map = reactive(raw)
      local dummy = nil
      effect(function()
        dummy = map:has(key)
      end
      )
      lu.assertEquals(dummy, true)
      map:delete(key)
      lu.assertEquals(dummy, false)
    end
    )
    it('should warn when both raw and reactive versions of the same object is used as key', function()
      local raw = Map()
      local rawKey = {}
      local key = reactive(rawKey)
      raw:set(rawKey, 1)
      raw:set(key, 1)
      local map = reactive(raw)
      map:set(key, 2)
      expect():toHaveBeenWarned()
    end
    )
    it('should not trigger key iteration when setting existing keys', function()
      local map = reactive(Map())
      local spy = jest:fn()
      effect(function()
        local keys = {}
        for _tmpi, key in pairs(map:keys()) do
          table.insert(keys, key)
        end
        spy(keys)
      end
      )
      spy.toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0+1][0+1]):toMatchObject({})
      map:set('a', 0)
      spy.toHaveBeenCalledTimes(2)
      expect(spy.mock.calls[1+1][0+1]):toMatchObject({'a'})
      map:set('b', 0)
      spy.toHaveBeenCalledTimes(3)
      expect(spy.mock.calls[2+1][0+1]):toMatchObject({'a', 'b'})
      map:set('b', 1)
      spy.toHaveBeenCalledTimes(3)
    end
    )
  end
  )
end
)