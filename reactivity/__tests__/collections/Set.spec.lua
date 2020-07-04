require("reactivity/src")
require("@vue/shared")

describe('reactivity/collections', function()
  describe('Set', function()
    mockWarn()
    it('instanceof', function()
      local original = Set()
      local observed = reactive(original)
      lu.assertEquals(isReactive(observed), true)
      lu.assertEquals(original:instanceof(Set), true)
      lu.assertEquals(observed:instanceof(Set), true)
    end
    )
    it('should observe mutations', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = set:has('value')
      end
      )
      lu.assertEquals(dummy, false)
      set:add('value')
      lu.assertEquals(dummy, true)
      set:delete('value')
      lu.assertEquals(dummy, false)
    end
    )
    it('should observe mutations with observed value', function()
      local dummy = nil
      local value = reactive({})
      local set = reactive(Set())
      effect(function()
        dummy = set:has(value)
      end
      )
      lu.assertEquals(dummy, false)
      set:add(value)
      lu.assertEquals(dummy, true)
      set:delete(value)
      lu.assertEquals(dummy, false)
    end
    )
    it('should observe for of iteration', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = 0
        for _tmpi, num in pairs(set) do
          dummy = dummy + num
        end
      end
      )
      lu.assertEquals(dummy, 0)
      set:add(2)
      set:add(1)
      lu.assertEquals(dummy, 3)
      set:delete(2)
      lu.assertEquals(dummy, 1)
      set:clear()
      lu.assertEquals(dummy, 0)
    end
    )
    it('should observe forEach iteration', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = 0
        set:forEach(function(num)
          dummy = dummy + num
        end
        )
      end
      )
      lu.assertEquals(dummy, 0)
      set:add(2)
      set:add(1)
      lu.assertEquals(dummy, 3)
      set:delete(2)
      lu.assertEquals(dummy, 1)
      set:clear()
      lu.assertEquals(dummy, 0)
    end
    )
    it('should observe values iteration', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = 0
        for _tmpi, num in pairs(set:values()) do
          dummy = dummy + num
        end
      end
      )
      lu.assertEquals(dummy, 0)
      set:add(2)
      set:add(1)
      lu.assertEquals(dummy, 3)
      set:delete(2)
      lu.assertEquals(dummy, 1)
      set:clear()
      lu.assertEquals(dummy, 0)
    end
    )
    it('should observe keys iteration', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = 0
        for _tmpi, num in pairs(set:keys()) do
          dummy = dummy + num
        end
      end
      )
      lu.assertEquals(dummy, 0)
      set:add(2)
      set:add(1)
      lu.assertEquals(dummy, 3)
      set:delete(2)
      lu.assertEquals(dummy, 1)
      set:clear()
      lu.assertEquals(dummy, 0)
    end
    )
    it('should observe entries iteration', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = 0
        for _tmpi,  in pairs(set:entries()) do
          
          dummy = dummy + num
        end
      end
      )
      lu.assertEquals(dummy, 0)
      set:add(2)
      set:add(1)
      lu.assertEquals(dummy, 3)
      set:delete(2)
      lu.assertEquals(dummy, 1)
      set:clear()
      lu.assertEquals(dummy, 0)
    end
    )
    it('should be triggered by clearing', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = set:has('key')
      end
      )
      lu.assertEquals(dummy, false)
      set:add('key')
      lu.assertEquals(dummy, true)
      set:clear()
      lu.assertEquals(dummy, false)
    end
    )
    it('should not observe custom property mutations', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = set.customProp
      end
      )
      lu.assertEquals(dummy, undefined)
      set.customProp = 'Hello World'
      lu.assertEquals(dummy, undefined)
    end
    )
    it('should observe size mutations', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = set.size
      end
      )
      lu.assertEquals(dummy, 0)
      set:add('value')
      set:add('value2')
      lu.assertEquals(dummy, 2)
      set:delete('value')
      lu.assertEquals(dummy, 1)
      set:clear()
      lu.assertEquals(dummy, 0)
    end
    )
    it('should not observe non value changing mutations', function()
      local dummy = nil
      local set = reactive(Set())
      local setSpy = jest:fn(function()
        dummy = set:has('value')
      end
      )
      effect(setSpy)
      lu.assertEquals(dummy, false)
      expect(setSpy):toHaveBeenCalledTimes(1)
      set:add('value')
      lu.assertEquals(dummy, true)
      expect(setSpy):toHaveBeenCalledTimes(2)
      set:add('value')
      lu.assertEquals(dummy, true)
      expect(setSpy):toHaveBeenCalledTimes(2)
      set:delete('value')
      lu.assertEquals(dummy, false)
      expect(setSpy):toHaveBeenCalledTimes(3)
      set:delete('value')
      lu.assertEquals(dummy, false)
      expect(setSpy):toHaveBeenCalledTimes(3)
      set:clear()
      lu.assertEquals(dummy, false)
      expect(setSpy):toHaveBeenCalledTimes(3)
    end
    )
    it('should not observe raw data', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = toRaw(set):has('value')
      end
      )
      lu.assertEquals(dummy, false)
      set:add('value')
      lu.assertEquals(dummy, false)
    end
    )
    it('should not observe raw iterations', function()
      local dummy = 0
      local set = reactive(Set())
      effect(function()
        dummy = 0
        for _tmpi,  in pairs(toRaw(set):entries()) do
          dummy = dummy + num
        end
        for _tmpi, num in pairs(toRaw(set):keys()) do
          dummy = dummy + num
        end
        for _tmpi, num in pairs(toRaw(set):values()) do
          dummy = dummy + num
        end
        toRaw(set):forEach(function(num)
          dummy = dummy + num
        end
        )
        for _tmpi, num in pairs(toRaw(set)) do
          dummy = dummy + num
        end
      end
      )
      lu.assertEquals(dummy, 0)
      set:add(2)
      set:add(3)
      lu.assertEquals(dummy, 0)
      set:delete(2)
      lu.assertEquals(dummy, 0)
    end
    )
    it('should not be triggered by raw mutations', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = set:has('value')
      end
      )
      lu.assertEquals(dummy, false)
      toRaw(set):add('value')
      lu.assertEquals(dummy, false)
      dummy = true
      toRaw(set):delete('value')
      lu.assertEquals(dummy, true)
      toRaw(set):clear()
      lu.assertEquals(dummy, true)
    end
    )
    it('should not observe raw size mutations', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = toRaw(set).size
      end
      )
      lu.assertEquals(dummy, 0)
      set:add('value')
      lu.assertEquals(dummy, 0)
    end
    )
    it('should not be triggered by raw size mutations', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = set.size
      end
      )
      lu.assertEquals(dummy, 0)
      toRaw(set):add('value')
      lu.assertEquals(dummy, 0)
    end
    )
    it('should support objects as key', function()
      local dummy = nil
      local key = {}
      local set = reactive(Set())
      local setSpy = jest:fn(function()
        dummy = set:has(key)
      end
      )
      effect(setSpy)
      lu.assertEquals(dummy, false)
      expect(setSpy):toHaveBeenCalledTimes(1)
      set:add({})
      lu.assertEquals(dummy, false)
      expect(setSpy):toHaveBeenCalledTimes(1)
      set:add(key)
      lu.assertEquals(dummy, true)
      expect(setSpy):toHaveBeenCalledTimes(2)
    end
    )
    it('should not pollute original Set with Proxies', function()
      local set = Set()
      local observed = reactive(set)
      local value = reactive({})
      observed:add(value)
      lu.assertEquals(observed:has(value), true)
      lu.assertEquals(set:has(value), false)
    end
    )
    it('should observe nested values in iterations (forEach)', function()
      local set = reactive(Set({{foo=1}}))
      local dummy = nil
      effect(function()
        dummy = 0
        set:forEach(function(value)
          lu.assertEquals(isReactive(value), true)
          dummy = dummy + value.foo
        end
        )
      end
      )
      lu.assertEquals(dummy, 1)
      set:forEach(function(value)
        value.foo=value.foo+1
      end
      )
      lu.assertEquals(dummy, 2)
    end
    )
    it('should observe nested values in iterations (values)', function()
      local set = reactive(Set({{foo=1}}))
      local dummy = nil
      effect(function()
        dummy = 0
        for _tmpi, value in pairs(set:values()) do
          lu.assertEquals(isReactive(value), true)
          dummy = dummy + value.foo
        end
      end
      )
      lu.assertEquals(dummy, 1)
      set:forEach(function(value)
        value.foo=value.foo+1
      end
      )
      lu.assertEquals(dummy, 2)
    end
    )
    it('should observe nested values in iterations (entries)', function()
      local set = reactive(Set({{foo=1}}))
      local dummy = nil
      effect(function()
        dummy = 0
        for _tmpi,  in pairs(set:entries()) do
          lu.assertEquals(isReactive(key), true)
          lu.assertEquals(isReactive(value), true)
          dummy = dummy + value.foo
        end
      end
      )
      lu.assertEquals(dummy, 1)
      set:forEach(function(value)
        value.foo=value.foo+1
      end
      )
      lu.assertEquals(dummy, 2)
    end
    )
    it('should observe nested values in iterations (for...of)', function()
      local set = reactive(Set({{foo=1}}))
      local dummy = nil
      effect(function()
        dummy = 0
        for _tmpi, value in pairs(set) do
          lu.assertEquals(isReactive(value), true)
          dummy = dummy + value.foo
        end
      end
      )
      lu.assertEquals(dummy, 1)
      set:forEach(function(value)
        value.foo=value.foo+1
      end
      )
      lu.assertEquals(dummy, 2)
    end
    )
    it('should work with reactive entries in raw set', function()
      local raw = Set()
      local entry = reactive({})
      raw:add(entry)
      local set = reactive(raw)
      lu.assertEquals(set:has(entry), true)
      lu.assertEquals(set:delete(entry), true)
      lu.assertEquals(set:has(entry), false)
    end
    )
    it('should track deletion of reactive entries in raw set', function()
      local raw = Set()
      local entry = reactive({})
      raw:add(entry)
      local set = reactive(raw)
      local dummy = nil
      effect(function()
        dummy = set:has(entry)
      end
      )
      lu.assertEquals(dummy, true)
      set:delete(entry)
      lu.assertEquals(dummy, false)
    end
    )
    it('should warn when set contains both raw and reactive versions of the same object', function()
      local raw = Set()
      local rawKey = {}
      local key = reactive(rawKey)
      raw:add(rawKey)
      raw:add(key)
      local set = reactive(raw)
      set:delete(key)
      expect():toHaveBeenWarned()
    end
    )
    it('thisArg', function()
      local raw = Set({'value'})
      local proxy = reactive(raw)
      local thisArg = {}
      local count = 0
      proxy:forEach(function(this, value, _, set)
        count=count+1
        lu.assertEquals(self, thisArg)
        lu.assertEquals(value, 'value')
        lu.assertEquals(set, proxy)
      end
      , thisArg)
      lu.assertEquals(count, 1)
    end
    )
  end
  )
end
)