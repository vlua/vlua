require("vue/__tests__/e2eUtils")

describe('e2e: grid', function()
  local  = setupPuppeteer()
  local columns = {'name', 'power'}
  function assertTable(data)
    expect():toBe(#data * #columns)
    local i = 0
    repeat
      local j = 0
      repeat
        -- [ts2lua]data[i+1]下标访问可能不正确
        expect():toContain(data[i+1][columns[j+1]])
        j=j+1
      until not(j < #columns)
      i=i+1
    until not(i < #data)
  end
  
  function testGrid(apiType)
    local baseUrl = nil
    expect():toBe(2)
    expect():toBe(0)
    expect():toContain('Name')
    expect():toContain('Power')
    expect():toBe(1)
    expect():toBe(0)
    expect():toBe(1)
    expect():toBe(0)
    expect():toBe(0)
    expect():toBe(1)
    expect():toBe(1)
    expect():toBe(1)
    expect():toBe(0)
    expect():toBe(1)
    expect():toBe(1)
    expect():toBe(1)
    expect():toBe(1)
    expect():toBe(0)
    expect():toBe(1)
    expect():toBe(1)
    expect():toBe(0)
    expect():toBe(1)
  end
  
  test('classic', function()
    
  end
  , E2E_TIMEOUT)
  test('composition', function()
    
  end
  , E2E_TIMEOUT)
end
)