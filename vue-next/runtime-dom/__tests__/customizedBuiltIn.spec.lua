require("@vue/runtime-dom")

describe('customized built-in elements support', function()
  local createElement = nil
  afterEach(function()
    createElement:mockRestore()
  end
  )
  test('should created element with is option', function()
    local root = document:createElement('div')
    createElement = jest:spyOn(document, 'createElement')
    render(h('button', {is='plastic-button'}), root)
    expect(createElement.mock.calls[0+1]):toMatchObject({'button', {is='plastic-button'}})
    expect(root.innerHTML):toBe()
  end
  )
end
)