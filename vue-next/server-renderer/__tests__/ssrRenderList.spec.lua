require("server-renderer/src/helpers/ssrRenderList")

describe('ssr: renderList', function()
  local stack = {}
  beforeEach(function()
    stack = {}
  end
  )
  it('should render items in an array', function()
    ssrRenderList({'1', '2', '3'}, function(item, index)
      table.insert(stack)
    end
    )
    expect(stack):toEqual({'node 0: 1', 'node 1: 2', 'node 2: 3'})
  end
  )
  it('should render characters of a string', function()
    ssrRenderList('abc', function(item, index)
      table.insert(stack)
    end
    )
    expect(stack):toEqual({'node 0: a', 'node 1: b', 'node 2: c'})
  end
  )
  it('should render integers 1 through N when given a number N', function()
    ssrRenderList(3, function(item, index)
      table.insert(stack)
    end
    )
    expect(stack):toEqual({'node 0: 1', 'node 1: 2', 'node 2: 3'})
  end
  )
  it('should render properties in an object', function()
    ssrRenderList({a=1, b=2, c=3}, function(item, key, index)
      table.insert(stack)
    end
    )
    expect(stack):toEqual({'node 0/a: 1', 'node 1/b: 2', 'node 2/c: 3'})
  end
  )
  it('should render an item for entry in an iterable', function()
    local iterable = function()
      coroutine.yield(1)
      coroutine.yield(2)
      coroutine.yield(3)
    end
    
    ssrRenderList(iterable(), function(item, index)
      table.insert(stack)
    end
    )
    expect(stack):toEqual({'node 0: 1', 'node 1: 2', 'node 2: 3'})
  end
  )
  it('should not render items when source is undefined', function()
    ssrRenderList(undefined, function(item, index)
      table.insert(stack)
    end
    )
    expect(stack):toEqual({})
  end
  )
end
)