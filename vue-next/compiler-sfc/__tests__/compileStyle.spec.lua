require("compiler-sfc/src/compileStyle")
require("@vue/shared")

describe('SFC scoped CSS', function()
  mockWarn()
  function compileScoped(source)
    local res = compileStyle({source=source, filename='test.css', id='test', scoped=true})
    if #res.errors then
      res.errors:forEach(function(err)
        console:error(err)
      end
      )
      expect(#res.errors):toBe(0)
    end
    return res.code
  end
  
  test('simple selectors', function()
    expect(compileScoped()):toMatch()
    expect(compileScoped()):toMatch()
  end
  )
  test('descendent selector', function()
    expect(compileScoped()):toMatch()
  end
  )
  test('multiple selectors', function()
    expect(compileScoped()):toMatch()
  end
  )
  test('pseudo class', function()
    expect(compileScoped()):toMatch()
  end
  )
  test('pseudo element', function()
    expect(compileScoped()):toMatch('[test]::selection {')
  end
  )
  test('spaces before pseudo element', function()
    local code = compileScoped()
    expect(code):toMatch('.abc[test],')
    expect(code):toMatch('[test]::selection {')
  end
  )
  test('::v-deep', function()
    expect(compileScoped()):toMatchInlineSnapshot()
    expect(compileScoped()):toMatchInlineSnapshot()
    expect(compileScoped()):toMatchInlineSnapshot()
  end
  )
  test('::v-slotted', function()
    expect(compileScoped()):toMatchInlineSnapshot()
    expect(compileScoped()):toMatchInlineSnapshot()
    expect(compileScoped()):toMatchInlineSnapshot()
  end
  )
  test('::v-global', function()
    expect(compileScoped()):toMatchInlineSnapshot()
    expect(compileScoped()):toMatchInlineSnapshot()
    expect(compileScoped()):toMatchInlineSnapshot()
  end
  )
  test('media query', function()
    expect(compileScoped()):toMatchInlineSnapshot()
  end
  )
  test('supports query', function()
    expect(compileScoped()):toMatchInlineSnapshot()
  end
  )
  test('scoped keyframes', function()
    local style = compileScoped()
    expect(style):toContain()
    expect(style):toContain()
    expect(style):toContain()
    expect(style):toContain()
    expect(style):toContain()
    expect(style):toContain()
    expect(style):toContain()
    expect(style):toContain()
    expect(style):toContain()
  end
  )
  test('spaces after selector', function()
    expect(compileScoped()):toMatchInlineSnapshot()
  end
  )
  describe('deprecated syntax', function()
    test('::v-deep as combinator', function()
      expect(compileScoped()):toMatchInlineSnapshot()
      expect(compileScoped()):toMatchInlineSnapshot()
      expect():toHaveBeenWarned()
    end
    )
    test('>>> (deprecated syntax)', function()
      local code = compileScoped()
      expect(code):toMatchInlineSnapshot()
      expect():toHaveBeenWarned()
    end
    )
    test('/deep/ (deprecated syntax)', function()
      local code = compileScoped()
      expect(code):toMatchInlineSnapshot()
      expect():toHaveBeenWarned()
    end
    )
  end
  )
end
)
describe('SFC CSS modules', function()
  test('should include resulting classes object in result', function()
    local result = nil
    expect(result.modules):toBeDefined()
    expect(().red):toMatch('_red_')
    expect(().green):toMatch('_green_')
    expect(().blue):toBeUndefined()
  end
  )
  test('postcss-modules options', function()
    local result = nil
    expect(result.modules):toBeDefined()
    expect(().fooBar):toMatch('__foo-bar__')
    expect(().bazQux):toBeUndefined()
  end
  )
end
)