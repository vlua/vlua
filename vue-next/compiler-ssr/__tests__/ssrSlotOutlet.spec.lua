require("compiler-ssr/src")

describe('ssr: <slot>', function()
  test('basic', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('with name', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('with dynamic name', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('with props', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('with fallback', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
end
)