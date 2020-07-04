
describe('ssrRenderTeleport', function()
  test('teleport rendering (compiled)', function()
    local ctx = {}
    local html = nil
    expect(html):toBe('<!--teleport start--><!--teleport end-->')
    -- [ts2lua]()下标访问可能不正确
    expect(()['#target']):toBe()
  end
  )
  test('teleport rendering (compiled + disabled)', function()
    local ctx = {}
    local html = nil
    expect(html):toBe('<!--teleport start--><div>content</div><!--teleport end-->')
    -- [ts2lua]()下标访问可能不正确
    expect(()['#target']):toBe()
  end
  )
  test('teleport rendering (vnode)', function()
    local ctx = {}
    local html = nil
    expect(html):toBe('<!--teleport start--><!--teleport end-->')
    -- [ts2lua]()下标访问可能不正确
    expect(()['#target']):toBe('<span>hello</span><!---->')
  end
  )
  test('teleport rendering (vnode + disabled)', function()
    local ctx = {}
    local html = nil
    expect(html):toBe('<!--teleport start--><span>hello</span><!--teleport end-->')
    -- [ts2lua]()下标访问可能不正确
    expect(()['#target']):toBe()
  end
  )
  test('multiple teleports with same target', function()
    local ctx = {}
    local html = nil
    expect(html):toBe('<div><!--teleport start--><!--teleport end--><!--teleport start--><!--teleport end--></div>')
    -- [ts2lua]()下标访问可能不正确
    expect(()['#target']):toBe('<span>hello</span><!---->world<!---->')
  end
  )
end
)