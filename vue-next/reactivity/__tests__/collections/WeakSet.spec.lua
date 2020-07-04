require("reactivity/src")

describe('reactivity/collections', function()
  describe('WeakSet', function()
    it('instanceof', function()
      local original = WeakSet()
      local observed = reactive(original)
      expect(isReactive(observed)):toBe(true)
      expect(original:instanceof(WeakSet)):toBe(true)
      expect(observed:instanceof(WeakSet)):toBe(true)
    end
    )
    it('should observe mutations', function()
      local dummy = nil
      local value = {}
      local set = reactive(WeakSet())
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
    it('should observe mutations with observed value', function()
      local dummy = nil
      local value = reactive({})
      local set = reactive(WeakSet())
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
    it('should not observe custom property mutations', function()
      local dummy = nil
      local set = reactive(WeakSet())
      effect(function()
        dummy = set.customProp
      end
      )
      expect(dummy):toBe(undefined)
      set.customProp = 'Hello World'
      expect(dummy):toBe(undefined)
    end
    )
    it('should not observe non value changing mutations', function()
      local dummy = nil
      local value = {}
      local set = reactive(WeakSet())
      local setSpy = jest:fn(function()
        dummy = set:has(value)
      end
      )
      effect(setSpy)
      expect(dummy):toBe(false)
      expect(setSpy):toHaveBeenCalledTimes(1)
      set:add(value)
      expect(dummy):toBe(true)
      expect(setSpy):toHaveBeenCalledTimes(2)
      set:add(value)
      expect(dummy):toBe(true)
      expect(setSpy):toHaveBeenCalledTimes(2)
      set:delete(value)
      expect(dummy):toBe(false)
      expect(setSpy):toHaveBeenCalledTimes(3)
      set:delete(value)
      expect(dummy):toBe(false)
      expect(setSpy):toHaveBeenCalledTimes(3)
    end
    )
    it('should not observe raw data', function()
      local value = {}
      local dummy = nil
      local set = reactive(WeakSet())
      effect(function()
        dummy = toRaw(set):has(value)
      end
      )
      expect(dummy):toBe(false)
      set:add(value)
      expect(dummy):toBe(false)
    end
    )
    it('should not be triggered by raw mutations', function()
      local value = {}
      local dummy = nil
      local set = reactive(WeakSet())
      effect(function()
        dummy = set:has(value)
      end
      )
      expect(dummy):toBe(false)
      toRaw(set):add(value)
      expect(dummy):toBe(false)
    end
    )
    it('should not pollute original Set with Proxies', function()
      local set = WeakSet()
      local observed = reactive(set)
      local value = reactive({})
      observed:add(value)
      expect(observed:has(value)):toBe(true)
      expect(set:has(value)):toBe(false)
    end
    )
  end
  )
end
)