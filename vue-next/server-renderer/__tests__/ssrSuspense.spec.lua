require("vue")
require("@vue/shared")

describe('SSR Suspense', function()
  mockWarn()
  local ResolvingAsync = {setup=function()
    return function()
      h('div', 'async')
    end
    
  
  end
  }
  local RejectingAsync = {setup=function()
    return Promise(function(_, reject)
      reject('foo')
    end
    )
  end
  }
  test('content', function()
    local Comp = {render=function()
      return h(Suspense, nil, {default=h(ResolvingAsync), fallback=h('div', 'fallback')})
    end
    }
    expect():toBe()
  end
  )
  test('reject', function()
    local Comp = {render=function()
      return h(Suspense, nil, {default=h(RejectingAsync), fallback=h('div', 'fallback')})
    end
    }
    expect():toBe()
    expect('Uncaught error in async setup'):toHaveBeenWarned()
    expect('missing template'):toHaveBeenWarned()
  end
  )
  test('2 components', function()
    local Comp = {render=function()
      return h(Suspense, nil, {default=h('div', {h(ResolvingAsync), h(ResolvingAsync)}), fallback=h('div', 'fallback')})
    end
    }
    expect():toBe()
  end
  )
  test('resolving component + rejecting component', function()
    local Comp = {render=function()
      return h(Suspense, nil, {default=h('div', {h(ResolvingAsync), h(RejectingAsync)}), fallback=h('div', 'fallback')})
    end
    }
    expect():toBe()
    expect('Uncaught error in async setup'):toHaveBeenWarned()
    expect('missing template or render function'):toHaveBeenWarned()
  end
  )
  test('failing suspense in passing suspense', function()
    local Comp = {render=function()
      return h(Suspense, nil, {default=h('div', {h(ResolvingAsync), h(Suspense, nil, {default=h('div', {h(RejectingAsync)}), fallback=h('div', 'fallback 2')})}), fallback=h('div', 'fallback 1')})
    end
    }
    expect():toBe()
    expect('Uncaught error in async setup'):toHaveBeenWarned()
    expect('missing template'):toHaveBeenWarned()
  end
  )
  test('passing suspense in failing suspense', function()
    local Comp = {render=function()
      return h(Suspense, nil, {default=h('div', {h(RejectingAsync), h(Suspense, nil, {default=h('div', {h(ResolvingAsync)}), fallback=h('div', 'fallback 2')})}), fallback=h('div', 'fallback 1')})
    end
    }
    expect():toBe()
    expect('Uncaught error in async setup'):toHaveBeenWarned()
    expect('missing template'):toHaveBeenWarned()
  end
  )
end
)