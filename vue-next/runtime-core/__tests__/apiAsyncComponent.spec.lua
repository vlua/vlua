require("runtime-core/src")
require("@vue/runtime-test")

local timeout = function(n = 0)
  if n == nil then
    n=0
  end
  Promise(function(r)
    setTimeout(r, n)
  end
  )
end

describe('api: defineAsyncComponent', function()
  test('simple usage', function()
    local resolve = nil
    local Foo = defineAsyncComponent(function()
      Promise(function(r)
        resolve = r
      end
      )
    end
    )
    local toggle = ref(true)
    local root = nodeOps:createElement('div')
    createApp({render=function()
      -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
      (toggle.value and {h(Foo)} or {nil})[1]
    end
    }):mount(root)
    expect(serializeInner(root)):toBe('<!---->')
    (function()
      'resolved'
    end
    )
    expect(serializeInner(root)):toBe('resolved')
    toggle.value = false
    expect(serializeInner(root)):toBe('<!---->')
    toggle.value = true
    expect(serializeInner(root)):toBe('resolved')
  end
  )
  test('with loading component', function()
    local resolve = nil
    local Foo = defineAsyncComponent({loader=function()
      Promise(function(r)
        resolve = r
      end
      )
    end
    , loadingComponent=function()
      'loading'
    end
    , delay=1})
    local toggle = ref(true)
    local root = nodeOps:createElement('div')
    createApp({render=function()
      -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
      (toggle.value and {h(Foo)} or {nil})[1]
    end
    }):mount(root)
    expect(serializeInner(root)):toBe('<!---->')
    expect(serializeInner(root)):toBe('loading')
    (function()
      'resolved'
    end
    )
    expect(serializeInner(root)):toBe('resolved')
    toggle.value = false
    expect(serializeInner(root)):toBe('<!---->')
    toggle.value = true
    expect(serializeInner(root)):toBe('resolved')
  end
  )
  test('with loading component + explicit delay (0)', function()
    local resolve = nil
    local Foo = defineAsyncComponent({loader=function()
      Promise(function(r)
        resolve = r
      end
      )
    end
    , loadingComponent=function()
      'loading'
    end
    , delay=0})
    local toggle = ref(true)
    local root = nodeOps:createElement('div')
    createApp({render=function()
      -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
      (toggle.value and {h(Foo)} or {nil})[1]
    end
    }):mount(root)
    expect(serializeInner(root)):toBe('loading')
    (function()
      'resolved'
    end
    )
    expect(serializeInner(root)):toBe('resolved')
    toggle.value = false
    expect(serializeInner(root)):toBe('<!---->')
    toggle.value = true
    expect(serializeInner(root)):toBe('resolved')
  end
  )
  test('error without error component', function()
    local resolve = nil
    local reject = nil
    local Foo = defineAsyncComponent(function()
      Promise(function(_resolve, _reject)
        resolve = _resolve
        reject = _reject
      end
      )
    end
    )
    local toggle = ref(true)
    local root = nodeOps:createElement('div')
    local app = createApp({render=function()
      -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
      (toggle.value and {h(Foo)} or {nil})[1]
    end
    })
    app.config.errorHandler = jest:fn()
    local handler = app.config.errorHandler
    app:mount(root)
    expect(serializeInner(root)):toBe('<!---->')
    local err = Error('foo')
    (err)
    expect(handler):toHaveBeenCalled()
    expect(handler.mock.calls[0+1][0+1]):toBe(err)
    expect(serializeInner(root)):toBe('<!---->')
    toggle.value = false
    expect(serializeInner(root)):toBe('<!---->')
    toggle.value = true
    expect(serializeInner(root)):toBe('<!---->')
    (function()
      'resolved'
    end
    )
    expect(serializeInner(root)):toBe('resolved')
  end
  )
  test('error with error component', function()
    local resolve = nil
    local reject = nil
    local Foo = defineAsyncComponent({loader=function()
      Promise(function(_resolve, _reject)
        resolve = _resolve
        reject = _reject
      end
      )
    end
    , errorComponent=function(props)
      props.error.message
    end
    })
    local toggle = ref(true)
    local root = nodeOps:createElement('div')
    local app = createApp({render=function()
      -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
      (toggle.value and {h(Foo)} or {nil})[1]
    end
    })
    app.config.errorHandler = jest:fn()
    local handler = app.config.errorHandler
    app:mount(root)
    expect(serializeInner(root)):toBe('<!---->')
    local err = Error('errored out')
    (err)
    expect(handler):toHaveBeenCalled()
    expect(serializeInner(root)):toBe('errored out')
    toggle.value = false
    expect(serializeInner(root)):toBe('<!---->')
    toggle.value = true
    expect(serializeInner(root)):toBe('<!---->')
    (function()
      'resolved'
    end
    )
    expect(serializeInner(root)):toBe('resolved')
  end
  )
  test('error with error + loading components', function()
    local resolve = nil
    local reject = nil
    local Foo = defineAsyncComponent({loader=function()
      Promise(function(_resolve, _reject)
        resolve = _resolve
        reject = _reject
      end
      )
    end
    , errorComponent=function(props)
      props.error.message
    end
    , loadingComponent=function()
      'loading'
    end
    , delay=1})
    local toggle = ref(true)
    local root = nodeOps:createElement('div')
    local app = createApp({render=function()
      -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
      (toggle.value and {h(Foo)} or {nil})[1]
    end
    })
    app.config.errorHandler = jest:fn()
    local handler = app.config.errorHandler
    app:mount(root)
    expect(serializeInner(root)):toBe('<!---->')
    expect(serializeInner(root)):toBe('loading')
    local err = Error('errored out')
    (err)
    expect(handler):toHaveBeenCalled()
    expect(serializeInner(root)):toBe('errored out')
    toggle.value = false
    expect(serializeInner(root)):toBe('<!---->')
    toggle.value = true
    expect(serializeInner(root)):toBe('<!---->')
    expect(serializeInner(root)):toBe('loading')
    (function()
      'resolved'
    end
    )
    expect(serializeInner(root)):toBe('resolved')
  end
  )
  test('timeout without error component', function()
    local resolve = nil
    local Foo = defineAsyncComponent({loader=function()
      Promise(function(_resolve)
        resolve = _resolve
      end
      )
    end
    , timeout=1})
    local root = nodeOps:createElement('div')
    local app = createApp({render=function()
      h(Foo)
    end
    })
    app.config.errorHandler = jest:fn()
    local handler = app.config.errorHandler
    app:mount(root)
    expect(serializeInner(root)):toBe('<!---->')
    expect(handler):toHaveBeenCalled()
    expect(handler.mock.calls[0+1][0+1].message):toMatch()
    expect(serializeInner(root)):toBe('<!---->')
    (function()
      'resolved'
    end
    )
    expect(serializeInner(root)):toBe('resolved')
  end
  )
  test('timeout with error component', function()
    local resolve = nil
    local Foo = defineAsyncComponent({loader=function()
      Promise(function(_resolve)
        resolve = _resolve
      end
      )
    end
    , timeout=1, errorComponent=function()
      'timed out'
    end
    })
    local root = nodeOps:createElement('div')
    local app = createApp({render=function()
      h(Foo)
    end
    })
    app.config.errorHandler = jest:fn()
    local handler = app.config.errorHandler
    app:mount(root)
    expect(serializeInner(root)):toBe('<!---->')
    expect(handler):toHaveBeenCalled()
    expect(serializeInner(root)):toBe('timed out')
    (function()
      'resolved'
    end
    )
    expect(serializeInner(root)):toBe('resolved')
  end
  )
  test('timeout with error + loading components', function()
    local resolve = nil
    local Foo = defineAsyncComponent({loader=function()
      Promise(function(_resolve)
        resolve = _resolve
      end
      )
    end
    , delay=1, timeout=16, errorComponent=function()
      'timed out'
    end
    , loadingComponent=function()
      'loading'
    end
    })
    local root = nodeOps:createElement('div')
    local app = createApp({render=function()
      h(Foo)
    end
    })
    app.config.errorHandler = jest:fn()
    local handler = app.config.errorHandler
    app:mount(root)
    expect(serializeInner(root)):toBe('<!---->')
    expect(serializeInner(root)):toBe('loading')
    expect(serializeInner(root)):toBe('timed out')
    expect(handler):toHaveBeenCalled()
    (function()
      'resolved'
    end
    )
    expect(serializeInner(root)):toBe('resolved')
  end
  )
  test('timeout without error component, but with loading component', function()
    local resolve = nil
    local Foo = defineAsyncComponent({loader=function()
      Promise(function(_resolve)
        resolve = _resolve
      end
      )
    end
    , delay=1, timeout=16, loadingComponent=function()
      'loading'
    end
    })
    local root = nodeOps:createElement('div')
    local app = createApp({render=function()
      h(Foo)
    end
    })
    app.config.errorHandler = jest:fn()
    local handler = app.config.errorHandler
    app:mount(root)
    expect(serializeInner(root)):toBe('<!---->')
    expect(serializeInner(root)):toBe('loading')
    expect(handler):toHaveBeenCalled()
    expect(handler.mock.calls[0+1][0+1].message):toMatch()
    expect(serializeInner(root)):toBe('loading')
    (function()
      'resolved'
    end
    )
    expect(serializeInner(root)):toBe('resolved')
  end
  )
  test('with suspense', function()
    local resolve = nil
    local Foo = defineAsyncComponent(function()
      Promise(function(_resolve)
        resolve = _resolve
      end
      )
    end
    )
    local root = nodeOps:createElement('div')
    local app = createApp({render=function()
      h(Suspense, nil, {default=function()
        {h(Foo), ' & ', h(Foo)}
      end
      , fallback=function()
        'loading'
      end
      })
    end
    })
    app:mount(root)
    expect(serializeInner(root)):toBe('loading')
    (function()
      'resolved'
    end
    )
    expect(serializeInner(root)):toBe('resolved & resolved')
  end
  )
  test('suspensible: false', function()
    local resolve = nil
    local Foo = defineAsyncComponent({loader=function()
      Promise(function(_resolve)
        resolve = _resolve
      end
      )
    end
    , suspensible=false})
    local root = nodeOps:createElement('div')
    local app = createApp({render=function()
      h(Suspense, nil, {default=function()
        {h(Foo), ' & ', h(Foo)}
      end
      , fallback=function()
        'loading'
      end
      })
    end
    })
    app:mount(root)
    expect(serializeInner(root)):toBe('<!----> & <!---->')
    (function()
      'resolved'
    end
    )
    expect(serializeInner(root)):toBe('resolved & resolved')
  end
  )
  test('suspense with error handling', function()
    local reject = nil
    local Foo = defineAsyncComponent(function()
      Promise(function(_resolve, _reject)
        reject = _reject
      end
      )
    end
    )
    local root = nodeOps:createElement('div')
    local app = createApp({render=function()
      h(Suspense, nil, {default=function()
        {h(Foo), ' & ', h(Foo)}
      end
      , fallback=function()
        'loading'
      end
      })
    end
    })
    app.config.errorHandler = jest:fn()
    local handler = app.config.errorHandler
    app:mount(root)
    expect(serializeInner(root)):toBe('loading')
    (Error('no'))
    expect(handler):toHaveBeenCalled()
    expect(serializeInner(root)):toBe('<!----> & <!---->')
  end
  )
  test('retry (success)', function()
    local loaderCallCount = 0
    local resolve = nil
    local reject = nil
    local Foo = defineAsyncComponent({loader=function()
      loaderCallCount=loaderCallCount+1
      return Promise(function(_resolve, _reject)
        resolve = _resolve
        reject = _reject
      end
      )
    end
    , onError=function(error, retry, fail)
      -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
      if error.message:match(/foo/) then
        retry()
      else
        fail()
      end
    end
    })
    local root = nodeOps:createElement('div')
    local app = createApp({render=function()
      h(Foo)
    end
    })
    app.config.errorHandler = jest:fn()
    local handler = app.config.errorHandler
    app:mount(root)
    expect(serializeInner(root)):toBe('<!---->')
    expect(loaderCallCount):toBe(1)
    local err = Error('foo')
    (err)
    expect(handler).tsvar_not:toHaveBeenCalled()
    expect(loaderCallCount):toBe(2)
    expect(serializeInner(root)):toBe('<!---->')
    (function()
      'resolved'
    end
    )
    expect(handler).tsvar_not:toHaveBeenCalled()
    expect(serializeInner(root)):toBe('resolved')
  end
  )
  test('retry (skipped)', function()
    local loaderCallCount = 0
    local reject = nil
    local Foo = defineAsyncComponent({loader=function()
      loaderCallCount=loaderCallCount+1
      return Promise(function(_resolve, _reject)
        reject = _reject
      end
      )
    end
    , onError=function(error, retry, fail)
      -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
      if error.message:match(/bar/) then
        retry()
      else
        fail()
      end
    end
    })
    local root = nodeOps:createElement('div')
    local app = createApp({render=function()
      h(Foo)
    end
    })
    app.config.errorHandler = jest:fn()
    local handler = app.config.errorHandler
    app:mount(root)
    expect(serializeInner(root)):toBe('<!---->')
    expect(loaderCallCount):toBe(1)
    local err = Error('foo')
    (err)
    expect(handler):toHaveBeenCalled()
    expect(handler.mock.calls[0+1][0+1]):toBe(err)
    expect(loaderCallCount):toBe(1)
    expect(serializeInner(root)):toBe('<!---->')
  end
  )
  test('retry (fail w/ max retry attempts)', function()
    local loaderCallCount = 0
    local reject = nil
    local Foo = defineAsyncComponent({loader=function()
      loaderCallCount=loaderCallCount+1
      return Promise(function(_resolve, _reject)
        reject = _reject
      end
      )
    end
    , onError=function(error, retry, fail, attempts)
      -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
      if error.message:match(/foo/) and attempts <= 1 then
        retry()
      else
        fail()
      end
    end
    })
    local root = nodeOps:createElement('div')
    local app = createApp({render=function()
      h(Foo)
    end
    })
    app.config.errorHandler = jest:fn()
    local handler = app.config.errorHandler
    app:mount(root)
    expect(serializeInner(root)):toBe('<!---->')
    expect(loaderCallCount):toBe(1)
    local err = Error('foo')
    (err)
    expect(handler).tsvar_not:toHaveBeenCalled()
    expect(loaderCallCount):toBe(2)
    expect(serializeInner(root)):toBe('<!---->')
    (err)
    expect(handler):toHaveBeenCalled()
    expect(handler.mock.calls[0+1][0+1]):toBe(err)
    expect(loaderCallCount):toBe(2)
    expect(serializeInner(root)):toBe('<!---->')
  end
  )
end
)