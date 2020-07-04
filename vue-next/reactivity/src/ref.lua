require("reactivity/src/effect")
require("reactivity/src/operations/TrackOpTypes")
require("reactivity/src/operations/TriggerOpTypes")
require("@vue/shared")
require("reactivity/src/reactive")

local RefSymbol = nil
local convert = function(val)
  -- [ts2lua]lua中0和空字符串也是true，此处isObject(val)需要确认
  (isObject(val) and {reactive(val)} or {val})[1]
end

-- [ts2lua]请手动处理DeclareFunction

function isRef(r)
  -- [ts2lua]lua中0和空字符串也是true，此处r需要确认
  return (r and {r.__v_isRef == true} or {false})[1]
end

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

function ref(value)
  return createRef(value)
end

-- [ts2lua]请手动处理DeclareFunction

-- [ts2lua]请手动处理DeclareFunction

function shallowRef(value)
  return createRef(value, true)
end

function createRef(rawValue, shallow)
  if shallow == nil then
    shallow=false
  end
  if isRef(rawValue) then
    return rawValue
  end
  -- [ts2lua]lua中0和空字符串也是true，此处shallow需要确认
  local value = (shallow and {rawValue} or {convert(rawValue)})[1]
  local r = {__v_isRef=true, value=function()
    track(r, TrackOpTypes.GET, 'value')
    return value
  end
  , value=function(newVal)
    if hasChanged(toRaw(newVal), rawValue) then
      rawValue = newVal
      -- [ts2lua]lua中0和空字符串也是true，此处shallow需要确认
      value = (shallow and {newVal} or {convert(newVal)})[1]
      -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
      trigger(r, TriggerOpTypes.SET, 'value', (__DEV__ and {{newValue=newVal}} or {undefined})[1])
    end
  end
  }
  return r
end

function triggerRef(ref)
  -- [ts2lua]lua中0和空字符串也是true，此处__DEV__需要确认
  trigger(ref, TriggerOpTypes.SET, 'value', (__DEV__ and {{newValue=ref.value}} or {undefined})[1])
end

function unref(ref)
  -- [ts2lua]lua中0和空字符串也是true，此处isRef(ref)需要确认
  return (isRef(ref) and {ref.value} or {ref})[1]
end

function customRef(factory)
  local  = factory(function()
    track(r, TrackOpTypes.GET, 'value')
  end
  , function()
    trigger(r, TriggerOpTypes.SET, 'value')
  end
  )
  local r = {__v_isRef=true, value=function()
    return get()
  end
  , value=function(v)
    set(v)
  end
  }
  return r
end

function toRefs(object)
  if __DEV__ and not isProxy(object) then
    console:warn()
  end
  local ret = {}
  for key in pairs(object) do
    -- [ts2lua]ret下标访问可能不正确
    ret[key] = toRef(object, key)
  end
  return ret
end

function toRef(object, key)
  return {__v_isRef=true, value=function()
    -- [ts2lua]object下标访问可能不正确
    return object[key]
  end
  , value=function(newVal)
    -- [ts2lua]object下标访问可能不正确
    object[key] = newVal
  end
  }
end
