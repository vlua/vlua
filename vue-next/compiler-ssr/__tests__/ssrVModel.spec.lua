require("compiler-ssr/src")

function compileWithWrapper(src)
  return compile()
end

describe('ssr: v-model', function()
  test('<input> (text types)', function()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
  end
  )
  test('<input type="radio">', function()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
  end
  )
  test('<input type="checkbox"', function()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
  end
  )
  test('<textarea>', function()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
  end
  )
  test('<input :type="x">', function()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
  end
  )
  test('<input v-bind="obj">', function()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
  end
  )
end
)