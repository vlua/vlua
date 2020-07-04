require("compiler-dom/src")

describe('compile', function()
  it('should contain standard transforms', function()
    local  = compile()
    expect(code):toMatchSnapshot()
  end
  )
end
)