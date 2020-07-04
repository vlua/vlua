require("@vue/runtime-test")

describe('Suspense', function()
  local deps = {}
  beforeEach(function()
    -- [ts2lua]修改数组长度需要手动处理。
    deps.length = 0
  end
  )
  function defineAsyncComponent(comp, delay)
    if delay == nil then
      delay=0
    end
    return {setup=function(props, )
      local p = Promise(function(resolve)
        setTimeout(function()
          resolve(function()
            h(comp, props, slots)
          end
          )
        end
        , delay)
      end
      )
      table.insert(deps, p:tsvar_then(function()
        Promise:resolve()
      end
      ))
      return p
    end
    }
  end
  
  test('fallback content', function()
    local Async = defineAsyncComponent({render=function()
      return h('div', 'async')
    end
    })
    local Comp = {setup=function()
      return function()
        h(Suspense, nil, {default=h(Async), fallback=h('div', 'fallback')})
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    expect(serializeInner(root)):toBe()
  end
  )
  test('nested async deps', function()
    local calls = {}
    local AsyncOuter = defineAsyncComponent({setup=function()
      onMounted(function()
        table.insert(calls, 'outer mounted')
      end
      )
      return function()
        h(AsyncInner)
      end
      
    
    end
    })
    local AsyncInner = defineAsyncComponent({setup=function()
      onMounted(function()
        table.insert(calls, 'inner mounted')
      end
      )
      return function()
        h('div', 'inner')
      end
      
    
    end
    }, 10)
    local Comp = {setup=function()
      return function()
        h(Suspense, nil, {default=h(AsyncOuter), fallback=h('div', 'fallback')})
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({})
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({})
    expect(calls):toEqual({})
    expect(serializeInner(root)):toBe()
  end
  )
  test('onResolve', function()
    local Async = defineAsyncComponent({render=function()
      return h('div', 'async')
    end
    })
    local onResolve = jest:fn()
    local Comp = {setup=function()
      return function()
        h(Suspense, {onResolve=onResolve}, {default=h(Async), fallback=h('div', 'fallback')})
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    expect(onResolve).tsvar_not:toHaveBeenCalled()
    expect(serializeInner(root)):toBe()
    expect(onResolve):toHaveBeenCalled()
  end
  )
  test('buffer mounted/updated hooks & watch callbacks', function()
    local deps = {}
    local calls = {}
    local toggle = ref(true)
    local Async = {setup=function()
      local p = Promise(function(r)
        setTimeout(r, 1)
      end
      )
      table.insert(deps, p:tsvar_then(function()
        Promise:resolve()
      end
      ))
      watchEffect(function()
        table.insert(calls, 'immediate effect')
      end
      )
      local count = ref(0)
      watch(count, function(v)
        table.insert(calls, 'watch callback')
      end
      )
      count.value=count.value+1
      onMounted(function()
        table.insert(calls, 'mounted')
      end
      )
      onUnmounted(function()
        table.insert(calls, 'unmounted')
      end
      )
      return function()
        h('div', 'async')
      end
      
    
    end
    }
    local Comp = {setup=function()
      return function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        h(Suspense, nil, {default=(toggle.value and {h(Async)} or {nil})[1], fallback=h('div', 'fallback')})
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({})
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({})
    toggle.value = false
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({'unmounted'})
  end
  )
  test('mounted/updated hooks & fallback component', function()
    local deps = {}
    local calls = {}
    local toggle = ref(true)
    local Async = {setup=function()
      local p = Promise(function(r)
        setTimeout(r, 1)
      end
      )
      table.insert(deps, p:tsvar_then(function()
        Promise:resolve()
      end
      ))
      return function()
        h('div', 'async')
      end
      
    
    end
    }
    local Fallback = {setup=function()
      onMounted(function()
        table.insert(calls, 'mounted')
      end
      )
      onUnmounted(function()
        table.insert(calls, 'unmounted')
      end
      )
      return function()
        h('div', 'fallback')
      end
      
    
    end
    }
    local Comp = {setup=function()
      return function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        h(Suspense, nil, {default=(toggle.value and {h(Async)} or {nil})[1], fallback=h(Fallback)})
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({})
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({})
  end
  )
  test('content update before suspense resolve', function()
    local Async = defineAsyncComponent({props={msg=String}, setup=function(props)
      return function()
        h('div', props.msg)
      end
      
    
    end
    })
    local msg = ref('foo')
    local Comp = {setup=function()
      return function()
        h(Suspense, nil, {default=h(Async, {msg=msg.value}), fallback=h('div', )})
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    msg.value = 'bar'
    expect(serializeInner(root)):toBe()
    expect(serializeInner(root)):toBe()
  end
  )
  test('unmount before suspense resolve', function()
    local deps = {}
    local calls = {}
    local toggle = ref(true)
    local Async = {setup=function()
      local p = Promise(function(r)
        setTimeout(r, 1)
      end
      )
      table.insert(deps, p)
      watchEffect(function()
        table.insert(calls, 'immediate effect')
      end
      )
      local count = ref(0)
      watch(count, function()
        table.insert(calls, 'watch callback')
      end
      )
      count.value=count.value+1
      onMounted(function()
        table.insert(calls, 'mounted')
      end
      )
      onUnmounted(function()
        table.insert(calls, 'unmounted')
      end
      )
      return function()
        h('div', 'async')
      end
      
    
    end
    }
    local Comp = {setup=function()
      return function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        h(Suspense, nil, {default=(toggle.value and {h(Async)} or {nil})[1], fallback=h('div', 'fallback')})
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({'immediate effect'})
    toggle.value = false
    expect(serializeInner(root)):toBe()
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({'immediate effect', 'watch callback', 'unmounted'})
  end
  )
  test('unmount suspense after resolve', function()
    local toggle = ref(true)
    local unmounted = jest:fn()
    local Async = defineAsyncComponent({setup=function()
      onUnmounted(unmounted)
      return function()
        h('div', 'async')
      end
      
    
    end
    })
    local Comp = {setup=function()
      return function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {h(Suspense, nil, {default=h(Async), fallback=h('div', 'fallback')})} or {nil})[1]
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    expect(serializeInner(root)):toBe()
    expect(unmounted).tsvar_not:toHaveBeenCalled()
    toggle.value = false
    expect(serializeInner(root)):toBe()
    expect(unmounted):toHaveBeenCalled()
  end
  )
  test('unmount suspense before resolve', function()
    local toggle = ref(true)
    local mounted = jest:fn()
    local unmounted = jest:fn()
    local Async = defineAsyncComponent({setup=function()
      onMounted(mounted)
      onUnmounted(unmounted)
      return function()
        h('div', 'async')
      end
      
    
    end
    })
    local Comp = {setup=function()
      return function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {h(Suspense, nil, {default=h(Async), fallback=h('div', 'fallback')})} or {nil})[1]
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    toggle.value = false
    expect(serializeInner(root)):toBe()
    expect(mounted).tsvar_not:toHaveBeenCalled()
    expect(unmounted).tsvar_not:toHaveBeenCalled()
    expect(mounted).tsvar_not:toHaveBeenCalled()
    expect(unmounted).tsvar_not:toHaveBeenCalled()
  end
  )
  test('nested suspense (parent resolves first)', function()
    local calls = {}
    local AsyncOuter = defineAsyncComponent({setup=function()
      onMounted(function()
        table.insert(calls, 'outer mounted')
      end
      )
      return function()
        h('div', 'async outer')
      end
      
    
    end
    }, 1)
    local AsyncInner = defineAsyncComponent({setup=function()
      onMounted(function()
        table.insert(calls, 'inner mounted')
      end
      )
      return function()
        h('div', 'async inner')
      end
      
    
    end
    }, 10)
    local Inner = {setup=function()
      return function()
        h(Suspense, nil, {default=h(AsyncInner), fallback=h('div', 'fallback inner')})
      end
      
    
    end
    }
    local Comp = {setup=function()
      return function()
        h(Suspense, nil, {default={h(AsyncOuter), h(Inner)}, fallback=h('div', 'fallback outer')})
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({})
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({})
  end
  )
  test('nested suspense (child resolves first)', function()
    local calls = {}
    local AsyncOuter = defineAsyncComponent({setup=function()
      onMounted(function()
        table.insert(calls, 'outer mounted')
      end
      )
      return function()
        h('div', 'async outer')
      end
      
    
    end
    }, 10)
    local AsyncInner = defineAsyncComponent({setup=function()
      onMounted(function()
        table.insert(calls, 'inner mounted')
      end
      )
      return function()
        h('div', 'async inner')
      end
      
    
    end
    }, 1)
    local Inner = {setup=function()
      return function()
        h(Suspense, nil, {default=h(AsyncInner), fallback=h('div', 'fallback inner')})
      end
      
    
    end
    }
    local Comp = {setup=function()
      return function()
        h(Suspense, nil, {default={h(AsyncOuter), h(Inner)}, fallback=h('div', 'fallback outer')})
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({})
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({})
  end
  )
  test('error handling', function()
    local Async = {setup=function()
      error(Error('oops'))
    end
    }
    local Comp = {setup=function()
      local errorMessage = ref(nil)
      onErrorCaptured(function(err)
        -- [ts2lua]lua中0和空字符串也是true，此处err:instanceof(Error)需要确认
        errorMessage.value = (err:instanceof(Error) and {err.message} or {})[1]
        return true
      end
      )
      return function()
        -- [ts2lua]lua中0和空字符串也是true，此处errorMessage.value需要确认
        (errorMessage.value and {h('div', errorMessage.value)} or {h(Suspense, nil, {default=h(Async), fallback=h('div', 'fallback')})})[1]
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    expect(serializeInner(root)):toBe()
  end
  )
  it('combined usage (nested async + nested suspense + multiple deps)', function()
    local msg = ref('nested msg')
    local calls = {}
    local AsyncChildWithSuspense = defineAsyncComponent({props={msg=String}, setup=function(props)
      onMounted(function()
        table.insert(calls, 0)
      end
      )
      return function()
        h(Suspense, nil, {default=h(AsyncInsideNestedSuspense, {msg=props.msg}), fallback=h('div', 'nested fallback')})
      end
      
    
    end
    })
    local AsyncInsideNestedSuspense = defineAsyncComponent({props={msg=String}, setup=function(props)
      onMounted(function()
        table.insert(calls, 2)
      end
      )
      return function()
        h('div', props.msg)
      end
      
    
    end
    }, 20)
    local AsyncChildParent = defineAsyncComponent({props={msg=String}, setup=function(props)
      onMounted(function()
        table.insert(calls, 1)
      end
      )
      return function()
        h(NestedAsyncChild, {msg=props.msg})
      end
      
    
    end
    })
    local NestedAsyncChild = defineAsyncComponent({props={msg=String}, setup=function(props)
      onMounted(function()
        table.insert(calls, 3)
      end
      )
      return function()
        h('div', props.msg)
      end
      
    
    end
    }, 10)
    local MiddleComponent = {setup=function()
      return function()
        h(AsyncChildWithSuspense, {msg=msg.value})
      end
      
    
    end
    }
    local Comp = {setup=function()
      return function()
        h(Suspense, nil, {default={h(MiddleComponent), h(AsyncChildParent, {msg='root async'})}, fallback=h('div', 'root fallback')})
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({})
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({})
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({0, 1, 3})
    msg.value = 'nested changed'
    expect(serializeInner(root)):toBe()
    expect(calls):toEqual({0, 1, 3, 2})
    msg.value = 'nested changed again'
    expect(serializeInner(root)):toBe()
  end
  )
  test('new async dep after resolve should cause suspense to restart', function()
    local toggle = ref(false)
    local ChildA = defineAsyncComponent({setup=function()
      return function()
        h('div', 'Child A')
      end
      
    
    end
    })
    local ChildB = defineAsyncComponent({setup=function()
      return function()
        h('div', 'Child B')
      end
      
    
    end
    })
    local Comp = {setup=function()
      return function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        h(Suspense, nil, {default={h(ChildA), (toggle.value and {h(ChildB)} or {nil})[1]}, fallback=h('div', 'root fallback')})
      end
      
    
    end
    }
    local root = nodeOps:createElement('div')
    render(h(Comp), root)
    expect(serializeInner(root)):toBe()
    expect(serializeInner(root)):toBe()
    toggle.value = true
    expect(serializeInner(root)):toBe()
    expect(serializeInner(root)):toBe()
  end
  )
  test:todo('teleport inside suspense')
end
)