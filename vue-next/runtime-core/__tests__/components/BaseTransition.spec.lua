require("@vue/runtime-test")

function mount(props, slot, withKeepAlive)
  if withKeepAlive == nil then
    withKeepAlive=false
  end
  local root = nodeOps:createElement('div')
  render(h(BaseTransition, props, function()
    -- [ts2lua]lua中0和空字符串也是true，此处withKeepAlive需要确认
    return (withKeepAlive and {h(KeepAlive, nil, slot())} or {slot()})[1]
  end
  ), root)
  return root
end

function mockProps(extra, withKeepAlive)
  if extra == nil then
    extra={}
  end
  if withKeepAlive == nil then
    withKeepAlive=false
  end
  local cbs = {doneEnter={}, doneLeave={}}
  local props = {onBeforeEnter=jest:fn(function(el)
    if not extra.persisted and not withKeepAlive then
      expect(el.parentNode):toBeNull()
    end
  end
  ), onEnter=jest:fn(function(el, done)
    -- [ts2lua]cbs.doneEnter下标访问可能不正确
    cbs.doneEnter[serialize(el)] = done
  end
  ), onAfterEnter=jest:fn(), onEnterCancelled=jest:fn(), onBeforeLeave=jest:fn(), onLeave=jest:fn(function(el, done)
    -- [ts2lua]cbs.doneLeave下标访问可能不正确
    cbs.doneLeave[serialize(el)] = done
  end
  ), onAfterLeave=jest:fn(), onLeaveCancelled=jest:fn(), onBeforeAppear=jest:fn(), onAppear=jest:fn(function(el, done)
    -- [ts2lua]cbs.doneEnter下标访问可能不正确
    cbs.doneEnter[serialize(el)] = done
  end
  ), onAfterAppear=jest:fn(), onAppearCancelled=jest:fn(), ...}
  return {props=props, cbs=cbs}
end

function assertCalls(props, calls)
  Object:keys(calls):forEach(function(key)
    -- [ts2lua]props下标访问可能不正确
    -- [ts2lua]calls下标访问可能不正确
    expect(props[key]):toHaveBeenCalledTimes(calls[key])
  end
  )
end

function assertCalledWithEl(fn, expected, callIndex)
  if callIndex == nil then
    callIndex=0
  end
  -- [ts2lua]fn.mock.calls下标访问可能不正确
  expect(serialize(fn.mock.calls[callIndex][0+1])):toBe(expected)
end

function runTestWithElements(tester)
  return tester({trueBranch=function()
    h('div')
  end
  , falseBranch=function()
    h('span')
  end
  , trueSerialized=, falseSerialized=})
end

function runTestWithComponents(tester)
  local CompA = function()
    h('div', msg)
  end
  
  local CompB = function()
    h(CompC, {msg=msg})
  end
  
  local CompC = function()
    h('span', msg)
  end
  
  return tester({trueBranch=function()
    h(CompA, {msg='foo'})
  end
  , falseBranch=function()
    h(CompB, {msg='bar'})
  end
  , trueSerialized=, falseSerialized=})
end

function runTestWithKeepAlive(tester)
  local trueComp = {setup=function()
    local count = ref(0)
    return function()
      h('div', count.value)
    end
    
  
  end
  }
  local falseComp = {setup=function()
    local count = ref(0)
    return function()
      h('span', count.value)
    end
    
  
  end
  }
  return tester({trueBranch=function()
    h(trueComp)
  end
  , falseBranch=function()
    h(falseComp)
  end
  , trueSerialized=, falseSerialized=}, true)
end

describe('BaseTransition', function()
  test('appear: true w/ appear hooks', function()
    local  = mockProps({appear=true})
    mount(props, function()
      h('div')
    end
    )
    expect(props.onBeforeAppear):toHaveBeenCalledTimes(1)
    expect(props.onAppear):toHaveBeenCalledTimes(1)
    expect(props.onAfterAppear).tsvar_not:toHaveBeenCalled()
    expect(props.onBeforeEnter).tsvar_not:toHaveBeenCalled()
    expect(props.onEnter).tsvar_not:toHaveBeenCalled()
    expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
    -- [ts2lua]cbs.doneEnter下标访问可能不正确
    cbs.doneEnter[]()
    expect(props.onAfterAppear):toHaveBeenCalledTimes(1)
    expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
  end
  )
  test('appear: true w/ fallback to enter hooks', function()
    local  = mockProps({appear=true, onBeforeAppear=undefined, onAppear=undefined, onAfterAppear=undefined, onAppearCancelled=undefined})
    mount(props, function()
      h('div')
    end
    )
    expect(props.onBeforeEnter):toHaveBeenCalledTimes(1)
    expect(props.onEnter):toHaveBeenCalledTimes(1)
    expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
    -- [ts2lua]cbs.doneEnter下标访问可能不正确
    cbs.doneEnter[]()
    expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
  end
  )
  describe('persisted: true', function()
    function mockPersistedHooks()
      local state = {show=true}
      local toggle = ref(true)
      local hooks = {onVnodeBeforeMount=function(vnode)
        ():beforeEnter()
      end
      , onVnodeMounted=function(vnode)
        ():enter()
      end
      , onVnodeUpdated=function(vnode, oldVnode)
        if ().id ~= ().id then
          if ().id then
            ():beforeEnter()
            state.show = true
            ():enter()
          else
            ():leave(function()
              state.show = false
            end
            )
          end
        end
      end
      }
      return {state=state, toggle=toggle, hooks=hooks}
    end
    
    test('w/ appear: false', function()
      local  = mockProps({persisted=true})
      local  = mockPersistedHooks()
      mount(props, function()
        h('div', {id=toggle.value, ...})
      end
      )
      expect(props.onBeforeEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      toggle.value = false
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(1)
      expect(props.onLeave):toHaveBeenCalledTimes(1)
      expect(props.onAfterLeave).tsvar_not:toHaveBeenCalled()
      expect(state.show):toBe(true)
      -- [ts2lua]cbs.doneLeave下标访问可能不正确
      cbs.doneLeave[]()
      expect(state.show):toBe(false)
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      toggle.value = true
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(1)
      expect(props.onEnter):toHaveBeenCalledTimes(1)
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      expect(state.show):toBe(true)
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[]()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
    end
    )
    test('w/ appear: true', function()
      local  = mockProps({persisted=true, appear=true})
      local  = mockPersistedHooks()
      mount(props, function()
        h('div', hooks)
      end
      )
      expect(props.onBeforeAppear):toHaveBeenCalledTimes(1)
      expect(props.onAppear):toHaveBeenCalledTimes(1)
      expect(props.onAfterAppear).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[]()
      expect(props.onAfterAppear):toHaveBeenCalledTimes(1)
    end
    )
  end
  )
  describe('toggle on-off', function()
    function testToggleOnOff()
      local toggle = ref(true)
      local  = mockProps()
      local root = mount(props, function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {trueBranch()} or {falseBranch()})[1]
      end
      )
      expect(props.onBeforeEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      toggle.value = false
      expect(serializeInner(root)):toBe()
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onBeforeLeave, trueSerialized)
      expect(props.onLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onLeave, trueSerialized)
      expect(props.onAfterLeave).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneLeave下标访问可能不正确
      cbs.doneLeave[trueSerialized]()
      expect(serializeInner(root)):toBe(falseSerialized)
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterLeave, trueSerialized)
      toggle.value = true
      expect(serializeInner(root)):toBe(trueSerialized)
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onBeforeEnter, trueSerialized)
      expect(props.onEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onEnter, trueSerialized)
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[trueSerialized]()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterEnter, trueSerialized)
      assertCalls(props, {onBeforeEnter=1, onEnter=1, onAfterEnter=1, onEnterCancelled=0, onBeforeLeave=1, onLeave=1, onAfterLeave=1, onLeaveCancelled=0})
    end
    
    test('w/ element', function()
      
    end
    )
    test('w/ component', function()
      local Comp = function()
        h('div', msg)
      end
      
    
    end
    )
  end
  )
  describe('toggle on-off before finish', function()
    function testToggleOnOffBeforeFinish()
      local toggle = ref(false)
      local  = mockProps()
      local root = mount(props, function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {trueBranch()} or {falseBranch()})[1]
      end
      )
      toggle.value = true
      expect(serializeInner(root)):toBe(trueSerialized)
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(1)
      expect(props.onEnter):toHaveBeenCalledTimes(1)
      toggle.value = false
      expect(serializeInner(root)):toBe()
      expect(props.onEnterCancelled):toHaveBeenCalled()
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(1)
      expect(props.onLeave):toHaveBeenCalledTimes(1)
      expect(props.onAfterLeave).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[trueSerialized]()
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      toggle.value = true
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(2)
      expect(props.onEnter):toHaveBeenCalledTimes(2)
      expect(serializeInner(root)):toBe(trueSerialized)
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      -- [ts2lua]cbs.doneLeave下标访问可能不正确
      cbs.doneLeave[trueSerialized]()
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[trueSerialized]()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      assertCalls(props, {onBeforeEnter=2, onEnter=2, onAfterEnter=1, onEnterCancelled=1, onBeforeLeave=1, onLeave=1, onAfterLeave=1, onLeaveCancelled=0})
    end
    
    test('w/ element', function()
      
    end
    )
    test('w/ component', function()
      local Comp = function()
        h('div', msg)
      end
      
    
    end
    )
  end
  )
  describe('toggle between branches', function()
    function testToggleBranches(, withKeepAlive)
      if withKeepAlive == nil then
        withKeepAlive=false
      end
      local toggle = ref(true)
      local  = mockProps({}, withKeepAlive)
      local root = mount(props, function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {trueBranch()} or {falseBranch()})[1]
      end
      , withKeepAlive)
      expect(props.onBeforeEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      toggle.value = false
      expect(serializeInner(root)):toBe()
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onBeforeLeave, trueSerialized)
      expect(props.onLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onLeave, trueSerialized)
      expect(props.onAfterLeave).tsvar_not:toHaveBeenCalled()
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onBeforeEnter, falseSerialized)
      expect(props.onEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onEnter, falseSerialized)
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[falseSerialized]()
      expect(serializeInner(root)):toBe()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterEnter, falseSerialized)
      expect(props.onAfterLeave).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneLeave下标访问可能不正确
      cbs.doneLeave[trueSerialized]()
      expect(serializeInner(root)):toBe()
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterLeave, trueSerialized)
      toggle.value = true
      expect(serializeInner(root)):toBe()
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onBeforeLeave, falseSerialized, 1)
      expect(props.onLeave):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onLeave, falseSerialized, 1)
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onBeforeEnter, trueSerialized, 1)
      expect(props.onEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onEnter, trueSerialized, 1)
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      -- [ts2lua]cbs.doneLeave下标访问可能不正确
      cbs.doneLeave[falseSerialized]()
      expect(serializeInner(root)):toBe()
      expect(props.onAfterLeave):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onAfterLeave, falseSerialized, 1)
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[trueSerialized]()
      expect(serializeInner(root)):toBe()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onAfterEnter, trueSerialized, 1)
      assertCalls(props, {onBeforeEnter=2, onEnter=2, onAfterEnter=2, onBeforeLeave=2, onLeave=2, onAfterLeave=2, onEnterCancelled=0, onLeaveCancelled=0})
    end
    
    test('w/ elements', function()
      
    end
    )
    test('w/ components', function()
      
    end
    )
    test('w/ KeepAlive', function()
      
    end
    )
  end
  )
  describe('toggle between branches before finish', function()
    function testToggleBranchesBeforeFinish(, withKeepAlive)
      if withKeepAlive == nil then
        withKeepAlive=false
      end
      local toggle = ref(true)
      local  = mockProps({}, withKeepAlive)
      local root = mount(props, function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {trueBranch()} or {falseBranch()})[1]
      end
      , withKeepAlive)
      toggle.value = false
      expect(serializeInner(root)):toBe()
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onBeforeLeave, trueSerialized)
      expect(props.onLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onLeave, trueSerialized)
      expect(props.onAfterLeave).tsvar_not:toHaveBeenCalled()
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onBeforeEnter, falseSerialized)
      expect(props.onEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onEnter, falseSerialized)
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      toggle.value = true
      expect(serializeInner(root)):toBe()
      if not withKeepAlive then
        expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
        assertCalledWithEl(props.onAfterLeave, trueSerialized)
      else
        expect(props.onLeaveCancelled):toHaveBeenCalledTimes(1)
        assertCalledWithEl(props.onLeaveCancelled, trueSerialized)
      end
      expect(props.onEnterCancelled):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onEnterCancelled, falseSerialized)
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[falseSerialized]()
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onBeforeLeave, falseSerialized, 1)
      expect(props.onLeave):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onLeave, falseSerialized, 1)
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onBeforeEnter, trueSerialized, 1)
      expect(props.onEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onEnter, trueSerialized, 1)
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      toggle.value = false
      expect(serializeInner(root)):toBe()
      if not withKeepAlive then
        expect(props.onAfterLeave):toHaveBeenCalledTimes(2)
        assertCalledWithEl(props.onAfterLeave, falseSerialized, 1)
      else
        expect(props.onLeaveCancelled):toHaveBeenCalledTimes(2)
        assertCalledWithEl(props.onLeaveCancelled, falseSerialized, 1)
      end
      expect(props.onEnterCancelled):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onEnterCancelled, trueSerialized, 1)
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[trueSerialized]()
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(3)
      assertCalledWithEl(props.onBeforeLeave, trueSerialized, 2)
      expect(props.onLeave):toHaveBeenCalledTimes(3)
      assertCalledWithEl(props.onLeave, trueSerialized, 2)
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(3)
      assertCalledWithEl(props.onBeforeEnter, falseSerialized, 2)
      expect(props.onEnter):toHaveBeenCalledTimes(3)
      assertCalledWithEl(props.onEnter, falseSerialized, 2)
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[falseSerialized]()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterEnter, falseSerialized)
      -- [ts2lua]cbs.doneLeave下标访问可能不正确
      cbs.doneLeave[trueSerialized]()
      if not withKeepAlive then
        expect(props.onAfterLeave):toHaveBeenCalledTimes(3)
        assertCalledWithEl(props.onAfterLeave, trueSerialized, 2)
      else
        expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
        assertCalledWithEl(props.onAfterLeave, trueSerialized)
      end
      -- [ts2lua]lua中0和空字符串也是true，此处withKeepAlive需要确认
      -- [ts2lua]lua中0和空字符串也是true，此处withKeepAlive需要确认
      assertCalls(props, {onBeforeEnter=3, onEnter=3, onAfterEnter=1, onEnterCancelled=2, onBeforeLeave=3, onLeave=3, onAfterLeave=(withKeepAlive and {1} or {3})[1], onLeaveCancelled=(withKeepAlive and {2} or {0})[1]})
    end
    
    test('w/ elements', function()
      
    end
    )
    test('w/ components', function()
      
    end
    )
    test('w/ KeepAlive', function()
      
    end
    )
  end
  )
  describe('mode: "out-in"', function()
    function testOutIn(, withKeepAlive)
      if withKeepAlive == nil then
        withKeepAlive=false
      end
      local toggle = ref(true)
      local  = mockProps({mode='out-in'}, withKeepAlive)
      local root = mount(props, function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {trueBranch()} or {falseBranch()})[1]
      end
      , withKeepAlive)
      toggle.value = false
      expect(serializeInner(root)):toBe()
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onBeforeLeave, trueSerialized)
      expect(props.onLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onLeave, trueSerialized)
      expect(props.onAfterLeave).tsvar_not:toHaveBeenCalled()
      expect(props.onBeforeEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneLeave下标访问可能不正确
      cbs.doneLeave[trueSerialized]()
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterLeave, trueSerialized)
      expect(serializeInner(root)):toBe(falseSerialized)
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onBeforeEnter, falseSerialized)
      expect(props.onEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onEnter, falseSerialized)
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[falseSerialized]()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterEnter, falseSerialized)
      toggle.value = true
      expect(serializeInner(root)):toBe()
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onBeforeLeave, falseSerialized, 1)
      expect(props.onLeave):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onLeave, falseSerialized, 1)
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(1)
      expect(props.onEnter):toHaveBeenCalledTimes(1)
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      -- [ts2lua]cbs.doneLeave下标访问可能不正确
      cbs.doneLeave[falseSerialized]()
      expect(props.onAfterLeave):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onAfterLeave, falseSerialized, 1)
      expect(serializeInner(root)):toBe(trueSerialized)
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onBeforeEnter, trueSerialized, 1)
      expect(props.onEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onEnter, trueSerialized, 1)
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[trueSerialized]()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onAfterEnter, trueSerialized, 1)
      assertCalls(props, {onBeforeEnter=2, onEnter=2, onAfterEnter=2, onEnterCancelled=0, onBeforeLeave=2, onLeave=2, onAfterLeave=2, onLeaveCancelled=0})
    end
    
    test('w/ elements', function()
      
    end
    )
    test('w/ components', function()
      
    end
    )
    test('w/ KeepAlive', function()
      
    end
    )
  end
  )
  describe('mode: "out-in" toggle before finish', function()
    function testOutInBeforeFinish(, withKeepAlive)
      if withKeepAlive == nil then
        withKeepAlive=false
      end
      local toggle = ref(true)
      local  = mockProps({mode='out-in'}, withKeepAlive)
      local root = mount(props, function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {trueBranch()} or {falseBranch()})[1]
      end
      , withKeepAlive)
      toggle.value = false
      toggle.value = true
      expect(serializeInner(root)):toBe()
      expect(props.onBeforeEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneLeave下标访问可能不正确
      cbs.doneLeave[trueSerialized]()
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterLeave, trueSerialized)
      expect(serializeInner(root)):toBe(trueSerialized)
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onBeforeEnter, trueSerialized)
      expect(props.onEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onEnter, trueSerialized)
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[trueSerialized]()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterEnter, trueSerialized)
      assertCalls(props, {onBeforeEnter=1, onEnter=1, onAfterEnter=1, onEnterCancelled=0, onBeforeLeave=1, onLeave=1, onAfterLeave=1, onLeaveCancelled=0})
    end
    
    test('w/ elements', function()
      
    end
    )
    test('w/ components', function()
      
    end
    )
    test('w/ KeepAlive', function()
      
    end
    )
  end
  )
  describe('mode: "out-in" double quick toggle', function()
    function testOutInDoubleToggle(, withKeepAlive)
      if withKeepAlive == nil then
        withKeepAlive=false
      end
      local toggle = ref(true)
      local  = mockProps({mode='out-in'}, withKeepAlive)
      local root = mount(props, function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {trueBranch()} or {falseBranch()})[1]
      end
      , withKeepAlive)
      toggle.value = false
      toggle.value = true
      toggle.value = false
      expect(serializeInner(root)):toBe()
      expect(props.onBeforeEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneLeave下标访问可能不正确
      cbs.doneLeave[trueSerialized]()
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterLeave, trueSerialized)
      expect(serializeInner(root)):toBe(falseSerialized)
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onBeforeEnter, falseSerialized)
      expect(props.onEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onEnter, falseSerialized)
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[falseSerialized]()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterEnter, falseSerialized)
      assertCalls(props, {onBeforeEnter=1, onEnter=1, onAfterEnter=1, onEnterCancelled=0, onBeforeLeave=1, onLeave=1, onAfterLeave=1, onLeaveCancelled=0})
    end
    
    test('w/ elements', function()
      
    end
    )
    test('w/ components', function()
      
    end
    )
    test('w/ KeepAlive', function()
      
    end
    )
  end
  )
  describe('mode: "in-out"', function()
    function testInOut(, withKeepAlive)
      if withKeepAlive == nil then
        withKeepAlive=false
      end
      local toggle = ref(true)
      local  = mockProps({mode='in-out'}, withKeepAlive)
      local root = mount(props, function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {trueBranch()} or {falseBranch()})[1]
      end
      , withKeepAlive)
      toggle.value = false
      expect(serializeInner(root)):toBe()
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onBeforeEnter, falseSerialized)
      expect(props.onEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onEnter, falseSerialized)
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onBeforeLeave).tsvar_not:toHaveBeenCalled()
      expect(props.onLeave).tsvar_not:toHaveBeenCalled()
      expect(props.onAfterLeave).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[falseSerialized]()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterEnter, falseSerialized)
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onBeforeLeave, trueSerialized)
      expect(props.onLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onLeave, trueSerialized)
      expect(props.onAfterLeave).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneLeave下标访问可能不正确
      cbs.doneLeave[trueSerialized]()
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterLeave, trueSerialized)
      toggle.value = true
      expect(serializeInner(root)):toBe()
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onBeforeEnter, trueSerialized, 1)
      expect(props.onEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onEnter, trueSerialized, 1)
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(1)
      expect(props.onLeave):toHaveBeenCalledTimes(1)
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[trueSerialized]()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onAfterEnter, trueSerialized, 1)
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onBeforeLeave, falseSerialized, 1)
      expect(props.onLeave):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onLeave, falseSerialized, 1)
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      -- [ts2lua]cbs.doneLeave下标访问可能不正确
      cbs.doneLeave[falseSerialized]()
      expect(props.onAfterLeave):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onAfterLeave, falseSerialized, 1)
      assertCalls(props, {onBeforeEnter=2, onEnter=2, onAfterEnter=2, onEnterCancelled=0, onBeforeLeave=2, onLeave=2, onAfterLeave=2, onLeaveCancelled=0})
    end
    
    test('w/ elements', function()
      
    end
    )
    test('w/ components', function()
      
    end
    )
    test('w/ KeepAlive', function()
      
    end
    )
  end
  )
  describe('mode: "in-out" toggle before finish', function()
    function testInOutBeforeFinish(, withKeepAlive)
      if withKeepAlive == nil then
        withKeepAlive=false
      end
      local toggle = ref(true)
      local  = mockProps({mode='in-out'}, withKeepAlive)
      local root = mount(props, function()
        -- [ts2lua]lua中0和空字符串也是true，此处toggle.value需要确认
        (toggle.value and {trueBranch()} or {falseBranch()})[1]
      end
      , withKeepAlive)
      toggle.value = false
      expect(serializeInner(root)):toBe()
      toggle.value = true
      expect(serializeInner(root)):toBe()
      expect(props.onBeforeEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onBeforeEnter, falseSerialized)
      assertCalledWithEl(props.onBeforeEnter, trueSerialized, 1)
      expect(props.onEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onEnter, falseSerialized)
      assertCalledWithEl(props.onEnter, trueSerialized, 1)
      expect(props.onAfterEnter).tsvar_not:toHaveBeenCalled()
      expect(props.onEnterCancelled).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[falseSerialized]()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterEnter, falseSerialized)
      expect(props.onBeforeLeave).tsvar_not:toHaveBeenCalled()
      expect(props.onLeave).tsvar_not:toHaveBeenCalled()
      expect(props.onAfterLeave).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneEnter下标访问可能不正确
      cbs.doneEnter[trueSerialized]()
      expect(props.onAfterEnter):toHaveBeenCalledTimes(2)
      assertCalledWithEl(props.onAfterEnter, trueSerialized, 1)
      expect(props.onBeforeLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onBeforeLeave, falseSerialized)
      expect(props.onLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onLeave, falseSerialized)
      expect(props.onAfterLeave).tsvar_not:toHaveBeenCalled()
      -- [ts2lua]cbs.doneLeave下标访问可能不正确
      cbs.doneLeave[falseSerialized]()
      expect(serializeInner(root)):toBe(trueSerialized)
      expect(props.onAfterLeave):toHaveBeenCalledTimes(1)
      assertCalledWithEl(props.onAfterLeave, falseSerialized)
      assertCalls(props, {onBeforeEnter=2, onEnter=2, onAfterEnter=2, onEnterCancelled=0, onBeforeLeave=1, onLeave=1, onAfterLeave=1, onLeaveCancelled=0})
    end
    
    test('w/ elements', function()
      
    end
    )
    test('w/ components', function()
      
    end
    )
    test('w/ KeepAlive', function()
      
    end
    )
  end
  )
end
)