require("@vue/runtime-test")
require("@vue/runtime-test/TrackOpTypes")
require("@vue/reactivity")
require("@vue/reactivity/TriggerOpTypes")

describe('api: lifecycle hooks', function()
  it('onBeforeMount', function()
    local root = nodeOps:createElement('div')
    local fn = jest:fn(function()
      expect(serializeInner(root)):toBe()
    end
    )
    local Comp = {setup=function()
      onBeforeMount(fn)
      return function()
        h('div')
      end
      
    
    end
    }
    render(h(Comp), root)
    expect(fn):toHaveBeenCalledTimes(1)
  end
  )
  it('onMounted', function()
    local root = nodeOps:createElement('div')
    local fn = jest:fn(function()
      expect(serializeInner(root)):toBe()
    end
    )
    local Comp = {setup=function()
      onMounted(fn)
      return function()
        h('div')
      end
      
    
    end
    }
    render(h(Comp), root)
    expect(fn):toHaveBeenCalledTimes(1)
  end
  )
  it('onBeforeUpdate', function()
    local count = ref(0)
    local root = nodeOps:createElement('div')
    local fn = jest:fn(function()
      expect(serializeInner(root)):toBe()
    end
    )
    local Comp = {setup=function()
      onBeforeUpdate(fn)
      return function()
        h('div', count.value)
      end
      
    
    end
    }
    render(h(Comp), root)
    count.value=count.value+1
    expect(fn):toHaveBeenCalledTimes(1)
  end
  )
  it('onUpdated', function()
    local count = ref(0)
    local root = nodeOps:createElement('div')
    local fn = jest:fn(function()
      expect(serializeInner(root)):toBe()
    end
    )
    local Comp = {setup=function()
      onUpdated(fn)
      return function()
        h('div', count.value)
      end
      
    
    end
    }
    render(h(Comp), root)
    count.value=count.value+1
    expect(fn):toHaveBeenCalledTimes(1)
  end
  )
  it('onBeforeUnmount', function()
    local toggle = ref(true)
    local root = nodeOps:createElement('div')
    local fn = jest:fn(function()
      expect(serializeInner(root)):toBe()
    end
    )
    local Comp = {setup=function()
      return function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {h(Child)} or {nil})[1]
      end
      
    
    end
    }
    local Child = {setup=function()
      onBeforeUnmount(fn)
      return function()
        h('div')
      end
      
    
    end
    }
    render(h(Comp), root)
    toggle.value = false
    expect(fn):toHaveBeenCalledTimes(1)
  end
  )
  it('onUnmounted', function()
    local toggle = ref(true)
    local root = nodeOps:createElement('div')
    local fn = jest:fn(function()
      expect(serializeInner(root)):toBe()
    end
    )
    local Comp = {setup=function()
      return function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {h(Child)} or {nil})[1]
      end
      
    
    end
    }
    local Child = {setup=function()
      onUnmounted(fn)
      return function()
        h('div')
      end
      
    
    end
    }
    render(h(Comp), root)
    toggle.value = false
    expect(fn):toHaveBeenCalledTimes(1)
  end
  )
  it('onBeforeUnmount in onMounted', function()
    local toggle = ref(true)
    local root = nodeOps:createElement('div')
    local fn = jest:fn(function()
      expect(serializeInner(root)):toBe()
    end
    )
    local Comp = {setup=function()
      return function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {h(Child)} or {nil})[1]
      end
      
    
    end
    }
    local Child = {setup=function()
      onMounted(function()
        onBeforeUnmount(fn)
      end
      )
      return function()
        h('div')
      end
      
    
    end
    }
    render(h(Comp), root)
    toggle.value = false
    expect(fn):toHaveBeenCalledTimes(1)
  end
  )
  it('lifecycle call order', function()
    local count = ref(0)
    local root = nodeOps:createElement('div')
    local calls = {}
    local Root = {setup=function()
      onBeforeMount(function()
        table.insert(calls, 'root onBeforeMount')
      end
      )
      onMounted(function()
        table.insert(calls, 'root onMounted')
      end
      )
      onBeforeUpdate(function()
        table.insert(calls, 'root onBeforeUpdate')
      end
      )
      onUpdated(function()
        table.insert(calls, 'root onUpdated')
      end
      )
      onBeforeUnmount(function()
        table.insert(calls, 'root onBeforeUnmount')
      end
      )
      onUnmounted(function()
        table.insert(calls, 'root onUnmounted')
      end
      )
      return function()
        h(Mid, {count=count.value})
      end
      
    
    end
    }
    local Mid = {setup=function(props)
      onBeforeMount(function()
        table.insert(calls, 'mid onBeforeMount')
      end
      )
      onMounted(function()
        table.insert(calls, 'mid onMounted')
      end
      )
      onBeforeUpdate(function()
        table.insert(calls, 'mid onBeforeUpdate')
      end
      )
      onUpdated(function()
        table.insert(calls, 'mid onUpdated')
      end
      )
      onBeforeUnmount(function()
        table.insert(calls, 'mid onBeforeUnmount')
      end
      )
      onUnmounted(function()
        table.insert(calls, 'mid onUnmounted')
      end
      )
      return function()
        h(Child, {count=props.count})
      end
      
    
    end
    }
    local Child = {setup=function(props)
      onBeforeMount(function()
        table.insert(calls, 'child onBeforeMount')
      end
      )
      onMounted(function()
        table.insert(calls, 'child onMounted')
      end
      )
      onBeforeUpdate(function()
        table.insert(calls, 'child onBeforeUpdate')
      end
      )
      onUpdated(function()
        table.insert(calls, 'child onUpdated')
      end
      )
      onBeforeUnmount(function()
        table.insert(calls, 'child onBeforeUnmount')
      end
      )
      onUnmounted(function()
        table.insert(calls, 'child onUnmounted')
      end
      )
      return function()
        h('div', props.count)
      end
      
    
    end
    }
    render(h(Root), root)
    expect(calls):toEqual({'root onBeforeMount', 'mid onBeforeMount', 'child onBeforeMount', 'child onMounted', 'mid onMounted', 'root onMounted'})
    
    calls.length = 0
    count.value=count.value+1
    expect(calls):toEqual({'root onBeforeUpdate', 'mid onBeforeUpdate', 'child onBeforeUpdate', 'child onUpdated', 'mid onUpdated', 'root onUpdated'})
    
    calls.length = 0
    render(nil, root)
    expect(calls):toEqual({'root onBeforeUnmount', 'mid onBeforeUnmount', 'child onBeforeUnmount', 'child onUnmounted', 'mid onUnmounted', 'root onUnmounted'})
  end
  )
  it('onRenderTracked', function()
    local events = {}
    local onTrack = jest:fn(function(e)
      table.insert(events, e)
    end
    )
    local obj = reactive({foo=1, bar=2})
    local Comp = {setup=function()
      onRenderTracked(onTrack)
      return function()
        h('div', {obj.foo, obj['bar'], Object:keys(obj):join('')})
      end
      
    
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect(onTrack):toHaveBeenCalledTimes(3)
    expect(events):toMatchObject({{target=obj, type=TrackOpTypes.GET, key='foo'}, {target=obj, type=TrackOpTypes.HAS, key='bar'}, {target=obj, type=TrackOpTypes.ITERATE, key=ITERATE_KEY}})
  end
  )
  it('onRenderTriggered', function()
    local events = {}
    local onTrigger = jest:fn(function(e)
      table.insert(events, e)
    end
    )
    local obj = reactive({foo=1, bar=2})
    local Comp = {setup=function()
      onRenderTriggered(onTrigger)
      return function()
        h('div', {obj.foo, obj['bar'], Object:keys(obj):join('')})
      end
      
    
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    obj.foo=obj.foo+1
    expect(onTrigger):toHaveBeenCalledTimes(1)
    expect(events[0+1]):toMatchObject({type=TriggerOpTypes.SET, key='foo', oldValue=1, newValue=2})
    obj.bar = nil
    expect(onTrigger):toHaveBeenCalledTimes(2)
    expect(events[1+1]):toMatchObject({type=TriggerOpTypes.DELETE, key='bar', oldValue=2})
    obj.baz = 3
    expect(onTrigger):toHaveBeenCalledTimes(3)
    expect(events[2+1]):toMatchObject({type=TriggerOpTypes.ADD, key='baz', newValue=3})
  end
  )
end
)