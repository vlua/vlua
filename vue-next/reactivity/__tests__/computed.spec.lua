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
    expect(cValue.value):toBe(undefined)
    value.foo = 1
    expect(cValue.value):toBe(1)
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
    expect(cValue.value):toBe(undefined)
    expect(getter):toHaveBeenCalledTimes(1)
    expect(getter):toHaveBeenCalledTimes(1)
    value.foo = 1
    expect(getter):toHaveBeenCalledTimes(1)
    expect(cValue.value):toBe(1)
    expect(getter):toHaveBeenCalledTimes(2)
    expect(getter):toHaveBeenCalledTimes(2)
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
    expect(dummy):toBe(undefined)
    value.foo = 1
    expect(dummy):toBe(1)
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
    expect(c2.value):toBe(1)
    expect(c1.value):toBe(0)
    value.foo=value.foo+1
    expect(c2.value):toBe(2)
    expect(c1.value):toBe(1)
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
    expect(dummy):toBe(1)
    expect(getter1):toHaveBeenCalledTimes(1)
    expect(getter2):toHaveBeenCalledTimes(1)
    value.foo=value.foo+1
    expect(dummy):toBe(2)
    expect(getter1):toHaveBeenCalledTimes(2)
    expect(getter2):toHaveBeenCalledTimes(2)
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
    expect(dummy):toBe(1)
    expect(getter1):toHaveBeenCalledTimes(1)
    expect(getter2):toHaveBeenCalledTimes(1)
    value.foo=value.foo+1
    expect(dummy):toBe(3)
    expect(getter1):toHaveBeenCalledTimes(2)
    expect(getter2):toHaveBeenCalledTimes(2)
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
    expect(dummy):toBe(undefined)
    value.foo = 1
    expect(dummy):toBe(1)
    stop(cValue.effect)
    value.foo = 2
    expect(dummy):toBe(1)
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
    expect(plusOne.value):toBe(2)
    n.value=n.value+1
    expect(plusOne.value):toBe(3)
    plusOne.value = 0
    expect(n.value):toBe(-1)
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
    expect(dummy):toBe(1)
    plusOne.value = 0
    expect(dummy):toBe(-1)
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