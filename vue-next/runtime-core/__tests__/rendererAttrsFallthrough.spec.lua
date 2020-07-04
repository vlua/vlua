require("@vue/runtime-dom")
require("@vue/shared")

describe('attribute fallthrough', function()
  mockWarn()
  it('should allow attrs to fallthrough', function()
    local click = jest:fn()
    local childUpdated = jest:fn()
    local Hello = {setup=function()
      local count = ref(0)
      function inc()
        count.value=count.value+1
        click()
      end
      
      return function()
        -- [ts2lua]lua中0和空字符串也是true，此处count.value需要确认
        h(Child, {foo=count.value + 1, id='test', class='c' .. count.value, style={color=(count.value and {'red'} or {'green'})[1]}, onClick=inc, data-id=count.value + 1})
      end
      
    
    end
    }
    local Child = {setup=function(props)
      onUpdated(childUpdated)
      return function()
        h('div', {class='c2', style={fontWeight='bold'}}, props.foo)
      end
      
    
    end
    }
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Hello), root)
    local node = root.children[0+1]
    expect(node:getAttribute('id')):toBe('test')
    expect(node:getAttribute('foo')):toBe('1')
    expect(node:getAttribute('class')):toBe('c2 c0')
    expect(node.style.color):toBe('green')
    expect(node.style.fontWeight):toBe('bold')
    expect(node.dataset.id):toBe('1')
    node:dispatchEvent(CustomEvent('click'))
    expect(click):toHaveBeenCalled()
    expect(childUpdated):toHaveBeenCalled()
    expect(node:getAttribute('id')):toBe('test')
    expect(node:getAttribute('foo')):toBe('2')
    expect(node:getAttribute('class')):toBe('c2 c1')
    expect(node.style.color):toBe('red')
    expect(node.style.fontWeight):toBe('bold')
    expect(node.dataset.id):toBe('2')
  end
  )
  it('should only allow whitelisted fallthrough on functional component with optional props', function()
    local click = jest:fn()
    local childUpdated = jest:fn()
    local count = ref(0)
    function inc()
      count.value=count.value+1
      click()
    end
    
    local Hello = function()
      -- [ts2lua]lua中0和空字符串也是true，此处count.value需要确认
      h(Child, {foo=count.value + 1, id='test', class='c' .. count.value, style={color=(count.value and {'red'} or {'green'})[1]}, onClick=inc})
    end
    
    local Child = function(props)
      childUpdated()
      return h('div', {class='c2', style={fontWeight='bold'}}, props.foo)
    end
    
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Hello), root)
    local node = root.children[0+1]
    expect(node:getAttribute('id')):toBe(nil)
    expect(node:getAttribute('foo')):toBe(nil)
    expect(node:getAttribute('class')):toBe('c2 c0')
    expect(node.style.color):toBe('green')
    expect(node.style.fontWeight):toBe('bold')
    node:dispatchEvent(CustomEvent('click'))
    expect(click):toHaveBeenCalled()
    expect(childUpdated):toHaveBeenCalled()
    expect(node:getAttribute('id')):toBe(nil)
    expect(node:getAttribute('foo')):toBe(nil)
    expect(node:getAttribute('class')):toBe('c2 c1')
    expect(node.style.color):toBe('red')
    expect(node.style.fontWeight):toBe('bold')
  end
  )
  it('should allow all attrs on functional component with declared props', function()
    local click = jest:fn()
    local childUpdated = jest:fn()
    local count = ref(0)
    function inc()
      count.value=count.value+1
      click()
    end
    
    local Hello = function()
      -- [ts2lua]lua中0和空字符串也是true，此处count.value需要确认
      h(Child, {foo=count.value + 1, id='test', class='c' .. count.value, style={color=(count.value and {'red'} or {'green'})[1]}, onClick=inc})
    end
    
    local Child = function(props)
      childUpdated()
      return h('div', {class='c2', style={fontWeight='bold'}}, props.foo)
    end
    
    Child.props = {'foo'}
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Hello), root)
    local node = root.children[0+1]
    expect(node:getAttribute('id')):toBe('test')
    expect(node:getAttribute('foo')):toBe(nil)
    expect(node:getAttribute('class')):toBe('c2 c0')
    expect(node.style.color):toBe('green')
    expect(node.style.fontWeight):toBe('bold')
    node:dispatchEvent(CustomEvent('click'))
    expect(click):toHaveBeenCalled()
    expect(childUpdated):toHaveBeenCalled()
    expect(node:getAttribute('id')):toBe('test')
    expect(node:getAttribute('foo')):toBe(nil)
    expect(node:getAttribute('class')):toBe('c2 c1')
    expect(node.style.color):toBe('red')
    expect(node.style.fontWeight):toBe('bold')
  end
  )
  it('should fallthrough for nested components', function()
    local click = jest:fn()
    local childUpdated = jest:fn()
    local grandChildUpdated = jest:fn()
    local Hello = {setup=function()
      local count = ref(0)
      function inc()
        count.value=count.value+1
        click()
      end
      
      return function()
        -- [ts2lua]lua中0和空字符串也是true，此处count.value需要确认
        h(Child, {foo=1, id='test', class='c' .. count.value, style={color=(count.value and {'red'} or {'green'})[1]}, onClick=inc})
      end
      
    
    end
    }
    local Child = {setup=function(props)
      onUpdated(childUpdated)
      return function()
        h(GrandChild, props)
      end
      
    
    end
    }
    local GrandChild = defineComponent({props={id=String, foo=Number}, setup=function(props)
      onUpdated(grandChildUpdated)
      return function()
        h('div', {id=props.id, class='c2', style={fontWeight='bold'}}, props.foo)
      end
      
    
    end
    })
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Hello), root)
    local node = root.children[0+1]
    expect(node:getAttribute('id')):toBe('test')
    expect(node:getAttribute('class')):toBe('c2 c0')
    expect(node.style.color):toBe('green')
    expect(node.style.fontWeight):toBe('bold')
    node:dispatchEvent(CustomEvent('click'))
    expect(click):toHaveBeenCalled()
    expect(node:hasAttribute('foo')):toBe(false)
    expect(childUpdated):toHaveBeenCalled()
    expect(grandChildUpdated):toHaveBeenCalled()
    expect(node:getAttribute('id')):toBe('test')
    expect(node:getAttribute('class')):toBe('c2 c1')
    expect(node.style.color):toBe('red')
    expect(node.style.fontWeight):toBe('bold')
    expect(node:hasAttribute('foo')):toBe(false)
  end
  )
  it('should not fallthrough with inheritAttrs: false', function()
    local Parent = {render=function()
      return h(Child, {foo=1, class='parent'})
    end
    }
    local Child = defineComponent({props={'foo'}, inheritAttrs=false, render=function()
      return h('div', self.foo)
    end
    })
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Parent), root)
    expect(root.innerHTML):toMatch()
  end
  )
  it('explicit spreading with inheritAttrs: false', function()
    local Parent = {render=function()
      return h(Child, {foo=1, class='parent'})
    end
    }
    local Child = defineComponent({props={'foo'}, inheritAttrs=false, render=function()
      return h('div', mergeProps({class='child'}, self.tsvar_attrs), self.foo)
    end
    })
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Parent), root)
    expect(root.innerHTML):toMatch()
  end
  )
  it('should warn when fallthrough fails on non-single-root', function()
    local Parent = {render=function()
      return h(Child, {foo=1, class='parent', onBar=function()
        
      end
      })
    end
    }
    local Child = defineComponent({props={'foo'}, render=function()
      return {h('div'), h('div')}
    end
    })
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Parent), root)
    expect():toHaveBeenWarned()
    expect():toHaveBeenWarned()
  end
  )
  it('should not warn when $attrs is used during render', function()
    local Parent = {render=function()
      return h(Child, {foo=1, class='parent', onBar=function()
        
      end
      })
    end
    }
    local Child = defineComponent({props={'foo'}, render=function()
      return {h('div'), h('div', self.tsvar_attrs)}
    end
    })
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Parent), root)
    expect().tsvar_not:toHaveBeenWarned()
    expect().tsvar_not:toHaveBeenWarned()
    expect(root.innerHTML):toBe()
  end
  )
  it('should not warn when context.attrs is used during render', function()
    local Parent = {render=function()
      return h(Child, {foo=1, class='parent', onBar=function()
        
      end
      })
    end
    }
    local Child = defineComponent({props={'foo'}, setup=function(_props, )
      return function()
        {h('div'), h('div', attrs)}
      end
      
    
    end
    })
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Parent), root)
    expect().tsvar_not:toHaveBeenWarned()
    expect().tsvar_not:toHaveBeenWarned()
    expect(root.innerHTML):toBe()
  end
  )
  it('should not warn when context.attrs is used during render (functional)', function()
    local Parent = {render=function()
      return h(Child, {foo=1, class='parent', onBar=function()
        
      end
      })
    end
    }
    local Child = function(_, )
      {h('div'), h('div', attrs)}
    end
    
    Child.props = {'foo'}
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Parent), root)
    expect().tsvar_not:toHaveBeenWarned()
    expect().tsvar_not:toHaveBeenWarned()
    expect(root.innerHTML):toBe()
  end
  )
  it('should not warn when functional component has optional props', function()
    local Parent = {render=function()
      return h(Child, {foo=1, class='parent', onBar=function()
        
      end
      })
    end
    }
    local Child = function(props)
      {h('div'), h('div', {class=props.class})}
    end
    
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Parent), root)
    expect().tsvar_not:toHaveBeenWarned()
    expect().tsvar_not:toHaveBeenWarned()
    expect(root.innerHTML):toBe()
  end
  )
  it('should warn when functional component has props and does not use attrs', function()
    local Parent = {render=function()
      return h(Child, {foo=1, class='parent', onBar=function()
        
      end
      })
    end
    }
    local Child = function()
      {h('div'), h('div')}
    end
    
    Child.props = {'foo'}
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Parent), root)
    expect():toHaveBeenWarned()
    expect():toHaveBeenWarned()
    expect(root.innerHTML):toBe()
  end
  )
  it('should update merged dynamic attrs on optimized child root', function()
    local aria = ref('true')
    local cls = ref('bar')
    local Parent = {render=function()
      return h(Child, {aria-hidden=aria.value, class=cls.value})
    end
    }
    local Child = {props={}, render=function()
      return openBlock(); createBlock('div')
    end
    }
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Parent), root)
    expect(root.innerHTML):toBe()
    aria.value = 'false'
    expect(root.innerHTML):toBe()
    cls.value = 'barr'
    expect(root.innerHTML):toBe()
  end
  )
  it('should not let listener fallthrough when declared in emits (stateful)', function()
    local Child = defineComponent({emits={'click'}, render=function()
      return h('button', {onClick=function()
        self:tsvar_emit('click', 'custom')
      end
      }, 'hello')
    end
    })
    local onClick = jest:fn()
    local App = {render=function()
      return h(Child, {onClick=onClick})
    end
    }
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(App), root)
    local node = root.children[0+1]
    node:dispatchEvent(CustomEvent('click'))
    expect(onClick):toHaveBeenCalledTimes(1)
    expect(onClick):toHaveBeenCalledWith('custom')
  end
  )
  it('should not let listener fallthrough when declared in emits (functional)', function()
    local Child = function(_, )
      expect(_.onClick):toBeUndefined()
      return h('button', {onClick=function()
        emit('click', 'custom')
      end
      })
    end
    
    Child.emits = {'click'}
    local onClick = jest:fn()
    local App = {render=function()
      return h(Child, {onClick=onClick})
    end
    }
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(App), root)
    local node = root.children[0+1]
    node:dispatchEvent(CustomEvent('click'))
    expect(onClick):toHaveBeenCalledTimes(1)
    expect(onClick):toHaveBeenCalledWith('custom')
  end
  )
  it('should support fallthrough for fragments with single element + comments', function()
    local click = jest:fn()
    local Hello = {setup=function()
      return function()
        h(Child, {class='foo', onClick=click})
      end
      
    
    end
    }
    local Child = {setup=function(props)
      return function()
        {createCommentVNode('hello'), h('button'), createCommentVNode('world')}
      end
      
    
    end
    }
    local root = document:createElement('div')
    document.body:appendChild(root)
    render(h(Hello), root)
    expect(root.innerHTML):toBe()
    local button = root.children[0+1]
    button:dispatchEvent(CustomEvent('click'))
    expect(click):toHaveBeenCalled()
  end
  )
end
)