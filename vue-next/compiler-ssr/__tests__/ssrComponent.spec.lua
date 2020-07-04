require("compiler-ssr/src")

describe('ssr: components', function()
  test('basic', function()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  test('dynamic component', function()
    expect(compile().code):toMatchInlineSnapshot()
    expect(compile().code):toMatchInlineSnapshot()
  end
  )
  describe('slots', function()
    test('implicit default slot', function()
      expect(compile().code):toMatchInlineSnapshot()
    end
    )
    test('explicit default slot', function()
      expect(compile().code):toMatchInlineSnapshot()
    end
    )
    test('named slots', function()
      expect(compile().code):toMatchInlineSnapshot()
    end
    )
    test('v-if slot', function()
      expect(compile().code):toMatchInlineSnapshot()
    end
    )
    test('v-for slot', function()
      expect(compile().code):toMatchInlineSnapshot()
    end
    )
    test('nested transform scoping in vnode branch', function()
      expect(compile().code):toMatchInlineSnapshot()
    end
    )
    test('built-in fallthroughs', function()
      expect(compile().code):toMatchInlineSnapshot()
      expect(compile().code):toMatchInlineSnapshot()
      expect(compile().code):toMatchInlineSnapshot()
    end
    )
  end
  )
end
)