require("reactivity/src")
require("@vue/shared")

describe('reactivity/readonly', function()
  mockWarn()
  describe('Object', function()
    it('should make nested values readonly', function()
      local original = {foo=1, bar={baz=2}}
      local wrapped = readonly(original)
      expect(wrapped).tsvar_not:toBe(original)
      expect(isProxy(wrapped)):toBe(true)
      expect(isReactive(wrapped)):toBe(false)
      expect(isReadonly(wrapped)):toBe(true)
      expect(isReactive(original)):toBe(false)
      expect(isReadonly(original)):toBe(false)
      expect(isReactive(wrapped.bar)):toBe(false)
      expect(isReadonly(wrapped.bar)):toBe(true)
      expect(isReactive(original.bar)):toBe(false)
      expect(isReadonly(original.bar)):toBe(false)
      expect(wrapped.foo):toBe(1)
      expect(wrapped['foo']):toBe(true)
      expect(Object:keys(wrapped)):toEqual({'foo', 'bar'})
    end
    )
    it('should not allow mutation', function()
      local qux = Symbol('qux')
      local original = {foo=1, bar={baz=2}, qux=3}
      local wrapped = readonly(original)
      wrapped.foo = 2
      expect(wrapped.foo):toBe(1)
      expect():toHaveBeenWarnedLast()
      wrapped.bar.baz = 3
      expect(wrapped.bar.baz):toBe(2)
      expect():toHaveBeenWarnedLast()
      -- [ts2lua]wrapped下标访问可能不正确
      wrapped[qux] = 4
      -- [ts2lua]wrapped下标访问可能不正确
      expect(wrapped[qux]):toBe(3)
      expect():toHaveBeenWarnedLast()
      wrapped.foo = nil
      expect(wrapped.foo):toBe(1)
      expect():toHaveBeenWarnedLast()
      wrapped.bar.baz = nil
      expect(wrapped.bar.baz):toBe(2)
      expect():toHaveBeenWarnedLast()
      -- [ts2lua]wrapped下标访问可能不正确
      wrapped[qux] = nil
      -- [ts2lua]wrapped下标访问可能不正确
      expect(wrapped[qux]):toBe(3)
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
      expect(dummy):toBe(1)
      wrapped.a = 2
      expect(wrapped.a):toBe(1)
      expect(dummy):toBe(1)
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
      expect(isProxy(wrapped)):toBe(true)
      expect(isReactive(wrapped)):toBe(false)
      expect(isReadonly(wrapped)):toBe(true)
      expect(isReactive(original)):toBe(false)
      expect(isReadonly(original)):toBe(false)
      expect(isReactive(wrapped[0+1])):toBe(false)
      expect(isReadonly(wrapped[0+1])):toBe(true)
      expect(isReactive(original[0+1])):toBe(false)
      expect(isReadonly(original[0+1])):toBe(false)
      expect(wrapped[0+1].foo):toBe(1)
      expect(wrapped[0]):toBe(true)
      expect(Object:keys(wrapped)):toEqual({'0'})
    end
    )
    it('should not allow mutation', function()
      local wrapped = readonly({{foo=1}})
      wrapped[0+1] = 1
      expect(wrapped[0+1]).tsvar_not:toBe(1)
      expect():toHaveBeenWarned()
      wrapped[0+1].foo = 2
      expect(wrapped[0+1].foo):toBe(1)
      expect():toHaveBeenWarned()
      -- [ts2lua]修改数组长度需要手动处理。
      wrapped.length = 0
      expect(#wrapped):toBe(1)
      expect(wrapped[0+1].foo):toBe(1)
      expect():toHaveBeenWarned()
      table.insert(wrapped, 2)
      expect(#wrapped):toBe(1)
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
      expect(dummy):toBe(1)
      wrapped[0+1].a = 2
      expect(wrapped[0+1].a):toBe(1)
      expect(dummy):toBe(1)
      expect():toHaveBeenWarnedTimes(1)
      wrapped[0+1] = {a=2}
      expect(wrapped[0+1].a):toBe(1)
      expect(dummy):toBe(1)
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
        expect(isProxy(wrapped)):toBe(true)
        expect(isReactive(wrapped)):toBe(false)
        expect(isReadonly(wrapped)):toBe(true)
        expect(isReactive(original)):toBe(false)
        expect(isReadonly(original)):toBe(false)
        expect(isReactive(wrapped:get(key1))):toBe(false)
        expect(isReadonly(wrapped:get(key1))):toBe(true)
        expect(isReactive(original:get(key1))):toBe(false)
        expect(isReadonly(original:get(key1))):toBe(false)
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
        expect(map:has(key)):toBe(false)
        expect():toHaveBeenWarned()
      end
      )
      if Collection == Map then
        test('should retrieve readonly values on iteration', function()
          local key1 = {}
          local key2 = {}
          local original = Collection({{key1, {}}, {key2, {}}})
          local wrapped = readonly(original)
          expect(wrapped.size):toBe(2)
          for _tmpi,  in pairs(wrapped) do
            expect(isReadonly(key)):toBe(true)
            expect(isReadonly(value)):toBe(true)
          end
          wrapped:forEach(function(value)
            expect(isReadonly(value)):toBe(true)
          end
          )
          for _tmpi, value in pairs(wrapped:values()) do
            expect(isReadonly(value)):toBe(true)
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
        expect(isProxy(wrapped)):toBe(true)
        expect(isReactive(wrapped)):toBe(false)
        expect(isReadonly(wrapped)):toBe(true)
        expect(isReactive(original)):toBe(false)
        expect(isReadonly(original)):toBe(false)
        expect(wrapped:has(reactive(key1))):toBe(true)
        expect(original:has(reactive(key1))):toBe(false)
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
        expect(dummy):toBe(false)
        set:add(key)
        expect(dummy):toBe(false)
        expect(set:has(key)):toBe(false)
        expect():toHaveBeenWarned()
      end
      )
      if Collection == Set then
        test('should retrieve readonly values on iteration', function()
          local original = Collection({{}, {}})
          local wrapped = readonly(original)
          expect(wrapped.size):toBe(2)
          for _tmpi, value in pairs(wrapped) do
            expect(isReadonly(value)):toBe(true)
          end
          wrapped:forEach(function(value)
            expect(isReadonly(value)):toBe(true)
          end
          )
          for _tmpi, value in pairs(wrapped:values()) do
            expect(isReadonly(value)):toBe(true)
          end
          for _tmpi,  in pairs(wrapped:entries()) do
            expect(isReadonly(v1)):toBe(true)
            expect(isReadonly(v2)):toBe(true)
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
    expect(isReadonly(b)):toBe(true)
    expect(toRaw(a)):toBe(toRaw(b))
  end
  )
  test('calling readonly on a reactive object should return readonly', function()
    local a = reactive({})
    local b = readonly(a)
    expect(isReadonly(b)):toBe(true)
    expect(toRaw(a)):toBe(toRaw(b))
  end
  )
  test('readonly should track and trigger if wrapping reactive original', function()
    local a = reactive({n=1})
    local b = readonly(a)
    expect(isReactive(b)):toBe(true)
    local dummy = nil
    effect(function()
      dummy = b.n
    end
    )
    expect(dummy):toBe(1)
    a.n=a.n+1
    expect(b.n):toBe(2)
    expect(dummy):toBe(2)
  end
  )
  test('wrapping already wrapped value should return same Proxy', function()
    local original = {foo=1}
    local wrapped = readonly(original)
    local wrapped2 = readonly(wrapped)
    expect(wrapped2):toBe(wrapped)
  end
  )
  test('wrapping the same value multiple times should return same Proxy', function()
    local original = {foo=1}
    local wrapped = readonly(original)
    local wrapped2 = readonly(original)
    expect(wrapped2):toBe(wrapped)
  end
  )
  test('markRaw', function()
    local obj = readonly({foo={a=1}, bar=markRaw({b=2})})
    expect(isReadonly(obj.foo)):toBe(true)
    expect(isReactive(obj.bar)):toBe(false)
  end
  )
  test('should make ref readonly', function()
    local n = readonly(ref(1))
    n.value = 2
    expect(n.value):toBe(1)
    expect():toHaveBeenWarned()
  end
  )
  describe('shallowReadonly', function()
    test('should not make non-reactive properties reactive', function()
      local props = shallowReadonly({n={foo=1}})
      expect(isReactive(props.n)):toBe(false)
    end
    )
    test('should make root level properties readonly', function()
      local props = shallowReadonly({n=1})
      props.n = 2
      expect(props.n):toBe(1)
      expect():toHaveBeenWarned()
    end
    )
    test('should NOT make nested properties readonly', function()
      local props = shallowReadonly({n={foo=1}})
      props.n.foo = 2
      expect(props.n.foo):toBe(2)
      expect().tsvar_not:toHaveBeenWarned()
    end
    )
  end
  )
end
)