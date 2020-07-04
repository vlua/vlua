require("compiler-ssr/src")
require("compiler-ssr/__tests__/utils")

describe('ssr: text', function()
  test('static text', function()
    expect(getCompiledString()):toMatchInlineSnapshot()
  end
  )
  test('static text with template string special chars', function()
    expect(getCompiledString()):toMatchInlineSnapshot()
  end
  )
  test('static text with char escape', function()
    expect(getCompiledString()):toMatchInlineSnapshot()
  end
  )
  test('comments', function()
    expect(getCompiledString()):toMatchInlineSnapshot()
  end
  )
  test('static text escape', function()
    expect(getCompiledString()):toMatchInlineSnapshot()
  end
  )
  test('nested elements with static text', function()
    expect(getCompiledString()):toMatchInlineSnapshot()
  end
  )
  test('interpolation', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('nested elements with interpolation', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
end
)