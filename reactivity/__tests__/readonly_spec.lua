require("reactivity/src")
require("@vue/shared")

describe('reactivity/readonly', function()
  mockWarn()
  describe('Object', function()
    it('should make nested values readonly', function()
      local original = {foo=1, bar={baz=2}}
      local wrapped = readonly(original)
      expect(wrapped).tsvar_not:toBe(original)
      lu.assertEquals(isProxy(wrapped), true)
      lu.assertEquals(isReactive(wrapped), false)
      lu.assertEquals(isReadonly(wrapped), true)
      lu.assertEquals(isReactive(original), false)
      lu.assertEquals(isReadonly(original), false)
      lu.assertEquals(isReactive(wrapped.bar), false)
      lu.assertEquals(isReadonly(wrapped.bar), true)
      lu.assertEquals(isReactive(original.bar), false)
      lu.assertEquals(isReadonly(original.bar), false)
      lu.assertEquals(wrapped.foo, 1)
      lu.assertEquals(wrapped['foo'], true)
      lu.assertEquals(Object:keys(wrapped), {'foo', 'bar'})
    end
    )
    it('should not allow mutation', function()
      local qux = Symbol('qux')
      local original = {foo=1, bar={baz=2}, qux=3}
      local wrapped = readonly(original)
      wrapped.foo = 2
      lu.assertEquals(wrapped.foo, 1)
      expect():toHaveBeenWarnedLast()
      wrapped.bar.baz = 3
      lu.assertEquals(wrapped.bar.baz, 2)
      expect():toHaveBeenWarnedLast()
      -- [ts2lua]wrapped下标访问可能不正确
      wrapped[qux] = 4
      -- [ts2lua]wrapped下标访问可能不正确
      lu.assertEquals(wrapped[qux], 3)
      expect():toHaveBeenWarnedLast()
      wrapped.foo = nil
      lu.assertEquals(wrapped.foo, 1)
      expect():toHaveBeenWarnedLast()
      wrapped.bar.baz = nil
      lu.assertEquals(wrapped.bar.baz, 2)
      expect():toHaveBeenWarnedLast()
      -- [ts2lua]wrapped下标访问可能不正确
      wrapped[qux] = nil
      -- [ts2lua]wrapped下标访问可能不正确
      lu.assertEquals(wrapped[qux], 3)
      expect():toHaveBeenWarnedLast()
    end
    )
    it('should not trigger effects', function()
      local wrapped = readonly({a=1})
      local dummy = nil
      effect(function()
        dummy = wrapped.a
      end
      )
      lu.assertEquals(dummy, 1)
      wrapped.a = 2
      lu.assertEquals(wrapped.a, 1)
      lu.assertEquals(dummy, 1)
      expect():toHaveBeenWarned()
    end
    )
  end
  )
  describe('Array', function()
    it('should make nested values readonly', function()
      local original = {{foo=1}}
      local wrapped = readonly(original)
      expect(wrapped).tsvar_not:toBe(original)
      lu.assertEquals(isProxy(wrapped), true)
      lu.assertEquals(isReactive(wrapped), false)
      lu.assertEquals(isReadonly(wrapped), true)
      lu.assertEquals(isReactive(original), false)
      lu.assertEquals(isReadonly(original), false)
      lu.assertEquals(isReactive(wrapped[0+1]), false)
      lu.assertEquals(isReadonly(wrapped[0+1]), true)
      lu.assertEquals(isReactive(original[0+1]), false)
      lu.assertEquals(isReadonly(original[0+1]), false)
      lu.assertEquals(wrapped[0+1].foo, 1)
      lu.assertEquals(wrapped[0], true)
      lu.assertEquals(Object:keys(wrapped), {'0'})
    end
    )
    it('should not allow mutation', function()
      local wrapped = readonly({{foo=1}})
      wrapped[0+1] = 1
      expect(wrapped[0+1]).tsvar_not:toBe(1)
      expect():toHaveBeenWarned()
      wrapped[0+1].foo = 2
      lu.assertEquals(wrapped[0+1].foo, 1)
      expect():toHaveBeenWarned()
      -- [ts2lua]修改数组长度需要手动处理。
      wrapped.length = 0
      lu.assertEquals(#wrapped, 1)
      lu.assertEquals(wrapped[0+1].foo, 1)
      expect():toHaveBeenWarned()
      table.insert(wrapped, 2)
      lu.assertEquals(#wrapped, 1)
      expect():toHaveBeenWarnedTimes(5)
    end
    )
    it('should not trigger effects', function()
      local wrapped = readonly({{a=1}})
      local dummy = nil
      effect(function()
        dummy = wrapped[0+1].a
      end
      )
      lu.assertEquals(dummy, 1)
      wrapped[0+1].a = 2
      lu.assertEquals(wrapped[0+1].a, 1)
      lu.assertEquals(dummy, 1)
      expect():toHaveBeenWarnedTimes(1)
      wrapped[0+1] = {a=2}
      lu.assertEquals(wrapped[0+1].a, 1)
      lu.assertEquals(dummy, 1)
      expect():toHaveBeenWarnedTimes(2)
    end
    )
  end
  )
  local maps = {Map, WeakMap}
  maps:forEach(function(Collection)
    describe(Collection.name, function()
      test('should make nested values readonly', function()
        local key1 = {}
        local key2 = {}
        local original = Collection({{key1, {}}, {key2, {}}})
        local wrapped = readonly(original)
        expect(wrapped).tsvar_not:toBe(original)
        lu.assertEquals(isProxy(wrapped), true)
        lu.assertEquals(isReactive(wrapped), false)
        lu.assertEquals(isReadonly(wrapped), true)
        lu.assertEquals(isReactive(original), false)
        lu.assertEquals(isReadonly(original), false)
        lu.assertEquals(isReactive(wrapped:get(key1)), false)
        lu.assertEquals(isReadonly(wrapped:get(key1)), true)
        lu.assertEquals(isReactive(original:get(key1)), false)
        lu.assertEquals(isReadonly(original:get(key1)), false)
      end
      )
      test('should not allow mutation & not trigger effect', function()
        local map = readonly(Collection())
        local key = {}
        local dummy = nil
        effect(function()
          dummy = map:get(key)
        end
        )
        expect(dummy):toBeUndefined()
        map:set(key, 1)
        expect(dummy):toBeUndefined()
        lu.assertEquals(map:has(key), false)
        expect():toHaveBeenWarned()
      end
      )
      if Collection == Map then
        test('should retrieve readonly values on iteration', function()
          local key1 = {}
          local key2 = {}
          local original = Collection({{key1, {}}, {key2, {}}})
          local wrapped = readonly(original)
          lu.assertEquals(wrapped.size, 2)
          for _tmpi,  in pairs(wrapped) do
            lu.assertEquals(isReadonly(key), true)
            lu.assertEquals(isReadonly(value), true)
          end
          wrapped:forEach(function(value)
            lu.assertEquals(isReadonly(value), true)
          end
          )
          for _tmpi, value in pairs(wrapped:values()) do
            lu.assertEquals(isReadonly(value), true)
          end
        end
        )
      end
    end
    )
  end
  )
  local sets = {Set, WeakSet}
  sets:forEach(function(Collection)
    describe(Collection.name, function()
      test('should make nested values readonly', function()
        local key1 = {}
        local key2 = {}
        local original = Collection({key1, key2})
        local wrapped = readonly(original)
        expect(wrapped).tsvar_not:toBe(original)
        lu.assertEquals(isProxy(wrapped), true)
        lu.assertEquals(isReactive(wrapped), false)
        lu.assertEquals(isReadonly(wrapped), true)
        lu.assertEquals(isReactive(original), false)
        lu.assertEquals(isReadonly(original), false)
        lu.assertEquals(wrapped:has(reactive(key1)), true)
        lu.assertEquals(original:has(reactive(key1)), false)
      end
      )
      test('should not allow mutation & not trigger effect', function()
        local set = readonly(Collection())
        local key = {}
        local dummy = nil
        effect(function()
          dummy = set:has(key)
        end
        )
        lu.assertEquals(dummy, false)
        set:add(key)
        lu.assertEquals(dummy, false)
        lu.assertEquals(set:has(key), false)
        expect():toHaveBeenWarned()
      end
      )
      if Collection == Set then
        test('should retrieve readonly values on iteration', function()
          local original = Collection({{}, {}})
          local wrapped = readonly(original)
          lu.assertEquals(wrapped.size, 2)
          for _tmpi, value in pairs(wrapped) do
            lu.assertEquals(isReadonly(value), true)
          end
          wrapped:forEach(function(value)
            lu.assertEquals(isReadonly(value), true)
          end
          )
          for _tmpi, value in pairs(wrapped:values()) do
            lu.assertEquals(isReadonly(value), true)
          end
          for _tmpi,  in pairs(wrapped:entries()) do
            lu.assertEquals(isReadonly(v1), true)
            lu.assertEquals(isReadonly(v2), true)
          end
        end
        )
      end
    end
    )
  end
  )
  test('calling reactive on an readonly should return readonly', function()
    local a = readonly({})
    local b = reactive(a)
    lu.assertEquals(isReadonly(b), true)
    lu.assertEquals(toRaw(a), toRaw(b))
  end
  )
  test('calling readonly on a reactive object should return readonly', function()
    local a = reactive({})
    local b = readonly(a)
    lu.assertEquals(isReadonly(b), true)
    lu.assertEquals(toRaw(a), toRaw(b))
  end
  )
  test('readonly should track and trigger if wrapping reactive original', function()
    local a = reactive({n=1})
    local b = readonly(a)
    lu.assertEquals(isReactive(b), true)
    local dummy = nil
    effect(function()
      dummy = b.n
    end
    )
    lu.assertEquals(dummy, 1)
    a.n=a.n+1
    lu.assertEquals(b.n, 2)
    lu.assertEquals(dummy, 2)
  end
  )
  test('wrapping already wrapped value should return same Proxy', function()
    local original = {foo=1}
    local wrapped = readonly(original)
    local wrapped2 = readonly(wrapped)
    lu.assertEquals(wrapped2, wrapped)
  end
  )
  test('wrapping the same value multiple times should return same Proxy', function()
    local original = {foo=1}
    local wrapped = readonly(original)
    local wrapped2 = readonly(original)
    lu.assertEquals(wrapped2, wrapped)
  end
  )
  test('markRaw', function()
    local obj = readonly({foo={a=1}, bar=markRaw({b=2})})
    lu.assertEquals(isReadonly(obj.foo), true)
    lu.assertEquals(isReactive(obj.bar), false)
  end
  )
  test('should make ref readonly', function()
    local n = readonly(ref(1))
    n.value = 2
    lu.assertEquals(n.value, 1)
    expect():toHaveBeenWarned()
  end
  )
  describe('shallowReadonly', function()
    test('should not make non-reactive properties reactive', function()
      local props = shallowReadonly({n={foo=1}})
      lu.assertEquals(isReactive(props.n), false)
    end
    )
    test('should make root level properties readonly', function()
      local props = shallowReadonly({n=1})
      props.n = 2
      lu.assertEquals(props.n, 1)
      expect():toHaveBeenWarned()
    end
    )
    test('should NOT make nested properties readonly', function()
      local props = shallowReadonly({n={foo=1}})
      props.n.foo = 2
      lu.assertEquals(props.n.foo, 2)
      expect().tsvar_not:toHaveBeenWarned()
    end
    )
  end
  )
end
)