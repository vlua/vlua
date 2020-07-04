require("compiler-ssr/__tests__/utils")
require("compiler-ssr/src")

describe('ssr: element', function()
  test('basic elements', function()
    expect(getCompiledString()):toMatchInlineSnapshot()
    expect(getCompiledString()):toMatchInlineSnapshot()
  end
  )
  test('nested elements', function()
    expect(getCompiledString()):toMatchInlineSnapshot()
  end
  )
  test('void element', function()
    expect(getCompiledString()):toMatchInlineSnapshot()
  end
  )
  describe('children override', function()
    test('v-html', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
    test('v-text', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
    test('<textarea> with dynamic value', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
    test('<textarea> with static value', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
    test('<textarea> with dynamic v-bind', function()
      expect(compile().code):toMatchInlineSnapshot()
    end
    )
    test('should pass tag to custom elements w/ dynamic v-bind', function()
      expect(compile({isCustomElement=function()
        true
      end
      }).code):toMatchInlineSnapshot()
    end
    )
  end
  )
  describe('attrs', function()
    test('static attrs', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
    test('v-bind:class', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
    test('static class + v-bind:class', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
    test('v-bind:style', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
    test('static style + v-bind:style', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
    test('v-bind:key (boolean)', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
    test('v-bind:key (non-boolean)', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
    test('v-bind:[key]', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
      expect(getCompiledString()):toMatchInlineSnapshot()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
    test('v-bind="obj"', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
      expect(getCompiledString()):toMatchInlineSnapshot()
      expect(getCompiledString()):toMatchInlineSnapshot()
      expect(getCompiledString()):toMatchInlineSnapshot()
      expect(getCompiledString()):toMatchInlineSnapshot()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
    test('should ignore v-on', function()
      expect(getCompiledString()):toMatchInlineSnapshot()
      expect(getCompiledString()):toMatchInlineSnapshot()
      expect(getCompiledString()):toMatchInlineSnapshot()
    end
    )
  end
  )
end
)