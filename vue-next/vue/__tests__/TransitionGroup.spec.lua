require("vue/__tests__/e2eUtils")
require("@vue/shared")
require("vue")

describe('e2e: TransitionGroup', function()
  mockWarn()
  local  = setupPuppeteer()
  local baseUrl = nil
  local duration = 50
  local buffer = 5
  local htmlWhenTransitionStart = function()
    page():evaluate(function()
      ():click()
      return Promise:resolve():tsvar_then(function()
        return ().innerHTML
      end
      )
    end
    )
  end
  
  local transitionFinish = function(time = duration)
    if time == nil then
      time=duration
    end
    timeout(time + buffer)
  end
  
  beforeEach(function()
    
  end
  )
  test('enter', function()
    
    expect():toBe( +  + )
    expect():toBe( +  +  +  + )
    expect():toBe( +  +  +  + )
    expect():toBe( +  +  +  + )
  end
  , E2E_TIMEOUT)
  test('leave', function()
    
    expect():toBe( +  + )
    expect():toBe( +  + )
    expect():toBe( +  + )
    expect():toBe()
  end
  , E2E_TIMEOUT)
  test('enter + leave', function()
    
    expect():toBe( +  + )
    expect():toBe( +  +  + )
    expect():toBe( +  +  + )
    expect():toBe( +  + )
  end
  , E2E_TIMEOUT)
  test('appear', function()
    local appearHtml = nil
    expect(appearHtml):toBe( +  + )
    expect():toBe( +  + )
    expect():toBe( +  + )
    expect():toBe( +  +  +  + )
    expect():toBe( +  +  +  + )
    expect():toBe( +  +  +  + )
  end
  , E2E_TIMEOUT)
  test('move', function()
    
    expect():toBe( +  + )
    expect():toBe( +  +  + )
    expect():toBe( +  +  + )
    expect():toBe( +  + )
  end
  , E2E_TIMEOUT)
  test('dynamic name', function()
    
    expect():toBe( +  + )
    expect():toBe( +  + )
    local moveHtml = nil
    expect(moveHtml):toBe( +  + )
    expect():toBe( +  + )
  end
  , E2E_TIMEOUT)
  test('events', function()
    local onLeaveSpy = jest:fn()
    local onEnterSpy = jest:fn()
    local onAppearSpy = jest:fn()
    local beforeLeaveSpy = jest:fn()
    local beforeEnterSpy = jest:fn()
    local beforeAppearSpy = jest:fn()
    local afterLeaveSpy = jest:fn()
    local afterEnterSpy = jest:fn()
    local afterAppearSpy = jest:fn()
    local appearHtml = nil
    expect(beforeAppearSpy):toBeCalled()
    expect(onAppearSpy):toBeCalled()
    expect(afterAppearSpy).tsvar_not:toBeCalled()
    expect(appearHtml):toBe( +  + )
    expect(afterAppearSpy).tsvar_not:toBeCalled()
    expect():toBe( +  + )
    expect(afterAppearSpy):toBeCalled()
    expect():toBe( +  + )
    expect():toBe( +  +  + )
    expect(beforeLeaveSpy):toBeCalled()
    expect(onLeaveSpy):toBeCalled()
    expect(afterLeaveSpy).tsvar_not:toBeCalled()
    expect(beforeEnterSpy):toBeCalled()
    expect(onEnterSpy):toBeCalled()
    expect(afterEnterSpy).tsvar_not:toBeCalled()
    expect():toBe( +  +  + )
    expect(afterLeaveSpy).tsvar_not:toBeCalled()
    expect(afterEnterSpy).tsvar_not:toBeCalled()
    expect():toBe( +  + )
    expect(afterLeaveSpy):toBeCalled()
    expect(afterEnterSpy):toBeCalled()
  end
  , E2E_TIMEOUT)
  test('warn unkeyed children', function()
    createApp({template=, setup=function()
      local items = ref({'a', 'b', 'c'})
      return {items=items}
    end
    }):mount(document:createElement('div'))
    expect():toHaveBeenWarned()
  end
  )
end
)