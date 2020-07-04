require("@vue/runtime-test")
require("@vue/runtime-test/NodeTypes")

describe('renderer: vnode hooks', function()
  function assertHooks(hooks, vnode1, vnode2)
    local root = nodeOps:createElement('div')
    render(vnode1, root)
    expect(hooks.onVnodeBeforeMount):toHaveBeenCalledWith(vnode1, nil)
    expect(hooks.onVnodeMounted):toHaveBeenCalledWith(vnode1, nil)
    expect(hooks.onVnodeBeforeUpdate).tsvar_not:toHaveBeenCalled()
    expect(hooks.onVnodeUpdated).tsvar_not:toHaveBeenCalled()
    expect(hooks.onVnodeBeforeUnmount).tsvar_not:toHaveBeenCalled()
    expect(hooks.onVnodeUnmounted).tsvar_not:toHaveBeenCalled()
    render(vnode2, root)
    expect(hooks.onVnodeBeforeMount):toHaveBeenCalledTimes(1)
    expect(hooks.onVnodeMounted):toHaveBeenCalledTimes(1)
    expect(hooks.onVnodeBeforeUpdate):toHaveBeenCalledWith(vnode2, vnode1)
    expect(hooks.onVnodeUpdated):toHaveBeenCalledWith(vnode2, vnode1)
    expect(hooks.onVnodeBeforeUnmount).tsvar_not:toHaveBeenCalled()
    expect(hooks.onVnodeUnmounted).tsvar_not:toHaveBeenCalled()
    render(nil, root)
    expect(hooks.onVnodeBeforeMount):toHaveBeenCalledTimes(1)
    expect(hooks.onVnodeMounted):toHaveBeenCalledTimes(1)
    expect(hooks.onVnodeBeforeUpdate):toHaveBeenCalledTimes(1)
    expect(hooks.onVnodeUpdated):toHaveBeenCalledTimes(1)
    expect(hooks.onVnodeBeforeUnmount):toHaveBeenCalledWith(vnode2, nil)
    expect(hooks.onVnodeUnmounted):toHaveBeenCalledWith(vnode2, nil)
  end
  
  test('should work on element', function()
    local hooks = {onVnodeBeforeMount=jest:fn(), onVnodeMounted=jest:fn(), onVnodeBeforeUpdate=jest:fn(function(vnode)
      expect(vnode.el.children[0+1]):toMatchObject({type=NodeTypes.TEXT, text='foo'})
    end
    ), onVnodeUpdated=jest:fn(function(vnode)
      expect(vnode.el.children[0+1]):toMatchObject({type=NodeTypes.TEXT, text='bar'})
    end
    ), onVnodeBeforeUnmount=jest:fn(), onVnodeUnmounted=jest:fn()}
    assertHooks(hooks, h('div', hooks, 'foo'), h('div', hooks, 'bar'))
  end
  )
  test('should work on component', function()
    local Comp = function(props)
      props.msg
    end
    
    local hooks = {onVnodeBeforeMount=jest:fn(), onVnodeMounted=jest:fn(), onVnodeBeforeUpdate=jest:fn(function(vnode)
      expect(vnode.el):toMatchObject({type=NodeTypes.TEXT, text='foo'})
    end
    ), onVnodeUpdated=jest:fn(function(vnode)
      expect(vnode.el):toMatchObject({type=NodeTypes.TEXT, text='bar'})
    end
    ), onVnodeBeforeUnmount=jest:fn(), onVnodeUnmounted=jest:fn()}
    assertHooks(hooks, h(Comp, {..., msg='foo'}), h(Comp, {..., msg='bar'}))
  end
  )
end
)