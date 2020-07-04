require("reactivity/src")
require("@vue/shared")

describe('reactivity/collections', function()
  describe('Set', function()
    mockWarn()
    it('instanceof', function()
      local original = Set()
      local observed = reactive(original)
      expect(isReactive(observed)):toBe(true)
      expect(original:instanceof(Set)):toBe(true)
      expect(observed:instanceof(Set)):toBe(true)
    end
    )
    it('should observe mutations', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = set:has('value')
      end
      )
      expect(dummy):toBe(false)
      set:add('value')
      expect(dummy):toBe(true)
      set:delete('value')
      expect(dummy):toBe(false)
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
      expect(dummy):toBe(false)
      set:add(value)
      expect(dummy):toBe(true)
      set:delete(value)
      expect(dummy):toBe(false)
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
      expect(dummy):toBe(0)
      set:add(2)
      set:add(1)
      expect(dummy):toBe(3)
      set:delete(2)
      expect(dummy):toBe(1)
      set:clear()
      expect(dummy):toBe(0)
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
      expect(dummy):toBe(0)
      set:add(2)
      set:add(1)
      expect(dummy):toBe(3)
      set:delete(2)
      expect(dummy):toBe(1)
      set:clear()
      expect(dummy):toBe(0)
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
      expect(dummy):toBe(0)
      set:add(2)
      set:add(1)
      expect(dummy):toBe(3)
      set:delete(2)
      expect(dummy):toBe(1)
      set:clear()
      expect(dummy):toBe(0)
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
      expect(dummy):toBe(0)
      set:add(2)
      set:add(1)
      expect(dummy):toBe(3)
      set:delete(2)
      expect(dummy):toBe(1)
      set:clear()
      expect(dummy):toBe(0)
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
      expect(dummy):toBe(0)
      set:add(2)
      set:add(1)
      expect(dummy):toBe(3)
      set:delete(2)
      expect(dummy):toBe(1)
      set:clear()
      expect(dummy):toBe(0)
    end
    )
    it('should be triggered by clearing', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = set:has('key')
      end
      )
      expect(dummy):toBe(false)
      set:add('key')
      expect(dummy):toBe(true)
      set:clear()
      expect(dummy):toBe(false)
    end
    )
    it('should not observe custom property mutations', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = set.customProp
      end
      )
      expect(dummy):toBe(undefined)
      set.customProp = 'Hello World'
      expect(dummy):toBe(undefined)
    end
    )
    it('should observe size mutations', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = set.size
      end
      )
      expect(dummy):toBe(0)
      set:add('value')
      set:add('value2')
      expect(dummy):toBe(2)
      set:delete('value')
      expect(dummy):toBe(1)
      set:clear()
      expect(dummy):toBe(0)
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
      expect(dummy):toBe(false)
      expect(setSpy):toHaveBeenCalledTimes(1)
      set:add('value')
      expect(dummy):toBe(true)
      expect(setSpy):toHaveBeenCalledTimes(2)
      set:add('value')
      expect(dummy):toBe(true)
      expect(setSpy):toHaveBeenCalledTimes(2)
      set:delete('value')
      expect(dummy):toBe(false)
      expect(setSpy):toHaveBeenCalledTimes(3)
      set:delete('value')
      expect(dummy):toBe(false)
      expect(setSpy):toHaveBeenCalledTimes(3)
      set:clear()
      expect(dummy):toBe(false)
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
      expect(dummy):toBe(false)
      set:add('value')
      expect(dummy):toBe(false)
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
      expect(dummy):toBe(0)
      set:add(2)
      set:add(3)
      expect(dummy):toBe(0)
      set:delete(2)
      expect(dummy):toBe(0)
    end
    )
    it('should not be triggered by raw mutations', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = set:has('value')
      end
      )
      expect(dummy):toBe(false)
      toRaw(set):add('value')
      expect(dummy):toBe(false)
      dummy = true
      toRaw(set):delete('value')
      expect(dummy):toBe(true)
      toRaw(set):clear()
      expect(dummy):toBe(true)
    end
    )
    it('should not observe raw size mutations', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = toRaw(set).size
      end
      )
      expect(dummy):toBe(0)
      set:add('value')
      expect(dummy):toBe(0)
    end
    )
    it('should not be triggered by raw size mutations', function()
      local dummy = nil
      local set = reactive(Set())
      effect(function()
        dummy = set.size
      end
      )
      expect(dummy):toBe(0)
      toRaw(set):add('value')
      expect(dummy):toBe(0)
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
      expect(dummy):toBe(false)
      expect(setSpy):toHaveBeenCalledTimes(1)
      set:add({})
      expect(dummy):toBe(false)
      expect(setSpy):toHaveBeenCalledTimes(1)
      set:add(key)
      expect(dummy):toBe(true)
      expect(setSpy):toHaveBeenCalledTimes(2)
    end
    )
    it('should not pollute original Set with Proxies', function()
      local set = Set()
      local observed = reactive(set)
      local value = reactive({})
      observed:add(value)
      expect(observed:has(value)):toBe(true)
      expect(set:has(value)):toBe(false)
    end
    )
    it('should observe nested values in iterations (forEach)', function()
      local set = reactive(Set({{foo=1}}))
      local dummy = nil
      effect(function()
        dummy = 0
        set:forEach(function(value)
          expect(isReactive(value)):toBe(true)
          dummy = dummy + value.foo
        end
        )
      end
      )
      expect(dummy):toBe(1)
      set:forEach(function(value)
        value.foo=value.foo+1
      end
      )
      expect(dummy):toBe(2)
    end
    )
    it('should observe nested values in iterations (values)', function()
      local set = reactive(Set({{foo=1}}))
      local dummy = nil
      effect(function()
        dummy = 0
        for _tmpi, value in pairs(set:values()) do
          expect(isReactive(value)):toBe(true)
          dummy = dummy + value.foo
        end
      end
      )
      expect(dummy):toBe(1)
      set:forEach(function(value)
        value.foo=value.foo+1
      end
      )
      expect(dummy):toBe(2)
    end
    )
    it('should observe nested values in iterations (entries)', function()
      local set = reactive(Set({{foo=1}}))
      local dummy = nil
      effect(function()
        dummy = 0
        for _tmpi,  in pairs(set:entries()) do
          expect(isReactive(key)):toBe(true)
          expect(isReactive(value)):toBe(true)
          dummy = dummy + value.foo
        end
      end
      )
      expect(dummy):toBe(1)
      set:forEach(function(value)
        value.foo=value.foo+1
      end
      )
      expect(dummy):toBe(2)
    end
    )
    it('should observe nested values in iterations (for...of)', function()
      local set = reactive(Set({{foo=1}}))
      local dummy = nil
      effect(function()
        dummy = 0
        for _tmpi, value in pairs(set) do
          expect(isReactive(value)):toBe(true)
          dummy = dummy + value.foo
        end
      end
      )
      expect(dummy):toBe(1)
      set:forEach(function(value)
        value.foo=value.foo+1
      end
      )
      expect(dummy):toBe(2)
    end
    )
    it('should work with reactive entries in raw set', function()
      local raw = Set()
      local entry = reactive({})
      raw:add(entry)
      local set = reactive(raw)
      expect(set:has(entry)):toBe(true)
      expect(set:delete(entry)):toBe(true)
      expect(set:has(entry)):toBe(false)
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
      expect(dummy):toBe(true)
      set:delete(entry)
      expect(dummy):toBe(false)
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
        expect(self):toBe(thisArg)
        expect(value):toBe('value')
        expect(set):toBe(proxy)
      end
      , thisArg)
      expect(count):toBe(1)
    end
    )
  end
  )
end
)