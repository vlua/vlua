require("@vue/runtime-test")

describe('renderer: element', function()
  local root = nil
  beforeEach(function()
    root = nodeOps:createElement('div')
  end
  )
  it('should create an element', function()
    render(h('div'), root)
    expect(inner(root)):toBe('<div></div>')
  end
  )
  it('should create an element with props', function()
    render(h('div', {id='foo', class='bar'}), root)
    expect(inner(root)):toBe('<div id="foo" class="bar"></div>')
  end
  )
  it('should create an element with direct text children', function()
    render(h('div', {'foo', ' ', 'bar'}), root)
    expect(inner(root)):toBe('<div>foo bar</div>')
  end
  )
  it('should create an element with direct text children and props', function()
    render(h('div', {id='foo'}, {'bar'}), root)
    expect(inner(root)):toBe('<div id="foo">bar</div>')
  end
  )
  it('should update an element tag which is already mounted', function()
    render(h('div', {'foo'}), root)
    expect(inner(root)):toBe('<div>foo</div>')
    render(h('span', {'foo'}), root)
    expect(inner(root)):toBe('<span>foo</span>')
  end
  )
  it('should update element props which is already mounted', function()
    render(h('div', {id='bar'}, {'foo'}), root)
    expect(inner(root)):toBe('<div id="bar">foo</div>')
    render(h('div', {id='baz', class='bar'}, {'foo'}), root)
    expect(inner(root)):toBe('<div id="baz" class="bar">foo</div>')
  end
  )
end
)