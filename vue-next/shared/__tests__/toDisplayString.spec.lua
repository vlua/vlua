require("shared/src")

describe('toDisplayString', function()
  test('nullish values', function()
    expect(toDisplayString(nil)):toBe('')
    expect(toDisplayString(undefined)):toBe('')
  end
  )
  test('primitive values', function()
    expect(toDisplayString(1)):toBe('1')
    expect(toDisplayString(true)):toBe('true')
    expect(toDisplayString(false)):toBe('false')
    expect(toDisplayString('hello')):toBe('hello')
  end
  )
  test('Object and Arrays', function()
    local obj = {foo=123}
    expect(toDisplayString(obj)):toBe(JSON:stringify(obj, nil, 2))
    local arr = {obj}
    expect(toDisplayString(arr)):toBe(JSON:stringify(arr, nil, 2))
  end
  )
  test('native objects', function()
    local div = document:createElement('div')
    expect(toDisplayString(div)):toBe()
    expect(toDisplayString({div=div})):toMatchInlineSnapshot()
  end
  )
  test('Map and Set', function()
    local m = Map({{1, 'foo'}, {{baz=1}, {foo='bar', qux=2}}})
    local s = Set({1, {foo='bar'}, m})
    expect(toDisplayString(m)):toMatchInlineSnapshot()
    expect(toDisplayString(s)):toMatchInlineSnapshot()
    expect(toDisplayString({m=m, s=s})):toMatchInlineSnapshot()
  end
  )
end
)