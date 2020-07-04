require("@vue/reactivity")
require("@vue/runtime-test")

describe('api: setup context', function()
  it('should expose return values to template render context', function()
    local Comp = defineComponent({setup=function()
      return {ref=ref('foo'), object=reactive({msg='bar'}), value='baz'}
    end
    , render=function()
      return 
    end
    })
    expect(renderToString(h(Comp))):toMatch()
  end
  )
  it('should support returning render function', function()
    local Comp = {setup=function()
      return function()
        return h('div', 'hello')
      end
      
    
    end
    }
    expect(renderToString(h(Comp))):toMatch()
  end
  )
  it('props', function()
    local count = ref(0)
    local dummy = nil
    local Parent = {render=function()
      h(Child, {count=count.value})
    end
    }
    local Child = defineComponent({props={count=Number}, setup=function(props)
      watchEffect(function()
        dummy = props.count
      end
      )
      return function()
        h('div', props.count)
      end
      
    
    end
    })
    local root = nodeOps:createElement('div')
    render(h(Parent), root)
    expect(serializeInner(root)):toMatch()
    expect(dummy):toBe(0)
    count.value=count.value+1
    expect(serializeInner(root)):toMatch()
    expect(dummy):toBe(1)
  end
  )
  it('setup props should resolve the correct types from props object', function()
    local count = ref(0)
    local dummy = nil
    local Parent = {render=function()
      h(Child, {count=count.value})
    end
    }
    local Child = defineComponent({props={count=Number}, setup=function(props)
      watchEffect(function()
        dummy = props.count
      end
      )
      return function()
        h('div', props.count)
      end
      
    
    end
    })
    local root = nodeOps:createElement('div')
    render(h(Parent), root)
    expect(serializeInner(root)):toMatch()
    expect(dummy):toBe(0)
    count.value=count.value+1
    expect(serializeInner(root)):toMatch()
    expect(dummy):toBe(1)
  end
  )
  it('context.attrs', function()
    local toggle = ref(true)
    local Parent = {render=function()
      -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
      h(Child, (toggle.value and {{id='foo'}} or {{class='baz'}})[1])
    end
    }
    local Child = {inheritAttrs=false, setup=function(props, )
      return function()
        h('div', attrs)
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Parent), root)
    expect(serializeInner(root)):toMatch()
    toggle.value = false
    expect(serializeInner(root)):toMatch()
  end
  )
  it('context.slots', function()
    local id = ref('foo')
    local Parent = {render=function()
      h(Child, nil, {foo=function()
        id.value
      end
      , bar=function()
        'bar'
      end
      })
    end
    }
    local Child = {setup=function(props, )
      return function()
        h('div', {..., ...})
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Parent), root)
    expect(serializeInner(root)):toMatch()
    id.value = 'baz'
    expect(serializeInner(root)):toMatch()
  end
  )
  it('context.emit', function()
    local count = ref(0)
    local spy = jest:fn()
    local Parent = {render=function()
      h(Child, {count=count.value, onInc=function(newVal)
        spy()
        count.value = newVal
      end
      })
    end
    }
    local Child = defineComponent({props={count={type=Number, default=1}}, setup=function(props, )
      return function()
        h('div', {onClick=function()
          emit('inc', props.count + 1)
        end
        }, props.count)
      end
      
    
    end
    })
    local root = nodeOps:createElement('div')
    render(h(Parent), root)
    expect(serializeInner(root)):toMatch()
    triggerEvent(root.children[0+1], 'click')
    expect(spy):toHaveBeenCalled()
    expect(serializeInner(root)):toMatch()
  end
  )
end
)