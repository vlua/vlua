require("reactivity/src")
require("@vue/shared")

describe('reactivity/computed', function()
  mockWarn()
  it('should return updated value', function()
    local value = reactive({})
    local cValue = computed(function()
      value.foo
    end
    )
    lu.assertEquals(cValue.value, undefined)
    value.foo = 1
    lu.assertEquals(cValue.value, 1)
  end
  )
  it('should compute lazily', function()
    local value = reactive({})
    local getter = jest:fn(function()
      value.foo
    end
    )
    local cValue = computed(getter)
    expect(getter).tsvar_not:toHaveBeenCalled()
    lu.assertEquals(cValue.value, undefined)
    getter.toHaveBeenCalledTimes(1)
    getter.toHaveBeenCalledTimes(1)
    value.foo = 1
    getter.toHaveBeenCalledTimes(1)
    lu.assertEquals(cValue.value, 1)
    getter.toHaveBeenCalledTimes(2)
    getter.toHaveBeenCalledTimes(2)
  end
  )
  it('should trigger effect', function()
    local value = reactive({})
    local cValue = computed(function()
      value.foo
    end
    )
    local dummy = nil
    effect(function()
      dummy = cValue.value
    end
    )
    lu.assertEquals(dummy, undefined)
    value.foo = 1
    lu.assertEquals(dummy, 1)
  end
  )
  it('should work when chained', function()
    local value = reactive({foo=0})
    local c1 = computed(function()
      value.foo
    end
    )
    local c2 = computed(function()
      c1.value + 1
    end
    )
    lu.assertEquals(c2.value, 1)
    lu.assertEquals(c1.value, 0)
    value.foo=value.foo+1
    lu.assertEquals(c2.value, 2)
    lu.assertEquals(c1.value, 1)
  end
  )
  it('should trigger effect when chained', function()
    local value = reactive({foo=0})
    local getter1 = jest:fn(function()
      value.foo
    end
    )
    local getter2 = jest:fn(function()
      return c1.value + 1
    end
    )
    local c1 = computed(getter1)
    local c2 = computed(getter2)
    local dummy = nil
    effect(function()
      dummy = c2.value
    end
    )
    lu.assertEquals(dummy, 1)
    getter1.toHaveBeenCalledTimes(1)
    getter2.toHaveBeenCalledTimes(1)
    value.foo=value.foo+1
    lu.assertEquals(dummy, 2)
    getter1.toHaveBeenCalledTimes(2)
    getter2.toHaveBeenCalledTimes(2)
  end
  )
  it('should trigger effect when chained (mixed invocations)', function()
    local value = reactive({foo=0})
    local getter1 = jest:fn(function()
      value.foo
    end
    )
    local getter2 = jest:fn(function()
      return c1.value + 1
    end
    )
    local c1 = computed(getter1)
    local c2 = computed(getter2)
    local dummy = nil
    effect(function()
      dummy = c1.value + c2.value
    end
    )
    lu.assertEquals(dummy, 1)
    getter1.toHaveBeenCalledTimes(1)
    getter2.toHaveBeenCalledTimes(1)
    value.foo=value.foo+1
    lu.assertEquals(dummy, 3)
    getter1.toHaveBeenCalledTimes(2)
    getter2.toHaveBeenCalledTimes(2)
  end
  )
  it('should no longer update when stopped', function()
    local value = reactive({})
    local cValue = computed(function()
      value.foo
    end
    )
    local dummy = nil
    effect(function()
      dummy = cValue.value
    end
    )
    lu.assertEquals(dummy, undefined)
    value.foo = 1
    lu.assertEquals(dummy, 1)
    stop(cValue.effect)
    value.foo = 2
    lu.assertEquals(dummy, 1)
  end
  )
  it('should support setter', function()
    local n = ref(1)
    local plusOne = computed({get=function()
      n.value + 1
    end
    , set=function(val)
      n.value = val - 1
    end
    })
    lu.assertEquals(plusOne.value, 2)
    n.value=n.value+1
    lu.assertEquals(plusOne.value, 3)
    plusOne.value = 0
    lu.assertEquals(n.value, -1)
  end
  )
  it('should trigger effect w/ setter', function()
    local n = ref(1)
    local plusOne = computed({get=function()
      n.value + 1
    end
    , set=function(val)
      n.value = val - 1
    end
    })
    local dummy = nil
    effect(function()
      dummy = n.value
    end
    )
    lu.assertEquals(dummy, 1)
    plusOne.value = 0
    lu.assertEquals(dummy, -1)
  end
  )
  it('should warn if trying to set a readonly computed', function()
    local n = ref(1)
    local plusOne = computed(function()
      n.value + 1
    end
    )
    plusOne.value=plusOne.value+1
    expect('Write operation failed: computed value is readonly'):toHaveBeenWarnedLast()
  end
  )
end
)