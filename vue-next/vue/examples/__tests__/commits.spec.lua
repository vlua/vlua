require("vue/__tests__/e2eUtils")
require("vue/examples/__tests__/commits.mock")

describe('e2e: commits', function()
  local  = setupPuppeteer()
  function testCommits(apiType)
    local baseUrl = nil
    page():on('request', function(req)
      -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
      local match = req:url():match(/&sha=(.*)$/)
      if not match then
        req:continue()
      else
        -- [ts2lua]mocks下标访问可能不正确
        req:respond({status=200, contentType='application/json', headers={Access-Control-Allow-Origin='*'}, body=JSON:stringify(mocks[match[1+1]])})
      end
    end
    )
    expect():toBe(2)
    expect():toBe(2)
    expect():toBe('master')
    expect():toBe('sync')
    expect():toBe(true)
    expect():toBe(false)
    expect():toBe('vuejs/vue@master')
    expect():toBe(3)
    expect():toBe(3)
    expect():toBe(3)
    expect():toBe('vuejs/vue@sync')
    expect():toBe(3)
    expect():toBe(3)
    expect():toBe(3)
  end
  
  test('classic', function()
    
  end
  , E2E_TIMEOUT)
  test('composition', function()
    
  end
  , E2E_TIMEOUT)
end
)