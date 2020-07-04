require("trycatch")
require("@vue/runtime-test")
require("runtime-core/src/errorHandling")
require("@vue/shared")

describe('error handling', function()
  mockWarn()
  beforeEach(function()
    setErrorRecovery(true)
  end
  )
  afterEach(function()
    setErrorRecovery(false)
  end
  )
  test('propagation', function()
    local err = Error('foo')
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info, 'root')
        return true
      end
      )
      return function()
        h(Child)
      end
      
    
    end
    }
    local Child = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info, 'child')
      end
      )
      return function()
        h(GrandChild)
      end
      
    
    end
    }
    local GrandChild = {setup=function()
      onMounted(function()
        error(err)
      end
      )
      return function()
        nil
      end
      
    
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect(fn):toHaveBeenCalledTimes(2)
    expect(fn):toHaveBeenCalledWith(err, 'mounted hook', 'root')
    expect(fn):toHaveBeenCalledWith(err, 'mounted hook', 'child')
  end
  )
  test('propagation stoppage', function()
    local err = Error('foo')
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info, 'root')
        return true
      end
      )
      return function()
        h(Child)
      end
      
    
    end
    }
    local Child = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info, 'child')
        return true
      end
      )
      return function()
        h(GrandChild)
      end
      
    
    end
    }
    local GrandChild = {setup=function()
      onMounted(function()
        error(err)
      end
      )
      return function()
        nil
      end
      
    
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect(fn):toHaveBeenCalledTimes(1)
    expect(fn):toHaveBeenCalledWith(err, 'mounted hook', 'child')
  end
  )
  test('async error handling', function()
    local err = Error('foo')
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info)
        return true
      end
      )
      return function()
        h(Child)
      end
      
    
    end
    }
    local Child = {setup=function()
      onMounted(function()
        error(err)
      end
      )
    end
    , render=function() end}
    render(h(Comp), nodeOps:createElement('div'))
    expect(fn).tsvar_not:toHaveBeenCalled()
    expect(fn):toHaveBeenCalledWith(err, 'mounted hook')
  end
  )
  test('error thrown in onErrorCaptured', function()
    local err = Error('foo')
    local err2 = Error('bar')
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info)
        return true
      end
      )
      return function()
        h(Child)
      end
      
    
    end
    }
    local Child = {setup=function()
      onErrorCaptured(function()
        error(err2)
      end
      )
      return function()
        h(GrandChild)
      end
      
    
    end
    }
    local GrandChild = {setup=function()
      onMounted(function()
        error(err)
      end
      )
      return function()
        nil
      end
      
    
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect(fn):toHaveBeenCalledTimes(2)
    expect(fn):toHaveBeenCalledWith(err, 'mounted hook')
    expect(fn):toHaveBeenCalledWith(err2, 'errorCaptured hook')
  end
  )
  test('setup function', function()
    local err = Error('foo')
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info)
        return true
      end
      )
      return function()
        h(Child)
      end
      
    
    end
    }
    local Child = {setup=function()
      error(err)
    end
    , render=function() end}
    render(h(Comp), nodeOps:createElement('div'))
    expect(fn):toHaveBeenCalledWith(err, 'setup function')
  end
  )
  test('in render function', function()
    local err = Error('foo')
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info)
        return true
      end
      )
      return function()
        h(Child)
      end
      
    
    end
    }
    local Child = {setup=function()
      return function()
        error(err)
      end
      
    
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect(fn):toHaveBeenCalledWith(err, 'render function')
  end
  )
  test('in function ref', function()
    local err = Error('foo')
    local ref = function()
      error(err)
    end
    
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info)
        return true
      end
      )
      return function()
        h(Child)
      end
      
    
    end
    }
    local Child = defineComponent(function()
      function()
        h('div', {ref=ref})
      end
      
    
    end
    )
    render(h(Comp), nodeOps:createElement('div'))
    expect(fn):toHaveBeenCalledWith(err, 'ref function')
  end
  )
  test('in effect', function()
    local err = Error('foo')
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info)
        return true
      end
      )
      return function()
        h(Child)
      end
      
    
    end
    }
    local Child = {setup=function()
      watchEffect(function()
        error(err)
      end
      )
      return function()
        nil
      end
      
    
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect(fn):toHaveBeenCalledWith(err, 'watcher callback')
  end
  )
  test('in watch getter', function()
    local err = Error('foo')
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info)
        return true
      end
      )
      return function()
        h(Child)
      end
      
    
    end
    }
    local Child = {setup=function()
      watch(function()
        error(err)
      end
      , function()
        
      end
      )
      return function()
        nil
      end
      
    
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect(fn):toHaveBeenCalledWith(err, 'watcher getter')
  end
  )
  test('in watch callback', function()
    local err = Error('foo')
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info)
        return true
      end
      )
      return function()
        h(Child)
      end
      
    
    end
    }
    local count = ref(0)
    local Child = {setup=function()
      watch(function()
        count.value
      end
      , function()
        error(err)
      end
      )
      return function()
        nil
      end
      
    
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    count.value=count.value+1
    expect(fn):toHaveBeenCalledWith(err, 'watcher callback')
  end
  )
  test('in effect cleanup', function()
    local err = Error('foo')
    local count = ref(0)
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info)
        return true
      end
      )
      return function()
        h(Child)
      end
      
    
    end
    }
    local Child = {setup=function()
      watchEffect(function(onCleanup)
        
        onCleanup(function()
          error(err)
        end
        )
      end
      )
      return function()
        nil
      end
      
    
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    count.value=count.value+1
    expect(fn):toHaveBeenCalledWith(err, 'watcher cleanup function')
  end
  )
  test('in component event handler via emit', function()
    local err = Error('foo')
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info)
        return true
      end
      )
      return function()
        h(Child, {onFoo=function()
          error(err)
        end
        })
      end
      
    
    end
    }
    local Child = {setup=function(props, )
      emit('foo')
      return function()
        nil
      end
      
    
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect(fn):toHaveBeenCalledWith(err, 'component event handler')
  end
  )
  test('in component event handler via emit (async)', function()
    local err = Error('foo')
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info)
        return true
      end
      )
      return function()
        h(Child, {onFoo=function()
          error(err)
        end
        })
      end
      
    
    end
    }
    local Child = {props={'onFoo'}, setup=function(props, )
      emit('foo')
      return function()
        nil
      end
      
    
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    expect(fn):toHaveBeenCalledWith(err, 'component event handler')
  end
  )
  test('in component event handler via emit (async + array)', function()
    local err = Error('foo')
    local fn = jest:fn()
    local res = {}
    local createAsyncHandler = function(p)
      function()
        table.insert(res, p)
        return p
      end
      
    
    end
    
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info)
        return true
      end
      )
      return function()
        h(Child, {onFoo={createAsyncHandler(Promise:reject(err)), createAsyncHandler(Promise:resolve(1))}})
      end
      
    
    end
    }
    local Child = {setup=function(props, )
      emit('foo')
      return function()
        nil
      end
      
    
    end
    }
    render(h(Comp), nodeOps:createElement('div'))
    try_catch{
      main = function()
        
      end,
      catch = function(e)
        expect(e):toBe(err)
      end
    }
    expect(fn):toHaveBeenCalledWith(err, 'component event handler')
  end
  )
  it('should warn unhandled', function()
    local onError = jest:spyOn(console, 'error')
    onError:mockImplementation(function()
      
    end
    )
    local groupCollapsed = jest:spyOn(console, 'groupCollapsed')
    groupCollapsed:mockImplementation(function()
      
    end
    )
    local log = jest:spyOn(console, 'log')
    log:mockImplementation(function()
      
    end
    )
    local err = Error('foo')
    local fn = jest:fn()
    local Comp = {setup=function()
      onErrorCaptured(function(err, instance, info)
        fn(err, info)
      end
      )
      return function()
        h(Child)
      end
      
    
    end
    }
    local Child = {setup=function()
      error(err)
    end
    , render=function() end}
    render(h(Comp), nodeOps:createElement('div'))
    expect(fn):toHaveBeenCalledWith(err, 'setup function')
    expect():toHaveBeenWarned()
    expect(onError):toHaveBeenCalledWith(err)
    onError:mockRestore()
    groupCollapsed:mockRestore()
    log:mockRestore()
  end
  )
end
)