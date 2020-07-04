require("compiler-ssr/src")

describe('ssr compile: suspense', function()
  test('implicit default', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('explicit slots', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
end
)