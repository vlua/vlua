require("tableutil")
require("runtime-core/src/index")
require("@vue/runtime-test")
require("@vue/reactivity")
require("@vue/reactivity/TrackOpTypes")
require("@vue/reactivity/TriggerOpTypes")
require("@vue/shared")

describe('api: watch', function()
  mockWarn()
  it('effect', function()
    local state = reactive({count=0})
    local dummy = nil
    watchEffect(function()
      dummy = state.count
    end
    )
    expect(dummy):toBe(0)
    state.count=state.count+1
    expect(dummy):toBe(1)
  end
  )
  it('watching single source: getter', function()
    local state = reactive({count=0})
    local dummy = nil
    watch(function()
      state.count
    end
    , function(count, prevCount)
      dummy = {count, prevCount}
      count + 1
      if prevCount then
        prevCount + 1
      end
    end
    )
    state.count=state.count+1
    expect(dummy):toMatchObject({1, 0})
  end
  )
  it('watching single source: ref', function()
    local count = ref(0)
    local dummy = nil
    watch(count, function(count, prevCount)
      dummy = {count, prevCount}
      count + 1
      if prevCount then
        prevCount + 1
      end
    end
    )
    count.value=count.value+1
    expect(dummy):toMatchObject({1, 0})
  end
  )
  it('watching single source: computed ref', function()
    local count = ref(0)
    local plus = computed(function()
      count.value + 1
    end
    )
    local dummy = nil
    watch(plus, function(count, prevCount)
      dummy = {count, prevCount}
      count + 1
      if prevCount then
        prevCount + 1
      end
    end
    )
    count.value=count.value+1
    expect(dummy):toMatchObject({2, 1})
  end
  )
  it('watching primitive with deep: true', function()
    local count = ref(0)
    local dummy = nil
    watch(count, function(c, prevCount)
      dummy = {c, prevCount}
    end
    , {deep=true})
    count.value=count.value+1
    expect(dummy):toMatchObject({1, 0})
  end
  )
  it('directly watching reactive object (with automatic deep: true)', function()
    local src = reactive({count=0})
    local dummy = nil
    watch(src, function()
      dummy = count
    end
    )
    src.count=src.count+1
    expect(dummy):toBe(1)
  end
  )
  it('watching multiple sources', function()
    local state = reactive({count=1})
    local count = ref(1)
    local plus = computed(function()
      count.value + 1
    end
    )
    local dummy = nil
    watch({function()
      state.count
    end
    , count, plus}, function(vals, oldVals)
      dummy = {vals, oldVals}
      table.merge(vals, 1)
      table.merge(oldVals, 1)
    end
    )
    state.count=state.count+1
    count.value=count.value+1
    expect(dummy):toMatchObject({{2, 2, 3}, {1, 1, 2}})
  end
  )
  it('watching multiple sources: readonly array', function()
    local state = reactive({count=1})
    local status = ref(false)
    local dummy = nil
    watch({function()
      state.count
    end
    , status}, function(vals, oldVals)
      dummy = {vals, oldVals}
      local  = vals
      local  = oldVals
      count + 1
      oldStatus == true
    end
    )
    state.count=state.count+1
    status.value = true
    expect(dummy):toMatchObject({{2, true}, {1, false}})
  end
  )
  it('watching multiple sources: reactive object (with automatic deep: true)', function()
    local src = reactive({count=0})
    local dummy = nil
    watch({src}, function()
      dummy = state
      state.count == 1
    end
    )
    src.count=src.count+1
    expect(dummy):toMatchObject({count=1})
  end
  )
  it('warn invalid watch source', function()
    watch(1, function()
      
    end
    )
    expect():toHaveBeenWarned()
  end
  )
  it('warn invalid watch source: multiple sources', function()
    watch({1}, function()
      
    end
    )
    expect():toHaveBeenWarned()
  end
  )
  it('stopping the watcher (effect)', function()
    local state = reactive({count=0})
    local dummy = nil
    local stop = watchEffect(function()
      dummy = state.count
    end
    )
    expect(dummy):toBe(0)
    stop()
    state.count=state.count+1
    expect(dummy):toBe(0)
  end
  )
  it('stopping the watcher (with source)', function()
    local state = reactive({count=0})
    local dummy = nil
    local stop = watch(function()
      state.count
    end
    , function(count)
      dummy = count
    end
    )
    state.count=state.count+1
    expect(dummy):toBe(1)
    stop()
    state.count=state.count+1
    expect(dummy):toBe(1)
  end
  )
  it('cleanup registration (effect)', function()
    local state = reactive({count=0})
    local cleanup = jest:fn()
    local dummy = nil
    local stop = watchEffect(function(onCleanup)
      onCleanup(cleanup)
      dummy = state.count
    end
    )
    expect(dummy):toBe(0)
    state.count=state.count+1
    expect(cleanup):toHaveBeenCalledTimes(1)
    expect(dummy):toBe(1)
    stop()
    expect(cleanup):toHaveBeenCalledTimes(2)
  end
  )
  it('cleanup registration (with source)', function()
    local count = ref(0)
    local cleanup = jest:fn()
    local dummy = nil
    local stop = watch(count, function(count, prevCount, onCleanup)
      onCleanup(cleanup)
      dummy = count
    end
    )
    count.value=count.value+1
    expect(cleanup):toHaveBeenCalledTimes(0)
    expect(dummy):toBe(1)
    count.value=count.value+1
    expect(cleanup):toHaveBeenCalledTimes(1)
    expect(dummy):toBe(2)
    stop()
    expect(cleanup):toHaveBeenCalledTimes(2)
  end
  )
  it('flush timing: post (default)', function()
    local count = ref(0)
    local callCount = 0
    local assertion = jest:fn(function(count)
      callCount=callCount+1
      -- [ts2lua]lua中0和空字符串也是true，此处callCount == 1需要确认
      local expectedDOM = (callCount == 1 and {} or {})[1]
      expect(serializeInner(root)):toBe(expectedDOM)
    end
    )
    local Comp = {setup=function()
      watchEffect(function()
        assertion(count.value)
      end
      )
      return function()
        count.value
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(assertion):toHaveBeenCalledTimes(1)
    count.value=count.value+1
    expect(assertion):toHaveBeenCalledTimes(2)
  end
  )
  it('flush timing: pre', function()
    local count = ref(0)
    local count2 = ref(0)
    local callCount = 0
    local assertion = jest:fn(function(count, count2Value)
      callCount=callCount+1
      -- [ts2lua]lua中0和空字符串也是true，此处callCount == 1需要确认
      local expectedDOM = (callCount == 1 and {} or {})[1]
      expect(serializeInner(root)):toBe(expectedDOM)
      -- [ts2lua]lua中0和空字符串也是true，此处callCount == 1需要确认
      local expectedState = (callCount == 1 and {0} or {1})[1]
      expect(count2Value):toBe(expectedState)
    end
    )
    local Comp = {setup=function()
      watchEffect(function()
        assertion(count.value, count2.value)
      end
      , {flush='pre'})
      return function()
        count.value
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(assertion):toHaveBeenCalledTimes(1)
    count.value=count.value+1
    count2.value=count2.value+1
    expect(assertion):toHaveBeenCalledTimes(2)
  end
  )
  it('flush timing: sync', function()
    local count = ref(0)
    local count2 = ref(0)
    local callCount = 0
    local assertion = jest:fn(function(count)
      callCount=callCount+1
      -- [ts2lua]lua中0和空字符串也是true，此处callCount == 1需要确认
      local expectedDOM = (callCount == 1 and {} or {})[1]
      expect(serializeInner(root)):toBe(expectedDOM)
      -- [ts2lua]lua中0和空字符串也是true，此处callCount < 3需要确认
      local expectedState = (callCount < 3 and {0} or {1})[1]
      expect(count2.value):toBe(expectedState)
    end
    )
    local Comp = {setup=function()
      watchEffect(function()
        assertion(count.value)
      end
      , {flush='sync'})
      return function()
        count.value
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(assertion):toHaveBeenCalledTimes(1)
    count.value=count.value+1
    count2.value=count2.value+1
    expect(assertion):toHaveBeenCalledTimes(3)
  end
  )
  it('deep', function()
    local state = reactive({nested={count=ref(0)}, array={1, 2, 3}, map=Map({{'a', 1}, {'b', 2}}), set=Set({1, 2, 3})})
    local dummy = nil
    watch(function()
      state
    end
    , function(state)
      dummy = {state.nested.count, state.array[0+1], state.map:get('a'), state.set:has(1)}
    end
    , {deep=true})
    state.nested.count=state.nested.count+1
    expect(dummy):toEqual({1, 1, 1, true})
    state.array[0+1] = 2
    expect(dummy):toEqual({1, 2, 1, true})
    state.map:set('a', 2)
    expect(dummy):toEqual({1, 2, 2, true})
    state.set:delete(1)
    expect(dummy):toEqual({1, 2, 2, false})
  end
  )
  it('immediate', function()
    local count = ref(0)
    local cb = jest:fn()
    watch(count, cb, {immediate=true})
    expect(cb):toHaveBeenCalledTimes(1)
    count.value=count.value+1
    expect(cb):toHaveBeenCalledTimes(2)
  end
  )
  it('immediate: triggers when initial value is null', function()
    local state = ref(nil)
    local spy = jest:fn()
    watch(function()
      state.value
    end
    , spy, {immediate=true})
    expect(spy):toHaveBeenCalled()
  end
  )
  it('immediate: triggers when initial value is undefined', function()
    local state = ref()
    local spy = jest:fn()
    watch(function()
      state.value
    end
    , spy, {immediate=true})
    expect(spy):toHaveBeenCalled()
    state.value = 3
    expect(spy):toHaveBeenCalledTimes(2)
    state.value = undefined
    expect(spy):toHaveBeenCalledTimes(3)
    state.value = undefined
    expect(spy):toHaveBeenCalledTimes(3)
  end
  )
  it('warn immediate option when using effect', function()
    local count = ref(0)
    local dummy = nil
    watchEffect(function()
      dummy = count.value
    end
    , {immediate=false})
    expect(dummy):toBe(0)
    expect():toHaveBeenWarned()
    count.value=count.value+1
    expect(dummy):toBe(1)
  end
  )
  it('warn and not respect deep option when using effect', function()
    local arr = ref({1, {2}})
    local spy = jest:fn()
    watchEffect(function()
      spy()
      return arr
    end
    , {deep=true})
    expect(spy):toHaveBeenCalledTimes(1)
    arr.value[1+1][0+1] = 3
    expect(spy):toHaveBeenCalledTimes(1)
    expect():toHaveBeenWarned()
  end
  )
  it('onTrack', function()
    local events = {}
    local dummy = nil
    local onTrack = jest:fn(function(e)
      table.insert(events, e)
    end
    )
    local obj = reactive({foo=1, bar=2})
    watchEffect(function()
      dummy = {obj.foo, obj['bar'], Object:keys(obj)}
    end
    , {onTrack=onTrack})
    expect(dummy):toEqual({1, true, {'foo', 'bar'}})
    expect(onTrack):toHaveBeenCalledTimes(3)
    expect(events):toMatchObject({{target=obj, type=TrackOpTypes.GET, key='foo'}, {target=obj, type=TrackOpTypes.HAS, key='bar'}, {target=obj, type=TrackOpTypes.ITERATE, key=ITERATE_KEY}})
  end
  )
  it('onTrigger', function()
    local events = {}
    local dummy = nil
    local onTrigger = jest:fn(function(e)
      table.insert(events, e)
    end
    )
    local obj = reactive({foo=1})
    watchEffect(function()
      dummy = obj.foo
    end
    , {onTrigger=onTrigger})
    expect(dummy):toBe(1)
    obj.foo=obj.foo+1
    expect(dummy):toBe(2)
    expect(onTrigger):toHaveBeenCalledTimes(1)
    expect(events[0+1]):toMatchObject({type=TriggerOpTypes.SET, key='foo', oldValue=1, newValue=2})
    obj.foo = nil
    expect(dummy):toBeUndefined()
    expect(onTrigger):toHaveBeenCalledTimes(2)
    expect(events[1+1]):toMatchObject({type=TriggerOpTypes.DELETE, key='foo', oldValue=2})
  end
  )
end
)