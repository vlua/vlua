require("reactivity/src/reactive")
require("reactivity/src/effect")

describe('shallowReactive', function()
  test('should not make non-reactive properties reactive', function()
    local props = shallowReactive({n={foo=1}})
    lu.assertEquals(isReactive(props.n), false)
  end
  )
  test('should keep reactive properties reactive', function()
    local props = shallowReactive({n=reactive({foo=1})})
    props.n = reactive({foo=2})
    lu.assertEquals(isReactive(props.n), true)
  end
  )
  describe('collections', function()
    test('should be reactive', function()
      local shallowSet = shallowReactive(Set())
      local a = {}
      local size = nil
      effect(function()
        size = shallowSet.size
      end
      )
      lu.assertEquals(size, 0)
      shallowSet:add(a)
      lu.assertEquals(size, 1)
      shallowSet:delete(a)
      lu.assertEquals(size, 0)
    end
    )
    test('should not observe when iterating', function()
      local shallowSet = shallowReactive(Set())
      local a = {}
      shallowSet:add(a)
      local spreadA = ({...})[0+1]
      lu.assertEquals(isReactive(spreadA), false)
    end
    )
    test('should not get reactive entry', function()
      local shallowMap = shallowReactive(Map())
      local a = {}
      local key = 'a'
      shallowMap:set(key, a)
      lu.assertEquals(isReactive(shallowMap:get(key)), false)
    end
    )
    test('should not get reactive on foreach', function()
      local shallowSet = shallowReactive(Set())
      local a = {}
      shallowSet:add(a)
      shallowSet:forEach(function(x)
        lu.assertEquals(isReactive(x), false)
      end
      )
    end
    )
    test('onTrack on called on objectSpread', function()
      local onTrackFn = jest:fn()
      local shallowSet = shallowReactive(Set())
      local a = nil
      effect(function()
        a = Array:from(shallowSet)
      end
      , {onTrack=onTrackFn})
      expect(a):toMatchObject({})
      expect(onTrackFn):toHaveBeenCalled()
    end
    )
  end
  )
  describe('array', function()
    test('should be reactive', function()
      local shallowArray = shallowReactive({})
      local a = {}
      local size = nil
      effect(function()
        -- [ts2lua]修改数组长度需要手动处理。
        size = shallowArray.length
      end
      )
      lu.assertEquals(size, 0)
      table.insert(shallowArray, a)
      lu.assertEquals(size, 1)
      shallowArray:pop()
      lu.assertEquals(size, 0)
    end
    )
    test('should not observe when iterating', function()
      local shallowArray = shallowReactive({})
      local a = {}
      table.insert(shallowArray, a)
      local spreadA = ({...})[0+1]
      lu.assertEquals(isReactive(spreadA), false)
    end
    )
    test('onTrack on called on objectSpread', function()
      local onTrackFn = jest:fn()
      local shallowArray = shallowReactive({})
      local a = nil
      effect(function()
        a = Array:from(shallowArray)
      end
      , {onTrack=onTrackFn})
      expect(a):toMatchObject({})
      expect(onTrackFn):toHaveBeenCalled()
    end
    )
  end
  )
end
)