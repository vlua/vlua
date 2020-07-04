require("runtime-core/src/helpers/scopeId")
require("@vue/runtime-test")

describe('scopeId runtime support', function()
  local withParentId = withScopeId('parent')
  local withChildId = withScopeId('child')
  test('should attach scopeId', function()
    local App = {__scopeId='parent', render=withParentId(function()
      return h('div', {h('div')})
    end
    )}
    local root = nodeOps:createElement('div')
    render(h(App), root)
    expect(serializeInner(root)):toBe()
  end
  )
  test('should attach scopeId to components in parent component', function()
    local Child = {__scopeId='child', render=withChildId(function()
      return h('div')
    end
    )}
    local App = {__scopeId='parent', render=withParentId(function()
      return h('div', {h(Child)})
    end
    )}
    local root = nodeOps:createElement('div')
    render(h(App), root)
    expect(serializeInner(root)):toBe()
  end
  )
  test('should work on slots', function()
    local Child = {__scopeId='child', render=withChildId(function(this)
      return h('div', self.tsvar_slots:default())
    end
    )}
    local withChil2Id = withScopeId('child2')
    local Child2 = {__scopeId='child2', render=withChil2Id(function()
      h('span')
    end
    )}
    local App = {__scopeId='parent', render=withParentId(function()
      return h(Child, withParentId(function()
        return {h('div'), h(Child2)}
      end
      ))
    end
    )}
    local root = nodeOps:createElement('div')
    render(h(App), root)
    expect(serializeInner(root)):toBe( +  +  + )
  end
  )
end
)