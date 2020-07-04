require("server-renderer/src/helpers/ssrRenderAttrs")

describe('ssr: renderAttrs', function()
  test('ignore reserved props', function()
    expect(ssrRenderAttrs({key=1, ref=function()
      
    end
    , onClick=function()
      
    end
    })):toBe('')
  end
  )
  test('normal attrs', function()
    expect(ssrRenderAttrs({id='foo', title='bar'})):toBe()
  end
  )
  test('empty value attrs', function()
    expect(ssrRenderAttrs({data-v-abc=''})):toBe()
  end
  )
  test('escape attrs', function()
    expect(ssrRenderAttrs({id='"><script'})):toBe()
  end
  )
  test('boolean attrs', function()
    expect(ssrRenderAttrs({checked=true, multiple=false})):toBe()
  end
  )
  test('ignore falsy values', function()
    expect(ssrRenderAttrs({foo=false, title=nil, baz=undefined})):toBe()
  end
  )
  test('ignore non-renderable values', function()
    expect(ssrRenderAttrs({foo={}, bar={}, baz=function()
      
    end
    })):toBe()
  end
  )
  test('props to attrs', function()
    expect(ssrRenderAttrs({readOnly=true, htmlFor='foobar'})):toBe()
  end
  )
  test('preserve name on custom element', function()
    expect(ssrRenderAttrs({fooBar='ok'}, 'my-el')):toBe()
  end
  )
end
)
describe('ssr: renderAttr', function()
  test('basic', function()
    expect(ssrRenderAttr('foo', 'bar')):toBe()
  end
  )
  test('null and undefined', function()
    expect(ssrRenderAttr('foo', nil)):toBe()
    expect(ssrRenderAttr('foo', undefined)):toBe()
  end
  )
  test('escape', function()
    expect(ssrRenderAttr('foo', '<script>')):toBe()
  end
  )
end
)
describe('ssr: renderClass', function()
  test('via renderProps', function()
    expect(ssrRenderAttrs({class={'foo', 'bar'}})):toBe()
  end
  )
  test('standalone', function()
    expect(ssrRenderClass()):toBe()
    expect(ssrRenderClass({})):toBe()
    expect(ssrRenderClass({foo=true, bar=false})):toBe()
    expect(ssrRenderClass({{foo=true, bar=false}, })):toBe()
  end
  )
  test('escape class values', function()
    expect(ssrRenderClass()):toBe()
  end
  )
end
)
describe('ssr: renderStyle', function()
  test('via renderProps', function()
    expect(ssrRenderAttrs({style={color='red'}})):toBe()
  end
  )
  test('standalone', function()
    expect(ssrRenderStyle()):toBe()
    expect(ssrRenderStyle({color=})):toBe()
    expect(ssrRenderStyle({{color=}, {fontSize=}})):toBe()
  end
  )
  test('number handling', function()
    expect(ssrRenderStyle({fontSize=15, opacity=0.5})):toBe()
  end
  )
  test('escape inline CSS', function()
    expect(ssrRenderStyle()):toBe()
    expect(ssrRenderStyle({color=})):toBe()
  end
  )
end
)