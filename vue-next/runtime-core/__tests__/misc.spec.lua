require("@vue/runtime-test")

describe('misc', function()
  test('component public instance should not be observable', function()
    local instance = nil
    local Comp = {render=function() end, mounted=function()
      instance = self
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect(instance):toBeDefined()
    local r = reactive(instance)
    expect(r):toBe(instance)
    expect(isReactive(r)):toBe(false)
  end
  )
end
)