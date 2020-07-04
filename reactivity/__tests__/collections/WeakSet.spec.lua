require("reactivity/src")

describe('reactivity/collections', function()
  describe('WeakSet', function()
    it('instanceof', function()
      local original = WeakSet()
      local observed = reactive(original)
      lu.assertEquals(isReactive(observed), true)
      lu.assertEquals(original:instanceof(WeakSet), true)
      lu.assertEquals(observed:instanceof(WeakSet), true)
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
      lu.assertEquals(dummy, false)
      set:add(value)
      lu.assertEquals(dummy, true)
      set:delete(value)
      lu.assertEquals(dummy, false)
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
      lu.assertEquals(dummy, false)
      set:add(value)
      lu.assertEquals(dummy, true)
      set:delete(value)
      lu.assertEquals(dummy, false)
    end
    )
    it('should not observe custom property mutations', function()
      local dummy = nil
      local set = reactive(WeakSet())
      effect(function()
        dummy = set.customProp
      end
      )
      lu.assertEquals(dummy, undefined)
      set.customProp = 'Hello World'
      lu.assertEquals(dummy, undefined)
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
      lu.assertEquals(dummy, false)
      expect(setSpy):toHaveBeenCalledTimes(1)
      set:add(value)
      lu.assertEquals(dummy, true)
      expect(setSpy):toHaveBeenCalledTimes(2)
      set:add(value)
      lu.assertEquals(dummy, true)
      expect(setSpy):toHaveBeenCalledTimes(2)
      set:delete(value)
      lu.assertEquals(dummy, false)
      expect(setSpy):toHaveBeenCalledTimes(3)
      set:delete(value)
      lu.assertEquals(dummy, false)
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
      lu.assertEquals(dummy, false)
      set:add(value)
      lu.assertEquals(dummy, false)
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
      lu.assertEquals(dummy, false)
      toRaw(set):add(value)
      lu.assertEquals(dummy, false)
    end
    )
    it('should not pollute original Set with Proxies', function()
      local set = WeakSet()
      local observed = reactive(set)
      local value = reactive({})
      observed:add(value)
      lu.assertEquals(observed:has(value), true)
      lu.assertEquals(set:has(value), false)
    end
    )
  end
  )
end
)