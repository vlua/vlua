require("stringutil")
require("tableutil")
require("@vue/runtime-core")
require("@vue/shared")

local TRANSITION = 'transition'
local ANIMATION = 'animation'
local Transition = function(props, )
  h(BaseTransition, resolveTransitionProps(props), slots)
end

Transition.displayName = 'Transition'
local DOMTransitionPropsValidators = {name=String, type=String, css={type=Boolean, default=true}, duration={String, Number, Object}, enterFromClass=String, enterActiveClass=String, enterToClass=String, appearFromClass=String, appearActiveClass=String, appearToClass=String, leaveFromClass=String, leaveActiveClass=String, leaveToClass=String}
Transition.props = extend({}, BaseTransition.props, DOMTransitionPropsValidators)
local TransitionPropsValidators = Transition.props
function resolveTransitionProps(rawProps)
  local  = rawProps
  local baseProps = {}
  for key in pairs(rawProps) do
    if not (DOMTransitionPropsValidators[key]) then
      
      -- [ts2lua]baseProps下标访问可能不正确
      -- [ts2lua]rawProps下标访问可能不正确
      baseProps[key] = rawProps[key]
    end
  end
  if not css then
    return baseProps
  end
  local durations = normalizeDuration(duration)
  local enterDuration = durations and durations[0+1]
  local leaveDuration = durations and durations[1+1]
  local  = baseProps
  local finishEnter = function(el, isAppear, done)
    -- [ts2lua]lua中0和空字符串也是true，此处isAppear需要确认
    removeTransitionClass(el, (isAppear and {appearToClass} or {enterToClass})[1])
    -- [ts2lua]lua中0和空字符串也是true，此处isAppear需要确认
    removeTransitionClass(el, (isAppear and {appearActiveClass} or {enterActiveClass})[1])
    done and done()
  end
  
  local finishLeave = function(el, done)
    removeTransitionClass(el, leaveToClass)
    removeTransitionClass(el, leaveActiveClass)
    done and done()
  end
  
  local makeEnterHook = function(isAppear)
    return function(el, done)
      -- [ts2lua]lua中0和空字符串也是true，此处isAppear需要确认
      local hook = (isAppear and {onAppear} or {onEnter})[1]
      local resolve = function()
        finishEnter(el, isAppear, done)
      end
      
      hook and hook(el, resolve)
      nextFrame(function()
        -- [ts2lua]lua中0和空字符串也是true，此处isAppear需要确认
        removeTransitionClass(el, (isAppear and {appearFromClass} or {enterFromClass})[1])
        -- [ts2lua]lua中0和空字符串也是true，此处isAppear需要确认
        addTransitionClass(el, (isAppear and {appearToClass} or {enterToClass})[1])
        if not (hook and #hook > 1) then
          if enterDuration then
            setTimeout(resolve, enterDuration)
          else
            whenTransitionEnds(el, type, resolve)
          end
        end
      end
      )
    end
    
  
  end
  
  return extend(baseProps, {onBeforeEnter=function(el)
    onBeforeEnter and onBeforeEnter(el)
    addTransitionClass(el, enterActiveClass)
    addTransitionClass(el, enterFromClass)
  end
  , onBeforeAppear=function(el)
    onBeforeAppear and onBeforeAppear(el)
    addTransitionClass(el, appearActiveClass)
    addTransitionClass(el, appearFromClass)
  end
  , onEnter=makeEnterHook(false), onAppear=makeEnterHook(true), onLeave=function(el, done)
    local resolve = function()
      finishLeave(el, done)
    end
    
    addTransitionClass(el, leaveActiveClass)
    addTransitionClass(el, leaveFromClass)
    nextFrame(function()
      removeTransitionClass(el, leaveFromClass)
      addTransitionClass(el, leaveToClass)
      if not (onLeave and #onLeave > 1) then
        if leaveDuration then
          setTimeout(resolve, leaveDuration)
        else
          whenTransitionEnds(el, type, resolve)
        end
      end
    end
    )
    onLeave and onLeave(el, resolve)
  end
  , onEnterCancelled=function(el)
    finishEnter(el, false)
    onEnterCancelled and onEnterCancelled(el)
  end
  , onAppearCancelled=function(el)
    finishEnter(el, true)
    onAppearCancelled and onAppearCancelled(el)
  end
  , onLeaveCancelled=function(el)
    finishLeave(el)
    onLeaveCancelled and onLeaveCancelled(el)
  end
  })
end

function normalizeDuration(duration)
  if duration == nil then
    return nil
  elseif isObject(duration) then
    return {NumberOf(duration.enter), NumberOf(duration.leave)}
  else
    local n = NumberOf(duration)
    return {n, n}
  end
end

function NumberOf(val)
  local res = toNumber(val)
  if __DEV__ then
    validateDuration(res)
  end
  return res
end

function validateDuration(val)
  if type(val) ~= 'number' then
    warn( + )
  elseif isNaN(val) then
    warn( .. 'the duration expression might be incorrect.')
  end
end

function addTransitionClass(el, cls)
  cls:split('%s+'):forEach(function(c)
    c and el.classList:add(c)
  end
  )
  (el._vtc or (el._vtc = Set())):add(cls)
end

function removeTransitionClass(el, cls)
  cls:split('%s+'):forEach(function(c)
    c and el.classList:remove(c)
  end
  )
  local  = el
  if _vtc then
    _vtc:delete(cls)
    if not ().size then
      
      el._vtc = undefined
    end
  end
end

function nextFrame(cb)
  requestAnimationFrame(function()
    requestAnimationFrame(cb)
  end
  )
end

function whenTransitionEnds(el, expectedType, cb)
  local  = getTransitionInfo(el, expectedType)
  if not type then
    return cb()
  end
  local endEvent = type .. 'end'
  local ended = 0
  local tsvar_end = function()
    el:removeEventListener(endEvent, onEnd)
    cb()
  end
  
  local onEnd = function(e)
    if e.target == el then
      ended=ended+1
      if ended >= propCount then
        tsvar_end()
      end
    end
  end
  
  setTimeout(function()
    if ended < propCount then
      tsvar_end()
    end
  end
  , timeout + 1)
  el:addEventListener(endEvent, onEnd)
end

function getTransitionInfo(el, expectedType)
  local styles = window:getComputedStyle(el)
  local getStyleProperties = function(key)
    -- [ts2lua]styles下标访问可能不正确
    (styles[key] or ''):split(', ')
  end
  
  local transitionDelays = getStyleProperties(TRANSITION .. 'Delay')
  local transitionDurations = getStyleProperties(TRANSITION .. 'Duration')
  local transitionTimeout = getTimeout(transitionDelays, transitionDurations)
  local animationDelays = getStyleProperties(ANIMATION .. 'Delay')
  local animationDurations = getStyleProperties(ANIMATION .. 'Duration')
  local animationTimeout = getTimeout(animationDelays, animationDurations)
  local type = nil
  local timeout = 0
  local propCount = 0
  if expectedType == TRANSITION then
    if transitionTimeout > 0 then
      type = TRANSITION
      timeout = transitionTimeout
      
      propCount = transitionDurations.length
    end
  elseif expectedType == ANIMATION then
    if animationTimeout > 0 then
      type = ANIMATION
      timeout = animationTimeout
      
      propCount = animationDurations.length
    end
  else
    timeout = Math:max(transitionTimeout, animationTimeout)
    -- [ts2lua]lua中0和空字符串也是true，此处transitionTimeout > animationTimeout需要确认
    -- [ts2lua]lua中0和空字符串也是true，此处timeout > 0需要确认
    type = (timeout > 0 and {(transitionTimeout > animationTimeout and {TRANSITION} or {ANIMATION})[1]} or {nil})[1]
    -- [ts2lua]lua中0和空字符串也是true，此处type == TRANSITION需要确认
    -- [ts2lua]lua中0和空字符串也是true，此处type需要确认
    propCount = (type and {(type == TRANSITION and {#transitionDurations} or {#animationDurations})[1]} or {0})[1]
  end
  -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
  -- [ts2lua]styles下标访问可能不正确
  local hasTransform = type == TRANSITION and (/\b(transform|all)(,|$)/):test(styles[TRANSITION .. 'Property'])
  return {type=type, timeout=timeout, propCount=propCount, hasTransform=hasTransform}
end

function getTimeout(delays, durations)
  while(#delays < #durations)
  do
  delays = table.merge(delays, delays)
  end
  return Math:max(...)
end

function toMs(s)
  return Number(s:slice(0, -1):gsub(',', '.')) * 1000
end
