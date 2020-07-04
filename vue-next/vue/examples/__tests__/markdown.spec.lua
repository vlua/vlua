require("vue/__tests__/e2eUtils")

describe('e2e: markdown', function()
  local  = setupPuppeteer()
  function testMarkdown(apiType)
    local baseUrl = nil
    expect():toBe(true)
    expect():toBe('# hello')
    expect():toBe('<h1 id="hello">hello</h1>\n')
    expect():toBe('<h1 id="hello">hello</h1>\n')
    expect():toBe('<h1 id="hello">hello</h1>\n' .. '<h2 id="foo">foo</h2>\n' .. '<ul>\n<li>bar</li>\n<li>baz</li>\n</ul>\n')
  end
  
  test('classic', function()
    
  end
  , E2E_TIMEOUT)
  test('composition', function()
    
  end
  , E2E_TIMEOUT)
end
)