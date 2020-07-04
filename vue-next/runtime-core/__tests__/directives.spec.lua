require("@vue/runtime-test")
require("runtime-core/src/component")

describe('directives', function()
  it('should work', function()
    local count = ref(0)
    function assertBindings(binding)
      expect(binding.value):toBe(count.value)
      expect(binding.arg):toBe('foo')
      expect(binding.instance):toBe(_instance and _instance.proxy)
      expect(binding.modifiers and binding.modifiers.ok):toBe(true)
    end
    
    local beforeMount = jest:fn(function(el, binding, vnode, prevVNode)
      expect(el.tag):toBe('div')
      expect(el.parentNode):toBe(nil)
      expect(#root.children):toBe(0)
      assertBindings(binding)
      expect(vnode):toBe(_vnode)
      expect(prevVNode):toBe(nil)
    end
    )
    local mounted = jest:fn(function(el, binding, vnode, prevVNode)
      expect(el.tag):toBe('div')
      expect(el.parentNode):toBe(root)
      expect(root.children[0+1]):toBe(el)
      assertBindings(binding)
      expect(vnode):toBe(_vnode)
      expect(prevVNode):toBe(nil)
    end
    )
    local beforeUpdate = jest:fn(function(el, binding, vnode, prevVNode)
      expect(el.tag):toBe('div')
      expect(el.parentNode):toBe(root)
      expect(root.children[0+1]):toBe(el)
      expect(el.children[0+1].text):toBe()
      assertBindings(binding)
      expect(vnode):toBe(_vnode)
      expect(prevVNode):toBe(_prevVnode)
    end
    )
    local updated = jest:fn(function(el, binding, vnode, prevVNode)
      expect(el.tag):toBe('div')
      expect(el.parentNode):toBe(root)
      expect(root.children[0+1]):toBe(el)
      expect(el.children[0+1].text):toBe()
      assertBindings(binding)
      expect(vnode):toBe(_vnode)
      expect(prevVNode):toBe(_prevVnode)
    end
    )
    local beforeUnmount = jest:fn(function(el, binding, vnode, prevVNode)
      expect(el.tag):toBe('div')
      expect(el.parentNode):toBe(root)
      expect(root.children[0+1]):toBe(el)
      assertBindings(binding)
      expect(vnode):toBe(_vnode)
      expect(prevVNode):toBe(nil)
    end
    )
    local unmounted = jest:fn(function(el, binding, vnode, prevVNode)
      expect(el.tag):toBe('div')
      expect(el.parentNode):toBe(nil)
      expect(#root.children):toBe(0)
      assertBindings(binding)
      expect(vnode):toBe(_vnode)
      expect(prevVNode):toBe(nil)
    end
    )
    local dir = {beforeMount=beforeMount, mounted=mounted, beforeUpdate=beforeUpdate, updated=updated, beforeUnmount=beforeUnmount, unmounted=unmounted}
    local _instance = nil
    local _vnode = nil
    local _prevVnode = nil
    local Comp = {setup=function()
      _instance = currentInstance
    end
    , render=function()
      _prevVnode = _vnode
      _vnode = withDirectives(h('div', count.value), {{dir, count.value, 'foo', {ok=true}}})
      return _vnode
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(beforeMount):toHaveBeenCalledTimes(1)
    expect(mounted):toHaveBeenCalledTimes(1)
    count.value=count.value+1
    expect(beforeUpdate):toHaveBeenCalledTimes(1)
    expect(updated):toHaveBeenCalledTimes(1)
    render(nil, root)
    expect(beforeUnmount):toHaveBeenCalledTimes(1)
    expect(unmounted):toHaveBeenCalledTimes(1)
  end
  )
  it('should work with a function directive', function()
    local count = ref(0)
    function assertBindings(binding)
      expect(binding.value):toBe(count.value)
      expect(binding.arg):toBe('foo')
      expect(binding.instance):toBe(_instance and _instance.proxy)
      expect(binding.modifiers and binding.modifiers.ok):toBe(true)
    end
    
    local fn = jest:fn(function(el, binding, vnode, prevVNode)
      expect(el.tag):toBe('div')
      expect(el.parentNode):toBe(root)
      assertBindings(binding)
      expect(vnode):toBe(_vnode)
      expect(prevVNode):toBe(_prevVnode)
    end
    )
    local _instance = nil
    local _vnode = nil
    local _prevVnode = nil
    local Comp = {setup=function()
      _instance = currentInstance
    end
    , render=function()
      _prevVnode = _vnode
      _vnode = withDirectives(h('div', count.value), {{fn, count.value, 'foo', {ok=true}}})
      return _vnode
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(fn):toHaveBeenCalledTimes(1)
    count.value=count.value+1
    expect(fn):toHaveBeenCalledTimes(2)
  end
  )
  it('should work on component vnode', function()
    local count = ref(0)
    function assertBindings(binding)
      expect(binding.value):toBe(count.value)
      expect(binding.arg):toBe('foo')
      expect(binding.instance):toBe(_instance and _instance.proxy)
      expect(binding.modifiers and binding.modifiers.ok):toBe(true)
    end
    
    local beforeMount = jest:fn(function(el, binding, vnode, prevVNode)
      expect(el.tag):toBe('div')
      expect(el.parentNode):toBe(nil)
      expect(#root.children):toBe(0)
      assertBindings(binding)
      expect(vnode.type):toBe(().type)
      expect(prevVNode):toBe(nil)
    end
    )
    local mounted = jest:fn(function(el, binding, vnode, prevVNode)
      expect(el.tag):toBe('div')
      expect(el.parentNode):toBe(root)
      expect(root.children[0+1]):toBe(el)
      assertBindings(binding)
      expect(vnode.type):toBe(().type)
      expect(prevVNode):toBe(nil)
    end
    )
    local beforeUpdate = jest:fn(function(el, binding, vnode, prevVNode)
      expect(el.tag):toBe('div')
      expect(el.parentNode):toBe(root)
      expect(root.children[0+1]):toBe(el)
      assertBindings(binding)
      expect(vnode.type):toBe(().type)
      expect(().type):toBe(().type)
    end
    )
    local updated = jest:fn(function(el, binding, vnode, prevVNode)
      expect(el.tag):toBe('div')
      expect(el.parentNode):toBe(root)
      expect(root.children[0+1]):toBe(el)
      expect(el.children[0+1].text):toBe()
      assertBindings(binding)
      expect(vnode.type):toBe(().type)
      expect(().type):toBe(().type)
    end
    )
    local beforeUnmount = jest:fn(function(el, binding, vnode, prevVNode)
      expect(el.tag):toBe('div')
      expect(el.parentNode):toBe(root)
      expect(root.children[0+1]):toBe(el)
      assertBindings(binding)
      expect(vnode.type):toBe(().type)
      expect(prevVNode):toBe(nil)
    end
    )
    local unmounted = jest:fn(function(el, binding, vnode, prevVNode)
      expect(el.tag):toBe('div')
      expect(el.parentNode):toBe(nil)
      expect(#root.children):toBe(0)
      assertBindings(binding)
      expect(vnode.type):toBe(().type)
      expect(prevVNode):toBe(nil)
    end
    )
    local dir = {beforeMount=beforeMount, mounted=mounted, beforeUpdate=beforeUpdate, updated=updated, beforeUnmount=beforeUnmount, unmounted=unmounted}
    local _instance = nil
    local _vnode = nil
    local _prevVnode = nil
    local Child = function(props)
      _prevVnode = _vnode
      _vnode = h('div', props.count)
      return _vnode
    end
    
    local Comp = {setup=function()
      _instance = currentInstance
    end
    , render=function()
      return withDirectives(h(Child, {count=count.value}), {{dir, count.value, 'foo', {ok=true}}})
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(beforeMount):toHaveBeenCalledTimes(1)
    expect(mounted):toHaveBeenCalledTimes(1)
    count.value=count.value+1
    expect(beforeUpdate):toHaveBeenCalledTimes(1)
    expect(updated):toHaveBeenCalledTimes(1)
    render(nil, root)
    expect(beforeUnmount):toHaveBeenCalledTimes(1)
    expect(unmounted):toHaveBeenCalledTimes(1)
  end
  )
end
)