require("runtime-core/src/helpers/renderList")

describe('renderList', function()
  it('should render items in an array', function()
    expect(renderList({'1', '2', '3'}, function(item, index)
      
    end
    )):toEqual({'node 0: 1', 'node 1: 2', 'node 2: 3'})
  end
  )
  it('should render characters of a string', function()
    expect(renderList('123', function(item, index)
      
    end
    )):toEqual({'node 0: 1', 'node 1: 2', 'node 2: 3'})
  end
  )
  it('should render integers 1 through N when given a number N', function()
    expect(renderList(3, function(item, index)
      
    end
    )):toEqual({'node 0: 1', 'node 1: 2', 'node 2: 3'})
  end
  )
  it('should render properties in an object', function()
    expect(renderList({a=1, b=2, c=3}, function(item, key, index)
      
    end
    )):toEqual({'node 0/a: 1', 'node 1/b: 2', 'node 2/c: 3'})
  end
  )
  it('should render an item for entry in an iterable', function()
    local iterable = function()
      coroutine.yield(1)
      coroutine.yield(2)
      coroutine.yield(3)
    end
    
    expect(renderList(iterable(), function(item, index)
      
    end
    )):toEqual({'node 0: 1', 'node 1: 2', 'node 2: 3'})
  end
  )
  it('should return empty array when source is undefined', function()
    expect(renderList(undefined, function(item, index)
      
    end
    )):toEqual({})
  end
  )
end
)