require("compiler-ssr/src")

describe('ssr compile: teleport', function()
  test('should work', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('disabled prop handling', function()
    expect(compile().code):toMatchInlineSnapshot()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
end
)