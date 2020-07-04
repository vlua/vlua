require("compiler-ssr/src")

describe('ssr: v-for', function()
  test('basic', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('nested content', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('nested v-for', function()
    expect(compile( +  + ).code):toMatchInlineSnapshot()
  end
  )
  test('template v-for (text)', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('template v-for (single element)', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('template v-for (multi element)', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('render loop args should not be prefixed', function()
    local  = compile()
    expect(code):toMatch()
    expect(code).tsvar_not:toMatch()
    expect(code).tsvar_not:toMatch()
    expect(code):toMatchInlineSnapshot()
  end
  )
end
)