require("stringutil")
require("runtime-dom/src/components/Transition")
require("@vue/runtime-core")
require("@vue/reactivity")
require("@vue/shared")

local positionMap = WeakMap()
local newPositionMap = WeakMap()
local TransitionGroupImpl = {name='TransitionGroup', props=extend({}, TransitionPropsValidators, {tag=String, moveClass=String}), setup=function(props, )
  local instance = nil
  local state = useTransitionState()
  local prevChildren = nil
  local children = nil
  onUpdated(function()
    if not #prevChildren then
      return
    end
    local moveClass = props.moveClass or 
    if not hasCSSTransform(prevChildren[0+1].el, instance.vnode.el, moveClass) then
      return
    end
    prevChildren:forEach(callPendingCbs)
    prevChildren:forEach(recordPosition)
    local movedChildren = prevChildren:filter(applyTranslation)
    forceReflow()
    movedChildren:forEach(function(c)
      local el = c.el
      local style = el.style
      addTransitionClass(el, moveClass)
      style.transitionDuration = ''
      style.webkitTransform = style.transitionDuration
      style.transform = style.webkitTransform
      el._moveCb = function(e)
        if e and e.target ~= el then
          return
        end
        -- [ts2lua]tslua无法自动转换正则表达式，请手动处理。
        if not e or (/transform$/):test(e.propertyName) then
          el:removeEventListener('transitionend', cb)
          el._moveCb = nil
          removeTransitionClass(el, moveClass)
        end
      end
      
      local cb = el._moveCb
      el:addEventListener('transitionend', cb)
    end
    )
  end
  )
  return function()
    local rawProps = toRaw(props)
    local cssTransitionProps = resolveTransitionProps(rawProps)
    local tag = rawProps.tag or Fragment
    prevChildren = children
    -- [ts2lua]lua中0和空字符串也是true，此处slots.default需要确认
    children = (slots.default and {getTransitionRawChildren(slots:default())} or {{}})[1]
    local i = 0
    repeat
      local child = children[i+1]
      if child.key ~= nil then
        setTransitionHooks(child, resolveTransitionHooks(child, cssTransitionProps, state, instance))
      elseif __DEV__ then
        warn()
      end
      i=i+1
    until not(i < #children)
    if prevChildren then
      local i = 0
      repeat
        local child = prevChildren[i+1]
        setTransitionHooks(child, resolveTransitionHooks(child, cssTransitionProps, state, instance))
        positionMap:set(child, child.el:getBoundingClientRect())
        i=i+1
      until not(i < #prevChildren)
    end
    return createVNode(tag, nil, children)
  end
  

end
}
TransitionGroupImpl.props.mode = nil
local TransitionGroup = TransitionGroupImpl
function callPendingCbs(c)
  local el = c.el
  if el._moveCb then
    el:_moveCb()
  end
  if el._enterCb then
    el:_enterCb()
  end
end

function recordPosition(c)
  newPositionMap:set(c, c.el:getBoundingClientRect())
end

function applyTranslation(c)
  local oldPos = nil
  local newPos = nil
  local dx = oldPos.left - newPos.left
  local dy = oldPos.top - newPos.top
  if dx or dy then
    local s = c.el.style
    s.webkitTransform = 
    s.transform = s.webkitTransform
    s.transitionDuration = '0s'
    return c
  end
end

function forceReflow()
  return document.body.offsetHeight
end

function hasCSSTransform(el, root, moveClass)
  local clone = el:cloneNode()
  if el._vtc then
    el._vtc:forEach(function(cls)
      cls:split('%s+'):forEach(function(c)
        c and clone.classList:remove(c)
      end
      )
    end
    )
  end
  moveClass:split('%s+'):forEach(function(c)
    c and clone.classList:add(c)
  end
  )
  clone.style.display = 'none'
  -- [ts2lua]lua中0和空字符串也是true，此处root.nodeType == 1需要确认
  local container = (root.nodeType == 1 and {root} or {root.parentNode})[1]
  container:appendChild(clone)
  local  = getTransitionInfo(clone)
  container:removeChild(clone)
  return hasTransform
end
