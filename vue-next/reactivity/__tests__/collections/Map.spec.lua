require("reactivity/src")
require("@vue/shared")

describe('reactivity/collections', function()
  describe('Map', function()
    mockWarn()
    test('instanceof', function()
      local original = Map()
      local observed = reactive(original)
      expect(isReactive(observed)):toBe(true)
      expect(original:instanceof(Map)):toBe(true)
      expect(observed:instanceof(Map)):toBe(true)
    end
    )
    it('should observe mutations', function()
      local dummy = nil
      local map = reactive(Map())
      effect(function()
        dummy = map:get('key')
      end
      )
      expect(dummy):toBe(undefined)
      map:set('key', 'value')
      expect(dummy):toBe('value')
      map:set('key', 'value2')
      expect(dummy):toBe('value2')
      map:delete('key')
      expect(dummy):toBe(undefined)
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
      expect(dummy):toBe(undefined)
      map:set(key, value)
      expect(dummy):toBe(value)
      map:delete(key)
      expect(dummy):toBe(undefined)
    end
    )
    it('should observe size mutations', function()
      local dummy = nil
      local map = reactive(Map())
      effect(function()
        dummy = map.size
      end
      )
      expect(dummy):toBe(0)
      map:set('key1', 'value')
      map:set('key2', 'value2')
      expect(dummy):toBe(2)
      map:delete('key1')
      expect(dummy):toBe(1)
      map:clear()
      expect(dummy):toBe(0)
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
      expect(dummy):toBe(0)
      map:set('key1', 3)
      expect(dummy):toBe(3)
      map:set('key2', 2)
      expect(dummy):toBe(5)
      map:set('key1', 4)
      expect(dummy):toBe(6)
      map:delete('key1')
      expect(dummy):toBe(2)
      map:clear()
      expect(dummy):toBe(0)
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
      expect(dummy):toBe(0)
      map:set('key1', 3)
      expect(dummy):toBe(3)
      map:set('key2', 2)
      expect(dummy):toBe(5)
      map:set('key1', 4)
      expect(dummy):toBe(6)
      map:delete('key1')
      expect(dummy):toBe(2)
      map:clear()
      expect(dummy):toBe(0)
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
      expect(dummy):toBe(0)
      map:set(3, 3)
      expect(dummy):toBe(3)
      map:set(2, 2)
      expect(dummy):toBe(5)
      map:delete(3)
      expect(dummy):toBe(2)
      map:clear()
      expect(dummy):toBe(0)
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
      expect(dummy):toBe(0)
      map:set('key1', 3)
      expect(dummy):toBe(3)
      map:set('key2', 2)
      expect(dummy):toBe(5)
      map:set('key1', 4)
      expect(dummy):toBe(6)
      map:delete('key1')
      expect(dummy):toBe(2)
      map:clear()
      expect(dummy):toBe(0)
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
      expect(dummy):toBe('')
      expect(dummy2):toBe(0)
      map:set('key1', 3)
      expect(dummy):toBe('key1')
      expect(dummy2):toBe(3)
      map:set('key2', 2)
      expect(dummy):toBe('key1key2')
      expect(dummy2):toBe(5)
      map:set('key1', 4)
      expect(dummy):toBe('key1key2')
      expect(dummy2):toBe(6)
      map:delete('key1')
      expect(dummy):toBe('key2')
      expect(dummy2):toBe(2)
      map:clear()
      expect(dummy):toBe('')
      expect(dummy2):toBe(0)
    end
    )
    it('should be triggered by clearing', function()
      local dummy = nil
      local map = reactive(Map())
      effect(function()
        dummy = map:get('key')
      end
      )
      expect(dummy):toBe(undefined)
      map:set('key', 3)
      expect(dummy):toBe(3)
      map:clear()
      expect(dummy):toBe(undefined)
    end
    )
    it('should not observe custom property mutations', function()
      local dummy = nil
      local map = reactive(Map())
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
      local map = reactive(Map())
      local mapSpy = jest:fn(function()
        dummy = map:get('key')
      end
      )
      effect(mapSpy)
      expect(dummy):toBe(undefined)
      expect(mapSpy):toHaveBeenCalledTimes(1)
      map:set('key', undefined)
      expect(dummy):toBe(undefined)
      expect(mapSpy):toHaveBeenCalledTimes(2)
      map:set('key', 'value')
      expect(dummy):toBe('value')
      expect(mapSpy):toHaveBeenCalledTimes(3)
      map:set('key', 'value')
      expect(dummy):toBe('value')
      expect(mapSpy):toHaveBeenCalledTimes(3)
      map:delete('key')
      expect(dummy):toBe(undefined)
      expect(mapSpy):toHaveBeenCalledTimes(4)
      map:delete('key')
      expect(dummy):toBe(undefined)
      expect(mapSpy):toHaveBeenCalledTimes(4)
      map:clear()
      expect(dummy):toBe(undefined)
      expect(mapSpy):toHaveBeenCalledTimes(4)
    end
    )
    it('should not observe raw data', function()
      local dummy = nil
      local map = reactive(Map())
      effect(function()
        dummy = toRaw(map):get('key')
      end
      )
      expect(dummy):toBe(undefined)
      map:set('key', 'Hello')
      expect(dummy):toBe(undefined)
      map:delete('key')
      expect(dummy):toBe(undefined)
    end
    )
    it('should not pollute original Map with Proxies', function()
      local map = Map()
      local observed = reactive(map)
      local value = reactive({})
      observed:set('key', value)
      expect(map:get('key')).tsvar_not:toBe(value)
      expect(map:get('key')):toBe(toRaw(value))
    end
    )
    it('should return observable versions of contained values', function()
      local observed = reactive(Map())
      local value = {}
      observed:set('key', value)
      local wrapped = observed:get('key')
      expect(isReactive(wrapped)):toBe(true)
      expect(toRaw(wrapped)):toBe(value)
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
      expect(dummy):toBe(2)
    end
    )
    it('should observe nested values in iterations (forEach)', function()
      local map = reactive(Map({{1, {foo=1}}}))
      local dummy = nil
      effect(function()
        dummy = 0
        map:forEach(function(value)
          expect(isReactive(value)):toBe(true)
          dummy = dummy + value.foo
        end
        )
      end
      )
      expect(dummy):toBe(1)
      ().foo=().foo+1
      expect(dummy):toBe(2)
    end
    )
    it('should observe nested values in iterations (values)', function()
      local map = reactive(Map({{1, {foo=1}}}))
      local dummy = nil
      effect(function()
        dummy = 0
        for _tmpi, value in pairs(map:values()) do
          expect(isReactive(value)):toBe(true)
          dummy = dummy + value.foo
        end
      end
      )
      expect(dummy):toBe(1)
      ().foo=().foo+1
      expect(dummy):toBe(2)
    end
    )
    it('should observe nested values in iterations (entries)', function()
      local key = {}
      local map = reactive(Map({{key, {foo=1}}}))
      local dummy = nil
      effect(function()
        dummy = 0
        for _tmpi,  in pairs(map:entries()) do
          
          expect(isReactive(key)):toBe(true)
          expect(isReactive(value)):toBe(true)
          dummy = dummy + value.foo
        end
      end
      )
      expect(dummy):toBe(1)
      ().foo=().foo+1
      expect(dummy):toBe(2)
    end
    )
    it('should observe nested values in iterations (for...of)', function()
      local key = {}
      local map = reactive(Map({{key, {foo=1}}}))
      local dummy = nil
      effect(function()
        dummy = 0
        for _tmpi,  in pairs(map) do
          
          expect(isReactive(key)):toBe(true)
          expect(isReactive(value)):toBe(true)
          dummy = dummy + value.foo
        end
      end
      )
      expect(dummy):toBe(1)
      ().foo=().foo+1
      expect(dummy):toBe(2)
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
      expect(mapSpy):toHaveBeenCalledTimes(1)
    end
    )
    it('should work with reactive keys in raw map', function()
      local raw = Map()
      local key = reactive({})
      raw:set(key, 1)
      local map = reactive(raw)
      expect(map:has(key)):toBe(true)
      expect(map:get(key)):toBe(1)
      expect(map:delete(key)):toBe(true)
      expect(map:has(key)):toBe(false)
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
      expect(dummy):toBe(1)
      map:set(key, 2)
      expect(dummy):toBe(2)
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
      expect(dummy):toBe(true)
      map:delete(key)
      expect(dummy):toBe(false)
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
      expect(spy):toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0+1][0+1]):toMatchObject({})
      map:set('a', 0)
      expect(spy):toHaveBeenCalledTimes(2)
      expect(spy.mock.calls[1+1][0+1]):toMatchObject({'a'})
      map:set('b', 0)
      expect(spy):toHaveBeenCalledTimes(3)
      expect(spy.mock.calls[2+1][0+1]):toMatchObject({'a', 'b'})
      map:set('b', 1)
      expect(spy):toHaveBeenCalledTimes(3)
    end
    )
  end
  )
end
)