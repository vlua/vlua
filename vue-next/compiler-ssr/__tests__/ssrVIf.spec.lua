require("compiler-ssr/src")

describe('ssr: v-if', function()
  test('basic', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('with nested content', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('v-if + v-else', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('v-if + v-else-if', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('v-if + v-else-if + v-else', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('<template v-if> (text)', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('<template v-if> (single element)', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('<template v-if> (multiple element)', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('<template v-if> (with v-for inside)', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('<template v-if> + normal v-else', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
end
)