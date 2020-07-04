require("vue")
require("server-renderer/src")

describe('ssr: scoped id on component root', function()
  test('basic', function()
    local withParentId = withScopeId('parent')
    local Child = {ssrRender=function(ctx, push, parent, attrs)
      push()
    end
    }
    local Comp = {ssrRender=withParentId(function(ctx, push, parent)
      push(ssrRenderComponent(Child), nil, nil, parent)
    end
    )}
    local result = nil
    expect(result):toBe()
  end
  )
  test('inside slot', function()
    local withParentId = withScopeId('parent')
    local Child = {ssrRender=function(_, push, _parent, attrs)
      push()
    end
    }
    local Wrapper = {__scopeId='wrapper', ssrRender=function(ctx, push, parent)
      ssrRenderSlot(ctx.tsvar_slots, 'default', {}, nil, push, parent)
    end
    }
    local Comp = {ssrRender=withParentId(function(_, push, parent)
      push(ssrRenderComponent(Wrapper, nil, {default=withParentId(function(_, push, parent)
        push(ssrRenderComponent(Child, nil, nil, parent))
      end
      ), _=1}, parent))
    end
    )}
    local result = nil
    expect(result):toBe()
  end
  )
end
)