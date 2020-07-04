require("reactivity/src/index")
require("reactivity/src/index/TrackOpTypes")
require("reactivity/src/index/TriggerOpTypes")
require("reactivity/src/effect")

describe('reactivity/effect', function()
  it('should run the passed function once (wrapped by a effect)', function()
    local fnSpy = jest:fn(function()
      
    end
    )
    effect(fnSpy)
    expect(fnSpy):toHaveBeenCalledTimes(1)
  end
  )
  it('should observe basic properties', function()
    local dummy = nil
    local counter = reactive({num=0})
    effect(function()
      dummy = counter.num
    end
    )
    expect(dummy):toBe(0)
    counter.num = 7
    expect(dummy):toBe(7)
  end
  )
  it('should observe multiple properties', function()
    local dummy = nil
    local counter = reactive({num1=0, num2=0})
    effect(function()
      dummy = counter.num1 + counter.num1 + counter.num2
    end
    )
    expect(dummy):toBe(0)
    counter.num2 = 7
    counter.num1 = counter.num2
    expect(dummy):toBe(21)
  end
  )
  it('should handle multiple effects', function()
    local dummy1 = nil
    local dummy2 = nil
    local counter = reactive({num=0})
    effect(function()
      dummy1 = counter.num
    end
    )
    effect(function()
      dummy2 = counter.num
    end
    )
    expect(dummy1):toBe(0)
    expect(dummy2):toBe(0)
    counter.num=counter.num+1
    expect(dummy1):toBe(1)
    expect(dummy2):toBe(1)
  end
  )
  it('should observe nested properties', function()
    local dummy = nil
    local counter = reactive({nested={num=0}})
    effect(function()
      dummy = counter.nested.num
    end
    )
    expect(dummy):toBe(0)
    counter.nested.num = 8
    expect(dummy):toBe(8)
  end
  )
  it('should observe delete operations', function()
    local dummy = nil
    local obj = reactive({prop='value'})
    effect(function()
      dummy = obj.prop
    end
    )
    expect(dummy):toBe('value')
    obj.prop = nil
    expect(dummy):toBe(undefined)
  end
  )
  it('should observe has operations', function()
    local dummy = nil
    local obj = reactive({prop='value'})
    effect(function()
      dummy = obj['prop']
    end
    )
    expect(dummy):toBe(true)
    obj.prop = nil
    expect(dummy):toBe(false)
    obj.prop = 12
    expect(dummy):toBe(true)
  end
  )
  it('should observe properties on the prototype chain', function()
    local dummy = nil
    local counter = reactive({num=0})
    local parentCounter = reactive({num=2})
    Object:setPrototypeOf(counter, parentCounter)
    effect(function()
      dummy = counter.num
    end
    )
    expect(dummy):toBe(0)
    counter.num = nil
    expect(dummy):toBe(2)
    parentCounter.num = 4
    expect(dummy):toBe(4)
    counter.num = 3
    expect(dummy):toBe(3)
  end
  )
  it('should observe has operations on the prototype chain', function()
    local dummy = nil
    local counter = reactive({num=0})
    local parentCounter = reactive({num=2})
    Object:setPrototypeOf(counter, parentCounter)
    effect(function()
      dummy = counter['num']
    end
    )
    expect(dummy):toBe(true)
    counter.num = nil
    expect(dummy):toBe(true)
    parentCounter.num = nil
    expect(dummy):toBe(false)
    counter.num = 3
    expect(dummy):toBe(true)
  end
  )
  it('should observe inherited property accessors', function()
    local dummy = nil
    local parentDummy = nil
    local hiddenValue = nil
    local obj = reactive({})
    local parent = reactive({prop=function(value)
      hiddenValue = value
    end
    , prop=function()
      return hiddenValue
    end
    })
    Object:setPrototypeOf(obj, parent)
    effect(function()
      dummy = obj.prop
    end
    )
    effect(function()
      parentDummy = parent.prop
    end
    )
    expect(dummy):toBe(undefined)
    expect(parentDummy):toBe(undefined)
    obj.prop = 4
    expect(dummy):toBe(4)
    parent.prop = 2
    expect(dummy):toBe(2)
    expect(parentDummy):toBe(2)
  end
  )
  it('should observe function call chains', function()
    local dummy = nil
    local counter = reactive({num=0})
    effect(function()
      dummy = getNum()
    end
    )
    function getNum()
      return counter.num
    end
    
    expect(dummy):toBe(0)
    counter.num = 2
    expect(dummy):toBe(2)
  end
  )
  it('should observe iteration', function()
    local dummy = nil
    local list = reactive({'Hello'})
    effect(function()
      dummy = list:join(' ')
    end
    )
    expect(dummy):toBe('Hello')
    table.insert(list, 'World!')
    expect(dummy):toBe('Hello World!')
    list:shift()
    expect(dummy):toBe('World!')
  end
  )
  it('should observe implicit array length changes', function()
    local dummy = nil
    local list = reactive({'Hello'})
    effect(function()
      dummy = list:join(' ')
    end
    )
    expect(dummy):toBe('Hello')
    list[1+1] = 'World!'
    expect(dummy):toBe('Hello World!')
    list[3+1] = 'Hello!'
    expect(dummy):toBe('Hello World!  Hello!')
  end
  )
  it('should observe sparse array mutations', function()
    local dummy = nil
    local list = reactive({})
    list[1+1] = 'World!'
    effect(function()
      dummy = list:join(' ')
    end
    )
    expect(dummy):toBe(' World!')
    list[0+1] = 'Hello'
    expect(dummy):toBe('Hello World!')
    list:pop()
    expect(dummy):toBe('Hello')
  end
  )
  it('should observe enumeration', function()
    local dummy = 0
    local numbers = reactive({num1=3})
    effect(function()
      dummy = 0
      for key in pairs(numbers) do
        -- [ts2lua]numbers下标访问可能不正确
        dummy = dummy + numbers[key]
      end
    end
    )
    expect(dummy):toBe(3)
    numbers.num2 = 4
    expect(dummy):toBe(7)
    numbers.num1 = nil
    expect(dummy):toBe(4)
  end
  )
  it('should observe symbol keyed properties', function()
    local key = Symbol('symbol keyed prop')
    local dummy = nil
    local hasDummy = nil
    local obj = reactive({key='value'})
    effect(function()
      -- [ts2lua]obj下标访问可能不正确
      dummy = obj[key]
    end
    )
    effect(function()
      hasDummy = obj[key]
    end
    )
    expect(dummy):toBe('value')
    expect(hasDummy):toBe(true)
    -- [ts2lua]obj下标访问可能不正确
    obj[key] = 'newValue'
    expect(dummy):toBe('newValue')
    -- [ts2lua]obj下标访问可能不正确
    obj[key] = nil
    expect(dummy):toBe(undefined)
    expect(hasDummy):toBe(false)
  end
  )
  it('should not observe well-known symbol keyed properties', function()
    local key = Symbol.isConcatSpreadable
    local dummy = nil
    local array = reactive({})
    effect(function()
      -- [ts2lua]array下标访问可能不正确
      dummy = array[key]
    end
    )
    -- [ts2lua]array下标访问可能不正确
    expect(array[key]):toBe(undefined)
    expect(dummy):toBe(undefined)
    -- [ts2lua]array下标访问可能不正确
    array[key] = true
    -- [ts2lua]array下标访问可能不正确
    expect(array[key]):toBe(true)
    expect(dummy):toBe(undefined)
  end
  )
  it('should observe function valued properties', function()
    local oldFunc = function()
      
    end
    
    local newFunc = function()
      
    end
    
    local dummy = nil
    local obj = reactive({func=oldFunc})
    effect(function()
      dummy = obj.func
    end
    )
    expect(dummy):toBe(oldFunc)
    obj.func = newFunc
    expect(dummy):toBe(newFunc)
  end
  )
  it('should observe chained getters relying on this', function()
    local obj = reactive({a=1, b=function()
      return self.a
    end
    })
    local dummy = nil
    effect(function()
      dummy = obj.b
    end
    )
    expect(dummy):toBe(1)
    obj.a=obj.a+1
    expect(dummy):toBe(2)
  end
  )
  it('should observe methods relying on this', function()
    local obj = reactive({a=1, b=function()
      return self.a
    end
    })
    local dummy = nil
    effect(function()
      dummy = obj:b()
    end
    )
    expect(dummy):toBe(1)
    obj.a=obj.a+1
    expect(dummy):toBe(2)
  end
  )
  it('should not observe set operations without a value change', function()
    local hasDummy = nil
    local getDummy = nil
    local obj = reactive({prop='value'})
    local getSpy = jest:fn(function()
      getDummy = obj.prop
    end
    )
    local hasSpy = jest:fn(function()
      hasDummy = obj['prop']
    end
    )
    effect(getSpy)
    effect(hasSpy)
    expect(getDummy):toBe('value')
    expect(hasDummy):toBe(true)
    obj.prop = 'value'
    expect(getSpy):toHaveBeenCalledTimes(1)
    expect(hasSpy):toHaveBeenCalledTimes(1)
    expect(getDummy):toBe('value')
    expect(hasDummy):toBe(true)
  end
  )
  it('should not observe raw mutations', function()
    local dummy = nil
    local obj = reactive({})
    effect(function()
      dummy = toRaw(obj).prop
    end
    )
    expect(dummy):toBe(undefined)
    obj.prop = 'value'
    expect(dummy):toBe(undefined)
  end
  )
  it('should not be triggered by raw mutations', function()
    local dummy = nil
    local obj = reactive({})
    effect(function()
      dummy = obj.prop
    end
    )
    expect(dummy):toBe(undefined)
    toRaw(obj).prop = 'value'
    expect(dummy):toBe(undefined)
  end
  )
  it('should not be triggered by inherited raw setters', function()
    local dummy = nil
    local parentDummy = nil
    local hiddenValue = nil
    local obj = reactive({})
    local parent = reactive({prop=function(value)
      hiddenValue = value
    end
    , prop=function()
      return hiddenValue
    end
    })
    Object:setPrototypeOf(obj, parent)
    effect(function()
      dummy = obj.prop
    end
    )
    effect(function()
      parentDummy = parent.prop
    end
    )
    expect(dummy):toBe(undefined)
    expect(parentDummy):toBe(undefined)
    toRaw(obj).prop = 4
    expect(dummy):toBe(undefined)
    expect(parentDummy):toBe(undefined)
  end
  )
  it('should avoid implicit infinite recursive loops with itself', function()
    local counter = reactive({num=0})
    local counterSpy = jest:fn(function()
      counter.num=counter.num+1
    end
    )
    effect(counterSpy)
    expect(counter.num):toBe(1)
    expect(counterSpy):toHaveBeenCalledTimes(1)
    counter.num = 4
    expect(counter.num):toBe(5)
    expect(counterSpy):toHaveBeenCalledTimes(2)
  end
  )
  it('should allow explicitly recursive raw function loops', function()
    local counter = reactive({num=0})
    local numSpy = jest:fn(function()
      counter.num=counter.num+1
      if counter.num < 10 then
        numSpy()
      end
    end
    )
    effect(numSpy)
    expect(counter.num):toEqual(10)
    expect(numSpy):toHaveBeenCalledTimes(10)
  end
  )
  it('should avoid infinite loops with other effects', function()
    local nums = reactive({num1=0, num2=1})
    local spy1 = jest:fn(function()
      nums.num1 = nums.num2
    end
    )
    local spy2 = jest:fn(function()
      nums.num2 = nums.num1
    end
    )
    effect(spy1)
    effect(spy2)
    expect(nums.num1):toBe(1)
    expect(nums.num2):toBe(1)
    expect(spy1):toHaveBeenCalledTimes(1)
    expect(spy2):toHaveBeenCalledTimes(1)
    nums.num2 = 4
    expect(nums.num1):toBe(4)
    expect(nums.num2):toBe(4)
    expect(spy1):toHaveBeenCalledTimes(2)
    expect(spy2):toHaveBeenCalledTimes(2)
    nums.num1 = 10
    expect(nums.num1):toBe(10)
    expect(nums.num2):toBe(10)
    expect(spy1):toHaveBeenCalledTimes(3)
    expect(spy2):toHaveBeenCalledTimes(3)
  end
  )
  it('should return a new reactive version of the function', function()
    function greet()
      return 'Hello World'
    end
    
    local effect1 = effect(greet)
    local effect2 = effect(greet)
    expect(type(effect1)):toBe('function')
    expect(type(effect2)):toBe('function')
    expect(effect1).tsvar_not:toBe(greet)
    expect(effect1).tsvar_not:toBe(effect2)
  end
  )
  it('should discover new branches while running automatically', function()
    local dummy = nil
    local obj = reactive({prop='value', run=false})
    local conditionalSpy = jest:fn(function()
      -- [ts2lua]lua中0和空字符串也是true，此处obj.run需要确认
      dummy = (obj.run and {obj.prop} or {'other'})[1]
    end
    )
    effect(conditionalSpy)
    expect(dummy):toBe('other')
    expect(conditionalSpy):toHaveBeenCalledTimes(1)
    obj.prop = 'Hi'
    expect(dummy):toBe('other')
    expect(conditionalSpy):toHaveBeenCalledTimes(1)
    obj.run = true
    expect(dummy):toBe('Hi')
    expect(conditionalSpy):toHaveBeenCalledTimes(2)
    obj.prop = 'World'
    expect(dummy):toBe('World')
    expect(conditionalSpy):toHaveBeenCalledTimes(3)
  end
  )
  it('should discover new branches when running manually', function()
    local dummy = nil
    local run = false
    local obj = reactive({prop='value'})
    local runner = effect(function()
      -- [ts2lua]lua中0和空字符串也是true，此处run需要确认
      dummy = (run and {obj.prop} or {'other'})[1]
    end
    )
    expect(dummy):toBe('other')
    runner()
    expect(dummy):toBe('other')
    run = true
    runner()
    expect(dummy):toBe('value')
    obj.prop = 'World'
    expect(dummy):toBe('World')
  end
  )
  it('should not be triggered by mutating a property, which is used in an inactive branch', function()
    local dummy = nil
    local obj = reactive({prop='value', run=true})
    local conditionalSpy = jest:fn(function()
      -- [ts2lua]lua中0和空字符串也是true，此处obj.run需要确认
      dummy = (obj.run and {obj.prop} or {'other'})[1]
    end
    )
    effect(conditionalSpy)
    expect(dummy):toBe('value')
    expect(conditionalSpy):toHaveBeenCalledTimes(1)
    obj.run = false
    expect(dummy):toBe('other')
    expect(conditionalSpy):toHaveBeenCalledTimes(2)
    obj.prop = 'value2'
    expect(dummy):toBe('other')
    expect(conditionalSpy):toHaveBeenCalledTimes(2)
  end
  )
  it('should not double wrap if the passed function is a effect', function()
    local runner = effect(function()
      
    end
    )
    local otherRunner = effect(runner)
    expect(runner).tsvar_not:toBe(otherRunner)
    expect(runner.raw):toBe(otherRunner.raw)
  end
  )
  it('should not run multiple times for a single mutation', function()
    local dummy = nil
    local obj = reactive({})
    local fnSpy = jest:fn(function()
      for key in pairs(obj) do
        -- [ts2lua]obj下标访问可能不正确
        dummy = obj[key]
      end
      dummy = obj.prop
    end
    )
    effect(fnSpy)
    expect(fnSpy):toHaveBeenCalledTimes(1)
    obj.prop = 16
    expect(dummy):toBe(16)
    expect(fnSpy):toHaveBeenCalledTimes(2)
  end
  )
  it('should allow nested effects', function()
    local nums = reactive({num1=0, num2=1, num3=2})
    local dummy = {}
    local childSpy = jest:fn(function()
      dummy.num1 = nums.num1
    end
    )
    local childeffect = effect(childSpy)
    local parentSpy = jest:fn(function()
      dummy.num2 = nums.num2
      childeffect()
      dummy.num3 = nums.num3
    end
    )
    effect(parentSpy)
    expect(dummy):toEqual({num1=0, num2=1, num3=2})
    expect(parentSpy):toHaveBeenCalledTimes(1)
    expect(childSpy):toHaveBeenCalledTimes(2)
    nums.num1 = 4
    expect(dummy):toEqual({num1=4, num2=1, num3=2})
    expect(parentSpy):toHaveBeenCalledTimes(1)
    expect(childSpy):toHaveBeenCalledTimes(3)
    nums.num2 = 10
    expect(dummy):toEqual({num1=4, num2=10, num3=2})
    expect(parentSpy):toHaveBeenCalledTimes(2)
    expect(childSpy):toHaveBeenCalledTimes(4)
    nums.num3 = 7
    expect(dummy):toEqual({num1=4, num2=10, num3=7})
    expect(parentSpy):toHaveBeenCalledTimes(3)
    expect(childSpy):toHaveBeenCalledTimes(5)
  end
  )
  it('should observe json methods', function()
    local dummy = {}
    local obj = reactive({})
    effect(function()
      dummy = JSON:parse(JSON:stringify(obj))
    end
    )
    obj.a = 1
    expect(dummy.a):toBe(1)
  end
  )
  it('should observe class method invocations', function()
    local Model = newClass({Class}, {name = 'Model'})
    
    function Model:__new__()
      self.count = 0
    end
    
    function Model:inc()
      self.count=self.count+1
    end
    
    local model = reactive(Model())
    local dummy = nil
    effect(function()
      dummy = model.count
    end
    )
    expect(dummy):toBe(0)
    model:inc()
    expect(dummy):toBe(1)
  end
  )
  it('lazy', function()
    local obj = reactive({foo=1})
    local dummy = nil
    local runner = effect(function()
      dummy = obj.foo
    end
    , {lazy=true})
    expect(dummy):toBe(undefined)
    expect(runner()):toBe(1)
    expect(dummy):toBe(1)
    obj.foo = 2
    expect(dummy):toBe(2)
  end
  )
  it('scheduler', function()
    local runner = nil
    local dummy = nil
    local scheduler = jest:fn(function(_runner)
      runner = _runner
    end
    )
    local obj = reactive({foo=1})
    effect(function()
      dummy = obj.foo
    end
    , {scheduler=scheduler})
    expect(scheduler).tsvar_not:toHaveBeenCalled()
    expect(dummy):toBe(1)
    obj.foo=obj.foo+1
    expect(scheduler):toHaveBeenCalledTimes(1)
    expect(dummy):toBe(1)
    runner()
    expect(dummy):toBe(2)
  end
  )
  it('events: onTrack', function()
    local events = {}
    local dummy = nil
    local onTrack = jest:fn(function(e)
      table.insert(events, e)
    end
    )
    local obj = reactive({foo=1, bar=2})
    local runner = effect(function()
      dummy = obj.foo
      dummy = obj['bar']
      dummy = Object:keys(obj)
    end
    , {onTrack=onTrack})
    expect(dummy):toEqual({'foo', 'bar'})
    expect(onTrack):toHaveBeenCalledTimes(3)
    expect(events):toEqual({{effect=runner, target=toRaw(obj), type=TrackOpTypes.GET, key='foo'}, {effect=runner, target=toRaw(obj), type=TrackOpTypes.HAS, key='bar'}, {effect=runner, target=toRaw(obj), type=TrackOpTypes.ITERATE, key=ITERATE_KEY}})
  end
  )
  it('events: onTrigger', function()
    local events = {}
    local dummy = nil
    local onTrigger = jest:fn(function(e)
      table.insert(events, e)
    end
    )
    local obj = reactive({foo=1})
    local runner = effect(function()
      dummy = obj.foo
    end
    , {onTrigger=onTrigger})
    obj.foo=obj.foo+1
    expect(dummy):toBe(2)
    expect(onTrigger):toHaveBeenCalledTimes(1)
    expect(events[0+1]):toEqual({effect=runner, target=toRaw(obj), type=TriggerOpTypes.SET, key='foo', oldValue=1, newValue=2})
    obj.foo = nil
    expect(dummy):toBeUndefined()
    expect(onTrigger):toHaveBeenCalledTimes(2)
    expect(events[1+1]):toEqual({effect=runner, target=toRaw(obj), type=TriggerOpTypes.DELETE, key='foo', oldValue=2})
  end
  )
  it('stop', function()
    local dummy = nil
    local obj = reactive({prop=1})
    local runner = effect(function()
      dummy = obj.prop
    end
    )
    obj.prop = 2
    expect(dummy):toBe(2)
    stop(runner)
    obj.prop = 3
    expect(dummy):toBe(2)
    runner()
    expect(dummy):toBe(3)
  end
  )
  it('stop with scheduler', function()
    local dummy = nil
    local obj = reactive({prop=1})
    local queue = {}
    local runner = effect(function()
      dummy = obj.prop
    end
    , {scheduler=function(e)
      table.insert(queue, e)
    end
    })
    obj.prop = 2
    expect(dummy):toBe(1)
    expect(#queue):toBe(1)
    stop(runner)
    queue:forEach(function(e)
      e()
    end
    )
    expect(dummy):toBe(1)
  end
  )
  it('events: onStop', function()
    local onStop = jest:fn()
    local runner = effect(function()
      
    end
    , {onStop=onStop})
    stop(runner)
    expect(onStop):toHaveBeenCalled()
  end
  )
  it('stop: a stopped effect is nested in a normal effect', function()
    local dummy = nil
    local obj = reactive({prop=1})
    local runner = effect(function()
      dummy = obj.prop
    end
    )
    stop(runner)
    obj.prop = 2
    expect(dummy):toBe(1)
    effect(function()
      runner()
    end
    )
    expect(dummy):toBe(2)
    obj.prop = 3
    expect(dummy):toBe(3)
  end
  )
  it('markRaw', function()
    local obj = reactive({foo=markRaw({prop=0})})
    local dummy = nil
    effect(function()
      dummy = obj.foo.prop
    end
    )
    expect(dummy):toBe(0)
    obj.foo.prop=obj.foo.prop+1
    expect(dummy):toBe(0)
    obj.foo = {prop=1}
    expect(dummy):toBe(1)
  end
  )
  it('should not be trigger when the value and the old value both are NaN', function()
    local obj = reactive({foo=NaN})
    local fnSpy = jest:fn(function()
      obj.foo
    end
    )
    effect(fnSpy)
    obj.foo = NaN
    expect(fnSpy):toHaveBeenCalledTimes(1)
  end
  )
  it('should trigger all effects when array length is set 0', function()
    local observed = reactive({1})
    local dummy = nil
    local record = nil
    effect(function()
      -- [ts2lua]修改数组长度需要手动处理。
      dummy = observed.length
    end
    )
    effect(function()
      record = observed[0+1]
    end
    )
    expect(dummy):toBe(1)
    expect(record):toBe(1)
    observed[1+1] = 2
    expect(observed[1+1]):toBe(2)
    observed:unshift(3)
    expect(dummy):toBe(3)
    expect(record):toBe(3)
    -- [ts2lua]修改数组长度需要手动处理。
    observed.length = 0
    expect(dummy):toBe(0)
    expect(record):toBeUndefined()
  end
  )
  it('should handle self dependency mutations', function()
    local count = ref(0)
    effect(function()
      count.value=count.value+1
    end
    )
    expect(count.value):toBe(1)
    count.value = 10
    expect(count.value):toBe(11)
  end
  )
end
)