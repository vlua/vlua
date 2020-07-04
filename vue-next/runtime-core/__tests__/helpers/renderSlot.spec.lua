require("runtime-core/src/helpers/renderSlot")
require("runtime-core/src/h")
require("@vue/shared")

describe('renderSlot', function()
  mockWarn()
  it('should render slot', function()
    local child = nil
    local vnode = renderSlot({default=function()
      {child = h('child')}
    end
    }, 'default')
    expect(vnode.children):toEqual({child})
  end
  )
  it('should render slot fallback', function()
    local vnode = renderSlot({}, 'default', {}, function()
      {'fallback'}
    end
    )
    expect(vnode.children):toEqual({'fallback'})
  end
  )
  it('should warn render ssr slot', function()
    renderSlot({default=function(a, b, c)
      {h('child')}
    end
    }, 'default')
    expect('SSR-optimized slot function detected'):toHaveBeenWarned()
  end
  )
end
)