require("@vue/shared")
require("@vue/reactivity")
require("runtime-core/src/errorHandling")
require("runtime-core/src/errorHandling/ErrorCodes")

local stack = {}
function pushWarningContext(vnode)
  table.insert(stack, vnode)
end

function popWarningContext()
  stack:pop()
end

function warn(msg, ...)
  pauseTracking()
  -- [ts2lua]stack下标访问可能不正确
  -- [ts2lua]lua中0和空字符串也是true，此处#stack需要确认
  local instance = (#stack and {stack[#stack - 1].component} or {nil})[1]
  local appWarnHandler = instance and instance.appContext.config.warnHandler
  local trace = getComponentTrace()
  if appWarnHandler then
    callWithErrorHandling(appWarnHandler, instance, ErrorCodes.APP_WARN_HANDLER, {msg + args:join(''), instance and instance.proxy, trace:map(function()
      
    end
    ):join('\n'), trace})
  else
    local warnArgs = {...}
    if #trace and not __TEST__ then
      table.insert(warnArgs, ...)
    end
    console:warn(...)
  end
  resetTracking()
end

function getComponentTrace()
  -- [ts2lua]stack下标访问可能不正确
  local currentVNode = stack[#stack - 1]
  if not currentVNode then
    return {}
  end
  local normalizedStack = {}
  while(currentVNode)
  do
  local last = normalizedStack[0+1]
  if last and last.vnode == currentVNode then
    last.recurseCount=last.recurseCount+1
  else
    table.insert(normalizedStack, {vnode=currentVNode, recurseCount=0})
  end
  local parentInstance = currentVNode.component and currentVNode.component.parent
  currentVNode = parentInstance and parentInstance.vnode
  end
  return normalizedStack
end

function formatTrace(trace)
  local logs = {}
  trace:forEach(function(entry, i)
    table.insert(logs, ..., ...)
  end
  )
  return logs
end

function formatTraceEntry()
  -- [ts2lua]lua中0和空字符串也是true，此处recurseCount > 0需要确认
  local postfix = (recurseCount > 0 and {} or {})[1]
  -- [ts2lua]lua中0和空字符串也是true，此处vnode.component需要确认
  local isRoot = (vnode.component and {vnode.component.parent == nil} or {false})[1]
  local open = nil
  local close =  + postfix
  -- [ts2lua]lua中0和空字符串也是true，此处vnode.props需要确认
  return (vnode.props and {{open, ..., close}} or {{open + close}})[1]
end

function formatProps(props)
  local res = {}
  local keys = Object:keys(props)
  keys:slice(0, 3):forEach(function(key)
    table.insert(res, ...)
  end
  )
  if #keys > 3 then
    table.insert(res)
  end
  return res
end

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

function formatProp(key, value, raw)
  if isString(value) then
    value = JSON:stringify(value)
    -- [ts2lua]lua中0和空字符串也是true，此处raw需要确认
    return (raw and {value} or {{}})[1]
  elseif (type(value) == 'number' or type(value) == 'boolean') or value == nil then
    -- [ts2lua]lua中0和空字符串也是true，此处raw需要确认
    return (raw and {value} or {{}})[1]
  elseif isRef(value) then
    value = formatProp(key, toRaw(value.value), true)
    -- [ts2lua]lua中0和空字符串也是true，此处raw需要确认
    return (raw and {value} or {{value, }})[1]
  elseif isFunction(value) then
    return {}
  else
    value = toRaw(value)
    -- [ts2lua]lua中0和空字符串也是true，此处raw需要确认
    return (raw and {value} or {{value}})[1]
  end
end
