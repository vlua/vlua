require("vue/__tests__/e2eUtils")

local globalStats = nil
-- [ts2lua]请手动处理DeclareFunction

describe('e2e: svg', function()
  local  = setupPuppeteer()
  function assertPolygon(total)
    expect():toBe(true)
  end
  
  function assertLabels(total)
    local positions = nil
    local i = 0
    repeat
      local textPosition = nil
      expect(textPosition):toEqual(positions[i+1])
      i=i+1
    until not(i < total)
  end
  
  function assertStats(expected)
    local statsValue = nil
    expect(statsValue):toEqual(expected)
  end
  
  function nthRange(n)
    return 
  end
  
  function testSvg(apiType)
    local baseUrl = nil
    expect():toBe(1)
    expect():toBe(1)
    expect():toBe(1)
    expect():toBe(6)
    expect():toBe(6)
    expect():toBe(7)
    expect():toBe(6)
    expect():toBe(5)
    expect():toBe(5)
    expect():toBe(6)
    expect():toBe(5)
    expect():toBe(6)
    expect():toBe(6)
    expect():toBe(7)
    expect():toBe(6)
  end
  
  test('classic', function()
    
  end
  , E2E_TIMEOUT)
  test('composition', function()
    
  end
  , E2E_TIMEOUT)
end
)