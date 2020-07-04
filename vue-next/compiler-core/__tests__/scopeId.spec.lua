require("compiler-core/src/compile")
require("compiler-core/src/runtimeHelpers")

describe('scopeId compiler support', function()
  test('should only work in module mode', function()
    expect(function()
      baseCompile({scopeId='test'})
    end
    ):toThrow()
  end
  )
  test('should wrap render function', function()
    local  = baseCompile({mode='module', scopeId='test'})
    expect(ast.helpers):toContain(WITH_SCOPE_ID)
    expect(code):toMatch()
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('should wrap default slot', function()
    local  = baseCompile({mode='module', scopeId='test'})
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('should wrap named slots', function()
    local  = baseCompile({mode='module', scopeId='test'})
    expect(code):toMatch()
    expect(code):toMatch()
    expect(code):toMatchSnapshot()
  end
  )
  test('should wrap dynamic slots', function()
    local  = baseCompile({mode='module', scopeId='test'})
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    expect(code):toMatch(/name: "foo",\s+fn: _withId\(/)
    -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
    expect(code):toMatch(/name: i,\s+fn: _withId\(/)
    expect(code):toMatchSnapshot()
  end
  )
  test('should push scopeId for hoisted nodes', function()
    local  = baseCompile({mode='module', scopeId='test', hoistStatic=true})
    expect(ast.helpers):toContain(PUSH_SCOPE_ID)
    expect(ast.helpers):toContain(POP_SCOPE_ID)
    expect(#ast.hoists):toBe(2)
    expect(code):toMatch(({}):join('\n'))
    expect(code):toMatchSnapshot()
  end
  )
end
)