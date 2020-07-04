require("@vue/runtime-test")

describe('renderer: component', function()
  test('should update parent(hoc) component host el when child component self update', function()
    local value = ref(true)
    local parentVnode = nil
    local childVnode1 = nil
    local childVnode2 = nil
    local Parent = {render=function()
      return parentVnode = h(Child)
    end
    }
    local Child = {render=function()
      -- [ts2lua]lua中0和空字符串也是true，此处value.value需要确认
      return (value.value and {childVnode1 = h('div')} or {childVnode2 = h('span')})[1]
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Parent), root)
    expect(serializeInner(root)):toBe()
    expect(().el):toBe(().el)
    value.value = false
    expect(serializeInner(root)):toBe()
    expect(().el):toBe(().el)
  end
  )
end
)