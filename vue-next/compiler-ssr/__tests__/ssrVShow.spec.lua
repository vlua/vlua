require("compiler-ssr/src")

function compileWithWrapper(src)
  return compile()
end

describe('ssr: v-show', function()
  test('basic as root', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('basic', function()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
  end
  )
  test('with static style', function()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
  end
  )
  test('with dynamic style', function()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
  end
  )
  test('with static + dynamic style', function()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
  end
  )
  test('with v-bind', function()
    expect(compileWithWrapper().code):toMatchInlineSnapshot()
  end
  )
end
)